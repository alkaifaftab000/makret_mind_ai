import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/utils/app_transitions.dart';
import 'package:market_mind/screens/ai_studio/scene_result_screen.dart';

class SceneGenerationScreen extends StatefulWidget {
  final String sceneTitle;
  final String productName;
  final List<Color> gradientColors;

  const SceneGenerationScreen({
    super.key,
    required this.sceneTitle,
    required this.productName,
    required this.gradientColors,
  });

  @override
  State<SceneGenerationScreen> createState() => _SceneGenerationScreenState();
}

class _SceneGenerationScreenState extends State<SceneGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _stepIndex = 0;
  final _steps = const [
    ('Preparing...', Icons.settings_rounded),
    ('Generating...', Icons.auto_awesome_rounded),
    ('Finalising...', Icons.check_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _runSteps();
  }

  Future<void> _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() => _stepIndex = i);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      FadeRoute(
        page: SceneResultScreen(
          sceneTitle: widget.sceneTitle,
          productName: widget.productName,
          gradientColors: widget.gradientColors,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = _steps[_stepIndex];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top info
              Text(
                'AI Studio',
                style: AppTextStyles.screenTitle(context, isDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Generating visual for "${widget.productName}"',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(context, isDark),
              ),
              const SizedBox(height: 60),

              // Animated gradient orb
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.gradientColors.first.withValues(alpha: 0.9),
                        widget.gradientColors.last.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Icon(
                        currentStep.$2,
                        key: ValueKey(_stepIndex),
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Step text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  currentStep.$1,
                  key: ValueKey(_stepIndex),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final isActive = index <= _stepIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive && index == _stepIndex ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? widget.gradientColors.first
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Step label row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final isActive = index <= _stepIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _steps[index].$1.replaceAll('...', ''),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight)
                            : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
