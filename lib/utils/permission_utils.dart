import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility for handling runtime permissions across Android versions
class PermissionUtils {
  /// Request permission to access photos/gallery
  /// Handles Android 13+ (READ_MEDIA_IMAGES) and older (READ_EXTERNAL_STORAGE)
  static Future<bool> requestPhotosPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    // On Android 13+ use Permission.photos, on older use Permission.storage
    if (Platform.isAndroid) {
      // Try photos first (Android 13+)
      var status = await Permission.photos.status;
      if (status.isGranted) return true;

      // Request photos permission
      status = await Permission.photos.request();
      if (status.isGranted) return true;

      // Fall back to storage for older Android
      status = await Permission.storage.status;
      if (status.isGranted) return true;

      status = await Permission.storage.request();
      if (status.isGranted) return true;

      // If permanently denied, guide user to settings
      if (status.isPermanentlyDenied) {
        debugPrint('Photo permission permanently denied — open settings');
      }
      return false;
    }

    // iOS
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request gallery/storage permission (alias for requestPhotosPermission)
  static Future<bool> requestGalleryPermission() async {
    return requestPhotosPermission();
  }

  /// Check if photos permission is granted
  static Future<bool> isPhotosPermissionGranted() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.status;
      if (photos.isGranted) return true;
      final storage = await Permission.storage.status;
      return storage.isGranted;
    }
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Open app settings so user can manually grant permissions
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
