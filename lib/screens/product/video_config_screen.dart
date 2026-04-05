import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/video_detail_screen.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class VideoConfigScreen extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onJobCreated;

  const VideoConfigScreen({
    super.key,
    required this.product,
    this.onJobCreated,
  });

  @override
  State<VideoConfigScreen> createState() => _VideoConfigScreenState();
}

class _VideoConfigScreenState extends State<VideoConfigScreen> {
  late ProductModel _product;
  bool _isGenerating = false;
  bool _isRefreshing = false;
  bool _isApproving = false;

  // Config state
  String _tone = 'professional';
  String _aspectRatio = 'mobile';
  String _duration = '10s';
  final _promptController = TextEditingController();

  // Scene editor: map from jobId → list of prompt controllers
  final Map<String, List<TextEditingController>> _sceneControllers = {};

  static const _tones = ['professional', 'playful', 'emotional', 'dramatic'];

  static const Map<String, String> _toneLabels = {
    'professional': 'Professional',
    'playful': 'Playful',
    'emotional': 'Emotional',
    'dramatic': 'Dramatic',
  };

  static const Map<String, String> _toneIcons = {
    'professional': '💼',
    'playful': '🎉',
    'emotional': '💖',
    'dramatic': '🎬',
  };

  static const Map<String, String> _aspectRatios = {
    'mobile': 'Mobile',
    'desktop': 'Desktop',
    'instagram_post': 'IG Post',
    'instagram_reel': 'IG Reel',
    'instagram_story': 'IG Story',
    'instagram_carousel': 'IG Carousel',
    'youtube_short': 'YT Short',
    'youtube_video': 'YT Video',
    'youtube_ad': 'YT Ad',
    'tiktok_video': 'TikTok',
    'linkedin_post': 'LinkedIn',
    'facebook_post': 'Facebook',
  };

