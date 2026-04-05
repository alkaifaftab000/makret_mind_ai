import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/poster_config_screen.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';

class ProductScreen extends StatefulWidget {
  final BrandModel brand;

  const ProductScreen({super.key, required this.brand});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await productService.getProductsByBrand(widget.brand.id);
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _startCreateProductFlow() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateProductSheet(
        brandId: widget.brand.id,
        onCreated: (product) async {
          await _loadProducts();
        },
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
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        title: Text(
          '${widget.brand.name} Products',
          style: AppTextStyles.sectionTitle(context, isDark),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? _EmptyProductsState(isDark: isDark)
            : ListView.separated(
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _ProductCard(
                  product: _products[index],
                  isDark: isDark,
                  onTap: () {
                    final product = _products[index];
                    // Navigate to poster config/results
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PosterConfigScreen(
                          product: product,
                          onJobCreated: () => _loadProducts(),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startCreateProductFlow,
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        label: Text(
          AppStrings.createProduct,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ─── Create Product Sheet (simplified: name + images) ─────────────
class _CreateProductSheet extends StatefulWidget {
  final String brandId;
  final Future<void> Function(ProductModel product) onCreated;

  const _CreateProductSheet({
    required this.brandId,
    required this.onCreated,
  });

  @override
  State<_CreateProductSheet> createState() => _CreateProductSheetState();
}

class _CreateProductSheetState extends State<_CreateProductSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _selectedImagePaths = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
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
      final picked = await picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;

      final limited = picked.take(5).toList();
      final saved = <String>[];

      for (final file in limited) {
        final path = await ImageUtils.saveImage(File(file.path));
        saved.add(path);
      }

      if (!mounted) return;
      setState(() {
        _selectedImagePaths
          ..clear()
          ..addAll(saved);
      });

      if (picked.length > 5) {
        AppNotification.info(
          context,
          message: 'Only first 5 images were selected',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to pick images');
    }
  }

  Future<void> _createProduct() async {
    if (_nameController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Product name is required');
      return;
    }

    if (_selectedImagePaths.isEmpty) {
      AppNotification.warning(context, message: 'Upload at least 1 image');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final product = await productService.createProduct(
        brandId: widget.brandId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imagePaths: _selectedImagePaths,
      );

      if (!mounted) return;
      AppNotification.success(context, message: 'Product created successfully');
      Navigator.pop(context);
      await widget.onCreated(product);
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to create product');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Create Product',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your product details and images',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          // ─── Upload Images ─────────────────────────────
          _UploadImagesField(
            imagePaths: _selectedImagePaths,
            onPick: _isSubmitting ? null : _pickImages,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          // ─── Product Name ──────────────────────────────
          _TextFieldBlock(
            label: 'Product Name *',
            controller: _nameController,
            hint: 'e.g., Summer Collection Sneakers',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          // ─── Description (optional) ────────────────────
          _TextFieldBlock(
            label: 'Description',
            controller: _descriptionController,
            hint: 'Brief description of your product...',
            isDark: isDark,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          // ─── Buttons ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _createProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
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
    );
  }
}

// ─── Upload images component ──────────────────────────────────────
class _UploadImagesField extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback? onPick;
  final bool isDark;

  const _UploadImagesField({
    required this.imagePaths,
    required this.onPick,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.5),
            style: imagePaths.isEmpty ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: imagePaths.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 32,
                      color: AppColors.buttonPrimary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload 2-5 product images',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePaths[index]),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: imagePaths.length,
              ),
      ),
    );
  }
}

// ─── Text field component ─────────────────────────────────────────
class _TextFieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;

  const _TextFieldBlock({
    required this.label,
    required this.controller,
    required this.hint,
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
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = product.images.isNotEmpty ? product.images.first : null;
    final posterCount = product.posters.length;
    final videoCount = product.videos.length;

    // Find latest poster result
    final latestPoster = product.latestPoster;
    final posterStatus = latestPoster?.status ?? 'none';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // ─── Image preview ──────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: preview != null
                    ? (preview.startsWith('http')
                        ? Image.network(
                            preview,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : Image.file(
                            File(preview),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          ))
                    : _imagePlaceholder(),
              ),
            ),
            // ─── Info ───────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.images.length} images',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (posterCount > 0)
                          _StatusBadge(
                            label: '$posterCount poster${posterCount > 1 ? 's' : ''}',
                            status: posterStatus,
                          ),
                        if (posterCount > 0 && videoCount > 0)
                          const SizedBox(width: 6),
                        if (videoCount > 0)
                          _StatusBadge(
                            label: '$videoCount video${videoCount > 1 ? 's' : ''}',
                            status: product.latestVideo?.status ?? 'none',
                          ),
                        if (posterCount == 0 && videoCount == 0)
                          Text(
                            'No generations yet',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
      child: const Center(
        child: Icon(Icons.image_rounded, size: 28),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final String status;

  const _StatusBadge({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        break;
      case 'processing':
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange.shade700;
        break;
      case 'failed':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = AppColors.buttonPrimary.withValues(alpha: 0.1);
        textColor = AppColors.buttonPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────
class _EmptyProductsState extends StatelessWidget {
  final bool isDark;

  const _EmptyProductsState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textMutedLight,
          ),
          const SizedBox(height: 12),
          Text(
            'No products yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to create your first product',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
