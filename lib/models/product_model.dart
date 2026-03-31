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

class VideoJob {
  final String id;
  final String status;
  final String? finalVideoUrl;
  final DateTime createdAt;
  final List<ProductScene> scenes;

  const VideoJob({
    required this.id,
    required this.status,
    this.finalVideoUrl,
    required this.createdAt,
    required this.scenes,
  });

  factory VideoJob.fromJson(Map<String, dynamic> json) {
    final rawScenes = json['scenes'] as List<dynamic>?;
    return VideoJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      finalVideoUrl: json['finalVideoUrl']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now()),
      scenes: rawScenes?.map((e) => ProductScene.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'finalVideoUrl': finalVideoUrl,
      'createdAt': createdAt.toIso8601String(),
      'scenes': scenes.map((s) => s.toJson()).toList(),
    };
  }
}

class PosterJob {
  final String id;
  final String status;
  final String? resultUrl;
  final DateTime createdAt;

  const PosterJob({
    required this.id,
    required this.status,
    this.resultUrl,
    required this.createdAt,
  });

  factory PosterJob.fromJson(Map<String, dynamic> json) {
    return PosterJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      resultUrl: json['resultUrl']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'resultUrl': resultUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProductModel {
  final String id;
  final String brandId;
  final String name;
  final List<String> imagePaths;
  
  // Config fields
  final String tone;
  final String modelType;
  final String aspectRatio;
  final String videoLength;
  final String prompt;

  // Media jobs
  final List<VideoJob> videoJobs;
  final List<PosterJob> posterJobs;

  // Global state
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Backward comp
  final List<ProductScene> scenes;
  final String? finalVideoUrl;
  final String type;
  final String audioType;
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
    required this.videoJobs,
    required this.posterJobs,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.scenes = const [],
    this.finalVideoUrl,
    this.type = 'video',
    this.audioType = 'none',
    this.customAspectRatio,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> config = json['config'] as Map<String, dynamic>? ?? {};
    
    final List<dynamic> videosRaw = json['videos'] as List<dynamic>? ?? [];
    final List<dynamic> postersRaw = json['posters'] as List<dynamic>? ?? [];

    final List<VideoJob> parsedVideoJobs = videosRaw.map((v) => VideoJob.fromJson(v as Map<String, dynamic>)).toList();
    final List<PosterJob> parsedPosterJobs = postersRaw.map((p) => PosterJob.fromJson(p as Map<String, dynamic>)).toList();
    
    final Map<String, dynamic>? firstVideo = videosRaw.isNotEmpty ? videosRaw.first as Map<String, dynamic>? : null;
    
    final String? parsedFinalVideoUrl = firstVideo?['finalVideoUrl']?.toString() ?? json['finalVideoUrl']?.toString();
    final List<dynamic>? rawScenes = firstVideo?['scenes'] as List<dynamic>? ?? json['scenes'] as List<dynamic>?;
    
    final bool hasVideos = parsedVideoJobs.isNotEmpty || parsedFinalVideoUrl != null || (rawScenes?.isNotEmpty ?? false);

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      brandId: json['brandId']?.toString() ?? json['brand_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imagePaths: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      
      tone: config['tone']?.toString() ?? 'professional',
      modelType: config['aiModel']?.toString() ?? 'standard',
      aspectRatio: config['aspectRatio']?.toString() ?? 'mobile',
      videoLength: config['duration']?.toString() ?? 'short',
      prompt: config['userPrompt']?.toString() ?? '',
      
      videoJobs: parsedVideoJobs,
      posterJobs: parsedPosterJobs,

      status: json['status']?.toString() ?? 'draft',
      scenes: rawScenes?.map((e) => ProductScene.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      finalVideoUrl: parsedFinalVideoUrl,
      
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : DateTime.now()),
      
      type: hasVideos ? 'video' : 'poster',
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
      'videos': videoJobs.map((v) => v.toJson()).toList(),
      'posters': posterJobs.map((p) => p.toJson()).toList(),
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
    List<VideoJob>? videoJobs,
    List<PosterJob>? posterJobs,
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
      videoJobs: videoJobs ?? this.videoJobs,
      posterJobs: posterJobs ?? this.posterJobs,
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
