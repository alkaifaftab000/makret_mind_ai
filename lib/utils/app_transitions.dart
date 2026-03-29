import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTransitions — Centralized premium transition helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Global fade + slide from bottom page route.
/// Use this everywhere instead of [MaterialPageRoute] for consistency.
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeSlideRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 320),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.06), // Subtle upward enter
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            // Slide the current screen OUT slightly when pushing
            final secondarySlide = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, -0.04),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOut,
            ));

            return SlideTransition(
              position: secondarySlide,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: slideAnimation, child: child),
              ),
            );
          },
        );
}

/// Lightweight fade-only route for modal-style screens (e.g. result screens)
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedTabSwitcher — Directional horizontal slide for tab body transitions
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedTabSwitcher extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedTabSwitcher({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slideIn;

  int _previousIndex = 0;
  late Widget _currentChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _controller = AnimationController(
      vsync: this,
      // Slower = more "movement" feel, like swiping between app pages
      duration: const Duration(milliseconds: 420),
    );
    _setupAnimations(fromRight: true);
    _controller.forward();
  }

  void _setupAnimations({required bool fromRight}) {
    final double direction = fromRight ? 1.0 : -1.0;

    // New screen enters from direction we're going
    _slideIn = Tween<Offset>(
      begin: Offset(direction * 0.30, 0), // 30% of width horizontal travel
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart, // Decelerates naturally
    ));

    // Fade in happens slightly faster than slide to feel snappy
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final bool goingRight = widget.index > _previousIndex;
      _previousIndex = oldWidget.index;
      _currentChild = widget.child;

      _setupAnimations(fromRight: goingRight);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slideIn, child: _currentChild),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TappableScale — Smooth scale-down tap feedback for any widget
// ─────────────────────────────────────────────────────────────────────────────

class TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const TappableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EntranceAnimator — Staggered fade+scale entrance for grid/list items
// ─────────────────────────────────────────────────────────────────────────────

class EntranceAnimator extends StatefulWidget {
  final Widget child;
  final int delay; // index-based delay in milliseconds
  final Duration duration;

  const EntranceAnimator({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  State<EntranceAnimator> createState() => _EntranceAnimatorState();
}

class _EntranceAnimatorState extends State<EntranceAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Stagger: wait then play
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
