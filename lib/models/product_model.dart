// ─── Poster Config ────────────────────────────────────────────────
class PosterConfig {
  final String aspectRatio;
  final String resolution;
  final String outputFormat;
  final String? style;
  final String? overlayText;
  final String? aiModelId;
  final String? modelExpression;
  final String? modelPose;

  const PosterConfig({
    this.aspectRatio = 'auto',
    this.resolution = '1K',
    this.outputFormat = 'png',
    this.style,
    this.overlayText,
    this.aiModelId,
    this.modelExpression,
    this.modelPose,
  });

  factory PosterConfig.fromJson(Map<String, dynamic> json) {
    return PosterConfig(
      aspectRatio: json['aspectRatio']?.toString() ?? 'auto',
      resolution: json['resolution']?.toString() ?? '1K',
      outputFormat: json['outputFormat']?.toString() ?? 'png',
      style: json['style']?.toString(),
      overlayText: json['overlayText']?.toString(),
      aiModelId: json['aiModelId']?.toString(),
      modelExpression: json['modelExpression']?.toString(),
      modelPose: json['modelPose']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspectRatio': aspectRatio,
      'resolution': resolution,
      'outputFormat': outputFormat,
      if (style != null) 'style': style,
      if (overlayText != null) 'overlayText': overlayText,
      if (aiModelId != null) 'aiModelId': aiModelId,
      if (modelExpression != null) 'modelExpression': modelExpression,
      if (modelPose != null) 'modelPose': modelPose,
    };
  }
}

// ─── Poster Job ───────────────────────────────────────────────────
class PosterJob {
  final String id;
  final String status; // pending, requires_approval, processing, completed, failed
  final PosterConfig? config;
  final String? taskId;
  final String? resultUrl;
  final DateTime createdAt;
  final String? error;

  const PosterJob({
    required this.id,
    required this.status,
    this.config,
    this.taskId,
    this.resultUrl,
    required this.createdAt,
    this.error,
  });

  factory PosterJob.fromJson(Map<String, dynamic> json) {
    return PosterJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      config: json['config'] != null
          ? PosterConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      taskId: json['taskId']?.toString(),
      resultUrl: json['resultUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      error: json['error']?.toString(),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      if (config != null) 'config': config!.toJson(),
      if (taskId != null) 'taskId': taskId,
      if (resultUrl != null) 'resultUrl': resultUrl,
      'createdAt': createdAt.toIso8601String(),
      if (error != null) 'error': error,
    };
  }
}

// ─── Video Config ─────────────────────────────────────────────────
class VideoConfig {
  final String tone;
  final String? aiModelId;
  final String aspectRatio;
  final String duration;
  final String userPrompt;

  const VideoConfig({
    required this.tone,
    this.aiModelId,
    required this.aspectRatio,
    required this.duration,
    required this.userPrompt,
  });

  factory VideoConfig.fromJson(Map<String, dynamic> json) {
    return VideoConfig(
      tone: json['tone']?.toString() ?? 'professional',
      aiModelId: json['aiModelId']?.toString(),
      aspectRatio: json['aspectRatio']?.toString() ?? 'mobile',
      duration: json['duration']?.toString() ?? '10s',
      userPrompt: json['userPrompt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      if (aiModelId != null) 'aiModelId': aiModelId,
      'aspectRatio': aspectRatio,
      'duration': duration,
      'userPrompt': userPrompt,
    };
  }
}

// ─── Video Scene ──────────────────────────────────────────────────
class VideoScene {
  final String id;
  final String prompt;
  final String description;
  final String? videoUrl;
  final String status;
  final int order;
  final int durationSeconds;

  const VideoScene({
    required this.id,
    required this.prompt,
    required this.description,
    this.videoUrl,
    required this.status,
    required this.order,
    this.durationSeconds = 3,
  });

  factory VideoScene.fromJson(Map<String, dynamic> json) {
    return VideoScene(
      id: json['id']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      order: json['order'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'description': description,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'status': status,
      'order': order,
      'durationSeconds': durationSeconds,
    };
  }
}

// ─── Video Job ────────────────────────────────────────────────────
class VideoJob {
  final String id;
  final String status;
  final VideoConfig? config;
  final List<VideoScene> scenes;
  final String? taskId;
  final String? finalVideoUrl;
  final DateTime createdAt;
  final String? error;

  const VideoJob({
    required this.id,
    required this.status,
    this.config,
    this.scenes = const [],
    this.taskId,
    this.finalVideoUrl,
    required this.createdAt,
    this.error,
  });

