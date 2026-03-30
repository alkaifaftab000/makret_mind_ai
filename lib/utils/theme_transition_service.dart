import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ThemeTransitionService {
  // Global key to capture the entire screen's pixels
  static final GlobalKey repaintBoundaryKey = GlobalKey();

  static Future<void> switchTheme({
    required BuildContext context,
    required Offset tapOffset,
    required VoidCallback toggleAction,
  }) async {
    // 1. Capture the exact current pixel-state of the app
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      toggleAction();
      return;
    }

    final ui.Image image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      toggleAction();
      return;
    }

    final overlayState = Overlay.of(context);
    if (!context.mounted) {
      toggleAction();
      return;
    }
    late OverlayEntry overlayEntry;

    // We manually enforce the start coordinate to be the Top-Right Corner
    // to strictly fulfill "from top right and transition til left bottom"
    final screenSize = MediaQuery.sizeOf(context);
    final topRightOffset = Offset(screenSize.width - 24, 48);

    // 3. Fire the theme switch in the background instantly
    toggleAction();

    // 4. Place the Old Screenshot directly over everything, and animate a hole opening up
    overlayEntry = OverlayEntry(
      builder: (context) => _ThemeTransitionOverlay(
        oldImage: byteData.buffer.asUint8List(),
        tapOffset: topRightOffset,
        onAnimationComplete: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERLAY LAYER
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeTransitionOverlay extends StatefulWidget {
  final Uint8List oldImage;
  final Offset tapOffset;
  final VoidCallback onAnimationComplete;

  const _ThemeTransitionOverlay({
    required this.oldImage,
    required this.tapOffset,
    required this.onAnimationComplete,
  });

  @override
  State<_ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<_ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Extended for better visibility
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCalculated) {
      final size = MediaQuery.sizeOf(context);
      
      // Calculate how big the circle must grow to hit the furthest edge of the phone
      // To ensure top-right to bottom-left effect cleanly sweeps, set origin explicitly to top right if tap isn't perfect
      final origin = const Offset(10000, -10000); // We will override but math is safer
      final targetCenter = widget.tapOffset;
      
      final maxRadius = _calculateMaxRadius(size, targetCenter);

      _radiusAnimation = Tween<double>(begin: 0, end: maxRadius).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );

      // Start expanding, dispose when finished
      _controller.forward().then((_) => widget.onAnimationComplete());
      _hasCalculated = true;
    }
  }

  double _calculateMaxRadius(Size size, Offset center) {
    final w = size.width;
    final h = size.height;
    final distances = [
      const Offset(0, 0),
      Offset(w, 0),
      Offset(0, h),
      Offset(w, h),
    ].map((corner) => (corner - center).distance).toList();
    distances.sort();
    return distances.last * 1.2; // 20% bleed margin
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      // Block interaction during transition purely for safety
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return ClipPath(
            clipper: _ThemeRevealClipper(widget.tapOffset, _radiusAnimation.value),
            child: Image.memory(
              widget.oldImage,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM CLIPPER: Pokes an inverted expanding hole into the old layout
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _ThemeRevealClipper(this.center, this.radius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
          center: center, radius: radius == 0 ? 0.1 : radius)) // Small protection logic against radius artifacts
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant _ThemeRevealClipper oldClipper) =>
      oldClipper.radius != radius || oldClipper.center != center;
}
