import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: AppColors.buttonPrimary,
      onPrimary: AppColors.buttonText,
      surface: AppColors.lightBackground,
      onSurface: AppColors.textPrimaryLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.buttonText,
      onPrimary: AppColors.darkBackground,
      surface: AppColors.darkBackground,
      onSurface: AppColors.textPrimaryDark,
    ),
  );
}
