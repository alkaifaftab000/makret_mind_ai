import 'package:flutter/material.dart';

import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _nextPage() {
    if (_currentIndex < AppStrings.onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onSkip() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: AppStrings.onboardingItems.length,
              itemBuilder: (context, index) {
                final item = AppStrings.onboardingItems[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image - 70% of available height
                      SizedBox(
                        height: size.height * 0.70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Text(
                                    'Image not found',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authTitle(
                          context,
                          isDark,
                        ).copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authSubtitle(context, isDark),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Skip button at bottom left
            if (_currentIndex < AppStrings.onboardingItems.length - 1)
              Positioned(
                bottom: 28,
                left: 24,
                child: GestureDetector(
                  onTap: _onSkip,
                  child: Text(
                    AppStrings.onboardingSkip,
                    style: AppTextStyles.smallMuted(context, isDark).copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Page Indicators at bottom center
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppStrings.onboardingItems.length, (
                  idx,
                ) {
                  bool isSelected = _currentIndex == idx;
                  return GestureDetector(
                    onTap: () => _goToPage(idx),
                    child: AnimatedContainer(
                      height: 8,
                      width: isSelected ? 30 : 10,
                      margin: EdgeInsets.symmetric(
                        horizontal: isSelected ? 6 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonPrimary.withValues(alpha: 0.8)
                            : AppColors.buttonSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      duration: const Duration(milliseconds: 300),
                    ),
                  );
                }),
              ),
            ),

            // Get Started button at bottom (last page only)
            if (_currentIndex == AppStrings.onboardingItems.length - 1)
              Positioned(
                bottom: 20,
                right: 18,
                left: 18,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: AppTextStyles.authButton(context),
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
