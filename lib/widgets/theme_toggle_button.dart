import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/main.dart';
import 'package:market_mind/utils/theme_transition_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Builder(
      builder: (btnContext) {
        return GestureDetector(
          onTap: () {
            // Get the precise (X,Y) global offset from this button on the screen
            final renderBox = btnContext.findRenderObject() as RenderBox;
            final offset = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
            
            // Fire our sophisticated view transition sequence
            ThemeTransitionService.switchTheme(
              context: context,
              tapOffset: offset,
              toggleAction: () {
                MainApp.toggleTheme(context);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.divider,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                // Mimic React rotation and scale transformation cleanly
                return RotationTransition(
                  turns: child.key == const ValueKey('dark') 
                      ? Tween<double>(begin: 0.5, end: 1.0).animate(animation)
                      : Tween<double>(begin: -0.5, end: 0.0).animate(animation),
                  child: ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Icon(
                isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                key: ValueKey(isDark ? 'dark' : 'light'),
                color: isDark ? Colors.indigo.shade200 : Colors.amber.shade600,
                size: 22,
              ),
            ),
          ),
        );
      }
    );
  }
}
