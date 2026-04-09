import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/picker_utils.dart';

class TemplateImageDetailScreen extends StatefulWidget {
  final String imagePath;
  final String templateCategory;
  final String title;

  const TemplateImageDetailScreen({
    super.key,
    required this.imagePath,
    required this.templateCategory,
    required this.title,
  });

  @override
  State<TemplateImageDetailScreen> createState() => _TemplateImageDetailScreenState();
}

class _TemplateImageDetailScreenState extends State<TemplateImageDetailScreen> with SingleTickerProviderStateMixin {
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

  void _onUseTemplate() {
    PickerUtils.showBrandPickerThenNavigate(
       context,
       'studio',
       templateName: widget.title,
       templateCategory: widget.templateCategory,
       initialPrompt: 'Generate a high-quality ${widget.title.toLowerCase()} similar to this template.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      bottomNavigationBar: Container(
         padding: EdgeInsets.fromLTRB(
           16,
           16,
           16,
           MediaQuery.of(context).padding.bottom + 16,
         ),
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
             // Share
             Container(
               decoration: BoxDecoration(
                 color: isDark ? AppColors.darkCard : AppColors.lightCard,
                 borderRadius: BorderRadius.circular(14),
                 border: Border.all(
                   color: AppColors.divider.withValues(alpha: 0.3),
                 ),
               ),
               child: IconButton(
                 icon: Icon(
                   Icons.share_rounded,
                   color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                 ),
                 onPressed: () => AppNotification.info(context, message: 'Share coming soon'),
               ),
             ),
             const SizedBox(width: 12),
             // Use Template
             Expanded(
               child: ElevatedButton.icon(
                 onPressed: _onUseTemplate,
                 icon: const Icon(Icons.auto_awesome_rounded),
                 label: Text(
                   'Use Template',
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
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 56,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkCard : AppColors.lightCard).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  widget.templateCategory,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Template Image Preview
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCardAlt,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                             blurRadius: 28,
                             spreadRadius: 2,
                             offset: const Offset(0, 10),
                           ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                             height: screenWidth * 0.8,
                             color: isDark ? AppColors.darkCard : AppColors.lightCardAlt,
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textMutedDark),
                                 const SizedBox(height: 8),
                                 Text('Image unavailable', style: GoogleFonts.poppins(color: AppColors.textMutedDark, fontSize: 13)),
                               ],
                             ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Config Card
                    _buildDetailsCard(isDark),
                    
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

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Template Overview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Featured',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricCard('Style', 'Modern', Icons.palette_rounded, isDark),
              const SizedBox(width: 10),
              _buildMetricCard('Quality', 'HD', Icons.high_quality_rounded, isDark),
              const SizedBox(width: 10),
              _buildMetricCard('Format', widget.imagePath.endsWith('.png') ? 'PNG' : 'JPEG', Icons.image_rounded, isDark),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: const Color(0xFF00B894),
              ),
              const SizedBox(width: 6),
              Text(
                'Free to use commercially',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.buttonPrimary.withValues(alpha: 0.8)),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
