import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';
import 'package:image_picker/image_picker.dart';

import 'package:market_mind/services/user_service.dart';

import 'package:market_mind/services/auth_service.dart';

class AccountModal extends StatefulWidget {
  const AccountModal({super.key});

  @override
  State<AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<AccountModal> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  String? _profileImagePath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = authService.currentUser;
    _nameController = TextEditingController(
      text: user?.name ?? 'MarketMind User',
    );
    _emailController = TextEditingController(
      text: user?.email ?? 'user@example.com',
    );
    _bioController = TextEditingController(
      text: 'Content creator focused on brand storytelling.',
    );
    _websiteController = TextEditingController(text: 'https://example.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      // In a real app we'd also upload the image to Cloudinary yielding a URL
      // but the API docs specify: { "name": "New Name", "avatar": "https://..." }
      await userService.updateCurrentUser(
        name: _nameController.text.trim(),
        // avatar: _profileImagePath != null ? await _uploadImageToCloudinary(_profileImagePath!) : null
      );

      if (mounted) {
        setState(() => _isEditing = false);
        AppNotification.success(
          context,
          message: 'Profile updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context, message: 'Failed to update profile');
      }
    }
  }

  Future<void> _changeProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final granted = source == ImageSource.camera
        ? await PermissionUtils.requestCameraPermission()
        : await PermissionUtils.requestPhotosPermission() ||
              await PermissionUtils.requestGalleryPermission();

    if (!granted) {
      if (!mounted) return;
      AppNotification.warning(
        context,
        message: 'Permission required to update profile photo',
      );
      return;
    }

    final imagePath = await ImageUtils.pickImage(source: source);
    if (imagePath == null || !mounted) return;

    setState(() {
      _profileImagePath = imagePath;
    });
    AppNotification.success(context, message: 'Profile photo updated');
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (!_isEditing)
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: AppColors.buttonPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightCard,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 42,
                                color: AppColors.buttonPrimary,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: _changeProfilePhoto,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.buttonPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: AppColors.buttonText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _changeProfilePhoto,
                    child: Text(
                      'Change Profile Photo',
                      style: GoogleFonts.poppins(
                        color: AppColors.buttonPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (_isEditing) ...[
              _buildFormField(
                isDark,
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _buildFormField(
                isDark,
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _buildFormField(
                isDark,
                label: 'Bio',
                controller: _bioController,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              _buildFormField(
                isDark,
                label: 'Website',
                controller: _websiteController,
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.buttonPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: AppColors.buttonPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildInfoRow(isDark, 'Name', _nameController.text),
              const SizedBox(height: 12),
              _buildInfoRow(isDark, 'Email', _emailController.text),
              const SizedBox(height: 12),
              _buildInfoRow(isDark, 'Bio', _bioController.text),
              const SizedBox(height: 12),
              _buildInfoRow(isDark, 'Website', _websiteController.text),
              const SizedBox(height: 12),
              _buildInfoRow(isDark, 'Member Since', 'January 2026'),
              const SizedBox(height: 12),
              _buildInfoRow(isDark, 'Account Status', 'Active'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    bool isDark, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
            prefixIcon: Icon(icon, color: AppColors.buttonPrimary, size: 18),
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.divider, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.divider, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.buttonPrimary,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
