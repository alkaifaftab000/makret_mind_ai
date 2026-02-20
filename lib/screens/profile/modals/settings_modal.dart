import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _soundEnabled = true;

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
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Display Settings
            _buildSectionHeader(isDark, 'Display'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              isDark,
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  AppNotification.info(
                    context,
                    message: value ? 'Dark mode enabled' : 'Light mode enabled',
                  );
                },
                activeThumbColor: AppColors.buttonPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Notifications
            _buildSectionHeader(isDark, 'Notifications'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              isDark,
              icon: Icons.notifications_rounded,
              title: 'Push Notifications',
              subtitle: 'Receive alerts',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                activeThumbColor: AppColors.buttonPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              isDark,
              icon: Icons.mail_outline_rounded,
              title: 'Email Notifications',
              subtitle: 'Get email updates',
              trailing: Switch(
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
                activeThumbColor: AppColors.buttonPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              isDark,
              icon: Icons.volume_up_rounded,
              title: 'Sound Effects',
              subtitle: 'Play notification sounds',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                },
                activeThumbColor: AppColors.buttonPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Data Options
            _buildSectionHeader(isDark, 'Data & Privacy'),
            const SizedBox(height: 12),
            _buildActionTile(
              isDark,
              icon: Icons.download_rounded,
              title: 'Export Data',
              onTap: () {
                AppNotification.success(
                  context,
                  message: 'Data export started...',
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              isDark,
              icon: Icons.delete_sweep_rounded,
              title: 'Clear Cache',
              onTap: () {
                _showClearCacheDialog(isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildSettingsTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            child: Icon(icon, color: AppColors.buttonPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              child: Icon(icon, color: AppColors.buttonPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'Clear Cache?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove cached data. Confirm?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppNotification.success(context, message: 'Cache cleared');
            },
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
