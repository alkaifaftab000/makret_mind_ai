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
    'https://images.unsplash.com/photo-1677442d019cecf8f6eca0a553e92f4fb0f4398a?w=400&h=600&fit=crop',
    'https://images.unsplash.com/photo-1611339555312-e607c04352fa?w=400&h=500&fit=crop',
    'https://images.unsplash.com/photo-1633356122544-f134324ef6db?w=400&h=700&fit=crop',
    'https://images.unsplash.com/photo-1677442d019cecf8f6eca0a553e92f4fb0f4398b?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1488190211105-8342f3e747d0?w=400&h=600&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=500&fit=crop',
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Masonry Grid of Images
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
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

          // Light Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
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
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Turn text, images, and concepts into cinematic AI-generated videos in seconds.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black54,
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
                          iconPath: 'assets/auth/apple.svg',
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
                              color: Colors.black54,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1),
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
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.iconPath != null)
                      SvgPicture.asset(widget.iconPath!, width: 24, height: 24)
                    else if (widget.backupIcon != null)
                      Icon(widget.backupIcon, color: Colors.black87, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
