import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.fieldText(isDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.fieldHint(isDark),
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
