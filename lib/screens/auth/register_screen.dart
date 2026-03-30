import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/screens/main_navigation_screen.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  bool _isGoogleLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;

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
    _fadeController.dispose();
    _slideController.dispose();
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a0033).withOpacity(0.95),
                  const Color(0xFF0a2463).withOpacity(0.95),
                  const Color(0xFF247ba0).withOpacity(0.95),
                  const Color(0xFF6c3a8c).withOpacity(0.95),
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // Glow effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
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
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9d4edd), Color(0xFF3a0ca3)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join our AI creative community',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Glassmorphism Form Container
                      _GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            _AuthInputField(
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              icon: Icons.mail_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            _AuthInputField(
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              icon: Icons.lock_outline_rounded,
                              obscure: !_showPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            _AuthInputField(
                              label: AppStrings.confirmPasswordLabel,
                              hint: AppStrings.passwordHint,
                              icon: Icons.lock_outline_rounded,
                              obscure: !_showConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign Up Button
                            _GradientButton(
                              label: 'Create Account',
                              isLoading: false,
                              onPressed: () {},
                            ),
                            const SizedBox(height: 18),

                            // Divider
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white24,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Or Sign Up With',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white24,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialLoginButton(
                                  path: 'assets/auth/google.svg',
                                  label: 'Google',
                                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                                  isLoading: _isGoogleLoading,
                                ),
                                const SizedBox(width: 12),
                                _SocialLoginButton(
                                  path: 'assets/auth/meta.svg',
                                  label: 'Meta',
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 12),
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

                      SizedBox(height: size.height * 0.03),

                      // Sign In Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
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
                            color: Colors.white54,
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

// Glassmorphism Container
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
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
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

// Custom Auth Input Field
class _AuthInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;

  const _AuthInputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
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
            color: Colors.white70,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: TextField(
            obscureText: obscure,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 15,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(icon, color: Colors.blueAccent, size: 20),
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
              colors: [Color(0xFF9d4edd), Color(0xFF5a189a), Color(0xFF3a0ca3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9d4edd).withOpacity(0.4),
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
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
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
                          color: Colors.white,
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
                            color: Colors.white70,
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

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;

  const _AuthField({
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      obscureText: obscure,
      style: AppTextStyles.fieldText(context, isDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.fieldLabel(context, isDark),
        hintStyle: AppTextStyles.fieldHint(context, isDark),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String path;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialIconButton({
    required this.path,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(14.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: onPressed,
              icon: SvgPicture.asset(path, width: 22, height: 22),
            ),
    );
  }
}
