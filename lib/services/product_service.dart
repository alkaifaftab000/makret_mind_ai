import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/services/cloudinary_service.dart';

class ProductService {
  final Dio _dio = authService.dioClient;
  final Logger _logger = Logger(printer: PrettyPrinter());

  Future<void> init() async {}

  // ─── Product CRUD ──────────────────────────────────────────────

  /// Get all products for a brand
  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    try {
      _logger.i('Fetching products for brand: $brandId');
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
      _logger.e('Error fetching products: $e');
      return [];
    }
  }

  /// Get all products
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
    } catch (e) { print("ERROR PARSING: $e"); 
      return [];
    }
  }

  /// Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _dio.get('/api/products/$productId');
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }
      return null;
    } catch (e) { print("ERROR PARSING: $e"); 
      return null;
    }
  }

  /// Create a product (simple: name + images + brandId)
  /// Images are uploaded to Cloudinary first, then URLs sent to API
  Future<ProductModel> createProduct({
    required String brandId,
    required String name,
    required List<String> imagePaths,
    String description = '',
  }) async {
    _logger.i('Creating product "$name" for brand $brandId');

    // 1. Upload local images to Cloudinary
    final localFiles = imagePaths
        .where((path) => !path.startsWith('http'))
        .map((path) => File(path))
        .toList();

    List<String> uploadedUrls = [];
    if (localFiles.isNotEmpty) {
      _logger.i('Uploading ${localFiles.length} images to Cloudinary...');
      uploadedUrls = await cloudinaryService.uploadMultipleImages(
        localFiles,
        folder: 'products',
      );
    }

    // Combine existing network URLs with newly uploaded ones
    final finalImageUrls = [
      ...imagePaths.where((path) => path.startsWith('http')),
      ...uploadedUrls,
    ];

    if (finalImageUrls.length < 2) {
      throw Exception('At least 2 images are required. Got ${finalImageUrls.length}');
    }

    // 2. Create product via API
    final payload = {
      'name': name,
      'description': description,
      'images': finalImageUrls,
      'brandId': brandId,
    };

    try {
      final response = await _dio.post('/api/products', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Product created successfully');
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to create product: ${response.statusCode}');
    } catch (e) {
      _logger.e('Error creating product: $e');
      if (e is DioException) {
        _logger.e('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      _logger.w('Deleting product: $productId');
      await _dio.delete('/api/products/$productId');
    } catch (e) {
      _logger.e('Error deleting product: $e');
      rethrow;
    }
  }

  /// Get product count for a brand
  Future<int> getProductCountByBrand(String brandId) async {
    final items = await getProductsByBrand(brandId);
    return items.length;
  }

  // ─── Poster Jobs ───────────────────────────────────────────────

  /// Create a poster job for a product
  /// POST /api/products/{product_id}/posters
  Future<ProductModel> createPosterJob({
    required String productId,
    PosterConfig config = const PosterConfig(),
  }) async {
    try {
      final payload = config.toJson();
      _logger.i('Creating poster job for product: $productId');
      _logger.i('Poster config payload: $payload');
      
      // Log auth header to verify token is attached
      final token = _dio.options.headers['Authorization'];
      _logger.i('Auth header present: ${token != null}');
      
      final response = await _dio.post(
        '/api/products/$productId/posters',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Poster job created successfully');
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to create poster job: ${response.statusCode}');
    } catch (e) {
      _logger.e('Error creating poster job: $e');
      if (e is DioException) {
        _logger.e('Response status: ${e.response?.statusCode}');
        _logger.e('Response body: ${e.response?.data}');
        _logger.e('Request URL: ${e.requestOptions.uri}');
        _logger.e('Request headers: ${e.requestOptions.headers}');
        _logger.e('Request data: ${e.requestOptions.data}');
      }
      rethrow;
    }
  }

  // ─── Video Jobs ────────────────────────────────────────────────

  /// Create a video job for a product
  /// POST /api/products/{product_id}/videos
  Future<ProductModel> createVideoJob({
    required String productId,
    required VideoConfig config,
  }) async {
    try {
      _logger.i('Creating video job for product: $productId');
      final response = await _dio.post(
        '/api/products/$productId/videos',
        data: config.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Video job created successfully');
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to create video job: ${response.statusCode}');
    } catch (e) {
      _logger.e('Error creating video job: $e');
      if (e is DioException) {
        _logger.e('Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Approve a video job's scenes
  /// POST /api/products/{product_id}/videos/{job_id}/approve
  Future<ProductModel> approveVideoJob({
    required String productId,
    required String jobId,
    List<VideoScene>? approvedScenes,
  }) async {
    try {
      _logger.i('Approving video job: $jobId');
      final response = await _dio.post(
        '/api/products/$productId/videos/$jobId/approve',
        data: approvedScenes?.map((s) => s.toJson()).toList(),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to approve video job');
    } catch (e) {
      _logger.e('Error approving video job: $e');
      rethrow;
    }
  }

  // ─── Product Update / Patch ──────────────────────────────────────

  /// PATCH a product (partial update)
  /// PATCH /api/products/{product_id}
  Future<ProductModel> patchProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.i('Patching product: $productId with data: ${data.keys}');
      final response = await _dio.patch(
        '/api/products/$productId',
        data: data,
      );

      if (response.statusCode == 200) {
        _logger.i('Product patched successfully');
        return ProductModel.fromJson(response.data);
      }
      throw Exception('Failed to patch product: ${response.statusCode}');
    } catch (e) {
      _logger.e('Error patching product: $e');
      if (e is DioException) {
        _logger.e('Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Update a specific poster's result in the backend DB.
  /// Sends the updated poster array via PATCH.
  Future<ProductModel> updatePosterResult({
    required String productId,
    required String posterId,
    required String status,
    required String resultUrl,
  }) async {
    try {
      // Fetch current product to get the full posters array
      final product = await getProductById(productId);
      if (product == null) throw Exception('Product not found');

      // Update the specific poster in the array
      final updatedPosters = product.posters.map((p) {
        if (p.id == posterId) {
          return PosterJob(
            id: p.id,
            status: status,
            config: p.config,
            taskId: p.taskId,
            resultUrl: resultUrl,
            createdAt: p.createdAt,
          );
        }
        return p;
      }).toList();

      // PATCH the product with the updated posters array
      return await patchProduct(
        productId: productId,
        data: {
          'posters': updatedPosters.map((p) => p.toJson()).toList(),
        },
      );
    } catch (e) {
      _logger.e('Error updating poster result: $e');
      rethrow;
    }
  }
}

final productService = ProductService();
