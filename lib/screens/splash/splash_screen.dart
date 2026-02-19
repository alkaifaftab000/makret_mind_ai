import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                'Market Mind AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade800,
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * .38,
            left: 0,
            right: 0,
            child: Center(
              child: DefaultTextStyle(
                style: GoogleFonts.luckiestGuy(
                  fontSize: 70.0,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(seconds: 1),
                  animatedTexts: [
                    ScaleAnimatedText('Upload'),
                    ScaleAnimatedText('Prompt'),
                    ScaleAnimatedText('Generate'),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.grey.shade800,
                      Colors.grey.shade600,
                    ],
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
                          'From prompts to videos, instantly.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20.0,
                            color: Colors.grey.shade50,
                            fontWeight: FontWeight.bold,
                          ),
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
                '@2026 Market Mind · v0.1',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
