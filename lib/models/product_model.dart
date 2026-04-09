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

// ─── Grok Video Config ───────────────────────────────────────────
class GrokVideoConfig {
  final String aspectRatio;
  final String duration; // seconds, 6-30
  final String resolution; // 480p | 720p
  final String mode; // normal | fun | spicy

  const GrokVideoConfig({
    this.aspectRatio = '16:9',
    this.duration = '10',
    this.resolution = '480p',
    this.mode = 'normal',
  });

  factory GrokVideoConfig.fromJson(Map<String, dynamic> json) {
    return GrokVideoConfig(
      aspectRatio: json['aspectRatio']?.toString() ?? '16:9',
      duration: json['duration']?.toString() ?? '10',
      resolution: json['resolution']?.toString() ?? '480p',
      mode: json['mode']?.toString() ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() => {
        'aspectRatio': aspectRatio,
        'duration': duration,
        'resolution': resolution,
        'mode': mode,
      };
}

// ─── Grok Video Job ───────────────────────────────────────────────
class GrokVideoJob {
  final String id;
  final String status; // pending|generating_frames|frames_ready|processing|completed|failed
  final GrokVideoConfig? config;
  final String? startFrameUrl;
  final String? endFrameUrl;
  final String? taskId;
  final String? finalVideoUrl;
  final String? error;
  final DateTime createdAt;

  const GrokVideoJob({
    required this.id,
    required this.status,
    this.config,
    this.startFrameUrl,
    this.endFrameUrl,
    this.taskId,
    this.finalVideoUrl,
    this.error,
    required this.createdAt,
  });

  factory GrokVideoJob.fromJson(Map<String, dynamic> json) {
    final rawConfig = json['config'];
    return GrokVideoJob(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      config: rawConfig is Map
          ? GrokVideoConfig.fromJson(Map<String, dynamic>.from(rawConfig))
          : null,
      startFrameUrl: json['startFrameUrl']?.toString() ?? json['start_frame_url']?.toString(),
      endFrameUrl: json['endFrameUrl']?.toString() ?? json['end_frame_url']?.toString(),
      taskId: json['taskId']?.toString() ?? json['task_id']?.toString(),
      finalVideoUrl: json['finalVideoUrl']?.toString() ?? json['final_video_url']?.toString(),
      error: json['error']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
    );
  }

  bool get isPending => status == 'pending';
  bool get isGeneratingFrames => status == 'generating_frames';
  bool get isFramesReady => status == 'frames_ready';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isInProgress =>
      isPending || isGeneratingFrames || isFramesReady || isProcessing;

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Queued';
      case 'generating_frames': return 'Generating Frames...';
      case 'frames_ready': return 'Creating Video...';
      case 'processing': return 'Processing Video...';
      case 'completed': return 'Completed';
      case 'failed': return 'Failed';
      default: return status;
    }
  }
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
  final List<GrokVideoJob> grokVideoJobs;
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
    this.grokVideoJobs = const [],
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
      grokVideoJobs: (() {
        final raw = json['grokVideoJobs'] ?? json['grok_video_jobs'];
        if (raw is! List) return <GrokVideoJob>[];
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => GrokVideoJob.fromJson(e))
            .toList();
      })(),
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
  bool get hasVideos => videos.isNotEmpty || grokVideoJobs.isNotEmpty;
  bool get hasGrokVideos => grokVideoJobs.isNotEmpty;
  /// True if there are AI Studio images — either raw URLs or full job objects.
  bool get hasStudioImages => studioImageUrls.isNotEmpty || studioImages.isNotEmpty;
  PosterJob? get latestPoster => posters.isNotEmpty ? posters.last : null;
  VideoJob? get latestVideo => videos.isNotEmpty ? videos.last : null;
  StudioImageJob? get latestStudioImage =>
      studioImages.isNotEmpty ? studioImages.last : null;
  GrokVideoJob? get latestGrokVideo =>
      grokVideoJobs.isNotEmpty ? grokVideoJobs.last : null;
  bool get hasActiveGrokJob =>
      grokVideoJobs.any((j) => j.isInProgress);

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
    List<GrokVideoJob>? grokVideoJobs,
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
      grokVideoJobs: grokVideoJobs ?? this.grokVideoJobs,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
