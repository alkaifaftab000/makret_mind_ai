import 'dart:io';

import 'package:dio/dio.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/services/cloudinary_service.dart';

class ProductService {
  final Dio _dio = authService.dioClient;

  Future<void> init() async {
    // No-op for Dio backend
  }

  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    try {
      final response = await _dio.get('/api/products/brand/$brandId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ProductModel> createProduct({
    required String brandId,
    required String name,
    required String type, // Will stay locally configured
    required List<String> imagePaths,
    required String prompt,
    required String tone,
    required String modelType,
    required String audioType,
    required String aspectRatio,
    String? customAspectRatio,
    String? videoLength,
  }) async {
    // 1. Upload all local images to Cloudinary first
    List<File> localFiles = imagePaths
        .where((path) => !path.startsWith('http'))
        .map((path) => File(path))
        .toList();

    List<String> uploadedUrls = [];
    if (localFiles.isNotEmpty) {
      uploadedUrls = await cloudinaryService.uploadMultipleImages(localFiles, folder: 'products');
    }

    // Combine any existing network URLs with the newly uploaded ones
    List<String> finalImageUrls = [
      ...imagePaths.where((path) => path.startsWith('http')),
      ...uploadedUrls,
    ];

    if (finalImageUrls.isEmpty) {
      throw Exception('Failed to upload images or no images provided');
    }

    // 2. Map UI values to Backend Enum values
    String mapTone(String t) {
      final tl = t.toLowerCase();
      if (tl.contains('professional')) return 'professional';
      if (tl.contains('playful')) return 'playful';
      if (tl.contains('emotional')) return 'emotional';
      if (tl.contains('dramatic')) return 'dramatic';
      return 'professional'; // default fallback
    }

    String mapAspectRatio(String r) {
      final rl = r.toLowerCase();
      if (rl.contains('mobile') || rl.contains('9:16')) return 'mobile';
      if (rl.contains('desktop') || rl.contains('16:9')) return 'desktop';
      return 'mobile'; // default fallback
    }

    String mapDuration(String d) {
      final dl = d.toLowerCase();
      if (dl.contains('15') || dl.contains('short')) return 'short';
      if (dl.contains('30') || dl.contains('medium')) return 'medium';
      if (dl.contains('60') || dl.contains('long')) return 'long';
      if (dl.contains('extra') || dl.contains('120')) return 'extraLong';
      return 'short'; // default fallback
    }

    String mapAiModel(String m) {
      final ml = m.toLowerCase();
      if (ml == 'no' || ml == 'none') return 'none';
      if (ml == 'male') return 'male';
      if (ml == 'female') return 'female';
      return 'none'; // default fallback
    }

    // Usually audio is somewhat decoupled, but if its backend enum let's do it similarly
    // Assuming backend takes male, female, or none for audio too if it's there
    String mapAudioType(String a) {
      final al = a.toLowerCase();
      if (al == 'no audio' || al == 'none') return 'none'; // Maybe 'none'
      if (al == 'male') return 'male';
      if (al == 'female') return 'female';
      return 'none';
    }

    final mappedTone = mapTone(tone);
    final mappedAspectRatio = mapAspectRatio(customAspectRatio ?? aspectRatio);
    final mappedDuration = mapDuration(videoLength ?? 'short');
    final mappedModel = mapAiModel(modelType);

    // 3. Post directly to /api/products with JSON data
    final Map<String, dynamic> payload = {
      'name': name,
      'brand_id': brandId, // API needs brand_id
      'images': finalImageUrls,
      'type': type,
      'config': {
        'tone': mappedTone,
        'aiModel': mappedModel, 
        'aspectRatio': mappedAspectRatio, 
        'duration': mappedDuration, 
        'userPrompt': prompt, 
      }
    };

    try {
      final response = await _dio.post(
        '/api/products',
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to create product');
    } catch (e) {
      if (e is DioException) {
        print('Dio Exception: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _dio.get('/api/products/$productId');
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel> updateProductConfiguration({
    required ProductModel product,
    required String name,
    required List<String> imagePaths,
    required String prompt,
    required String tone,
    required String modelType,
    required String audioType,
    required String aspectRatio,
    String? customAspectRatio,
    String? videoLength,
  }) async {
    try {
      String mapTone(String t) {
        final tl = t.toLowerCase();
        if (tl.contains('professional')) return 'professional';
        if (tl.contains('playful')) return 'playful';
        if (tl.contains('emotional')) return 'emotional';
        if (tl.contains('dramatic')) return 'dramatic';
        return 'professional'; 
      }

      String mapAspectRatio(String r) {
        final rl = r.toLowerCase();
        if (rl.contains('mobile') || rl.contains('9:16')) return 'mobile';
        if (rl.contains('desktop') || rl.contains('16:9')) return 'desktop';
        return 'mobile'; 
      }

      String mapDuration(String d) {
        final dl = d.toLowerCase();
        if (dl.contains('15') || dl.contains('short')) return 'short';
        if (dl.contains('30') || dl.contains('medium')) return 'medium';
        if (dl.contains('60') || dl.contains('long')) return 'long';
        if (dl.contains('extra') || dl.contains('120')) return 'extraLong';
        return 'short'; 
      }

      String mapAiModel(String m) {
        final ml = m.toLowerCase();
        if (ml == 'no' || ml == 'none') return 'none';
        if (ml == 'male') return 'male';
        if (ml == 'female') return 'female';
        return 'none'; 
      }

      final mappedTone = mapTone(tone);
      final mappedAspectRatio = mapAspectRatio(customAspectRatio ?? aspectRatio);
      final mappedDuration = mapDuration(videoLength ?? 'short');
      final mappedModel = mapAiModel(modelType);

      final response = await _dio.patch(
        '/api/products/${product.id}',
        data: {
          'name': name,
          'config': {
            'tone': mappedTone,
            'aiModel': mappedModel,
            'aspectRatio': mappedAspectRatio,
            'duration': mappedDuration,
            'userPrompt': prompt,
          },
        },
      );
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to update product');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getProductCountByBrand(String brandId) async {
    final items = await getProductsByBrand(brandId);
    return items.length;
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _dio.get('/api/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/api/products/$productId');
    } catch (e) {
      rethrow;
    }
  }
}

final productService = ProductService();
