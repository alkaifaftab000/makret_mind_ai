import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/screens/auth/register_screen.dart';
import 'package:market_mind/screens/main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    'assets/auth/login.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.loginTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.authTitle(isDark),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.loginSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.authSubtitle(isDark),
              ),
              const SizedBox(height: 18),
              _AuthField(
                label: AppStrings.emailLabel,
                hint: AppStrings.emailHint,
              ),
              const SizedBox(height: 12),
              _AuthField(
                label: AppStrings.passwordLabel,
                hint: AppStrings.passwordHint,
                obscure: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.signIn,
                    style: AppTextStyles.authButton,
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
                      style: AppTextStyles.smallMuted(isDark),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(path: 'assets/auth/google.svg'),
                  SizedBox(width: 16),
                  _SocialIconButton(path: 'assets/auth/meta.svg'),
                  SizedBox(width: 16),
                  _SocialIconButton(path: 'assets/auth/microsoft.svg'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount,
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.register,
                      style: AppTextStyles.bodyStrong(isDark),
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
      style: AppTextStyles.fieldText(isDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.fieldLabel(isDark),
        hintStyle: AppTextStyles.fieldHint(isDark),
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

  const _SocialIconButton({required this.path});

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
      child: IconButton(
        onPressed: () {},
        icon: SvgPicture.asset(path, width: 22, height: 22),
      ),
    );
  }
}
