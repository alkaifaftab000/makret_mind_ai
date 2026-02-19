import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BrandModel> _brands = [];
  List<BrandModel> _filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _searchController.addListener(_filterBrands);
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await brandService.getAllBrands();
      setState(() {
        _brands = brands;
        _filteredBrands = brands;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading brands: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBrands() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _filteredBrands = _brands;
      });
    } else {
      setState(() {
        _filteredBrands = _brands
            .where(
              (brand) =>
                  brand.name.toLowerCase().contains(query.toLowerCase()) ||
                  (brand.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      });
    }
  }

  void _showCreateBrandSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CreateBrandSheet(onBrandCreated: _onBrandCreated),
    );
  }

  void _onBrandCreated(BrandModel brand) {
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brands',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                style: AppTextStyles.fieldText(isDark),
                decoration: InputDecoration(
                  hintText: 'Search brands...',
                  hintStyle: AppTextStyles.fieldHint(isDark),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBrands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.add_business_rounded,
                                size: 64,
                                color: AppColors.buttonPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Brands Yet',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first brand to get started',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _filteredBrands.length,
                        itemBuilder: (context, index) {
                          final brand = _filteredBrands[index];
                          return _BrandCard(
                            brand: brand,
                            isDark: isDark,
                            onRefresh: _loadBrands,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBrandSheet,
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Create Brand',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isDark;
  final VoidCallback onRefresh;

  const _BrandCard({
    required this.brand,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to brand details screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildBrandImage(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${brand.productions} productions',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Create product action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Create Product',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandImage() {
    final imageFile = ImageUtils.loadImage(brand.imagePath);
    if (imageFile != null && imageFile.existsSync()) {
      return Image.file(
        imageFile,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    // Fallback to placeholder
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class CreateBrandSheet extends StatefulWidget {
  final Function(BrandModel) onBrandCreated;

  const CreateBrandSheet({required this.onBrandCreated, super.key});

  @override
  State<CreateBrandSheet> createState() => _CreateBrandSheetState();
}

class _CreateBrandSheetState extends State<CreateBrandSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _audienceController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedImagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _audienceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Request photo/gallery permission
      final permissionGranted = await PermissionUtils.requestPhotosPermission();

      if (!permissionGranted) {
        if (mounted) {
          AppNotification.warning(
            context,
            message: 'Permission required to access photos',
          );
        }
        return;
      }

      final imagePath = await ImageUtils.pickImage(source: ImageSource.gallery);
      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          message: 'Failed to pick image. Please try again.',
        );
      }
    }
  }

  Future<void> _submitBrand() async {
    // Validate brand name
    if (_nameController.text.isEmpty) {
      AppNotification.warning(context, message: 'Brand name is required');
      return;
    }

    // Validate image
    if (_selectedImagePath == null) {
      AppNotification.warning(context, message: 'Brand logo is required');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final brand = await brandService.createBrand(
        name: _nameController.text,
        imagePath: _selectedImagePath!,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        targetAudience: _audienceController.text.isEmpty
            ? null
            : _audienceController.text,
        category: _categoryController.text.isEmpty
            ? null
            : _categoryController.text,
      );

      if (mounted) {
        widget.onBrandCreated(brand);
        Navigator.pop(context);
        AppNotification.success(
          context,
          message: 'Brand created successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          message: 'Error creating brand. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
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
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create New Brand',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            size: 40,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Brand Logo *',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Brand Name *',
              hint: 'e.g., Tech Innovations',
              controller: _nameController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Description',
              hint: 'Tell us about your brand...',
              controller: _descriptionController,
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Target Audience',
              hint: 'e.g., Tech enthusiasts, 18-35',
              controller: _audienceController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Category',
              hint: 'e.g., Technology, Fashion',
              controller: _categoryController,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBrand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.buttonPrimary
                          .withValues(alpha: 0.5),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.buttonText,
                              ),
                            ),
                          )
                        : Text(
                            'Create',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isDark;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.isDark,
    this.maxLines = 1,
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
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : 3,
          style: AppTextStyles.fieldText(isDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.fieldHint(isDark),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
