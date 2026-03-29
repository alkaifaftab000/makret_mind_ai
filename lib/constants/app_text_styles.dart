import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle splashTitle(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 35;
    return GoogleFonts.poppins(
      color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade800,
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle splashAnimated(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 30;
    return GoogleFonts.luckiestGuy(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade800,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle splashTagline(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 15;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade50,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle footer(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 10;
    return GoogleFonts.poppins(
      color: isDark ? AppColors.textMutedDark : Colors.grey.shade500,
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle authTitle(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 20;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle authSubtitle(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 14;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w500,
      color: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
    );
  }

  static TextStyle authButton(BuildContext context) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 15;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle smallMuted(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 12;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      color: isDark ? AppColors.textMutedDark : const Color(0xFF666666),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle bodyMedium(BuildContext context, bool isDark) =>
      GoogleFonts.poppins(
        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4E4E4E),
        fontWeight: FontWeight.w500,
      );

  static TextStyle bodyStrong(BuildContext context, bool isDark) =>
      GoogleFonts.poppins(
        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1D1D1D),
        fontWeight: FontWeight.w600,
      );

  static TextStyle fieldText(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 14;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle fieldLabel(BuildContext context, bool isDark) =>
      GoogleFonts.poppins(
        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF6C6C6C),
        fontWeight: FontWeight.w500,
      );

  static TextStyle fieldHint(BuildContext context, bool isDark) =>
      GoogleFonts.poppins(
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        fontWeight: FontWeight.w500,
      );

  static TextStyle screenTitle(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 22;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle pageHeading(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 32;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle sectionTitle(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 18;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle titleMedium(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 20;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle bodySmall(BuildContext context, bool isDark) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 13;
    return GoogleFonts.poppins(
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      color: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
    );
  }

  static TextStyle buttonLabel(BuildContext context) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 14;
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
    );
  }

  static TextStyle cardTitleOnImage(BuildContext context) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 14;
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle cardSubtitleOnImage(BuildContext context) {
    double screenScale = MediaQuery.of(context).size.width / 375.0;
    double baseSize = 11;
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: MediaQuery.of(
        context,
      ).textScaler.scale(baseSize * screenScale.clamp(0.8, 1.5)),
      fontWeight: FontWeight.w500,
    );
  }
}
