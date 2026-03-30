import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mind/screens/auth/login_screen.dart';
import 'package:market_mind/screens/auth/register_screen.dart';

import '../../services/auth_service.dart';
import '../../utils/app_notification.dart';
import '../main_navigation_screen.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _isGoogleLoading = false;

  final List<String> _images = [
    'https://picsum.photos/seed/ai1/400/600',
    'https://picsum.photos/seed/ai2/400/500',
    'https://picsum.photos/seed/ai3/400/700',
    'https://picsum.photos/seed/ai4/400/400',
    'https://picsum.photos/seed/ai5/400/600',
    'https://picsum.photos/seed/ai6/400/500',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final user = await authService.loginWithGoogle();
      if (user != null && mounted) {
        AppNotification.success(context, message: 'Welcome, ${user.name}!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // Background Masonry Grid of Images
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1
                    Expanded(
                      child: Column(
                        children: [
                          _buildImageCard(_images[0], 220),
                          _buildImageCard(_images[1], 180),
                          _buildImageCard(_images[2], 260),
                        ],
                      ),
                    ),
                    // Column 2
                    Expanded(
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -60),
                            child: Column(
                              children: [
                                _buildImageCard(_images[3], 260),
                                _buildImageCard(_images[4], 200),
                                _buildImageCard(_images[5], 220),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Column 3
                    Expanded(
                      child: Column(
                        children: [
                          _buildImageCard(_images[1], 160),
                          _buildImageCard(_images[2], 280),
                          _buildImageCard(_images[0], 200),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    const Color(0xFF1a0033).withOpacity(0.6),
                    const Color(0xFF0F0F1A).withOpacity(0.95),
                    const Color(0xFF0F0F1A),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          'Create Stunning AI\nVideos Instantly',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Turn text, images, and concepts into cinematic AI-generated videos in seconds.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Buttons Container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Primary CTA - Continue with Email
                        _PrimaryActionBtn(
                          label: 'Continue with Email',
                          icon: Icons.mail_rounded,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Apple Login
                        _GlassActionButton(
                          label: 'Continue with Apple',
                          iconPath: 'assets/auth/apple.svg', // Assuming you have this icon
                          backupIcon: Icons.apple_rounded,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),

                        // Google Login
                        _GlassActionButton(
                          label: 'Continue with Google',
                          iconPath: 'assets/auth/google.svg',
                          onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Footer - Sign Up Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String url, double height) {
    return Container(
      margin: const EdgeInsets.all(6),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PrimaryActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_PrimaryActionBtn> createState() => _PrimaryActionBtnState();
}

class _PrimaryActionBtnState extends State<_PrimaryActionBtn> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(_scaleController),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9d4edd), Color(0xFFe91e63)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFe91e63).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatefulWidget {
  final String label;
  final String? iconPath;
  final IconData? backupIcon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GlassActionButton({
    required this.label,
    this.iconPath,
    this.backupIcon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<_GlassActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) _scaleController.forward();
      },
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(_scaleController),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.iconPath != null)
                          SvgPicture.asset(widget.iconPath!, width: 24, height: 24)
                        else if (widget.backupIcon != null)
                          Icon(widget.backupIcon, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
