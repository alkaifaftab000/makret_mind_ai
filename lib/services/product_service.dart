import 'package:hive_flutter/hive_flutter.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  static const String _boxName = 'products';
  late Box _productsBox;

  Future<void> init() async {
    _productsBox = await Hive.openBox(_boxName);
  }

  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    try {
      return _productsBox.values
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .where((product) => product.brandId == brandId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<ProductModel> createProduct({
    required String brandId,
    required String name,
    required String type,
    required List<String> imagePaths,
    required String prompt,
    required String tone,
    required String modelType,
    required String audioType,
    required String aspectRatio,
    String? customAspectRatio,
    String? videoLength,
  }) async {
    final now = DateTime.now();
    final descriptions = List<String>.generate(
      imagePaths.length,
      (index) => _generateDescription(
        productType: type,
        prompt: prompt,
        imageIndex: index + 1,
      ),
    );

    final product = ProductModel(
      id: const Uuid().v4(),
      brandId: brandId,
      name: name,
      type: type,
      imagePaths: imagePaths,
      imageDescriptions: descriptions,
      prompt: prompt,
      tone: tone,
      modelType: modelType,
      audioType: audioType,
      aspectRatio: aspectRatio,
      customAspectRatio: customAspectRatio,
      videoLength: videoLength,
      createdAt: now,
      updatedAt: now,
    );

    await _productsBox.put(product.id, product.toJson());
    return product;
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final raw = _productsBox.get(productId);
      if (raw is! Map) return null;
      return ProductModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel> updateProductConfiguration({
    required ProductModel product,
    required String name,
    required List<String> imagePaths,
    required List<String> imageDescriptions,
    required String prompt,
    required String tone,
    required String modelType,
    required String audioType,
    required String aspectRatio,
    String? customAspectRatio,
    String? videoLength,
  }) async {
    final updated = product.copyWith(
      name: name,
      imagePaths: imagePaths,
      imageDescriptions: imageDescriptions,
      prompt: prompt,
      tone: tone,
      modelType: modelType,
      audioType: audioType,
      aspectRatio: aspectRatio,
      customAspectRatio: customAspectRatio,
      videoLength: videoLength,
      updatedAt: DateTime.now(),
    );

    await _productsBox.put(updated.id, updated.toJson());
    return updated;
  }

  Future<int> getProductCountByBrand(String brandId) async {
    final items = await getProductsByBrand(brandId);
    return items.length;
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      return _productsBox.values
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  String _generateDescription({
    required String productType,
    required String prompt,
    required int imageIndex,
  }) {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return 'Auto generated description for image $imageIndex';
    }
    return '${productType == 'video' ? 'Video frame' : 'Poster image'} $imageIndex generated from prompt: $trimmedPrompt';
  }
}

final productService = ProductService();
