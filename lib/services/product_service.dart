import 'package:dio/dio.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/services/auth_service.dart';

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
    // We use /api/products/with-images to upload actual files
    final formData = FormData.fromMap({
      'name': name,
      'brandId': brandId, // API needs brandId
      'tone': tone,
      'aiModel': modelType, // API needs aiModel
      'aspectRatio': customAspectRatio ?? aspectRatio, // API needs aspectRatio
      'duration': videoLength ?? 'short', // API needs duration
      'userPrompt': prompt, // API needs userPrompt
      'type': type,
    });

    for (var path in imagePaths) {
      if (!path.startsWith('http')) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(path)),
        );
      }
    }

    try {
      final response = await _dio.post(
        '/api/products/with-images',
        data: formData,
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
      final response = await _dio.patch(
        '/api/products/${product.id}',
        data: {
          'name': name,
          'config': {
            'tone': tone,
            'aiModel': modelType,
            'aspectRatio': customAspectRatio ?? aspectRatio,
            'duration': videoLength,
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
