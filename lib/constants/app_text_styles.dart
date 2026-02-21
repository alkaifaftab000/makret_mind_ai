import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle splashTitle(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade800,
    fontSize: 50,
    fontWeight: FontWeight.w900,
  );

  static TextStyle splashAnimated(bool isDark) => GoogleFonts.luckiestGuy(
    fontSize: 70,
    color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade800,
    fontWeight: FontWeight.bold,
  );

  static TextStyle splashTagline(bool isDark) => GoogleFonts.poppins(
    fontSize: 20,
    color: isDark ? AppColors.textPrimaryDark : Colors.grey.shade50,
    fontWeight: FontWeight.w300,
  );

  static TextStyle footer(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textMutedDark : Colors.grey.shade500,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle authTitle(bool isDark) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle authSubtitle(bool isDark) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle get authButton =>
      GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle smallMuted(bool isDark) => GoogleFonts.poppins(
    fontSize: 12,
    color: isDark ? AppColors.textMutedDark : const Color(0xFF666666),
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4E4E4E),
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyStrong(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1D1D1D),
    fontWeight: FontWeight.w700,
  );

  static TextStyle fieldText(bool isDark) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle fieldLabel(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF6C6C6C),
    fontWeight: FontWeight.w500,
  );

  static TextStyle fieldHint(bool isDark) => GoogleFonts.poppins(
    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
    fontWeight: FontWeight.w500,
  );

  static TextStyle screenTitle(bool isDark) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle pageHeading(bool isDark) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle sectionTitle(bool isDark) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle titleMedium(bool isDark) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.poppins(
    fontSize: 13,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle buttonLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle cardTitleOnImage = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static TextStyle cardSubtitleOnImage = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
