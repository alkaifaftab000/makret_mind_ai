import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/screens/auth/auth_landing_screen.dart';

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

  void _nextPage() {
    if (_currentIndex < AppStrings.onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
      );
    }
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      extendBodyBehindAppBar: true,
      body: Stack(
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

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.4, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 140, 
                    left: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          if (_currentIndex < AppStrings.onboardingItems.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 24,
              child: GestureDetector(
                onTap: _onSkip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(AppStrings.onboardingItems.length, (
                    idx,
                  ) {
                    bool isSelected = _currentIndex == idx;
                    return AnimatedContainer(
                      height: 4,
                      width: isSelected ? 24 : 12,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black
                            : Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }),
                ),

                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == AppStrings.onboardingItems.length - 1
                              ? 'Start'
                              : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}