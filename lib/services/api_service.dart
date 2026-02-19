/// API Service - Template for backend integration
///
/// This service will be used to sync local brands with your backend API.
/// Currently, all data is stored locally using Hive.
///
/// When you're ready to integrate with your backend:
/// 1. Implement the HTTP methods below using packages like `http` or `dio`
/// 2. Call these methods from BrandService.syncWithBackend()
/// 3. Handle authentication tokens and error responses
/// 4. Sync updated data back to local Hive storage

class APIService {
  // TODO: Add your API base URL here
  static const String baseUrl = 'https://your-api.com/api';

  /// Create a brand on the backend
  /// POST /brands
  ///
  /// Body:
  /// {
  ///   "name": "Brand Name",
  ///   "description": "Brand description",
  ///   "targetAudience": "Target audience",
  ///   "category": "Category",
  ///   "image": <multipart image file>
  /// }
  ///
  /// Returns: { "id": "backend_brand_id", "success": true }
  static Future<Map<String, dynamic>> createBrand({
    required String name,
    required String imagePath,
    String? description,
    String? targetAudience,
    String? category,
  }) async {
    // TODO: Implement HTTP POST request
    // Example structure:
    // var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/brands'));
    // request.fields['name'] = name;
    // request.fields['description'] = description ?? '';
    // request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    // var response = await request.send();
    // return jsonDecode(await response.stream.bytesToString());

    throw UnimplementedError('API integration not yet implemented');
  }

  /// Get all brands from backend
  /// GET /brands
  static Future<List<Map<String, dynamic>>> getBrands() async {
    // TODO: Implement HTTP GET request
    throw UnimplementedError('API integration not yet implemented');
  }

  /// Get a single brand by ID
  /// GET /brands/{id}
  static Future<Map<String, dynamic>> getBrandById(String id) async {
    // TODO: Implement HTTP GET request
    throw UnimplementedError('API integration not yet implemented');
  }

  /// Update a brand
  /// PUT /brands/{id}
  static Future<Map<String, dynamic>> updateBrand({
    required String id,
    required String name,
    String? imagePath,
    String? description,
    String? targetAudience,
    String? category,
  }) async {
    // TODO: Implement HTTP PUT request
    throw UnimplementedError('API integration not yet implemented');
  }

  /// Delete a brand
  /// DELETE /brands/{id}
  static Future<void> deleteBrand(String id) async {
    // TODO: Implement HTTP DELETE request
    throw UnimplementedError('API integration not yet implemented');
  }

  /// Search brands
  /// GET /brands/search?q=query
  static Future<List<Map<String, dynamic>>> searchBrands(String query) async {
    // TODO: Implement HTTP GET request with query parameter
    throw UnimplementedError('API integration not yet implemented');
  }
}
