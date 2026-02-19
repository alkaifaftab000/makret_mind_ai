import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: const Center(child: Text('Search Screen')),
    );
  }
}
