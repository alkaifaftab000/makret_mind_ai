import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/screens/auth/register_screen.dart';
import 'package:market_mind/screens/main_navigation_screen.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isGoogleLoading = false;
  bool _isDevLoginLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final TextEditingController _emailController = TextEditingController(text: 'avinash@stallar.tech');
  final TextEditingController _nameController = TextEditingController(text: 'Avinash Shrivastava');

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleDevLogin() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      AppNotification.error(context, message: 'Please enter both email and name.');
      return;
    }

    setState(() => _isDevLoginLoading = true);
    try {
      final user = await authService.devLogin(email: email, name: name);
      if (user != null && mounted) {
        AppNotification.success(
          context,
          message: 'Dev Login Success: Welcome back, ${user.name}!',
        );
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
        setState(() => _isDevLoginLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final user = await authService.loginWithGoogle();
      if (user != null && mounted) {
        AppNotification.success(
          context,
          message: 'Welcome back, ${user.name}!',
        );
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
    final size = MediaQuery.sizeOf(context);

    // Light theme background SVG pattern
    const String bgPatternSvg = '''
    <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <pattern id="smallGrid" width="20" height="20" patternUnits="userSpaceOnUse">
          <path d="M 20 0 L 0 0 0 20" fill="none" stroke="rgba(0,0,0,0.02)" stroke-width="0.5"/>
        </pattern>
        <pattern id="grid" width="100" height="100" patternUnits="userSpaceOnUse">
          <rect width="100" height="100" fill="url(#smallGrid)"/>
          <path d="M 100 0 L 0 0 0 100" fill="none" stroke="rgba(0,0,0,0.04)" stroke-width="1"/>
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#grid)" />
    </svg>
    ''';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Light gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFF8F7FF).withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // SVG Pattern Background
          Positioned.fill(
            child: SvgPicture.string(
              bgPatternSvg,
              fit: BoxFit.cover,
            ),
          ),

          // Glowing Orb 1 (Top Right - Indigo)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.08),
              ),
            ),
          ),

          // Glowing Orb 2 (Bottom Left - Purple)
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
            ),
          ),

          // Global Backdrop Filter to blur the orbs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox(),
            ),
          ),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                    .animate(_slideController),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Branding Section
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            // Premium AI Logo container
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.hub_rounded, 
                                  color: Colors.white, 
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Market Mind AI',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create Stunning AI Visuals Instantly',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Form Container
                      _GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            _AuthInputField(
                              controller: _emailController,
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              icon: Icons.mail_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Name Field (replacing password for dev login)
                            _AuthInputField(
                              controller: _nameController,
                              label: 'Name',
                              hint: 'Enter your name',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF6366F1),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign In Button
                            _GradientButton(
                              label: 'Sign In (Dev Mode)',
                              isLoading: _isDevLoginLoading,
                              onPressed: _isDevLoginLoading ? null : _handleDevLogin,
                            ),
                            const SizedBox(height: 18),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.12),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Or Continue With',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.black.withOpacity(0.12),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Social Login Buttons
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _SocialLoginButton(
                                  path: 'assets/auth/google.svg',
                                  label: 'Google',
                                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                                  isLoading: _isGoogleLoading,
                                ),
                                _SocialLoginButton(
                                  path: 'assets/auth/meta.svg',
                                  label: 'Meta',
                                  onPressed: () {},
                                ),
                                _SocialLoginButton(
                                  path: 'assets/auth/microsoft.svg',
                                  label: 'Microsoft',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Register Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
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
                      ),

                      const SizedBox(height: 16),

                      // Footer Text
                      Center(
                        child: Text(
                          'By continuing, you agree to Terms & Privacy',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Light Theme Glassmorphism Container
class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: child,
        ),
      ),
    );
  }
}

// Custom Auth Input Field - Light Theme
class _AuthInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const _AuthInputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.6),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.black38,
                fontSize: 15,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// Gradient Button
class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> with SingleTickerProviderStateMixin {
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
      onTapUp: (_) {
        _scaleController.reverse();
      },
      onTapCancel: () {
        _scaleController.reverse();
      },
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(_scaleController),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Social Login Button
class _SocialLoginButton extends StatefulWidget {
  final String path;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.path,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> with SingleTickerProviderStateMixin {
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
      onTapUp: (_) {
        _scaleController.reverse();
      },
      onTapCancel: () {
        _scaleController.reverse();
      },
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.92).animate(_scaleController),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 100,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(widget.path, width: 20, height: 20),
                        const SizedBox(height: 4),
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
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

