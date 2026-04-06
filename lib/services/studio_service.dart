import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/api_constants.dart';
import 'package:market_mind/models/studio_model.dart';
import 'package:market_mind/services/auth_service.dart';

class StudioService {
  final Dio _dio = authService.dioClient;
  final Logger _logger = Logger(printer: PrettyPrinter());

  Future<List<AIHumanModel>> getStudioModels({
    bool includeInactive = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studioModels,
        queryParameters: {'include_inactive': includeInactive},
      );
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((e) => AIHumanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching studio models: $e');
      return [];
    }
  }

  Future<AIHumanModel> createStudioModel(AIHumanModelCreate payload) async {
    final response = await _dio.post(
      ApiConstants.studioModels,
      data: payload.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AIHumanModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create model: ${response.statusCode}');
  }

  Future<List<SceneTemplate>> getSceneTemplates({
    bool includeInactive = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studioScenes,
        queryParameters: {'include_inactive': includeInactive},
      );
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((e) => SceneTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching scene templates: $e');
      return [];
    }
  }

  Future<StudioAppOptions> getAppOptions() async {
    try {
      final response = await _dio.get(ApiConstants.appOptions);
      if (response.statusCode == 200) {
        return StudioAppOptions.fromJson(response.data as Map<String, dynamic>);
      }
      return const StudioAppOptions();
    } catch (e) {
      _logger.e('Error fetching app options: $e');
      return const StudioAppOptions();
    }
  }

  Future<StudioJobCreateResponse> createStudioJob(
    StudioJobCreateRequest payload,
  ) async {
    final response = await _dio.post(
      ApiConstants.studioJobs,
      data: payload.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudioJobCreateResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create studio job: ${response.statusCode}');
  }

  Future<List<StudioJob>> getProductStudioJobs(String productId) async {
    try {
      final response = await _dio.get('/api/studio/products/$productId/jobs');
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((e) => StudioJob.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching product studio jobs: $e');
      return [];
    }
  }

  Future<StudioJob?> getStudioJob(String jobId) async {
    try {
      final response = await _dio.get('${ApiConstants.studioJobs}/$jobId');
      if (response.statusCode == 200) {
        return StudioJob.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _logger.e('Error fetching studio job: $e');
      return null;
    }
  }

  Future<void> selectStudioImage(SelectStudioImageRequest payload) async {
    final response = await _dio.post(
      ApiConstants.studioSelect,
      data: payload.toJson(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to select studio image: ${response.statusCode}');
    }
  }

  /// Update a specific shot's result in the backend DB.
  /// Sends the updated shots array via PATCH.
  Future<StudioJob> updateStudioJobResult({
    required String jobId,
    required String shotId,
    required String status,
    required List<String> outputs,
  }) async {
    try {
      // Fetch current job to get the full shots array
      final job = await getStudioJob(jobId);
      if (job == null) throw Exception('Studio job not found');

      // Update the specific shot in the array
      final updatedShots = job.shots.map((s) {
        if (s.id == shotId || (jobId == shotId && job.shots.length == 1)) {
          return StudioShot(
            id: s.id,
            modelId: s.modelId,
            sceneId: s.sceneId,
            status: status,
            outputs: outputs,
            error: s.error,
            taskId: s.taskId,
          );
        }
        return s;
      }).toList();

      // PATCH the job with the updated shots array
      final response = await _dio.patch(
        '${ApiConstants.studioJobs}/$jobId',
        data: {
          'shots': updatedShots.map((s) => {
            'id': s.id,
            'model_id': s.modelId,
            'scene_id': s.sceneId,
            'status': s.status,
            'outputs': s.outputs,
            'error': s.error,
            'task_id': s.taskId,
          }).toList(),
          // Auto-mark the whole job completed if all shots are done
          if (updatedShots.every((s) => s.status == 'completed' || s.status == 'failed'))
            'status': updatedShots.any((s) => s.status == 'failed') ? 'failed' : 'completed',
        },
      );

      if (response.statusCode == 200) {
        return StudioJob.fromJson(response.data);
      }
      throw Exception('Failed to patch studio job');
    } catch (e) {
      _logger.e('Error updating studio result: $e');
      rethrow;
    }
  }
}

final studioService = StudioService();
