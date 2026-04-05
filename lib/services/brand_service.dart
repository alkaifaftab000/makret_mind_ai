import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/api_constants.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/auth_service.dart';
import 'package:market_mind/services/cloudinary_service.dart';

class BrandService {
  static final BrandService _instance = BrandService._internal();

  factory BrandService() {
    return _instance;
  }

  BrandService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());

  // Use the Dio instance from AuthService because it already handles injecting the token
  Dio get _dio => authService.dioClient;

  /// Get all brands (GET /api/brands)
  Future<List<BrandModel>> getAllBrands({int skip = 0, int limit = 100}) async {
    try {
      _logger.i('Fetching all brands...');
      final response = await _dio.get(
        ApiConstants.brands,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BrandModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load brands. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching brands: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Get a single brand by ID (GET /api/brands/{brand_id})
  Future<BrandModel?> getBrandById(String id) async {
    try {
      _logger.i('Fetching brand ID: $id');
      final response = await _dio.get('${ApiConstants.brands}/$id');
      
      if (response.statusCode == 200) {
        return BrandModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load brand. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching brand: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Get product count for a brand (GET /api/brands/{brand_id}/products-count)
  Future<int> getBrandProductCount(String id) async {
    try {
      _logger.i('Fetching product count for brand ID: $id');
      final response = await _dio.get('${ApiConstants.brands}/$id/products-count');
      
      if (response.statusCode == 200) {
        return response.data['product_count'] as int;
      }
      return 0;
    } catch (e) {
       _logger.e('Error fetching brand product count: $e');
       return 0; // Fallback to 0 if count fails, rather than crashing UI
    }
  }

  /// Create a new brand without file upload (POST /api/brands)
  Future<BrandModel> createBrand({
    required String name,
    String? logo,
    String? description,
    String? tagline,
    String? websiteUrl,
    String? brandVoice,
    List<String>? targetAudience,
    List<String>? category,
    Map<String, String?>? colorPalette,
    Map<String, String?>? socialLinks,
  }) async {
    try {
      _logger.i('Creating new brand...');
      
      final currentUserId = authService.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User is not authenticated. Please log in again.');
      }

      final data = {
        'name': name,
        'user_id': currentUserId,
        if (logo != null) 'logo': logo,
        if (description != null && description.isNotEmpty) 'description': description,
        if (tagline != null && tagline.isNotEmpty) 'tagline': tagline,
        if (websiteUrl != null && websiteUrl.isNotEmpty) 'website_url': websiteUrl,
        if (brandVoice != null && brandVoice.isNotEmpty) 'brand_voice': brandVoice,
        if (targetAudience != null && targetAudience.isNotEmpty)
          'target_audience': targetAudience,
        if (category != null && category.isNotEmpty)
          'category': category,
        if (colorPalette != null) 'color_palette': colorPalette,
        if (socialLinks != null) 'social_links': socialLinks,
      };

      final response = await _dio.post(
        ApiConstants.brands,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BrandModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create brand. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error creating brand: $e');
      if (e is DioException) {
        _logger.e('Dio Exception Data: ${e.response?.data}');
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Create a new brand with a logo upload (POST /api/brands) using Cloudinary
  Future<BrandModel> createBrandWithLogo({
    required String name,
    required File logoFile,
    String? description,
    String? tagline,
    String? websiteUrl,
    String? brandVoice,
    List<String>? targetAudience,
    List<String>? category,
    Map<String, String?>? colorPalette,
    Map<String, String?>? socialLinks,
  }) async {
    try {
      _logger.i('Uploading logo to Cloudinary...');
      
      final String? logoUrl = await cloudinaryService.uploadImage(logoFile, folder: 'brands');
      
      if (logoUrl == null) {
        throw Exception('Failed to get logo URL from Cloudinary');
      }

      _logger.i('Creating new brand with hosted logo URL...');
      
      return await createBrand(
        name: name,
        logo: logoUrl,
        description: description,
        tagline: tagline,
        websiteUrl: websiteUrl,
        brandVoice: brandVoice,
        targetAudience: targetAudience,
        category: category,
        colorPalette: colorPalette,
        socialLinks: socialLinks,
      );
    } catch (e) {
      _logger.e('Error creating brand with logo: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<BrandModel> updateBrand({
    required String id,
    required String name,
    required String logo,
    List<String>? targetAudience,
    List<String>? category,
  }) async {
    try {
      _logger.i('Updating brand ID: $id');
      final data = {
        'name': name,
        'logo': logo,
        if (targetAudience != null && targetAudience.isNotEmpty)
          'target_audience': targetAudience,
        if (category != null && category.isNotEmpty)
          'category': category,
      };

      final response = await _dio.put(
        '${ApiConstants.brands}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return BrandModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update brand. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating brand: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Patch specific fields of a brand (PATCH /api/brands/{brand_id})
  Future<BrandModel> patchBrand({
    required String id,
    String? name,
    String? logo,
    List<String>? targetAudience,
    List<String>? category,
  }) async {
    try {
      _logger.i('Patching brand ID: $id');
      
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (logo != null) data['logo'] = logo;
      if (targetAudience != null) data['target_audience'] = targetAudience;
      if (category != null) data['category'] = category;

      // Don't make empty updates Request
      if (data.isEmpty) throw Exception('No fields to patch');

      final response = await _dio.patch(
        '${ApiConstants.brands}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return BrandModel.fromJson(response.data);
      } else {
        throw Exception('Failed to patch brand. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error patching brand: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Delete a brand by ID (DELETE /api/brands/{brand_id})
  Future<void> deleteBrand(String id) async {
    try {
      _logger.w('Deleting brand ID: $id');
      final response = await _dio.delete('${ApiConstants.brands}/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete brand. Server returned ${response.statusCode}');
      }
      _logger.i('Brand deleted successfully');
    } catch (e) {
      _logger.e('Error deleting brand: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      if (statusCode == 422) {
        throw Exception('Validation error: Please check your input data.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Unauthorized. Your session may have expired.');
      } else if (statusCode == 404) {
        throw Exception('Brand not found.');
      } else if (statusCode! >= 500) {
        throw Exception('Internal server error. Please try again later.');
      } else {
        throw Exception('Server error: $responseData');
      }
    } else {
      throw Exception('Network error: Unable to connect to the server.');
    }
  }
}

/// Singleton instance
final brandService = BrandService();
