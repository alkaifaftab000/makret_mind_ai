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
}

final studioService = StudioService();
