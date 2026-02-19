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
    };
  }

  /// Create from JSON (for API responses)
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetAudience: json['targetAudience'] as String?,
      category: json['category'] as String?,
      imagePath: json['imagePath'] as String,
      productions: json['productions'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
    );
  }
}
