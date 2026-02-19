import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Notification types
enum NotificationType { success, error, info, warning }

/// Reusable notification utility for showing notifications at the bottom
class AppNotification {
  static OverlayEntry? _overlayEntry;

  /// Show success notification
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }

  /// Show error notification
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showNotification(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
    );
  }

  /// Show info notification
  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }

  /// Show warning notification
  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showNotification(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }

  /// Internal method to show notification using overlay
  static void _showNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    required Duration duration,
  }) {
    Color backgroundColor;
    IconData icon;
    Color textColor;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_rounded;
        textColor = Colors.white;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_rounded;
        textColor = Colors.white;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.amber.shade600;
        icon = Icons.warning_rounded;
        textColor = Colors.white;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_rounded;
        textColor = Colors.white;
        break;
    }

    // Remove previous notification if still showing
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      Overlay.of(context).insert(_overlayEntry!);

      // Auto-dismiss after duration
      Future.delayed(duration, () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
