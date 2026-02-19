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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentIndex < AppStrings.onboardingItems.length - 1) {
      _goToPage(_currentIndex + 1);
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _onSkip() {
    _goToPage(AppStrings.onboardingItems.length - 1);
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
        child: PageView.builder(
          controller: _pageController,
          itemCount: AppStrings.onboardingItems.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = AppStrings.onboardingItems[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: size.height * 0.70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.asset(item.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authTitle(
                      isDark,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authSubtitle(isDark),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onSkip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonSecondary,
                              foregroundColor: AppColors.buttonText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppStrings.onboardingSkip,
                              style: AppTextStyles.authButton,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: AppColors.buttonText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currentIndex ==
                                      AppStrings.onboardingItems.length - 1
                                  ? AppStrings.onboardingDone
                                  : AppStrings.onboardingNext,
                              style: AppTextStyles.authButton,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
