import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class KieService {
  static final KieService _instance = KieService._internal();

  factory KieService() {
    return _instance;
  }

  KieService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());
  final Dio _dio = Dio();
  
  // TODO: Insert your actual KIE API key here
  static const String _apiKey = '46c3b599074c1c6a376b2c0a64731035';

  /// 1. Get a 20-minute temporary secure download URL for a KIE tempfile URL
  Future<String> getDownloadUrl(String tempFileUrl) async {
    try {
      _logger.i('Requesting KIE download URL for: $tempFileUrl');
      final response = await _dio.post(
        'https://api.kie.ai/api/v1/common/download-url',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {'url': tempFileUrl},
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return response.data['data'] as String;
      } else {
        throw Exception('KIE API returned error: ${response.data}');
      }
    } catch (e) {
      _logger.e('Failed to get KIE download URL: $e');
      rethrow;
    }
  }

  /// 2. Download the actual image to a temporary local File
  Future<File> downloadImageToFile(String secureDownloadUrl) async {
    try {
      _logger.i('Downloading image from KIE secure URL...');
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/kie_img_${DateTime.now().millisecondsSinceEpoch}.png';

      await _dio.download(secureDownloadUrl, tempPath);
      _logger.i('Image saved locally to $tempPath');
      
      return File(tempPath);
    } catch (e) {
      _logger.e('Failed to download image to local file: $e');
      rethrow;
    }
  }
}

final kieService = KieService();
