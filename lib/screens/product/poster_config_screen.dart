import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/poster_detail_screen.dart';
import 'package:market_mind/services/cloudinary_service.dart';
import 'package:market_mind/services/kie_ai_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class PosterConfigScreen extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onJobCreated;

  const PosterConfigScreen({
    super.key,
    required this.product,
    this.onJobCreated,
  });

  @override
  State<PosterConfigScreen> createState() => _PosterConfigScreenState();
}

class _PosterConfigScreenState extends State<PosterConfigScreen> {
  late ProductModel _product;
  bool _isGenerating = false;
  final Logger _logger = Logger(printer: PrettyPrinter());

  // Active Kie AI polls (taskId → completer)
  final Map<String, Completer<void>> _activePolls = {};

  // Config state
  String _aspectRatio = 'auto';
  String _resolution = '1K';
  String _outputFormat = 'png';
  final _styleController = TextEditingController();
  final _overlayTextController = TextEditingController();

  static const _aspectRatios = [
    'auto', '1:1', '4:3', '3:4', '4:5', '5:4',
    '9:16', '16:9', '2:3', '3:2', '21:9',
  ];

  static const _resolutions = ['1K', '2K', '4K'];
  static const _outputFormats = ['png', 'jpg', 'jpeg'];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    // Start polling any existing active jobs via Kie AI
    _pollExistingActiveJobs();
  }

  @override
  void dispose() {
    // Cancel all active polls
    for (final completer in _activePolls.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _activePolls.clear();
    _styleController.dispose();
    _overlayTextController.dispose();
    super.dispose();
  }

  // ─── Kie AI Direct Polling ──────────────────────────────────────

  /// Poll any existing processing/pending jobs that have a taskId
  void _pollExistingActiveJobs() {
    for (final poster in _product.posters) {
      if ((poster.status == 'processing' || poster.status == 'pending') &&
          poster.taskId != null &&
          poster.taskId!.isNotEmpty) {
        _pollKieAiForPoster(poster.id, poster.taskId!);
      }
    }
  }

  /// Start polling Kie AI directly for a specific poster job's taskId
  Future<void> _pollKieAiForPoster(String posterId, String taskId) async {
    if (_activePolls.containsKey(taskId)) return; // Already polling

    final completer = Completer<void>();
    _activePolls[taskId] = completer;

    _logger.i('Starting Kie AI direct poll for task: $taskId (poster: $posterId)');

    try {
      final result = await kieAiService.pollUntilComplete(
        taskId,
        pollInterval: const Duration(seconds: 5),
        timeout: const Duration(minutes: 10),
        onProgress: (progress) {
          if (!mounted || completer.isCompleted) return;
          _logger.i('Kie AI task $taskId progress: ${progress.status} '
              '${progress.progress != null ? "${(progress.progress! * 100).toInt()}%" : ""}');
        },
      );

      if (!mounted) return;

      if (result.isCompleted) {
        _logger.i('Kie AI task completed! Output: ${result.outputUrl}');
        _logger.i('Result URLs: ${result.resultUrls}');

        String? permanentUrl;

        if (result.outputUrl != null) {
          // Step 1: Get downloadable URL from Kie AI (temp, 20 min expiry)
          String downloadableUrl = result.outputUrl!;
          final tempDownloadUrl = await kieAiService.getDownloadUrl(result.outputUrl!);
          if (tempDownloadUrl != null) {
            downloadableUrl = tempDownloadUrl;
          }
          _logger.i('Step 1 done: Got downloadable URL');

          // Step 2: Upload to Cloudinary for permanent storage
          _logger.i('Step 2: Uploading to Cloudinary...');
          permanentUrl = await cloudinaryService.uploadImageFromUrl(
            downloadableUrl,
            folder: 'posters',
          );
          _logger.i('Step 2 done: Cloudinary URL = $permanentUrl');
        }

        // Step 3: Update local UI immediately
        _updatePosterResult(posterId, permanentUrl ?? '');

        // Step 4: Save the permanent URL to backend DB
        if (permanentUrl != null && permanentUrl.isNotEmpty) {
          try {
            _logger.i('Step 3: Saving poster result to backend...');
            await productService.updatePosterResult(
              productId: _product.id,
              posterId: posterId,
              status: 'completed',
              resultUrl: permanentUrl,
            );
            _logger.i('Step 3 done: Poster saved to backend DB ✅');
          } catch (e) {
            _logger.e('Failed to save poster to backend (image is still on Cloudinary): $e');
          }
        }

        if (mounted) {
          AppNotification.success(
            context,
            message: 'Poster generated successfully! 🎨',
          );
        }
      } else if (result.isFailed) {
        _logger.e('Kie AI task failed: ${result.error}');
        _updatePosterFailed(posterId, result.error ?? 'Generation failed');

        if (mounted) {
          AppNotification.error(
            context,
            message: 'Poster generation failed: ${result.error ?? "Unknown error"}',
          );
        }
      }
    } catch (e) {
      _logger.e('Error polling Kie AI: $e');
    } finally {
      _activePolls.remove(taskId);
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// Update local poster status to completed with result URL
  void _updatePosterResult(String posterId, String resultUrl) {
    if (!mounted) return;
    setState(() {
      final updatedPosters = _product.posters.map((p) {
        if (p.id == posterId) {
          return PosterJob(
            id: p.id,
            status: 'completed',
            config: p.config,
            taskId: p.taskId,
            resultUrl: resultUrl,
            createdAt: p.createdAt,
          );
        }
        return p;
      }).toList();
      _product = _product.copyWith(posters: updatedPosters);
    });
  }

  /// Update local poster status to failed
  void _updatePosterFailed(String posterId, String error) {
    if (!mounted) return;
    setState(() {
      final updatedPosters = _product.posters.map((p) {
        if (p.id == posterId) {
          return PosterJob(
            id: p.id,
            status: 'failed',
            config: p.config,
            taskId: p.taskId,
            createdAt: p.createdAt,
            error: error,
          );
        }
        return p;
      }).toList();
      _product = _product.copyWith(posters: updatedPosters);
    });
  }

  Future<void> _refreshProduct({bool silent = false}) async {
    try {
      final updated = await productService.getProductById(_product.id);
      if (updated != null && mounted) {
        setState(() => _product = updated);
      }
    } catch (_) {}
  }

  Future<void> _generatePoster() async {
    setState(() => _isGenerating = true);

    try {
      final config = PosterConfig(
        aspectRatio: _aspectRatio,
        resolution: _resolution,
        outputFormat: _outputFormat,
        style: _styleController.text.trim().isNotEmpty
            ? _styleController.text.trim()
            : null,
        overlayText: _overlayTextController.text.trim().isNotEmpty
            ? _overlayTextController.text.trim()
            : null,
      );

      final updatedProduct = await productService.createPosterJob(
        productId: _product.id,
        config: config,
      );

      if (!mounted) return;
      setState(() => _product = updatedProduct);
      widget.onJobCreated?.call();

      AppNotification.success(
        context,
        message: 'Poster generation started',
      );

      // Find the newly created poster job and poll Kie AI directly
      final newPoster = updatedProduct.posters.lastOrNull;
      if (newPoster != null && newPoster.taskId != null && newPoster.taskId!.isNotEmpty) {
        _logger.i('New poster job created with taskId: ${newPoster.taskId}');
        _pollKieAiForPoster(newPoster.id, newPoster.taskId!);
      } else {
        _logger.w('Poster job created but no taskId found. '
            'Poster IDs: ${updatedProduct.posters.map((p) => "${p.id}:${p.taskId}").join(", ")}');
        // Fall back to backend polling
        _startBackendPolling();
      }
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to generate poster. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  /// Fallback: poll backend if no taskId is available
  void _startBackendPolling() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _refreshProduct(silent: true);

      // Check if any poster now has a taskId we can poll
      for (final poster in _product.posters) {
        if ((poster.status == 'processing' || poster.status == 'pending') &&
            poster.taskId != null &&
            poster.taskId!.isNotEmpty &&
            !_activePolls.containsKey(poster.taskId)) {
          _pollKieAiForPoster(poster.id, poster.taskId!);
          timer.cancel();
          return;
        }
      }

      // Stop if no active jobs
      if (!_product.posters.any((p) => p.status == 'processing' || p.status == 'pending')) {
        timer.cancel();
      }
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  List<PosterJob> get _completedPosters =>
      _product.posters.where((p) => p.isCompleted).toList().reversed.toList();

  List<PosterJob> get _activePosters =>
      _product.posters.where((p) => p.isProcessing || p.isPending).toList();

  List<PosterJob> get _failedPosters =>
      _product.posters.where((p) => p.isFailed).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        title: Text(
          _product.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _refreshProduct(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Product Images Preview ─────────────
            _ProductImagesPreview(
              images: _product.images,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // ─── Active / Processing Jobs ───────────
            if (_activePosters.isNotEmpty) ...[
              _SectionLabel('Generating...', isDark: isDark),
              const SizedBox(height: 10),
              ..._activePosters.map((poster) => _ProcessingCard(
                    poster: poster,
                    isDark: isDark,
                  )),
              const SizedBox(height: 20),
            ],

            // ─── Completed Posters Grid ─────────────
            if (_completedPosters.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel('Generated Posters', isDark: isDark),
                  Text(
                    '${_completedPosters.length} poster${_completedPosters.length > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _completedPosters.length,
                itemBuilder: (context, index) {
                  final poster = _completedPosters[index];
                  return _PosterGridItem(
                    poster: poster,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PosterDetailScreen(
                            poster: poster,
                            productName: _product.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // ─── Failed Jobs ────────────────────────
            if (_failedPosters.isNotEmpty) ...[
              _SectionLabel('Failed', isDark: isDark),
              const SizedBox(height: 8),
              ..._failedPosters.map((poster) => _FailedCard(
                    poster: poster,
                    isDark: isDark,
                  )),
              const SizedBox(height: 20),
            ],

            // ─── Config Section ─────────────────────
            if (_activePosters.isEmpty && _completedPosters.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Poster',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Aspect Ratio
                  _ConfigLabel('Aspect Ratio', isDark: isDark),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _aspectRatios.map((ratio) {
                      final isSelected = ratio == _aspectRatio;
                      return GestureDetector(
                        onTap: () => setState(() => _aspectRatio = ratio),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.buttonPrimary
                                : (isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.divider
                                        .withValues(alpha: 0.5),
                                  ),
                          ),
                          child: Text(
                            ratio,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.buttonText
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Resolution
                  _ConfigLabel('Resolution', isDark: isDark),
                  const SizedBox(height: 6),
                  Row(
                    children: _resolutions.map((res) {
                      final isSelected = res == _resolution;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: res != _resolutions.last ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _resolution = res),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.buttonPrimary
                                    : (isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppColors.divider
                                            .withValues(alpha: 0.5),
                                      ),
                              ),
                              child: Text(
                                res,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.buttonText
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Output Format
                  _ConfigLabel('Output Format', isDark: isDark),
                  const SizedBox(height: 6),
                  Row(
                    children: _outputFormats.map((fmt) {
                      final isSelected = fmt == _outputFormat;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: fmt != _outputFormats.last ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _outputFormat = fmt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.buttonPrimary
                                    : (isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppColors.divider
                                            .withValues(alpha: 0.5),
                                      ),
                              ),
                              child: Text(
                                fmt.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.buttonText
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Style
                  _ConfigLabel('Style (optional)', isDark: isDark),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _styleController,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'e.g., minimalist, luxury, vibrant, cinematic',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Overlay Text
                  _ConfigLabel('Overlay Text (optional)', isDark: isDark),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _overlayTextController,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., "50% OFF", "New Arrival"',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generatePoster,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor:
                            AppColors.buttonPrimary.withValues(alpha: 0.5),
                      ),
                      child: _isGenerating
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.buttonText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Generating...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Generate Poster',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Processing Card ──────────────────────────────────────────────
class _ProcessingCard extends StatelessWidget {
  final PosterJob poster;
  final bool isDark;

  const _ProcessingCard({required this.poster, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDAA5E).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAA5E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFDAA5E)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poster.status == 'pending'
                          ? 'Queued for generation'
                          : 'Generating poster...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'This may take a minute',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.divider.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFFFDAA5E)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Poster Grid Item ─────────────────────────────────────────────
class _PosterGridItem extends StatelessWidget {
  final PosterJob poster;
  final bool isDark;
  final VoidCallback onTap;

  const _PosterGridItem({
    required this.poster,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: poster.resultUrl != null
                    ? Image.network(
                        poster.resultUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark
                              ? AppColors.darkCardAlt
                              : AppColors.lightCardAlt,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? AppColors.darkCardAlt
                            : AppColors.lightCardAlt,
                        child: const Center(
                          child: Icon(Icons.image_rounded, size: 32),
                        ),
                      ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B894),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      poster.config?.aspectRatio ?? 'auto',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Failed Card ──────────────────────────────────────────────────
class _FailedCard extends StatelessWidget {
  final PosterJob poster;
  final bool isDark;

  const _FailedCard({required this.poster, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 20, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              poster.error ?? 'Generation failed',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Images Preview ───────────────────────────────────────
class _ProductImagesPreview extends StatelessWidget {
  final List<String> images;
  final bool isDark;

  const _ProductImagesPreview({required this.images, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final img = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: img.startsWith('http')
                ? Image.network(
                    img,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: isDark
                          ? AppColors.darkCardAlt
                          : AppColors.lightCardAlt,
                      child: const Icon(Icons.broken_image_rounded, size: 20),
                    ),
                  )
                : Container(
                    width: 90,
                    height: 90,
                    color: isDark
                        ? AppColors.darkCardAlt
                        : AppColors.lightCardAlt,
                    child: const Icon(Icons.image_rounded, size: 20),
                  ),
          );
        },
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _ConfigLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _ConfigLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }
}
