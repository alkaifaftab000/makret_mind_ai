import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isGoogleLoading = false;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: size.height * 0.34,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Image.asset(
                    'assets/auth/register.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.registerTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.authTitle(context, isDark),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.registerSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.authSubtitle(context, isDark),
              ),
              const SizedBox(height: 18),
              const _AuthField(
                label: AppStrings.emailLabel,
                hint: AppStrings.emailHint,
              ),
              const SizedBox(height: 12),
              const _AuthField(
                label: AppStrings.passwordLabel,
                hint: AppStrings.passwordHint,
                obscure: true,
              ),
              const SizedBox(height: 12),
              const _AuthField(
                label: AppStrings.confirmPasswordLabel,
                hint: AppStrings.passwordHint,
                obscure: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.register,
                    style: AppTextStyles.authButton(context),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      AppStrings.orContinue,
                      style: AppTextStyles.smallMuted(context, isDark),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(
                    path: 'assets/auth/google.svg',
                    onPressed: _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(width: 16),
                  _SocialIconButton(
                    path: 'assets/auth/meta.svg',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  _SocialIconButton(
                    path: 'assets/auth/microsoft.svg',
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: AppTextStyles.bodyMedium(context, isDark),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      AppStrings.signIn,
                      style: AppTextStyles.bodyStrong(context, isDark),
                    ),
                  ),
                ],
              ),
            ],
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
