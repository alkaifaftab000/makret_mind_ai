class ProductModel {
  final String id;
  final String brandId;
  final String name;
  final String type;
  final List<String> imagePaths;
  final List<String> imageDescriptions;
  final String prompt;
  final String tone;
  final String modelType;
  final String audioType;
  final String aspectRatio;
  final String? customAspectRatio;
  final String? videoLength;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.type,
    required this.imagePaths,
    required this.imageDescriptions,
    required this.prompt,
    required this.tone,
    required this.modelType,
    required this.audioType,
    required this.aspectRatio,
    this.customAspectRatio,
    this.videoLength,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final paths = (json['imagePaths'] as List<dynamic>).cast<String>();
    final rawDescriptions =
        (json['imageDescriptions'] as List<dynamic>?)?.cast<String>() ??
        <String>[];
    final descriptions = List<String>.generate(
      paths.length,
      (index) => index < rawDescriptions.length
          ? rawDescriptions[index]
          : 'Auto generated description for image ${index + 1}',
    );

    return ProductModel(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      imagePaths: paths,
      imageDescriptions: descriptions,
      prompt: json['prompt'] as String,
      tone: json['tone'] as String,
      modelType: json['modelType'] as String,
      audioType: json['audioType'] as String,
      aspectRatio: json['aspectRatio'] as String,
      customAspectRatio: json['customAspectRatio'] as String?,
      videoLength: json['videoLength'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandId': brandId,
      'name': name,
      'type': type,
      'imagePaths': imagePaths,
      'imageDescriptions': imageDescriptions,
      'prompt': prompt,
      'tone': tone,
      'modelType': modelType,
      'audioType': audioType,
      'aspectRatio': aspectRatio,
      'customAspectRatio': customAspectRatio,
      'videoLength': videoLength,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? name,
    String? type,
    List<String>? imagePaths,
    List<String>? imageDescriptions,
    String? prompt,
    String? tone,
    String? modelType,
    String? audioType,
    String? aspectRatio,
    String? customAspectRatio,
    String? videoLength,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id,
      brandId: brandId,
      name: name ?? this.name,
      type: type ?? this.type,
      imagePaths: imagePaths ?? this.imagePaths,
      imageDescriptions: imageDescriptions ?? this.imageDescriptions,
      prompt: prompt ?? this.prompt,
      tone: tone ?? this.tone,
      modelType: modelType ?? this.modelType,
      audioType: audioType ?? this.audioType,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      customAspectRatio: customAspectRatio ?? this.customAspectRatio,
      videoLength: videoLength ?? this.videoLength,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
