import 'package:hive/hive.dart';

part 'brand_model.g.dart';

@HiveType(typeId: 0)
class BrandModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String? description;

  @HiveField(3)
  late String? targetAudience;

  @HiveField(4)
  late String? category;

  @HiveField(5)
  late String imagePath; // Local file path to the image

  @HiveField(6)
  late int productions;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  final String? tagline;
  final String? websiteUrl;

  BrandModel({
    required this.id,
    required this.name,
    this.description,
    this.targetAudience,
    this.category,
    required this.imagePath,
    this.productions = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tagline,
    this.websiteUrl,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAudience': targetAudience,
      'category': category,
      'imagePath': imagePath,
      'productions': productions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tagline': tagline,
      'websiteUrl': websiteUrl,
    };
  }

  /// Create from JSON (for API responses)
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(), // Not standard in new API, but keep for local compatibility
      targetAudience: json['target_audience']?.toString() ?? json['targetAudience']?.toString(),
      category: json['category']?.toString(),
      imagePath: json['logo']?.toString() ?? json['imagePath']?.toString() ?? '', // API uses 'logo'
      productions: json['product_count'] as int? ?? json['productions'] as int? ?? 0, // API uses 'product_count'
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null),
      tagline: json['tagline']?.toString(),
      websiteUrl: json['website_url']?.toString() ?? json['websiteUrl']?.toString(),
    );
  }

  /// Copy with method for immutable updates
  BrandModel copyWith({
    String? id,
    String? name,
    String? description,
    String? targetAudience,
    String? category,
    String? imagePath,
    int? productions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tagline,
    String? websiteUrl,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAudience: targetAudience ?? this.targetAudience,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      productions: productions ?? this.productions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagline: tagline ?? this.tagline,
      websiteUrl: websiteUrl ?? this.websiteUrl,
    );
  }
}
