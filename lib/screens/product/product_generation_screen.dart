import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';

/// Legacy screen — placeholder for video generation flow.
/// Will be rewritten when video generation is implemented.
class ProductGenerationScreen extends StatelessWidget {
  final ProductModel product;
  final bool startWithFinal;
  final String? overrideFinalAsset;

  const ProductGenerationScreen({
    super.key,
    required this.product,
    this.startWithFinal = false,
    this.overrideFinalAsset,
  });

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
          'Video Generation',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textMutedLight,
            ),
            const SizedBox(height: 12),
            Text(
              'Video generation coming soon',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This feature is under development',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
