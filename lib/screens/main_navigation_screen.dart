import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/screens/home/home_screen.dart';
import 'package:market_mind/screens/templates/templates_screen.dart';
import 'package:market_mind/screens/search/search_screen.dart';
import 'package:market_mind/screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TemplatesScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = const ['Home', 'Templates', 'Search', 'Profile'];
  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.layers_rounded,
    Icons.search_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
        ),
        child: BottomNavigationBar(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.buttonPrimary,
          unselectedItemColor: isDark
              ? AppColors.textMutedDark
              : AppColors.textMutedLight,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: List.generate(
            _labels.length,
            (index) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(_icons[index], size: 24),
              ),
              label: _labels[index],
            ),
          ),
        ),
      ),
    );
  }
}
