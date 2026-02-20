import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';

class AboutUsTab extends StatelessWidget {
  const AboutUsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo / Icon
            Container(
              width: screenSize.width * 0.25,
              height: screenSize.width * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.buttonPrimary, AppColors.buttonSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonPrimary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.video_camera_front_rounded,
                size: screenSize.width * 0.12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // App Name and Version
            Text(
              'MarketMind',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Tagline
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.6),
              ),
              child: Text(
                'Intelligent Content Creation for Brand Growth',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // About Description
            Text(
              'About MarketMind',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.6),
              ),
              child: Text(
                'MarketMind is a comprehensive digital marketing and content creation platform designed to empower brands and content creators. Our application leverages cutting-edge technology to streamline the production of high-quality visual content including short-form videos, promotional posters, and dynamic multimedia assets. '
                '\n\n'
                'With an intuitive interface and powerful editing capabilities, MarketMind enables users to manage multiple brand personas, create consistent visual identities, and generate compelling marketing materials efficiently. Our platform is built to accelerate content production workflows while maintaining exceptional quality standards.'
                '\n\n'
                'Whether you are a solo entrepreneur, marketing agency, or large-scale content producer, MarketMind provides the tools necessary to elevate your brand presence and engage your target audience effectively.',
                textAlign: TextAlign.justify,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.6,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Features
            Text(
              'Key Features',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              isDark,
              Icons.layers_rounded,
              'Brand Management',
              'Manage multiple brands and their unique identities',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              isDark,
              Icons.video_library_rounded,
              'Video Creation',
              'Generate professional short-form and long-form videos',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              isDark,
              Icons.image_rounded,
              'Image Editing',
              'Create stunning promotional posters and graphics',
            ),
            const SizedBox(height: 8),
            _buildFeatureTile(
              isDark,
              Icons.settings_rounded,
              'Advanced Controls',
              'Fine-tune audio, aspect ratios, and content parameters',
            ),
            const SizedBox(height: 28),

            // Development Info
            Text(
              'Development',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Framework:', 'Flutter & Dart', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow('Platform:', 'iOS, Android, Web', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow('Storage:', 'Local Database (Hive)', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Architecture:',
                    'MVC with Service Layer',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GitHub Link
            _buildActionButton(
              isDark,
              icon: Icons.code_rounded,
              label: 'View on GitHub',
              subtitle: 'github.com/alkaifaftab000',
              onTap: () {
                AppNotification.info(
                  context,
                  message: 'GitHub: github.com/alkaifaftab000',
                );
              },
            ),
            const SizedBox(height: 24),

            // Footer
            Text(
              '© 2026 MarketMind. All rights reserved.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AppNotification.info(context, message: 'Privacy Policy');
                  },
                  child: Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.buttonPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(' • ', style: GoogleFonts.poppins(fontSize: 10)),
                GestureDetector(
                  onTap: () {
                    AppNotification.info(context, message: 'Terms of Service');
                  },
                  child: Text(
                    'Terms of Service',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.buttonPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    bool isDark,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.buttonPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.buttonPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
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
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      children: [
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
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    bool isDark, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.buttonPrimary.withValues(alpha: 0.1),
              AppColors.buttonSecondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.buttonPrimary, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.buttonPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.buttonPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: AppColors.buttonPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
