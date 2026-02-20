import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';

class AboutModal extends StatelessWidget {
  const AboutModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About MarketMind',
              style: GoogleFonts.poppins(
                fontSize: 18,
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
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider, width: 0.6),
              ),
              child: Text(
                'MarketMind is a comprehensive digital marketing and content creation platform designed to empower brands and content creators. Our application leverages cutting-edge technology to streamline the production of high-quality visual content including short-form videos, promotional posters, and dynamic multimedia assets.',
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
            const SizedBox(height: 16),

            // Key Features
            Text(
              'Key Features',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            _buildFeatureItem(
              isDark,
              '• Brand Management - Manage multiple brands',
            ),
            const SizedBox(height: 6),
            _buildFeatureItem(
              isDark,
              '• Video Creation - Professional short & long form',
            ),
            const SizedBox(height: 6),
            _buildFeatureItem(
              isDark,
              '• Image Editing - Create stunning graphics',
            ),
            const SizedBox(height: 6),
            _buildFeatureItem(
              isDark,
              '• Advanced Controls - Fine-tune parameters',
            ),
            const SizedBox(height: 20),

            // Technology
            Text(
              'Technology Stack',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            _buildTechItem(isDark, 'Framework', 'Flutter & Dart'),
            const SizedBox(height: 6),
            _buildTechItem(isDark, 'Database', 'Hive (Local)'),
            const SizedBox(height: 6),
            _buildTechItem(isDark, 'Architecture', 'MVC Pattern'),
            const SizedBox(height: 20),

            // GitHub Link
            GestureDetector(
              onTap: () {
                AppNotification.info(
                  context,
                  message: 'GitHub: github.com/alkaifaftab000',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.buttonPrimary.withValues(alpha: 0.1),
                      AppColors.buttonSecondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.buttonPrimary,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.code_rounded,
                      color: AppColors.buttonPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View on GitHub',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'github.com/alkaifaftab000',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.buttonPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: AppColors.buttonPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Copyright
            Center(
              child: Text(
                '© 2026 MarketMind. All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(bool isDark, String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildTechItem(bool isDark, String label, String value) {
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
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.buttonPrimary,
          ),
        ),
      ],
    );
  }
}
