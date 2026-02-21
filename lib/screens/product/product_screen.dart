import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/product_description_screen.dart';
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
    final type = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ProductTypeSheet(),
    );

    if (type == null || !mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateProductSheet(
        brandId: widget.brand.id,
        productType: type,
        onCreated: () async {
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
          style: AppTextStyles.sectionTitle(isDark),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? _EmptyProductsState(isDark: isDark)
            : GridView.builder(
                itemCount: _products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (_, index) => _ProductCard(
                  product: _products[index],
                  isDark: isDark,
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDescriptionScreen(product: _products[index]),
                      ),
                    );

                    if (changed == true) {
                      await _loadProducts();
                    }
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startCreateProductFlow,
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        label: Text(
          '✨ ${AppStrings.createProduct}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ProductTypeSheet extends StatelessWidget {
  const _ProductTypeSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Product Type',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _TypeTile(
            icon: Icons.image_rounded,
            title: 'Create Poster',
            subtitle: 'Images + prompt flow',
            onTap: () => Navigator.pop(context, 'poster'),
          ),
          const SizedBox(height: 10),
          _TypeTile(
            icon: Icons.videocam_rounded,
            title: 'Create Video',
            subtitle: 'Images + prompt + duration',
            onTap: () => Navigator.pop(context, 'video'),
          ),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateProductSheet extends StatefulWidget {
  final String brandId;
  final String productType;
  final Future<void> Function() onCreated;

  const _CreateProductSheet({
    required this.brandId,
    required this.productType,
    required this.onCreated,
  });

  @override
  State<_CreateProductSheet> createState() => _CreateProductSheetState();
}

class _CreateProductSheetState extends State<_CreateProductSheet> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  final _toneController = TextEditingController();
  final _customRatioController = TextEditingController();

  String _modelType = 'no';
  String _audioType = 'no audio';
  String _aspectRatio = 'mobile 16:9';
  String _videoLength = '30 sec';
  bool _isSubmitting = false;
  final List<String> _selectedImagePaths = [];

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _toneController.dispose();
    _customRatioController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final photoPermission = await PermissionUtils.requestPhotosPermission();
      final storagePermission =
          await PermissionUtils.requestGalleryPermission();
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

    if (_selectedImagePaths.length < 2) {
      AppNotification.warning(context, message: 'Upload at least 2 images');
      return;
    }

    if (_selectedImagePaths.length > 5) {
      AppNotification.warning(context, message: 'Maximum 5 images allowed');
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Prompt is required');
      return;
    }

    if (_aspectRatio == 'custom' &&
        _customRatioController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Custom ratio is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await productService.createProduct(
        brandId: widget.brandId,
        name: _nameController.text.trim(),
        type: widget.productType,
        imagePaths: _selectedImagePaths,
        prompt: _promptController.text.trim(),
        tone: _toneController.text.trim().isEmpty
            ? 'neutral'
            : _toneController.text.trim(),
        modelType: _modelType,
        audioType: widget.productType == 'poster' ? 'no audio' : _audioType,
        aspectRatio: _aspectRatio,
        customAspectRatio: _aspectRatio == 'custom'
            ? _customRatioController.text.trim()
            : null,
        videoLength: widget.productType == 'video' ? _videoLength : null,
      );

      if (!mounted) return;
      await widget.onCreated();
      if (!mounted) return;
      AppNotification.success(context, message: 'Product created successfully');
      Navigator.pop(context);
    } catch (_) {
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
          const SizedBox(height: 12),
          Text(
            'Create ${widget.productType == 'poster' ? 'Poster' : 'Video'} Product',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          _UploadImagesField(
            imagePaths: _selectedImagePaths,
            onPick: _isSubmitting ? null : _pickImages,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _TextFieldBlock(
            label: 'Product Name *',
            controller: _nameController,
            hint: 'e.g. New Launch Reel',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _TextFieldBlock(
            label: 'Prompt *',
            controller: _promptController,
            hint: 'Describe what to generate',
            isDark: isDark,
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          _TextFieldBlock(
            label: 'Tone',
            controller: _toneController,
            hint: 'e.g. premium, modern, cinematic',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _DropdownBlock(
            label: 'Model Type',
            value: _modelType,
            items: const ['male', 'female', 'no'],
            isDark: isDark,
            onChanged: (value) => setState(() => _modelType = value ?? 'no'),
          ),
          if (widget.productType == 'video') ...[
            const SizedBox(height: 10),
            _DropdownBlock(
              label: 'Audio',
              value: _audioType,
              items: const ['male', 'female', 'no audio'],
              isDark: isDark,
              onChanged: (value) =>
                  setState(() => _audioType = value ?? 'no audio'),
            ),
          ],
          const SizedBox(height: 10),
          _DropdownBlock(
            label: 'Aspect Ratio',
            value: _aspectRatio,
            items: const ['mobile 16:9', 'web', 'tab', 'custom'],
            isDark: isDark,
            onChanged: (value) =>
                setState(() => _aspectRatio = value ?? 'mobile 16:9'),
          ),
          if (_aspectRatio == 'custom') ...[
            const SizedBox(height: 10),
            _TextFieldBlock(
              label: 'Custom Ratio *',
              controller: _customRatioController,
              hint: 'e.g. 1:1, 9:16',
              isDark: isDark,
            ),
          ],
          if (widget.productType == 'video') ...[
            const SizedBox(height: 10),
            _DropdownBlock(
              label: 'Length',
              value: _videoLength,
              items: const ['15 sec', '30 sec', '45 sec', '60 sec'],
              isDark: isDark,
              onChanged: (value) =>
                  setState(() => _videoLength = value ?? '30 sec'),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: imagePaths.isEmpty
            ? Center(
                child: Text(
                  'Upload 2 to 5 images *',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePaths[index]),
                    width: 90,
                    height: 90,
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
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownBlock extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _DropdownBlock({
    required this.label,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Column(
          children: items.map((item) {
            final isSelected = item == value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(item),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.buttonPrimary.withValues(alpha: 0.14)
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.buttonPrimary
                          : AppColors.divider,
                      width: isSelected ? 1.2 : 0.7,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppColors.buttonPrimary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

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
    final preview = product.imagePaths.isNotEmpty
        ? product.imagePaths.first
        : null;
    return GestureDetector(
      onTap: onTap,
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
              child: preview != null
                  ? Image.file(
                      File(preview),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded),
                      ),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product.type.toUpperCase()} • ${product.videoLength ?? '-'} • ${product.aspectRatio == 'custom' ? product.customAspectRatio ?? 'custom' : product.aspectRatio}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
}

class _EmptyProductsState extends StatelessWidget {
  final bool isDark;

  const _EmptyProductsState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.video_collection_rounded,
              size: 64,
              color: AppColors.buttonPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.noProductsYet,
            style: AppTextStyles.titleMedium(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noProductsSubtitle,
            style: AppTextStyles.bodySmall(isDark),
          ),
        ],
      ),
    );
  }
}
