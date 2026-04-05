import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/screens/brand_details/brand_service.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/cloudinary_service.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';

class BrandDetailsScreen extends StatefulWidget {
  final BrandModel brand;

  const BrandDetailsScreen({super.key, required this.brand});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  late BrandModel _brand;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _brand = widget.brand;
  }

  Future<void> _deleteBrand() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppStrings.deleteBrand,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.brand.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMutedLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.delete,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await brandDetailsActionService.deleteBrand(_brand.id);

      if (mounted) {
        AppNotification.success(
          context,
          message: 'Brand deleted successfully!',
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(
              context,
              true,
            ); // Return true to indicate refresh needed
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          message: 'Failed to delete brand. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMutedLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _MenuOption(
              icon: Icons.edit_rounded,
              label: AppStrings.editBrand,
              onTap: () async {
                Navigator.pop(context);
                await _editBrand();
              },
            ),
            _MenuOption(
              icon: Icons.share_rounded,
              label: AppStrings.share,
              onTap: () async {
                Navigator.pop(context);
                await _shareBrand();
              },
            ),
            _MenuOption(
              icon: Icons.delete_rounded,
              label: AppStrings.delete,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _deleteBrand();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            _brand.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 12,
                  child: _OverlayIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 12,
                  child: _OverlayIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: _showOptionsMenu,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_brand.description != null &&
                      _brand.description!.trim().isNotEmpty) ...[
                    _SectionTitle(AppStrings.description),
                    const SizedBox(height: 6),
                    Text(
                      _brand.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SectionTitle(AppStrings.details),
                  const SizedBox(height: 8),
                  _SimpleDetailRow(
                    heading: AppStrings.category,
                    value: _brand.category?.trim().isNotEmpty == true
                        ? _brand.category!
                        : AppStrings.notSet,
                  ),
                  _SimpleDetailRow(
                    heading: AppStrings.targetAudience,
                    value: _brand.targetAudience?.trim().isNotEmpty == true
                        ? _brand.targetAudience!
                        : AppStrings.notSet,
                  ),
                  _SimpleDetailRow(
                    heading: AppStrings.productions,
                    value:
                        '${_brand.productions} production${_brand.productions == 1 ? '' : 's'}',
                  ),
                  _SimpleDetailRow(
                    heading: AppStrings.created,
                    value: _formatDate(_brand.createdAt),
                  ),
                  _SimpleDetailRow(
                    heading: AppStrings.updated,
                    value: _formatDate(_brand.updatedAt),
                  ),
                  const SizedBox(height: 12),
                  // ─── Primary CTA ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(brand: _brand),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Products',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ─── Secondary Actions ─────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _editBrand,
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: Text(
                            AppStrings.edit,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkCardAlt
                                  : AppColors.lightCardAlt,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareBrand,
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: Text(
                            AppStrings.share,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkCardAlt
                                  : AppColors.lightCardAlt,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _deleteBrand,
                          icon: Icon(Icons.delete_rounded, size: 16, color: Colors.red.shade400),
                          label: Text(
                            AppStrings.delete,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBrand() async {
    try {
      await brandDetailsActionService.shareBrand(_brand);
      if (!mounted) return;
      AppNotification.success(
        context,
        message: 'Brand details copied for sharing',
      );
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Unable to share brand now');
    }
  }

  Future<void> _editBrand() async {
    final updatedBrand = await showModalBottomSheet<BrandModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditBrandSheet(brand: _brand),
    );

    if (updatedBrand != null && mounted) {
      setState(() {
        _brand = updatedBrand;
      });
      AppNotification.success(
        context,
        message: 'Brand updated successfully!',
      );
    }
  }

  Widget _buildImage() {
    if (_brand.imagePath.startsWith('http')) {
      return Image.network(
        _brand.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    } else {
      final file = File(_brand.imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 80,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textMutedLight,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title, style: AppTextStyles.sectionTitle(context, isDark));
  }
}

class _SimpleDetailRow extends StatelessWidget {
  final String heading;
  final String value;

  const _SimpleDetailRow({required this.heading, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              heading,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMutedLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.26),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Edit Brand Sheet ─────────────────────────────────────────────
class _EditBrandSheet extends StatefulWidget {
  final BrandModel brand;

  const _EditBrandSheet({required this.brand});

  @override
  State<_EditBrandSheet> createState() => _EditBrandSheetState();
}

class _EditBrandSheetState extends State<_EditBrandSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _targetAudienceController;
  bool _isSubmitting = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand.name);
    _descController = TextEditingController(text: widget.brand.description ?? '');
    _categoryController = TextEditingController(text: widget.brand.category ?? '');
    _targetAudienceController = TextEditingController(text: widget.brand.targetAudience ?? '');
  }

  Future<void> _pickImage() async {
    try {
      final photoPermission = await PermissionUtils.requestPhotosPermission();
      final storagePermission = await PermissionUtils.requestGalleryPermission();
      if (!photoPermission && !storagePermission) {
        if (!mounted) return;
        AppNotification.warning(
          context,
          message: 'Permission required to access photos',
        );
        return;
      }

      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final savedPath = await ImageUtils.saveImage(File(picked.path));

      if (!mounted) return;
      setState(() {
        _selectedImageFile = File(savedPath);
      });
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to pick image');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _targetAudienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppNotification.warning(context, message: 'Brand name is required');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final oldCat = widget.brand.category ?? '';
      final newCat = _categoryController.text.trim();
      final categoryList = newCat != oldCat && newCat.isNotEmpty
          ? newCat.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : null;

      final oldAud = widget.brand.targetAudience ?? '';
      final newAud = _targetAudienceController.text.trim();
      final audienceList = newAud != oldAud && newAud.isNotEmpty
          ? newAud.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : null;

      String? finalLogoUrl;
      if (_selectedImageFile != null) {
        finalLogoUrl = await cloudinaryService.uploadImage(
          _selectedImageFile!,
          folder: 'brands',
        );
        if (finalLogoUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      final updated = await brandDetailsActionService.editBrand(
        brand: widget.brand,
        name: name != widget.brand.name ? name : null,
        category: categoryList,
        targetAudience: audienceList,
        imagePath: finalLogoUrl,
      );

      final Map<String, dynamic> patchData = {};
      if (name != widget.brand.name) patchData['name'] = name;
      if (_descController.text.trim() != (widget.brand.description ?? '')) {
        patchData['description'] = _descController.text.trim();
      }
      if (newCat != oldCat) {
        patchData['category'] = newCat.isNotEmpty ? newCat.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : [];
      }
      if (newAud != oldAud) {
        patchData['target_audience'] = newAud.isNotEmpty ? newAud.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : [];
      }
      // If we used editBrand, it handles logo. But patchData overrides.
      if (finalLogoUrl != null) {
        patchData['logo'] = finalLogoUrl;
      }

      BrandModel finalBrand = widget.brand;
      if (patchData.isNotEmpty) {
        finalBrand = await brandService.patchBrandRaw(id: widget.brand.id, data: patchData);
      }

      if (!mounted) return;
      Navigator.pop(context, finalBrand);
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to update brand details');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMutedLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Edit Brand',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          // ─── Image Picker ────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                        )
                      : (widget.brand.imagePath.startsWith('http')
                          ? Image.network(
                              widget.brand.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.add_a_photo_rounded, size: 28),
                            )
                          : const Icon(Icons.add_a_photo_rounded, size: 28)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Tap to change logo',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _TextFieldLabel(label: 'Brand Name *', isDark: isDark),
          _StyledTextField(controller: _nameController, isDark: isDark),
          const SizedBox(height: 12),
          
          _TextFieldLabel(label: 'Description', isDark: isDark),
          _StyledTextField(controller: _descController, isDark: isDark, maxLines: 3),
          const SizedBox(height: 12),
          
          _TextFieldLabel(label: 'Category (comma separated)', isDark: isDark),
          _StyledTextField(controller: _categoryController, isDark: isDark),
          const SizedBox(height: 12),
          
          _TextFieldLabel(label: 'Target Audience (comma separated)', isDark: isDark),
          _StyledTextField(controller: _targetAudienceController, isDark: isDark),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.buttonText),
                        )
                      : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextFieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _TextFieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
