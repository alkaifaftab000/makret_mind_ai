import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      imagePath: 'assets/onboarding/1.png',
      title: 'Turn Ideas Into Cinematic Clips',
      description:
          'Upload visuals, add your prompt, and start creating in seconds.',
    ),
    _OnboardingItem(
      imagePath: 'assets/onboarding/2.png',
      title: 'Guide Every Scene Clearly',
      description:
          'Describe style, mood, and movement to shape the output video.',
    ),
    _OnboardingItem(
      imagePath: 'assets/onboarding/3.png',
      title: 'Pick The Right AI Model',
      description:
          'Select the model that best fits your concept and quality target.',
    ),
    _OnboardingItem(
      imagePath: 'assets/onboarding/4.png',
      title: 'Generate Faster, Iterate Better',
      description:
          'Submit once, preview quickly, and refine prompts with confidence.',
    ),
    _OnboardingItem(
      imagePath: 'assets/onboarding/5.png',
      title: 'Create Production-Ready Videos',
      description:
          'Go from rough concept to polished visual story with Market Mind AI.',
    ),
  ];

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
    if (_currentIndex < _items.length - 1) {
      _goToPage(_currentIndex + 1);
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _onSkip() {
    _goToPage(_items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _items.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = _items[index];
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
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1F1F1F),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A4A4A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                              backgroundColor: const Color(0xFF2E2E2E),
                              foregroundColor: const Color(0xFFE6E6E6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
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
                              backgroundColor: const Color(0xFF141414),
                              foregroundColor: const Color(0xFFEDEDED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currentIndex == _items.length - 1
                                  ? 'Done'
                                  : 'Next',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
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

class _OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
