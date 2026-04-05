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
      // ─── Persistent Bottom Action Bar ─────────────
      bottomNavigationBar: (poster.isCompleted && poster.resultUrl != null)
          ? Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.share_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      onPressed: _sharePoster,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadPoster,
                      icon: _isDownloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                value: _downloadProgress > 0 ? _downloadProgress : null,
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
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
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
                    const SizedBox(height: 10),
                    // Image container
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: screenWidth * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: poster.resultUrl != null
                            ? Image.network(
                                poster.resultUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder: (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: screenWidth * 0.8,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: AppColors.buttonPrimary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: screenWidth * 0.8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        size: 48,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: screenWidth * 0.8,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 48),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Config Details ─────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Configuration Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(poster.status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _statusColor(poster.status).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  _statusText(poster.status),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(poster.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (poster.config != null) ...[
                            Row(
                              children: [
                                _buildMetricCard('Aspect Ratio', poster.config!.aspectRatio, Icons.crop_rounded, isDark),
                                const SizedBox(width: 12),
                                _buildMetricCard('Resolution', poster.config!.resolution, Icons.hd_rounded, isDark),
                                const SizedBox(width: 12),
                                _buildMetricCard('Format', poster.config!.outputFormat.toUpperCase(), Icons.image_rounded, isDark),
                              ],
                            ),
                            if (poster.config!.style != null || poster.config!.overlayText != null) ...[
                              const SizedBox(height: 20),
                              if (poster.config!.style != null)
                                _buildDetailField('Style', poster.config!.style!, Icons.brush_rounded, isDark),
                              if (poster.config!.style != null && poster.config!.overlayText != null)
                                const SizedBox(height: 12),
                              if (poster.config!.overlayText != null)
                                _buildDetailField('Overlay Text', poster.config!.overlayText!, Icons.text_fields_rounded, isDark),
                            ],
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1),
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              const SizedBox(width: 8),
                              Text(
                                'Created on ${_formatDate(poster.createdAt)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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

  Widget _buildMetricCard(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkBackground : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.buttonPrimary.withValues(alpha: 0.8)),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBackground : AppColors.lightBackground),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.buttonPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