  factory VideoJob.fromJson(Map<String, dynamic> json) {
    return VideoJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      config: json['config'] != null
          ? VideoConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((e) => VideoScene.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      taskId: json['taskId']?.toString(),
      finalVideoUrl: json['finalVideoUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      error: json['error']?.toString(),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';
  bool get requiresApproval => status == 'requires_approval';
}

class StudioImageConfig {
  final String? lighting;
  final String? backgroundPrompt;
  final String? cameraAngle;

  const StudioImageConfig({
    this.lighting,
    this.backgroundPrompt,
    this.cameraAngle,
  });

  factory StudioImageConfig.fromJson(Map<String, dynamic> json) {
    return StudioImageConfig(
      lighting: json['lighting']?.toString(),
      backgroundPrompt: json['backgroundPrompt']?.toString(),
      cameraAngle: json['cameraAngle']?.toString(),
    );
  }
}

class StudioImageJob {
  final String id;
  final String? jobId;
  final String status;
  final StudioImageConfig? config;
  final List<String> outputs;
  final DateTime createdAt;
  final String? error;
  final String? taskId;

  const StudioImageJob({
    required this.id,
    this.jobId,
    required this.status,
    this.config,
    this.outputs = const [],
    required this.createdAt,
    this.error,
    this.taskId,
  });

  factory StudioImageJob.fromJson(Map<String, dynamic> json) {
    return StudioImageJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      config: json['config'] != null
          ? StudioImageConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      outputs: (json['outputs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      error: json['error']?.toString(),
      taskId: json['taskId']?.toString() ?? json['task_id']?.toString(),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';
}

// ─── Product Model ────────────────────────────────────────────────
class ProductModel {
  final String id;
  final String brandId;
  final String name;
  final String description;
  final List<String> images;
  final List<PosterJob> posters;
  final List<VideoJob> videos;
  final List<StudioImageJob> studioImages;
  /// Raw studio image URLs stored directly on the product document
  /// (pushed via /studio/select endpoint as plain strings).
  final List<String> studioImageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.description = '',
    required this.images,
    this.posters = const [],
    this.videos = const [],
    this.studioImages = const [],
    this.studioImageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // The backend stores studio images as a flat list of URL strings
    // (pushed via `$push: {studioImages: url}`). Parse accordingly —
    // if elements are Strings treat as URL list, if Maps try StudioImageJob.
    final rawStudio = (json['studioImages'] ??
            json['studio_images'] ??
            json['studioJobs'] ??
            json['studio_jobs']) as List<dynamic>?;

    final List<String> studioUrls = [];
    final List<StudioImageJob> studioJobs = [];

    for (final e in rawStudio ?? []) {
      if (e is String) {
        studioUrls.add(e);
      } else if (e is Map<String, dynamic>) {
        try { studioJobs.add(StudioImageJob.fromJson(e)); } catch (_) {}
      }
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      brandId: json['brandId']?.toString() ?? json['brand_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      posters: (json['posters'] as List<dynamic>?)
              ?.map((e) => PosterJob.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => VideoJob.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studioImages: studioJobs,
      studioImageUrls: studioUrls,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'images': images,
      'brandId': brandId,
    };
  }

  /// Quick helpers
  bool get hasPosters => posters.isNotEmpty;
  bool get hasVideos => videos.isNotEmpty;
  /// True if there are AI Studio images — either raw URLs or full job objects.
  bool get hasStudioImages => studioImageUrls.isNotEmpty || studioImages.isNotEmpty;
  PosterJob? get latestPoster => posters.isNotEmpty ? posters.last : null;
  VideoJob? get latestVideo => videos.isNotEmpty ? videos.last : null;
  StudioImageJob? get latestStudioImage =>
      studioImages.isNotEmpty ? studioImages.last : null;

  /// All studio output URLs: raw URL list + any URLs from StudioImageJob outputs.
  List<String> get allStudioImageUrls {
    final urls = List<String>.from(studioImageUrls);
    for (final job in studioImages) {
      urls.addAll(job.outputs);
    }
    return urls;
  }

  /// For backward compat with existing UI that reads imagePaths
  List<String> get imagePaths => images;

  ProductModel copyWith({
    String? name,
    String? description,
    List<String>? images,
    List<PosterJob>? posters,
    List<VideoJob>? videos,
    List<StudioImageJob>? studioImages,
    List<String>? studioImageUrls,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id,
      brandId: brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      posters: posters ?? this.posters,
      videos: videos ?? this.videos,
      studioImages: studioImages ?? this.studioImages,
      studioImageUrls: studioImageUrls ?? this.studioImageUrls,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
