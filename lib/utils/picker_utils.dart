import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/brand_model.dart';
import '../models/product_model.dart';
import '../services/brand_service.dart';
import '../services/product_service.dart';
import '../utils/app_notification.dart';
import '../utils/image_utils.dart';
import '../screens/studio/studio_template_flow_screen.dart';

class PickerUtils {
  static Future<void> showBrandPickerThenNavigate(
    BuildContext context,
    String productType, {
    String? templateName,
    String? templateCategory,
    String? initialPrompt,
    String? initialAspectRatio,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show a loading indicator while fetching brands
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<BrandModel> brands = [];
    try {
      brands = await BrandService().getAllBrands();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        AppNotification.error(context, message: 'Failed to load brands');
      }
      return;
    }

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (brands.isEmpty) {
      AppNotification.warning(context, message: 'No brands available. Create one first.');
      return;
    }

    final brand = await showModalBottomSheet<BrandModel>(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Brand',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  productType == 'video'
                      ? 'Choose a brand to generate a video ad'
                      : (productType == 'studio'
                          ? 'Choose a brand to create a studio job for'
                          : 'Choose a brand to generate a poster'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: brands.length,
                  itemBuilder: (_, index) {
                    final b = brands[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => Navigator.pop(context, b),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: _buildBrandThumbnail(b),
                          ),
                        ),
                        title: Text(
                          b.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        subtitle: Text(
                          b.category ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (brand != null && context.mounted) {
      await showProductPickerForBrand(
        context,
        brand,
        productType,
        templateName: templateName,
        templateCategory: templateCategory,
        initialPrompt: initialPrompt,
        initialAspectRatio: initialAspectRatio,
      );
    }
  }

  static Future<void> showProductPickerForBrand(
    BuildContext context,
    BrandModel brand,
    String productType, {
    String? templateName,
    String? templateCategory,
    String? initialPrompt,
    String? initialAspectRatio,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<ProductModel> products = [];
    try {
      products = await ProductService().getProductsByBrand(brand.id);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        AppNotification.error(context, message: 'Failed to load products');
      }
      return;
    }

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (products.isEmpty) {
      AppNotification.warning(context, message: 'No products for this brand.');
      return;
    }

    final product = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Product',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  productType == 'video'
                      ? 'Choose a product to generate a video ad'
                      : (productType == 'studio'
                          ? 'Choose a product to generate a studio job'
                          : 'Choose a product to generate a poster'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => Navigator.pop(context, p),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: p.images.isNotEmpty && p.images.first.startsWith('http')
                                ? Image.network(
                                    p.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                                      child: const Icon(Icons.image_rounded, size: 20),
                                    ),
                                  )
                                : Container(
                                    color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                                    child: const Icon(Icons.image_rounded, size: 20),
                                  ),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        subtitle: Text(
                          '\${p.images.length} images',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        trailing: Icon(
                          productType == 'video'
                              ? Icons.videocam_rounded
                              : (productType == 'studio'
                                  ? Icons.auto_awesome_rounded
                                  : Icons.image_rounded),
                          size: 18,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (product != null && context.mounted) {
      if (productType == 'studio') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudioTemplateFlowScreen(
              product: product,
              templateName: templateName ?? 'Custom Studio Job',
              templateCategory: templateCategory ?? 'Custom',
              initialPrompt: initialPrompt ?? '',
              initialAspectRatio: initialAspectRatio ?? '1:1',
            ),
          ),
        );
      } else {
        // Fallback for missing references to poster/video configuration screens
      }
    }
  }

  static Widget _buildBrandThumbnail(BrandModel brand) {
    if (brand.imagePath.startsWith('http')) {
      return Image.network(
        brand.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbFallback(),
      );
    }
    final file = ImageUtils.loadImage(brand.imagePath);
    if (file != null && file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return _thumbFallback();
  }

  static Widget _thumbFallback() => Container(
        color: Colors.grey.shade300,
        child: Icon(
          Icons.storefront_rounded,
          color: Colors.grey.shade600,
          size: 22,
        ),
      );
}