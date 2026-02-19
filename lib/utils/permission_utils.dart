import 'package:permission_handler/permission_handler.dart';

/// Utility for handling runtime permissions
class PermissionUtils {
  /// Request permission to access photos/gallery
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request permission to access gallery (legacy)
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Check if gallery/storage permission is granted
  static Future<bool> isGalleryPermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
