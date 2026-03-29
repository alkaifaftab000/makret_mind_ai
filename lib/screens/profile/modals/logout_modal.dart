import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/screens/onboarding/onboarding_screen.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/services/user_service.dart';

class LogoutModal extends StatelessWidget {
  const LogoutModal({super.key});

  void _performLogout(BuildContext context) async {
    try {
      await authService.logOut();
      if (!context.mounted) return;

      AppNotification.success(context, message: 'Logged out successfully');

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      if (context.mounted) {
        AppNotification.error(context, message: 'Failed to logout');
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          AppStrings.confirmLogout,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppStrings.logoutMessage,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(color: AppColors.buttonPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: Text(
              AppStrings.logout,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account and all associated data? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(color: AppColors.buttonPrimary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              try {
                await userService.deleteCurrentUser();
                await authService.logOut();

                if (context.mounted) {
                  AppNotification.success(
                    context,
                    message: 'Account deleted successfully',
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppNotification.error(
                    context,
                    message: 'Failed to delete account',
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.logout,
              style: AppTextStyles.sectionTitle(context, isDark),
            ),
            const SizedBox(height: 16),

            // Warning Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                'Logging out will end your current session. Your local data will be preserved.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Cards
            _buildInfoCard(
              isDark,
              icon: Icons.cloud_done_rounded,
              title: 'Data is Safe',
              description: 'All brands and products stored locally',
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              isDark,
              icon: Icons.security_rounded,
              title: 'Secure',
              description: 'Authentication tokens will be cleared',
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              isDark,
              icon: Icons.login_rounded,
              title: 'Easy Re-login',
              description: 'You can log back in anytime',
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLogoutConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.logoutNow,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showDeleteAccountConfirmation(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.buttonPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.buttonPrimary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
