import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());

  // Ideally, these would go in .env, but hardcoding per user request for now
  static const String _cloudName = 'dz4muwh1c';
  static const String _uploadPreset = 'marketmind'; // Make sure to configure an unsigned upload preset in Cloudinary!

  final _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  /// Uploads a single file to Cloudinary and returns the secure URL
  Future<String?> uploadImage(File file, {String folder = 'uploads'}) async {
    try {
      _logger.i('Uploading image to Cloudinary (folder: $folder)...');
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      _logger.i('Upload successful! URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      _logger.e('Failed to upload image to Cloudinary: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Uploads multiple files and returns a list of secure URLs
  Future<List<String>> uploadMultipleImages(List<File> files, {String folder = 'uploads'}) async {
    List<String> urls = [];
    
    for (var file in files) {
      final url = await uploadImage(file, folder: folder);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Downloads an image from a temporary URL and uploads it to Cloudinary.
  /// Used for Kie AI generated images that have expiring URLs (20 min).
  /// Returns the permanent Cloudinary secure URL.
  Future<String?> uploadImageFromUrl(String tempUrl, {String folder = 'posters'}) async {
    try {
      _logger.i('Downloading image from temp URL to re-upload to Cloudinary...');
      
      // 1. Download the image to a temp file
      final dio = Dio();
      final tempDir = await Directory.systemTemp.createTemp('kie_ai_');
      final tempFile = File('${tempDir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png');
      
      await dio.download(tempUrl, tempFile.path);
      _logger.i('Downloaded image to ${tempFile.path} (${await tempFile.length()} bytes)');
      
      // 2. Upload to Cloudinary
      final cloudinaryUrl = await uploadImage(tempFile, folder: folder);
      
      // 3. Clean up temp file
      try {
        await tempFile.delete();
        await tempDir.delete();
      } catch (_) {}
      
      _logger.i('Image re-uploaded to Cloudinary: $cloudinaryUrl');
      return cloudinaryUrl;
    } catch (e) {
      _logger.e('Failed to upload image from URL to Cloudinary: $e');
      return null;
    }
  }
}

final cloudinaryService = CloudinaryService();
