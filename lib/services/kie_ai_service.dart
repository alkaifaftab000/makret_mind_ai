import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Service that polls Kie AI directly for task status.
/// Used when the backend creates a Kie AI task (poster/video generation)
/// and returns a taskId — the frontend polls Kie AI until completion.
class KieAiService {
  static final KieAiService _instance = KieAiService._internal();
  factory KieAiService() => _instance;
  KieAiService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());

  static const String _baseUrl = 'https://api.kie.ai';
  static const String _apiKey = '46c3b599074c1c6a376b2c0a64731035';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Check the status of a Kie AI task by its taskId.
  /// Uses GET /api/v1/jobs/recordInfo?taskId={taskId}
  /// Returns a [KieTaskResult] with status, output URLs, etc.
  Future<KieTaskResult> checkTaskStatus(String taskId) async {
    try {
      _logger.i('Checking Kie AI task status: $taskId');
      final response = await _dio.get(
        '/api/v1/jobs/recordInfo',
        queryParameters: {'taskId': taskId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final code = data['code'];

        if (code == 200) {
          final taskData = data['data'];
          if (taskData != null) {
            // Kie AI states: waiting, queuing, generating, success, fail
            final state = taskData['state']?.toString() ?? 'unknown';

            // Log the FULL raw response when task is completed so we can see the structure
            if (state == 'success' || state == 'fail') {
              _logger.w('🔍 RAW Kie AI response for $taskId:\n'
                  'Keys: ${taskData.keys.toList()}\n'
                  'Full data: $taskData');
            }

            // Parse result URLs — try multiple known response formats
            List<String> resultUrls = [];

            // Format 1: data.resultJson.resultUrls (array of strings)
            if (taskData['resultJson'] != null) {
              final resultJson = taskData['resultJson'];
              _logger.i('resultJson type: ${resultJson.runtimeType}, value: $resultJson');

              if (resultJson is Map) {
                // Format 1a: { "resultUrls": ["url1", "url2"] }
                if (resultJson['resultUrls'] is List) {
                  resultUrls = (resultJson['resultUrls'] as List)
                      .map((e) => e.toString())
                      .where((url) => url.startsWith('http'))
                      .toList();
                }
                // Format 1b: { "works": [{ "resource": { "resource": "url" } }] }
                if (resultJson['works'] is List && resultUrls.isEmpty) {
                  for (final work in resultJson['works']) {
                    if (work is Map) {
                      final resource = work['resource'];
                      if (resource is Map && resource['resource'] is String) {
                        resultUrls.add(resource['resource'] as String);
                      } else if (resource is String && resource.startsWith('http')) {
                        resultUrls.add(resource);
                      }
                      // Also check for 'url' field in work
                      if (work['url'] is String) {
                        resultUrls.add(work['url'] as String);
                      }
                    }
                  }
                }
              } else if (resultJson is String) {
                // Format 1c: resultJson is a raw JSON string
                // Try to extract URLs from it
                final urlRegex = RegExp(r'https?://[^\s"]+');
                final matches = urlRegex.allMatches(resultJson);
                for (final match in matches) {
                  resultUrls.add(match.group(0)!);
                }
              }
            }

            // Format 2: data.resultUrl (single string)
            if (resultUrls.isEmpty && taskData['resultUrl'] is String) {
              final url = taskData['resultUrl'] as String;
              if (url.startsWith('http')) resultUrls.add(url);
            }

            // Format 3: data.output (single string)
            if (resultUrls.isEmpty && taskData['output'] is String) {
              final url = taskData['output'] as String;
              if (url.startsWith('http')) resultUrls.add(url);
            }

            // Format 4: data.works (array)
            if (resultUrls.isEmpty && taskData['works'] is List) {
              for (final work in taskData['works']) {
                if (work is Map) {
                  for (final val in work.values) {
                    if (val is String && val.startsWith('http')) {
                      resultUrls.add(val);
                    }
                    if (val is Map) {
                      for (final innerVal in val.values) {
                        if (innerVal is String && innerVal.startsWith('http')) {
                          resultUrls.add(innerVal);
                        }
                      }
                    }
                  }
                }
              }
            }

            // Format 5: Scan ALL string values in taskData for URLs as last resort
            if (resultUrls.isEmpty && state == 'success') {
              _extractUrls(taskData, resultUrls);
            }

            _logger.i('Kie AI task $taskId → state: $state, '
                'resultUrls: ${resultUrls.length}'
                '${resultUrls.isNotEmpty ? " → ${resultUrls.first}" : ""}');

            return KieTaskResult(
              taskId: taskId,
              status: state,
              resultUrls: resultUrls,
              outputUrl: resultUrls.isNotEmpty ? resultUrls.first : null,
              raw: taskData,
            );
          }
        }

        // Handle error response
        final msg = data['msg']?.toString() ?? 'Unknown error';
        _logger.w('Kie AI API returned code $code: $msg');
        return KieTaskResult(taskId: taskId, status: 'unknown', error: msg);
      }

      return KieTaskResult(taskId: taskId, status: 'unknown');
    } catch (e) {
      _logger.e('Error checking Kie AI task $taskId: $e');
      if (e is DioException) {
        _logger.e('Status: ${e.response?.statusCode}');
        _logger.e('Response: ${e.response?.data}');
      }
      return KieTaskResult(
        taskId: taskId,
        status: 'error',
        error: e.toString(),
      );
    }
  }

  /// Recursively extract HTTP URLs from a nested data structure
  void _extractUrls(dynamic data, List<String> urls) {
    if (data is String && data.startsWith('http')) {
      urls.add(data);
    } else if (data is Map) {
      for (final value in data.values) {
        _extractUrls(value, urls);
      }
    } else if (data is List) {
      for (final item in data) {
        _extractUrls(item, urls);
      }
    }
  }

  /// Get a temporary download URL for a Kie AI generated file.
  /// Download links expire after 20 minutes.
  Future<String?> getDownloadUrl(String fileUrl) async {
    try {
      _logger.i('Getting download URL for: $fileUrl');
      final response = await _dio.post(
        '/api/v1/common/download-url',
        data: {'url': fileUrl},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200) {
          final url = data['data']?.toString();
          _logger.i('Download URL obtained: $url');
          return url;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error getting download URL: $e');
      return null;
    }
  }

  /// Check account credit balance
  Future<int?> checkCredits() async {
    try {
      final response = await _dio.get('/api/v1/chat/credit');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200) {
          return data['data'] as int?;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error checking credits: $e');
      return null;
    }
  }

  /// Poll a task until it completes, fails, or times out.
  /// Returns the final [KieTaskResult].
  ///
  /// [onProgress] is called on each poll with the current result.
  /// [pollInterval] defaults to 5 seconds.
  /// [timeout] defaults to 10 minutes.
  Future<KieTaskResult> pollUntilComplete(
    String taskId, {
    Duration pollInterval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 10),
    void Function(KieTaskResult)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    int pollCount = 0;

    while (stopwatch.elapsed < timeout) {
      pollCount++;
      final result = await checkTaskStatus(taskId);
      onProgress?.call(result);

      _logger.i('Poll #$pollCount for task $taskId: ${result.status}');

      if (result.isCompleted || result.isFailed) {
        stopwatch.stop();
        _logger.i('Task $taskId finished with status: ${result.status} '
            'after ${stopwatch.elapsed.inSeconds}s ($pollCount polls)');
        return result;
      }

      // Use exponential backoff: start at pollInterval, max 15 seconds
      final delay = Duration(
        milliseconds: (pollInterval.inMilliseconds *
                (1.0 + (pollCount * 0.2)).clamp(1.0, 3.0))
            .round(),
      );
      await Future.delayed(delay);
    }

    stopwatch.stop();
    _logger.w('Kie AI task $taskId timed out after ${timeout.inMinutes} minutes '
        '($pollCount polls)');
    return KieTaskResult(
      taskId: taskId,
      status: 'timeout',
      error: 'Task timed out after ${timeout.inMinutes} minutes',
    );
  }
}

/// Result of a Kie AI task status check.
class KieTaskResult {
  final String taskId;
  final String status; // waiting, queuing, generating, success, fail, timeout, error
  final String? outputUrl; // First result URL
  final List<String> resultUrls; // All result URLs
  final double? progress; // 0.0 – 1.0 if available
  final String? error;
  final dynamic raw; // Full response data for debugging

  const KieTaskResult({
    required this.taskId,
    required this.status,
    this.outputUrl,
    this.resultUrls = const [],
    this.progress,
    this.error,
    this.raw,
  });

  /// Task completed successfully
  bool get isCompleted => status == 'success';

  /// Task failed or errored
  bool get isFailed =>
      status == 'fail' || status == 'error' || status == 'timeout';

  /// Task is still in progress
  bool get isProcessing =>
      status == 'waiting' ||
      status == 'queuing' ||
      status == 'generating' ||
      status == 'processing' ||
      status == 'pending' ||
      status == 'submitted';

  @override
  String toString() => 'KieTaskResult(taskId: $taskId, status: $status, '
      'outputUrl: $outputUrl, resultUrls: ${resultUrls.length})';
}

/// Singleton instance
final kieAiService = KieAiService();
