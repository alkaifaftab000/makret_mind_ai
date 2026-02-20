import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display Settings Section
            _buildSectionHeader(isDark, 'Display Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              isDark,
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme for your workspace',
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
            const SizedBox(height: 24),

            // Notification Settings Section
            _buildSectionHeader(isDark, 'Notifications'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              isDark,
              icon: Icons.notifications_rounded,
              title: 'Push Notifications',
              subtitle: 'Receive alerts about your projects',
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
              subtitle: 'Get email updates on important events',
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
            const SizedBox(height: 24),

            // Data Section
            _buildSectionHeader(isDark, 'Data & Privacy'),
            const SizedBox(height: 12),
            _buildActionTile(
              isDark,
              icon: Icons.download_rounded,
              title: 'Export Data',
              subtitle: 'Download your brands & products as JSON',
              onTap: () {
                AppNotification.success(
                  context,
                  message: 'Data export started...',
                );
              },
              accentColor: Colors.blue,
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              isDark,
              icon: Icons.backup_rounded,
              title: 'Backup Data',
              subtitle: 'Backup your content to cloud storage',
              onTap: () {
                AppNotification.info(
                  context,
                  message: 'Backup feature coming soon',
                );
              },
              accentColor: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              isDark,
              icon: Icons.delete_sweep_rounded,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              onTap: () {
                _showClearCacheDialog(isDark);
              },
              accentColor: Colors.orange,
            ),
            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader(isDark, 'App Settings'),
            const SizedBox(height: 12),
            _buildActionTile(
              isDark,
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () {
                AppNotification.info(
                  context,
                  message: 'Language settings coming soon',
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              isDark,
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
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
        color: isDark ? AppColors.darkCard : Colors.white,
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
            child: Icon(icon, color: AppColors.buttonPrimary, size: 20),
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
    required String subtitle,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider, width: 0.6),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (accentColor ?? AppColors.buttonPrimary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: accentColor ?? AppColors.buttonPrimary,
                size: 20,
              ),
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
          'This will remove cached images and videos. You can redownload them later.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
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
