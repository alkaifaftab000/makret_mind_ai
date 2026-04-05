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

  @HiveField(9)
  late String? tagline;

  @HiveField(10)
  late String? websiteUrl;

  @HiveField(11)
  late String? brandVoice;

  @HiveField(12)
  late String? colorPrimary;

  @HiveField(13)
  late String? colorSecondary;

  @HiveField(14)
  late String? colorAccent;

  @HiveField(15)
  late String? instagram;

  @HiveField(16)
  late String? tiktok;

  @HiveField(17)
  late String? facebook;

  @HiveField(18)
  late String? twitter;

  @HiveField(19)
  late String? youtube;

  BrandModel({
    required this.id,
    required this.name,
    this.description,
    this.targetAudience,
    this.category,
    required this.imagePath,
    this.productions = 0,
    this.tagline,
    this.websiteUrl,
    this.brandVoice,
    this.colorPrimary,
    this.colorSecondary,
    this.colorAccent,
    this.instagram,
    this.tiktok,
    this.facebook,
    this.twitter,
    this.youtube,
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
      'tagline': tagline,
      'website_url': websiteUrl,
      'brand_voice': brandVoice,
      'target_audience': targetAudience != null && targetAudience!.isNotEmpty
          ? targetAudience!.split(', ')
          : [],
      'category': category != null && category!.isNotEmpty
          ? category!.split(', ')
          : [],
      'logo': imagePath,
      if (colorPrimary != null || colorSecondary != null || colorAccent != null)
        'color_palette': {
          if (colorPrimary != null) 'primary': colorPrimary,
          if (colorSecondary != null) 'secondary': colorSecondary,
          if (colorAccent != null) 'accent': colorAccent,
        },
      if (instagram != null || tiktok != null || facebook != null || twitter != null || youtube != null)
        'social_links': {
          if (instagram != null) 'instagram': instagram,
          if (tiktok != null) 'tiktok': tiktok,
          if (facebook != null) 'facebook': facebook,
          if (twitter != null) 'twitter': twitter,
          if (youtube != null) 'youtube': youtube,
        },
      'productions': productions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (for API responses)
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final colorPalette = json['color_palette'] as Map<String, dynamic>?;
    final socialLinks = json['social_links'] as Map<String, dynamic>?;
    return BrandModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      tagline: json['tagline']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      brandVoice: json['brand_voice']?.toString(),
      targetAudience: _parseListField(json['target_audience'] ?? json['targetAudience']),
      category: _parseListField(json['category']),
      imagePath: json['logo']?.toString() ?? json['imagePath']?.toString() ?? '',
      productions: json['product_count'] as int? ?? json['productions'] as int? ?? 0,
      colorPrimary: colorPalette?['primary']?.toString(),
      colorSecondary: colorPalette?['secondary']?.toString(),
      colorAccent: colorPalette?['accent']?.toString(),
      instagram: socialLinks?['instagram']?.toString(),
      tiktok: socialLinks?['tiktok']?.toString(),
      facebook: socialLinks?['facebook']?.toString(),
      twitter: socialLinks?['twitter']?.toString(),
      youtube: socialLinks?['youtube']?.toString(),
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
    String? tagline,
    String? websiteUrl,
    String? brandVoice,
    String? colorPrimary,
    String? colorSecondary,
    String? colorAccent,
    String? instagram,
    String? tiktok,
    String? facebook,
    String? twitter,
    String? youtube,
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
      tagline: tagline ?? this.tagline,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      brandVoice: brandVoice ?? this.brandVoice,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorSecondary: colorSecondary ?? this.colorSecondary,
      colorAccent: colorAccent ?? this.colorAccent,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      facebook: facebook ?? this.facebook,
      twitter: twitter ?? this.twitter,
      youtube: youtube ?? this.youtube,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
