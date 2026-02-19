import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_util;
import 'package:uuid/uuid.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  static Future<String?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Compress to 85% quality
      );

      if (pickedFile != null) {
        return await saveImage(File(pickedFile.path));
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Save image to app documents directory
  static Future<String> saveImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/brand_images');

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final fileName =
          '${const Uuid().v4()}${path_util.extension(imageFile.path)}';
      final savedImage = File('${imagesDir.path}/$fileName');

      // Copy image to app directory
      await imageFile.copy(savedImage.path);
      print('Image saved to: ${savedImage.path}');
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  /// Load image from local path
  static File? loadImage(String imagePath) {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  /// Delete image from local storage
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Image deleted: $imagePath');
      }
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  /// Get image size in bytes
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes;
      }
      return null;
    } catch (e) {
      print('Error getting image size: $e');
      return null;
    }
  }

  /// Format bytes to readable size
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    final k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes / k).floor();
    return '${(bytes / (k * k)).toStringAsFixed(2)} ${sizes[i]}';
  }

  /// Clear all brand images (for app cleanup/testing)
  static Future<void> clearAllImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/brand_images');

      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        print('All brand images cleared');
      }
    } catch (e) {
      print('Error clearing images: $e');
      rethrow;
    }
  }
}