  static const _durations = ['10s', '15s'];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _initSceneControllers();
  }

  void _initSceneControllers() {
    for (final video in _product.videos) {
      if (video.requiresApproval && _sceneControllers[video.id] == null) {
        _sceneControllers[video.id] = video.scenes
            .map((s) => TextEditingController(text: s.prompt))
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    for (final controllers in _sceneControllers.values) {
      for (final c in controllers) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _generateVideo() async {
    if (_promptController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Please enter a prompt');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final config = VideoConfig(
        tone: _tone,
        aspectRatio: _aspectRatio,
        duration: _duration,
        userPrompt: _promptController.text.trim(),
      );

      final updatedProduct = await productService.createVideoJob(
        productId: _product.id,
        config: config,
      );

      if (!mounted) return;
      setState(() {
        _product = updatedProduct;
        _initSceneControllers();
        _promptController.clear();
      });
      widget.onJobCreated?.call();

      AppNotification.success(
        context,
        message: 'Scenes generated! Review & approve below.',
      );
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to generate scenes. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _approveVideoJob(VideoJob video) async {
    final controllers = _sceneControllers[video.id];
    if (controllers == null) return;

    // Build edited scenes
    final editedScenes = List.generate(video.scenes.length, (i) {
      final s = video.scenes[i];
      return VideoScene(
        id: s.id,
        prompt: controllers[i].text.trim().isNotEmpty
            ? controllers[i].text.trim()
            : s.prompt,
        description: s.description,
        videoUrl: s.videoUrl,
        status: s.status,
        order: s.order,
        durationSeconds: s.durationSeconds,
      );
    });

    // Confirmation dialog — safety net to not burn credits accidentally
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Approve & Generate Video?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'This will start the actual video generation using Kling AI and consume your Kie credits. Are you sure?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Yes, Generate',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isApproving = true);
    try {
      final updatedProduct = await productService.approveVideoJob(
        productId: _product.id,
        jobId: video.id,
        approvedScenes: editedScenes,
      );
      if (!mounted) return;
      setState(() => _product = updatedProduct);
      AppNotification.success(
        context,
        message: 'Video generation started!',
      );
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to approve. Check your connection.',
      );
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  Future<void> _refreshProduct() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await productService.getProductById(_product.id);
      if (updated != null && mounted) {
        setState(() {
          _product = updated;
          _initSceneControllers();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingVideos = _product.videos
        .where((v) => v.isPending || v.isProcessing)
        .toList();
    final approvalVideos = _product.videos
        .where((v) => v.requiresApproval)
        .toList();
    final completedVideos = _product.videos
        .where((v) => v.isCompleted)
        .toList();
    final failedVideos = _product.videos
        .where((v) => v.isFailed)
        .toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : AppColors.lightCard)
                  .withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _product.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Video Studio',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          if (_product.hasVideos)
            IconButton(
              onPressed: _isRefreshing ? null : _refreshProduct,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ─── Product Images Preview ──────────────
            _ProductImagesPreview(images: _product.images, isDark: isDark),
            const SizedBox(height: 24),

            // ─── Completed Videos ───────────────────
            if (completedVideos.isNotEmpty) ...[
              _SectionLabel(
                '✅  Completed Videos',
                isDark: isDark,
                accent: const Color(0xFF00B894),
              ),
              const SizedBox(height: 10),
              ...completedVideos.reversed.map(
                (video) => _CompletedVideoCard(
                  video: video,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailScreen(
                          video: video,
                          productName: _product.name,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Requires Approval ──────────────────
            if (approvalVideos.isNotEmpty) ...[
              _SectionLabel(
                '✏️  Review Scenes',
                isDark: isDark,
                accent: const Color(0xFF6C63FF),
              ),
              const SizedBox(height: 6),
              Text(
                'AI generated prompts for each video clip. Edit them to refine the output before approving.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 12),
              ...approvalVideos.reversed.map(
                (video) => _SceneEditorCard(
                  video: video,
                  isDark: isDark,
                  controllers: _sceneControllers[video.id] ?? [],
                  isApproving: _isApproving,
                  onApprove: () => _approveVideoJob(video),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Processing / Pending ───────────────
            if (pendingVideos.isNotEmpty) ...[
              _SectionLabel(
                '⏳  In Progress',
                isDark: isDark,
                accent: const Color(0xFFFDAA5E),
              ),
              const SizedBox(height: 10),
              ...pendingVideos.reversed.map(
                (video) => _ProcessingVideoCard(video: video, isDark: isDark),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Failed ─────────────────────────────
            if (failedVideos.isNotEmpty) ...[
              _SectionLabel(
                '❌  Failed',
                isDark: isDark,
                accent: Colors.redAccent,
              ),
              const SizedBox(height: 10),
              ...failedVideos.reversed.map(
                (video) => _FailedVideoCard(video: video, isDark: isDark),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Config Section ──────────────────────
            if (approvalVideos.isEmpty && pendingVideos.isEmpty) ...[
              _SectionLabel('🎬  New Video', isDark: isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prompt
                    _ConfigLabel('Ad Prompt *', isDark: isDark),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe the video you want to create...',
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
                    const SizedBox(height: 16),

                    // Tone
                    _ConfigLabel('Tone', isDark: isDark),
                    const SizedBox(height: 8),
                    Row(
                      children: _tones.map((tone) {
                        final isSelected = tone == _tone;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: tone != _tones.last ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _tone = tone),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
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
                                              .withValues(alpha: 0.4),
                                        ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _toneIcons[tone]!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _toneLabels[tone]!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.buttonText
                                            : (isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Aspect Ratio
                    _ConfigLabel('Aspect Ratio', isDark: isDark),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _aspectRatios.entries.map((entry) {
                        final isSelected = entry.key == _aspectRatio;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _aspectRatio = entry.key),
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
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppColors.divider
                                          .withValues(alpha: 0.4),
                                    ),
                            ),
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
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
                    const SizedBox(height: 16),

                    // Duration
                    _ConfigLabel('Duration', isDark: isDark),
                    const SizedBox(height: 8),
                    Row(
                      children: _durations.map((dur) {
                        final isSelected = dur == _duration;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: dur != _durations.last ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _duration = dur),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.buttonPrimary
                                      : (isDark
                                          ? AppColors.darkBackground
                                          : AppColors.lightBackground),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: AppColors.divider
                                              .withValues(alpha: 0.4),
                                        ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_rounded,
                                      size: 16,
                                      color: isSelected
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      dur == '10s' ? '10 sec' : '15 sec',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.buttonText
                                            : (isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
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
                                    'Generating Scenes...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Generate Scenes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Scene Editor Card (requires_approval) ─────────────────────────
class _SceneEditorCard extends StatefulWidget {
  final VideoJob video;
  final bool isDark;
  final List<TextEditingController> controllers;
  final bool isApproving;
  final VoidCallback onApprove;

  const _SceneEditorCard({
    required this.video,
    required this.isDark,
    required this.controllers,
    required this.isApproving,
    required this.onApprove,
  });

  @override
  State<_SceneEditorCard> createState() => _SceneEditorCardState();
}

class _SceneEditorCardState extends State<_SceneEditorCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isDark ? const Color(0xFF8B87FF) : AppColors.buttonPrimary;
    final accentBg = widget.isDark
        ? const Color(0xFF8B87FF).withValues(alpha: 0.1)
        : AppColors.buttonPrimary.withValues(alpha: 0.06);
    final accentBorder = widget.isDark
        ? const Color(0xFF8B87FF).withValues(alpha: 0.25)
        : AppColors.buttonPrimary.withValues(alpha: 0.18);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 20,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review AI Scenes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${widget.video.scenes.length} clips  •  ${widget.video.config?.duration ?? '?'} total',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: widget.isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentBorder),
                  ),
                  child: Text(
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scenes list ───────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  children: List.generate(widget.video.scenes.length, (i) {
                    final scene = widget.video.scenes[i];
                    final controller =
                        i < widget.controllers.length ? widget.controllers[i] : null;
                    return _SceneEditorTile(
                      scene: scene,
                      index: i,
                      totalScenes: widget.video.scenes.length,
                      controller: controller,
                      isDark: widget.isDark,
                    );
                  }),
                ),
              ),
            ),
          ),

          // ── Config chips ──────────────────────────────
          if (widget.video.config != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _ConfigChip(
                    label: widget.video.config!.tone,
                    icon: Icons.record_voice_over_rounded,
                    isDark: widget.isDark,
                  ),
                  _ConfigChip(
                    label: widget.video.config!.aspectRatio,
                    icon: Icons.crop_rounded,
                    isDark: widget.isDark,
                  ),
                  _ConfigChip(
                    label: widget.video.config!.duration,
                    icon: Icons.timer_rounded,
                    isDark: widget.isDark,
                  ),
                ],
              ),
            ),

          // ── Approve button ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isApproving ? null : widget.onApprove,
                icon: widget.isApproving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.buttonText,
                        ),
                      )
                    : const Icon(Icons.rocket_launch_rounded, size: 18),
                label: Text(
                  widget.isApproving
                      ? 'Approving...'
                      : 'Approve & Generate Video',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneEditorTile extends StatelessWidget {
  final VideoScene scene;
  final int index;
  final int totalScenes;
  final TextEditingController? controller;
  final bool isDark;

  const _SceneEditorTile({
    required this.scene,
    required this.index,
    required this.totalScenes,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = index == totalScenes - 1;
    // Consistent accent color for the clip badge in both themes
    final clipBadgeColor = isDark
        ? const Color(0xFF8B87FF).withValues(alpha: 0.18)
        : AppColors.buttonPrimary.withValues(alpha: 0.08);
    final clipBadgeTextColor = isDark
        ? const Color(0xFFB3B0FF)
        : AppColors.buttonPrimary;
    final fieldFill = isDark ? AppColors.darkBackground : AppColors.lightCardAlt;
    final fieldBorder = AppColors.divider.withValues(alpha: isDark ? 0.18 : 0.28);
    final fieldFocusBorder = isDark
        ? const Color(0xFF8B87FF).withValues(alpha: 0.55)
        : AppColors.buttonPrimary.withValues(alpha: 0.45);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fieldFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: isDark ? 0.08 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Scene header row ───────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clip badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: clipBadgeColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: clipBadgeTextColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  'Clip ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: clipBadgeTextColor,
                  ),
                ),
              ),
              // Duration badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  '${scene.durationSeconds}s',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ── Scene Description ────────────────────────
          Text(
            scene.description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // ── Editable prompt ─────────────────────────
          if (controller != null)
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 5,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Edit the AI prompt for this clip...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: fieldFocusBorder,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Completed Video Card ──────────────────────────────────────────
class _CompletedVideoCard extends StatelessWidget {
  final VideoJob video;
  final bool isDark;
  final VoidCallback onTap;

  const _CompletedVideoCard({
    required this.video,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00B894).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Ready',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${video.scenes.length} clips • ${video.config?.aspectRatio ?? ''} • ${video.config?.duration ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Processing Video Card ─────────────────────────────────────────
class _ProcessingVideoCard extends StatelessWidget {
  final VideoJob video;
  final bool isDark;

  const _ProcessingVideoCard({required this.video, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDAA5E).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAA5E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFFDAA5E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generating Video...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Kling AI is rendering your clips',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
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
          LinearProgressIndicator(
            backgroundColor: AppColors.divider.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFDAA5E)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ─── Failed Video Card ─────────────────────────────────────────────
class _FailedVideoCard extends StatelessWidget {
  final VideoJob video;
  final bool isDark;

  const _FailedVideoCard({required this.video, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generation Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (video.error != null)
                  Text(
                    video.error!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.redAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Config Chip ───────────────────────────────────────────────────
class _ConfigChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _ConfigChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.buttonPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product images preview ────────────────────────────────────────
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
            borderRadius: BorderRadius.circular(12),
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
                      child: const Icon(Icons.broken_image_rounded, size: 24),
                    ),
                  )
                : Container(
                    width: 90,
                    height: 90,
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

// ─── Helpers ───────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color? accent;

  const _SectionLabel(this.text, {required this.isDark, this.accent});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: accent ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
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
