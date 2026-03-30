import 'package:flutter/material.dart';
import 'package:market_mind/screens/splash/splash_service.dart';
import 'package:market_mind/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SplashService _splashService = SplashService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Continuous subtle motion (12 seconds)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _startSplashHold();
  }

  Future<void> _startSplashHold() async {
    await _splashService.holdSplash(); // 8 seconds delay as constrained
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide transition (Bottom -> Up) combined with Fade
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 0.2),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart));
          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light off-white tone
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Collage Grid with subtle motion
          _CollageGrid(animationController: _animationController),

          // Top and Bottom Gradient Overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(
                      0xFFF8F9FA,
                    ).withOpacity(0.95), // Top fade for readability
                    const Color(0xFFF8F9FA).withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFFF8F9FA).withOpacity(0.8), // Bottom fade
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Title
          const Positioned(
            top: 120, // Top-middle area
            left: 0,
            right: 0,
            child: _SplashTitle(),
          ),
        ],
      ),
    );
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "AI Image",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111111), // Dark text color (near-black)
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        Text(
          "Generator",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111111),
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _CollageGrid extends StatelessWidget {
  final AnimationController animationController;

  const _CollageGrid({Key? key, required this.animationController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a wider screen area to allow translation without seeing edges
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: -60,
      left: -60,
      width: screenWidth + 120,
      height: screenHeight + 120,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          // Subtle drift: move by a max of 40px left and 30px up
          final offsetX = -20.0 + (40.0 * animationController.value);
          final offsetY = -15.0 + (30.0 * animationController.value);

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: child,
          );
        },
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _AnimatedTile(index: 0),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 2),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 4),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 6),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 8),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: const [
                    SizedBox(height: 40), // Offset the second column
                    _AnimatedTile(index: 1),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 3),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 5),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 7),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 9),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: const [
                    _AnimatedTile(index: 10),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 11),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 12),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 13),
                    SizedBox(height: 12),
                    _AnimatedTile(index: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _AnimatedTile extends StatelessWidget {
  final int index;

  const _AnimatedTile({required this.index});

  @override
  Widget build(BuildContext context) {
    // Artificial heights for masonry look
    final List<double> heights = [
      220,
      180,
      260,
      200,
      240,
      160,
      210,
      250,
      190,
      230,
      200,
      250,
      170,
      220,
      240,
    ];
    final double height = heights[index % heights.length];

    // Abstract nature imagery using picsum seed as placeholder images
    final imageUrl = 'https://picsum.photos/seed/ai_splash_$index/400/600';

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
