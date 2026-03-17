import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:logger/logger.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());

  // Ideally, these would go in .env, but hardcoding per user request for now
  static const String _cloudName = 'dzxkvvkdj';
  static const String _uploadPreset = 'market_mind_uploads'; // Make sure to configure an unsigned upload preset in Cloudinary!

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
}

final cloudinaryService = CloudinaryService();
