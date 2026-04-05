class AIHumanModel {
  final String id;
  final String name;
  final String gender;
  final String? ageRange;
  final String? ethnicity;
  final String avatar;
  final List<String> referenceImages;
  final List<String> poses;
  final List<String> expressions;
  final List<String> clothingStyles;
  final bool isActive;
  final bool isPremium;
  final DateTime? createdAt;

  const AIHumanModel({
    required this.id,
    required this.name,
    required this.gender,
    this.ageRange,
    this.ethnicity,
    required this.avatar,
    this.referenceImages = const [],
    this.poses = const [],
    this.expressions = const [],
    this.clothingStyles = const [],
    this.isActive = true,
    this.isPremium = false,
    this.createdAt,
  });

  factory AIHumanModel.fromJson(Map<String, dynamic> json) {
    return AIHumanModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      ageRange: json['age_range']?.toString(),
      ethnicity: json['ethnicity']?.toString(),
      avatar: json['avatar']?.toString() ?? '',
      referenceImages: (json['reference_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      poses: (json['poses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expressions: (json['expressions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      clothingStyles: (json['clothing_styles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class AIHumanModelCreate {
  final String name;
  final String gender;
  final String avatar;
  final List<String> referenceImages;
  final String? ageRange;
  final String? ethnicity;
  final List<String> poses;
  final List<String> expressions;
  final List<String> clothingStyles;
  final bool isActive;
  final bool isPremium;

  const AIHumanModelCreate({
    required this.name,
    required this.gender,
    required this.avatar,
    required this.referenceImages,
    this.ageRange,
    this.ethnicity,
    this.poses = const [],
    this.expressions = const [],
    this.clothingStyles = const [],
    this.isActive = true,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'avatar': avatar,
      'reference_images': referenceImages,
      if (ageRange != null && ageRange!.isNotEmpty) 'age_range': ageRange,
      if (ethnicity != null && ethnicity!.isNotEmpty) 'ethnicity': ethnicity,
      'poses': poses,
      'expressions': expressions,
      'clothing_styles': clothingStyles,
      'is_active': isActive,
      'is_premium': isPremium,
    };
  }
}

class SceneTemplate {
  final String id;
  final String name;
  final String category;
  final String backgroundPrompt;
  final String lightingSetup;
  final String? sampleImageUrl;
  final bool isActive;

  const SceneTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.backgroundPrompt,
    required this.lightingSetup,
    this.sampleImageUrl,
    required this.isActive,
  });

  factory SceneTemplate.fromJson(Map<String, dynamic> json) {
    return SceneTemplate(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      backgroundPrompt: json['backgroundPrompt']?.toString() ?? '',
      lightingSetup: json['lightingSetup']?.toString() ?? '',
      sampleImageUrl: json['sampleImageUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class StudioShotCreate {
  final String? modelId;
  final String? sceneId;
  final String? pose;
  final String? expression;
  final String? cameraAngle;
  final String? aspectRatio;
  final String? resolution;
  final String? outputFormat;
  final String? customPrompt;
  final int numImages;

  const StudioShotCreate({
    this.modelId,
    this.sceneId,
    this.pose,
    this.expression,
    this.cameraAngle,
    this.aspectRatio,
    this.resolution,
    this.outputFormat,
    this.customPrompt,
    this.numImages = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      if (modelId != null) 'model_id': modelId,
      if (sceneId != null) 'scene_id': sceneId,
      if (pose != null && pose!.isNotEmpty) 'pose': pose,
      if (expression != null && expression!.isNotEmpty) 'expression': expression,
      if (cameraAngle != null && cameraAngle!.isNotEmpty) 'camera_angle': cameraAngle,
      if (aspectRatio != null && aspectRatio!.isNotEmpty) 'aspect_ratio': aspectRatio,
      if (resolution != null && resolution!.isNotEmpty) 'resolution': resolution,
      if (outputFormat != null && outputFormat!.isNotEmpty) 'output_format': outputFormat,
      if (customPrompt != null && customPrompt!.isNotEmpty) 'custom_prompt': customPrompt,
      'num_images': numImages,
    };
  }
}

class StudioJobCreateRequest {
  final String productId;
  final List<StudioShotCreate> shots;

  const StudioJobCreateRequest({
    required this.productId,
    required this.shots,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'shots': shots.map((e) => e.toJson()).toList(),
    };
  }
}

class StudioJobCreateResponse {
  final String jobId;
  final String status;
  final String? taskId;

  const StudioJobCreateResponse({
    required this.jobId,
    required this.status,
    this.taskId,
  });

  factory StudioJobCreateResponse.fromJson(Map<String, dynamic> json) {
    return StudioJobCreateResponse(
      jobId: json['job_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      taskId: json['taskId']?.toString() ?? json['task_id']?.toString(),
    );
  }
}

class StudioShot {
  final String id;
  final String? modelId;
  final String? sceneId;
  final String status;
  final List<String> outputs;
  final String? error;
  final String? taskId;

  const StudioShot({
    required this.id,
    this.modelId,
    this.sceneId,
    required this.status,
    this.outputs = const [],
    this.error,
    this.taskId,
  });

  factory StudioShot.fromJson(Map<String, dynamic> json) {
    return StudioShot(
      id: json['id']?.toString() ?? '',
      modelId: json['model_id']?.toString(),
      sceneId: json['scene_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      outputs: (json['outputs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      error: json['error']?.toString(),
      taskId: json['taskId']?.toString() ?? json['task_id']?.toString(),
    );
  }
}

class StudioJob {
  final String id;
  final String productId;
  final String userId;
  final List<StudioShot> shots;
  final int totalRequestedImages;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudioJob({
    required this.id,
    required this.productId,
    required this.userId,
    this.shots = const [],
    required this.totalRequestedImages,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory StudioJob.fromJson(Map<String, dynamic> json) {
    return StudioJob(
      id: json['_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      shots: (json['shots'] as List<dynamic>?)
              ?.map((e) => StudioShot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalRequestedImages: json['total_requested_images'] as int? ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  List<String> get allOutputs =>
      shots.expand((shot) => shot.outputs).where((url) => url.isNotEmpty).toList();
}

class SelectStudioImageRequest {
  final String productId;
  final String imageUrl;

  const SelectStudioImageRequest({
    required this.productId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'image_url': imageUrl,
    };
  }
}

class StudioAppOptions {
  final List<String> poses;
  final List<String> expressions;
  final List<String> cameraAngles;
  final List<String> resolutions;
  final List<String> outputFormats;

  const StudioAppOptions({
    this.poses = const [],
    this.expressions = const [],
    this.cameraAngles = const [],
    this.resolutions = const [],
    this.outputFormats = const [],
  });

  factory StudioAppOptions.fromJson(Map<String, dynamic> json) {
    List<String> _extractList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      if (value is Map) {
        return value.values
            .expand((entry) => entry is List ? entry : const [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    final options = json['options'];
    final source = options is Map<String, dynamic> ? options : json;

    return StudioAppOptions(
      poses: _extractList(source['poses'] ?? source['poseOptions'] ?? source['model_poses']),
      expressions: _extractList(source['expressions'] ?? source['expressionOptions'] ?? source['model_expressions']),
      cameraAngles: _extractList(source['cameraAngles'] ?? source['camera_angles']),
      resolutions: _extractList(source['resolutions'] ?? source['studioResolutions']),
      outputFormats: _extractList(source['outputFormats'] ?? source['studioOutputFormats']),
    );
  }
}
