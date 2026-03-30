import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoGenerationScreen extends StatefulWidget {
  VideoGenerationScreen({Key? key}) : super(key: key);

  @override
  _VideoGenerationScreenState createState() => _VideoGenerationScreenState();
}

class _VideoGenerationScreenState extends State<VideoGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  final List<String> _steps = [
    'Uploading video...',
    'Generating transitions...',
    'Adding effects...',
    'Rendering video...',
    'Finalizing...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _startGeneration();
  }

  void _startGeneration() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 1200));
      if (mounted) {
        setState(() => _currentStep = i + 1);
      }
    }

    // After all steps, navigate to result
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      _navigateToResult();
    }
  }

  void _navigateToResult() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Progress Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent.withOpacity(0.3),
                      Colors.blueAccent.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _animationController,
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 60,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48),

              // Animated Status Text
              SizedBox(
                height: 60,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: Text(
                      _currentStep < _steps.length
                          ? _steps[_currentStep]
                          : 'Video Generated!',
                      key: ValueKey<int>(_currentStep),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 48),

              // Step Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _currentStep
                            ? Colors.deepPurpleAccent
                            : Colors.white30,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Progress Text
              Text(
                '${_currentStep} of ${_steps.length} steps',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
