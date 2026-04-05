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
      'target_audience': targetAudience != null && targetAudience!.isNotEmpty
          ? targetAudience!.split(', ')
          : [],
      'category': category != null && category!.isNotEmpty
          ? category!.split(', ')
          : [],
      'logo': imagePath,
      'productions': productions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (for API responses)
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      targetAudience: _parseListField(json['target_audience'] ?? json['targetAudience']),
      category: _parseListField(json['category']),
      imagePath: json['logo']?.toString() ?? json['imagePath']?.toString() ?? '',
      productions: json['product_count'] as int? ?? json['productions'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null),
    );
  }

  /// Parse a field that could be a List<String> or a String into a comma-separated String
  static String? _parseListField(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final items = value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      return items.isEmpty ? null : items.join(', ');
    }
    final str = value.toString();
    return str.isEmpty ? null : str;
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
