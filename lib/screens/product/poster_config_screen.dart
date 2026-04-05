import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
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
  bool _isRefreshing = false;

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
  }

  @override
  void dispose() {
    _styleController.dispose();
    _overlayTextController.dispose();
    super.dispose();
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

  Future<void> _refreshProduct() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await productService.getProductById(_product.id);
      if (updated != null && mounted) {
        setState(() => _product = updated);
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

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
          if (_product.hasPosters)
            IconButton(
              onPressed: _isRefreshing ? null : _refreshProduct,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Product Images Preview ────────────────
            _ProductImagesPreview(
              images: _product.images,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // ─── Existing Posters ──────────────────────
            if (_product.hasPosters) ...[
              _SectionLabel('Generated Posters', isDark: isDark),
              const SizedBox(height: 10),
              ..._product.posters.reversed.map(
                (poster) => _PosterResultCard(
                  poster: poster,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Config Section ────────────────────────
            _SectionLabel('Poster Configuration', isDark: isDark),
            const SizedBox(height: 12),

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
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.divider.withValues(alpha: 0.5),
                            ),
                    ),
                    child: Text(
                      ratio,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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
                                  ? AppColors.darkCard
                                  : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color:
                                      AppColors.divider.withValues(alpha: 0.5),
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
                                  ? AppColors.darkCard
                                  : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color:
                                      AppColors.divider.withValues(alpha: 0.5),
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
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g., minimalist, luxury, vibrant, cinematic',
                hintStyle: GoogleFonts.poppins(fontSize: 13),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
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
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g., "50% OFF", "New Arrival"',
                hintStyle: GoogleFonts.poppins(fontSize: 13),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
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
            const SizedBox(height: 24),

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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Product images preview ───────────────────────────────────────
class _ProductImagesPreview extends StatelessWidget {
  final List<String> images;
  final bool isDark;

  const _ProductImagesPreview({
    required this.images,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final img = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: img.startsWith('http')
                ? Image.network(
                    img,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: isDark
                          ? AppColors.darkCardAlt
                          : AppColors.lightCardAlt,
                      child: const Icon(Icons.broken_image_rounded),
                    ),
                  )
                : Container(
                    width: 110,
                    height: 110,
                    color: isDark
                        ? AppColors.darkCardAlt
                        : AppColors.lightCardAlt,
                    child: const Icon(Icons.image_rounded),
                  ),
          );
        },
      ),
    );
  }
}

// ─── Poster result card ───────────────────────────────────────────
class _PosterResultCard extends StatelessWidget {
  final PosterJob poster;
  final bool isDark;

  const _PosterResultCard({
    required this.poster,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Status header ────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        _formatConfig(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ─── Result image ─────────────
          if (poster.isCompleted && poster.resultUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              child: Image.network(
                poster.resultUrl!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: isDark
                      ? AppColors.darkCardAlt
                      : AppColors.lightCardAlt,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 40),
                  ),
                ),
              ),
            ),
          // ─── Error message ────────────
          if (poster.isFailed && poster.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  poster.error!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          // ─── Processing indicator ─────
          if (poster.isProcessing || poster.isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.divider.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(AppColors.buttonPrimary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    if (poster.isCompleted) {
      icon = Icons.check_circle_rounded;
      color = Colors.green;
    } else if (poster.isProcessing) {
      icon = Icons.hourglass_top_rounded;
      color = Colors.orange;
    } else if (poster.isFailed) {
      icon = Icons.error_rounded;
      color = Colors.red;
    } else {
      icon = Icons.schedule_rounded;
      color = Colors.grey;
    }

    return Icon(icon, size: 22, color: color);
  }

  String _statusLabel() {
    switch (poster.status) {
      case 'completed':
        return 'Poster Ready';
      case 'processing':
        return 'Generating...';
      case 'failed':
        return 'Generation Failed';
      default:
        return 'Queued';
    }
  }

  String _formatConfig() {
    final parts = <String>[];
    if (poster.config != null) {
      parts.add(poster.config!.aspectRatio);
      parts.add(poster.config!.resolution);
      parts.add(poster.config!.outputFormat.toUpperCase());
    }
    return parts.isEmpty ? 'Default config' : parts.join(' • ');
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
