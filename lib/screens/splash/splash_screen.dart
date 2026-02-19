import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/screens/splash/splash_service.dart';
import 'package:market_mind/screens/onboarding/onboarding_screen.dart';
import 'package:market_mind/widgets/custom_curve.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashService _splashService = SplashService();

  @override
  void initState() {
    super.initState();
    _startSplashHold();
  }

  Future<void> _startSplashHold() async {
    await _splashService.holdSplash();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned(
            top: screenSize.height * .05,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/video/splash.gif',
                width: screenSize.width * .86,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * .26,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: AppTextStyles.splashTitle(isDark),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * .38,
            left: 0,
            right: 0,
            child: Center(
              child: DefaultTextStyle(
                style: AppTextStyles.splashAnimated(isDark),
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(seconds: 1),
                  animatedTexts: [
                    ScaleAnimatedText(AppStrings.splashWordUpload),
                    ScaleAnimatedText(AppStrings.splashWordPrompt),
                    ScaleAnimatedText(AppStrings.splashWordGenerate),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipPath(
              clipper: SCurveClipper(),
              child: Container(
                height: screenSize.height * .3,
                width: screenSize.width,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.splashCurveGradient,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenSize.height * .1),
                      LoadingAnimationWidget.progressiveDots(
                        color: const Color(0xFFE0E0E0),
                        size: 60,
                      ),
                      Center(
                        child: Text(
                          AppStrings.splashTagline,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.splashTagline(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppStrings.footer,
                textAlign: TextAlign.center,
                style: AppTextStyles.footer(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
