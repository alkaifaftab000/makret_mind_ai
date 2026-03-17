import 'package:flutter/services.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/brand_service.dart';

class BrandDetailsActionService {
  Future<void> deleteBrand(String brandId) async {
    await brandService.deleteBrand(brandId);
  }

  Future<BrandModel> editBrand({
    required BrandModel brand,
    String? name,
    String? imagePath, // used as logo
    String? targetAudience,
    String? category,
  }) async {
    return brandService.patchBrand(
      id: brand.id,
      name: name,
      logo: imagePath,
      targetAudience: targetAudience,
      category: category,
    );
  }

  Future<void> shareBrand(BrandModel brand) async {
    final shareText = _buildShareText(brand);
    await Clipboard.setData(ClipboardData(text: shareText));
  }

  String _buildShareText(BrandModel brand) {
    final buffer = StringBuffer();
    buffer.writeln('Brand: ${brand.name}');
    if (brand.description != null && brand.description!.isNotEmpty) {
      buffer.writeln('Description: ${brand.description}');
    }
    if (brand.category != null && brand.category!.isNotEmpty) {
      buffer.writeln('Category: ${brand.category}');
    }
    if (brand.targetAudience != null && brand.targetAudience!.isNotEmpty) {
      buffer.writeln('Target Audience: ${brand.targetAudience}');
    }
    buffer.writeln('Productions: ${brand.productions}');
    return buffer.toString();
  }
}

final brandDetailsActionService = BrandDetailsActionService();
