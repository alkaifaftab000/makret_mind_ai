class ProductScene {
  final String id;
  final String imageUrl;
  final String? description;
  final String? videoUrl;
  final String status;
  final int order;
  final int durationSeconds;

  const ProductScene({
    required this.id,
    required this.imageUrl,
    this.description,
    this.videoUrl,
    required this.status,
    required this.order,
    required this.durationSeconds,
  });

  factory ProductScene.fromJson(Map<String, dynamic> json) {
    return ProductScene(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      order: json['order'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'videoUrl': videoUrl,
      'status': status,
      'order': order,
      'durationSeconds': durationSeconds,
    };
  }
}

class ProductModel {
  final String id;
  final String brandId;
  final String name;
  final List<String> imagePaths; // API uses 'images'
  
  // Config fields
  final String tone;
  final String modelType; // API uses 'aiModel'
  final String aspectRatio;
  final String videoLength; // API uses 'duration'
  final String prompt; // API uses 'userPrompt'

  // Backend generated fields
  final String status;
  final List<ProductScene> scenes;
  final String? finalVideoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // We map 'type' and 'audioType' which might be local-only or derived
  final String type; // poster or video (derive from videoLength/scenes etc or keep local default)
  final String audioType; // local UI field for now

  // Add customAspectRatio for backwards comp.
  final String? customAspectRatio;

  const ProductModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.imagePaths,
    required this.tone,
    required this.modelType,
    required this.aspectRatio,
    required this.videoLength,
    required this.prompt,
    required this.status,
    required this.scenes,
    this.finalVideoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.type = 'video', // default for backward compat
    this.audioType = 'none', // default
    this.customAspectRatio,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> config = json['config'] as Map<String, dynamic>? ?? {};
    
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      brandId: json['brandId']?.toString() ?? json['brand_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imagePaths: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      
      // Parse Config
      tone: config['tone']?.toString() ?? 'professional',
      modelType: config['aiModel']?.toString() ?? 'standard',
      aspectRatio: config['aspectRatio']?.toString() ?? 'mobile',
      videoLength: config['duration']?.toString() ?? 'short',
      prompt: config['userPrompt']?.toString() ?? '',
      
      // Top level states
      status: json['status']?.toString() ?? 'draft',
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((e) => ProductScene.fromJson(e as Map<String, dynamic>))
              .toList() ?? 
          [],
      finalVideoUrl: json['finalVideoUrl']?.toString(),
      
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now()),
      
      // Backward Compat mappings (optional logic)
      type: json['finalVideoUrl'] != null || (json['scenes']?.isNotEmpty ?? false) ? 'video' : 'poster',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': imagePaths,
      'config': {
        'tone': tone,
        'aiModel': modelType,
        'aspectRatio': aspectRatio,
        'duration': videoLength,
        'userPrompt': prompt,
      },
      'brandId': brandId,
      'status': status,
      'scenes': scenes.map((s) => s.toJson()).toList(),
      if (finalVideoUrl != null) 'finalVideoUrl': finalVideoUrl,
    };
  }

  ProductModel copyWith({
    String? name,
    List<String>? imagePaths,
    String? tone,
    String? modelType,
    String? aspectRatio,
    String? videoLength,
    String? prompt,
    String? status,
    List<ProductScene>? scenes,
    String? finalVideoUrl,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id,
      brandId: brandId,
      name: name ?? this.name,
      imagePaths: imagePaths ?? this.imagePaths,
      tone: tone ?? this.tone,
      modelType: modelType ?? this.modelType,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      videoLength: videoLength ?? this.videoLength,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      scenes: scenes ?? this.scenes,
      finalVideoUrl: finalVideoUrl ?? this.finalVideoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type,
      audioType: audioType,
      customAspectRatio: customAspectRatio,
    );
  }
}
