import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:market_mind/models/brand_model.dart';

class BrandService {
  static const String _boxName = 'brands';
  late Box<BrandModel> _brandsBox;

  /// Initialize the service and open Hive box
  Future<void> init() async {
    _brandsBox = await Hive.openBox<BrandModel>(_boxName);
  }

  /// Get all brands from local storage
  Future<List<BrandModel>> getAllBrands() async {
    try {
      return _brandsBox.values.toList();
    } catch (e) {
      print('Error fetching brands: $e');
      return [];
    }
  }

  /// Get a single brand by ID
  Future<BrandModel?> getBrandById(String id) async {
    try {
      return _brandsBox.values.cast<BrandModel?>().firstWhere(
        (brand) => brand?.id == id,
      );
    } catch (e) {
      print('Error fetching brand: $e');
      return null;
    }
  }

  /// Create a new brand
  Future<BrandModel> createBrand({
    required String name,
    required String imagePath,
    String? description,
    String? targetAudience,
    String? category,
  }) async {
    try {
      final id = const Uuid().v4();
      final brand = BrandModel(
        id: id,
        name: name,
        imagePath: imagePath,
        description: description,
        targetAudience: targetAudience,
        category: category,
        productions: 0,
      );

      await _brandsBox.put(id, brand);
      print('Brand created successfully: $id');
      return brand;
    } catch (e) {
      print('Error creating brand: $e');
      rethrow;
    }
  }

  /// Update an existing brand
  Future<BrandModel> updateBrand({
    required String id,
    String? name,
    String? imagePath,
    String? description,
    String? targetAudience,
    String? category,
    int? productions,
  }) async {
    try {
      final brand = _brandsBox.get(id);
      if (brand == null) throw Exception('Brand not found');

      final updatedBrand = brand.copyWith(
        name: name,
        imagePath: imagePath,
        description: description,
        targetAudience: targetAudience,
        category: category,
        productions: productions,
        updatedAt: DateTime.now(),
      );

      await _brandsBox.put(id, updatedBrand);
      print('Brand updated successfully: $id');
      return updatedBrand;
    } catch (e) {
      print('Error updating brand: $e');
      rethrow;
    }
  }

  /// Delete a brand by ID
  Future<void> deleteBrand(String id) async {
    try {
      await _brandsBox.delete(id);
      print('Brand deleted successfully: $id');
    } catch (e) {
      print('Error deleting brand: $e');
      rethrow;
    }
  }

  /// Search brands by name
  Future<List<BrandModel>> searchBrands(String query) async {
    try {
      return _brandsBox.values
          .where(
            (brand) =>
                brand.name.toLowerCase().contains(query.toLowerCase()) ||
                (brand.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      print('Error searching brands: $e');
      return [];
    }
  }

  /// Get total number of brands
  Future<int> getBrandCount() async {
    try {
      return _brandsBox.length;
    } catch (e) {
      print('Error getting brand count: $e');
      return 0;
    }
  }

  /// Clear all brands (for testing)
  Future<void> clearAllBrands() async {
    try {
      await _brandsBox.clear();
      print('All brands cleared');
    } catch (e) {
      print('Error clearing brands: $e');
      rethrow;
    }
  }

  /// Sync brands with backend (placeholder for future API integration)
  /// This will be called when you implement backend API
  Future<void> syncWithBackend(
    Future<Map<String, dynamic>> Function(BrandModel) submitBrand,
  ) async {
    try {
      final brands = await getAllBrands();
      for (final brand in brands) {
        // Submit each brand to backend
        final response = await submitBrand(brand);
        if (response['success'] == true) {
          // Update brand with backend ID if needed
          final backendId = response['id'];
          if (backendId != null) {
            await updateBrand(id: brand.id);
          }
        }
      }
      print('Brands synced with backend successfully');
    } catch (e) {
      print('Error syncing with backend: $e');
      rethrow;
    }
  }
}

/// Singleton instance
final brandService = BrandService();
