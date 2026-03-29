import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../utils/app_transitions.dart';
import 'home/home_screen.dart';
import 'templates/templates_screen.dart';
import 'ai_studio/ai_studio_screen.dart';
import 'search/search_screen.dart';
import 'profile/profile_screen.dart';

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
    AIStudioScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = const [
    'Home',
    'Templates',
    'Studio', // Shortened from AI Studio to fit better in pill
    'Search',
    'Profile',
  ];

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.layers_rounded,
    Icons.auto_awesome_rounded,
    Icons.search_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      extendBody: true, // This enables the bleed-under effect
      body: AnimatedTabSwitcher(
        key: ValueKey(_currentIndex),
        index: _currentIndex,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
          child: _FloatingNavBarContainer(
            isDark: isDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Space around avoids tight edges
              children: List.generate(
                _labels.length,
                (index) => _NavBarItem(
                  icon: _icons[index],
                  label: _labels[index],
                  isSelected: _currentIndex == index,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBarContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _FloatingNavBarContainer({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Fixed height for aesthetic balance
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35), // Rounded pill container
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              // Glass semi-transparent background
              color: isDark 
                  ? AppColors.darkCard.withValues(alpha: 0.65) 
                  : Colors.white.withValues(alpha: 0.75),
              // Subtle border for the rim light effect (glass reflex)
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.4),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If selected, we animate width to show background & text for Google-like pill nav
    // Combined with glowing box shadow beneath the icon to fulfill prompt constraints.
    return TappableScale(
      onTap: onTap,
      scaleDown: 0.90,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 6,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Subtle pill background when active
          color: isSelected
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.buttonPrimary.withValues(alpha: 0.05))
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon wrapper for glow highlight
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C6FF).withValues(alpha: 0.4), // Cyan glow
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    )
                  : const BoxDecoration(),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFF00C6FF) // Glow match color
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
            
            // Animated text label
            if (isSelected)
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
