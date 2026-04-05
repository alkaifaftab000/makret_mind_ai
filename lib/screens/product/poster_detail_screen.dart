import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:path_provider/path_provider.dart';

class PosterDetailScreen extends StatefulWidget {
  final PosterJob poster;
  final String productName;

  const PosterDetailScreen({
    super.key,
    required this.poster,
    required this.productName,
  });

  @override
  State<PosterDetailScreen> createState() => _PosterDetailScreenState();
}

class _PosterDetailScreenState extends State<PosterDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _downloadPoster() async {
    if (widget.poster.resultUrl == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'poster_${widget.poster.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.${widget.poster.config?.outputFormat ?? "png"}';
      final filePath = '${dir.path}/$fileName';

      await Dio().download(
        widget.poster.resultUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      AppNotification.success(
        context,
        message: 'Poster saved to $fileName',
      );
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to download poster',
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _sharePoster() async {
    // Placeholder for share functionality
    if (!mounted) return;
    AppNotification.info(context, message: 'Share coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poster = widget.poster;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ─── Custom App Bar ─────────────────────
          SliverAppBar(
            expandedHeight: 56,
            floating: true,
            pinned: true,
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
            title: Text(
              widget.productName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            actions: [
              if (poster.isCompleted && poster.resultUrl != null)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkCard : AppColors.lightCard)
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  onPressed: _sharePoster,
                ),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Poster Image ───────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image container
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: screenWidth * 0.8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.4 : 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: poster.resultUrl != null
                            ? Image.network(
                                poster.resultUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder: (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: screenWidth * 0.8,
                                    color: isDark
                                        ? AppColors.darkCard
                                        : AppColors.lightCard,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: AppColors.buttonPrimary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: screenWidth * 0.8,
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        size: 48,
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: screenWidth * 0.8,
                                color: isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 48),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Config Details ─────────────────
                    _InfoCard(
                      isDark: isDark,
                      children: [
                        _InfoRow(
                          label: 'Status',
                          value: _statusText(poster.status),
                          valueColor: _statusColor(poster.status),
                          isDark: isDark,
                        ),
                        if (poster.config != null) ...[
                          const Divider(height: 20),
                          _InfoRow(
                            label: 'Aspect Ratio',
                            value: poster.config!.aspectRatio,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            label: 'Resolution',
                            value: poster.config!.resolution,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            label: 'Format',
                            value: poster.config!.outputFormat.toUpperCase(),
                            isDark: isDark,
                          ),
                          if (poster.config!.style != null) ...[
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Style',
                              value: poster.config!.style!,
                              isDark: isDark,
                            ),
                          ],
                          if (poster.config!.overlayText != null) ...[
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Overlay',
                              value: poster.config!.overlayText!,
                              isDark: isDark,
                            ),
                          ],
                        ],
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Created',
                          value: _formatDate(poster.createdAt),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── Download Button ────────────────
                    if (poster.isCompleted && poster.resultUrl != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _downloadPoster,
                          icon: _isDownloading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    value: _downloadProgress > 0
                                        ? _downloadProgress
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.buttonText,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(
                            _isDownloading
                                ? 'Downloading ${(_downloadProgress * 100).toInt()}%'
                                : 'Download Poster',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      default:
        return 'Queued';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF00B894);
      case 'processing':
        return const Color(0xFFFDAA5E);
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${h == 0 ? 12 : h}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }
}

// ─── Info Card ────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ??
                  (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ],
    );
  }
}
