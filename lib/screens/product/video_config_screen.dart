import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
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

  // Config state
  String _tone = 'professional';
  String _aspectRatio = 'mobile';
  String _duration = '10s';
  final _promptController = TextEditingController();

  static const _tones = ['professional', 'playful', 'emotional', 'dramatic'];

  static const Map<String, String> _toneLabels = {
    'professional': 'Professional',
    'playful': 'Playful',
    'emotional': 'Emotional',
    'dramatic': 'Dramatic',
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
  }

  @override
  void dispose() {
    _promptController.dispose();
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
      setState(() => _product = updatedProduct);
      widget.onJobCreated?.call();

      AppNotification.success(
        context,
        message: 'Video generation started',
      );
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to generate video. Please try again.',
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
          if (_product.hasVideos)
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

            // ─── Existing Videos ───────────────────────
            if (_product.hasVideos) ...[
              _SectionLabel('Generated Videos', isDark: isDark),
              const SizedBox(height: 10),
              ..._product.videos.reversed.map(
                (video) => _VideoResultCard(
                  video: video,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Config Section ────────────────────────
            _SectionLabel('Video Configuration', isDark: isDark),
            const SizedBox(height: 12),

            // Prompt (required)
            _ConfigLabel('Ad Prompt *', isDark: isDark),
            const SizedBox(height: 6),
            TextField(
              controller: _promptController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe the video you want to create...',
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

            // Tone
            _ConfigLabel('Tone', isDark: isDark),
            const SizedBox(height: 6),
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
                          _toneLabels[tone]!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
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

            // Aspect Ratio
            _ConfigLabel('Aspect Ratio', isDark: isDark),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _aspectRatios.entries.map((entry) {
                final isSelected = entry.key == _aspectRatio;
                return GestureDetector(
                  onTap: () => setState(() => _aspectRatio = entry.key),
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
                      entry.value,
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

            // Duration
            _ConfigLabel('Duration', isDark: isDark),
            const SizedBox(height: 6),
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
                          dur == '10s' ? '10 Seconds' : '15 Seconds',
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
            const SizedBox(height: 24),

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
                        'Generate Video',
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

// ─── Video result card ────────────────────────────────────────────
class _VideoResultCard extends StatelessWidget {
  final VideoJob video;
  final bool isDark;

  const _VideoResultCard({
    required this.video,
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
          // Scenes count
          if (video.scenes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                '${video.scenes.length} scenes generated',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.buttonPrimary,
                ),
              ),
            ),
          // Error message
          if (video.status == 'failed' && video.error != null)
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
                  video.error!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          // Processing indicator
          if (video.status == 'processing' || video.status == 'pending' || video.status == 'requires_approval')
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

    switch (video.status) {
      case 'completed':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'processing':
        icon = Icons.hourglass_top_rounded;
        color = Colors.orange;
        break;
      case 'requires_approval':
        icon = Icons.approval_rounded;
        color = Colors.blue;
        break;
      case 'failed':
        icon = Icons.error_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.schedule_rounded;
        color = Colors.grey;
    }

    return Icon(icon, size: 22, color: color);
  }

  String _statusLabel() {
    switch (video.status) {
      case 'completed':
        return 'Video Ready';
      case 'processing':
        return 'Generating...';
      case 'requires_approval':
        return 'Awaiting Approval';
      case 'failed':
        return 'Generation Failed';
      default:
        return 'Queued';
    }
  }

  String _formatConfig() {
    final parts = <String>[];
    if (video.config != null) {
      parts.add(video.config!.tone);
      parts.add(video.config!.aspectRatio);
      parts.add(video.config!.duration);
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
