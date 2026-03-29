import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/product_generation_screen.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class ProductDescriptionScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDescriptionScreen({super.key, required this.product});

  @override
  State<ProductDescriptionScreen> createState() =>
      _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  late ProductModel _product;
  late TextEditingController _nameController;
  late TextEditingController _promptController;
  late TextEditingController _toneController;
  late TextEditingController _customRatioController;

  late String _modelType;
  late String _audioType;
  late String _aspectRatio;
  late String _videoLength;

  bool _isSaving = false;
  late List<String> _imagePaths;
  late List<TextEditingController> _imageDescriptionControllers;

  @override
  void initState() {
    super.initState();
    _product = widget.product;

    _nameController = TextEditingController(text: _product.name);
    _promptController = TextEditingController(text: _product.prompt);
    _toneController = TextEditingController(text: _product.tone);
    _customRatioController = TextEditingController(
      text: _product.customAspectRatio ?? '',
    );

    _modelType = _product.modelType;
    _audioType = _product.audioType;
    _aspectRatio = _product.aspectRatio;
    _videoLength = _product.videoLength ?? '30 sec';

    _imagePaths = List<String>.from(_product.imagePaths);
    _imageDescriptionControllers = _buildDescriptionControllers(
      imageCount: _product.imagePaths.length,
    );
  }

  List<TextEditingController> _buildDescriptionControllers({
    required int imageCount,
  }) {
    return List<TextEditingController>.generate(
      imageCount,
      (index) => TextEditingController(
        text: 'Auto generated description for image ${index + 1}',
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _toneController.dispose();
    _customRatioController.dispose();
    for (final controller in _imageDescriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _removeImage(int index) async {
    if (_imagePaths.length <= 1) {
      AppNotification.warning(
        context,
        message: 'At least 1 image should remain',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Image?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This image and its description will be removed.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel, style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _imagePaths.removeAt(index);
      final controller = _imageDescriptionControllers.removeAt(index);
      controller.dispose();
    });
  }

  Future<void> _submitConfiguration() async {
    if (_nameController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Product name is required');
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Prompt is required');
      return;
    }

    if (_imagePaths.isEmpty) {
      AppNotification.warning(
        context,
        message: 'At least one image is required',
      );
      return;
    }

    if (_aspectRatio == 'custom' &&
        _customRatioController.text.trim().isEmpty) {
      AppNotification.warning(context, message: 'Custom ratio is required');
      return;
    }

    final descriptions = _imageDescriptionControllers
        .map(
          (controller) => controller.text.trim().isEmpty
              ? 'Auto generated description'
              : controller.text.trim(),
        )
        .toList();

    setState(() => _isSaving = true);

    try {
      final updated = await productService.updateProductConfiguration(
        product: _product,
        name: _nameController.text.trim(),
        imagePaths: _imagePaths,
        prompt: _promptController.text.trim(),
        tone: _toneController.text.trim().isEmpty
            ? 'neutral'
            : _toneController.text.trim(),
        modelType: _modelType,
        audioType: _product.type == 'poster' ? 'no audio' : _audioType,
        aspectRatio: _aspectRatio,
        customAspectRatio: _aspectRatio == 'custom'
            ? _customRatioController.text.trim()
            : null,
        videoLength: _product.type == 'video' ? _videoLength : null,
      );

      if (!mounted) return;
      setState(() {
        _product = updated;
      });

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.buttonPrimary,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Generating short clips from configuration...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);

      if (updated.scenes.isEmpty) {
        AppNotification.info(
          context,
          message:
              'Backend scenes pending. Loading mock short clips for testing.',
        );
      }

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ProductGenerationScreen(product: _product),
        ),
      );

      if (!mounted) return;
      if (completed == true) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to submit configuration');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          'Product Description',
          style: AppTextStyles.sectionTitle(context, isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TextFieldBlock(
              label: 'Product Name',
              controller: _nameController,
              hint: 'Product name',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _TextFieldBlock(
              label: 'Prompt',
              controller: _promptController,
              hint: 'Describe generated output',
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _TextFieldBlock(
              label: 'Tone',
              controller: _toneController,
              hint: 'e.g. premium, modern',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DropdownBlock(
              label: 'Model Type',
              value: _modelType,
              items: const ['male', 'female', 'no'],
              isDark: isDark,
              onChanged: (value) {
                setState(() {
                  _modelType = value ?? 'no';
                });
              },
            ),
            if (_product.type == 'video') ...[
              const SizedBox(height: 10),
              _DropdownBlock(
                label: 'Audio',
                value: _audioType,
                items: const ['male', 'female', 'no audio'],
                isDark: isDark,
                onChanged: (value) {
                  setState(() {
                    _audioType = value ?? 'no audio';
                  });
                },
              ),
            ],
            const SizedBox(height: 10),
            _DropdownBlock(
              label: 'Aspect Ratio',
              value: _aspectRatio,
              items: const ['mobile 16:9', 'web', 'tab', 'custom'],
              isDark: isDark,
              onChanged: (value) {
                setState(() {
                  _aspectRatio = value ?? 'mobile 16:9';
                });
              },
            ),
            if (_aspectRatio == 'custom') ...[
              const SizedBox(height: 10),
              _TextFieldBlock(
                label: 'Custom Ratio',
                controller: _customRatioController,
                hint: 'e.g. 1:1',
                isDark: isDark,
              ),
            ],
            if (_product.type == 'video') ...[
              const SizedBox(height: 10),
              _DropdownBlock(
                label: 'Length',
                value: _videoLength,
                items: const ['15 sec', '30 sec', '45 sec', '60 sec'],
                isDark: isDark,
                onChanged: (value) {
                  setState(() {
                    _videoLength = value ?? '30 sec';
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Generated Image Descriptions',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_imagePaths.length, (index) {
              return _ImageDescriptionEditor(
                imagePath: _imagePaths[index],
                controller: _imageDescriptionControllers[index],
                onRemove: () async => _removeImage(index),
                isDark: isDark,
                index: index,
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Submit Configuration',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageDescriptionEditor extends StatelessWidget {
  final String imagePath;
  final TextEditingController controller;
  final VoidCallback onRemove;
  final bool isDark;
  final int index;

  const _ImageDescriptionEditor({
    required this.imagePath,
    required this.controller,
    required this.onRemove,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: isDark
                              ? AppColors.darkCardAlt
                              : AppColors.lightCardAlt,
                          child: const Icon(Icons.image_not_supported_rounded),
                        ),
                      )
                    : Image.file(
                        File(imagePath),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: isDark
                              ? AppColors.darkCardAlt
                              : AppColors.lightCardAlt,
                          child: const Icon(Icons.image_not_supported_rounded),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Image ${index + 1}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: GoogleFonts.poppins(fontSize: 12),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkCardAlt
                  : AppColors.lightCardAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ],
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
          style: GoogleFonts.poppins(fontSize: 13),
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
