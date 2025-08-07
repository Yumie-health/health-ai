import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class PermissionService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Check if permissions have been requested before
  static Future<bool> _hasRequestedPermissionsBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permissions_requested') ?? false;
  }

  // Mark permissions as requested
  static Future<void> _markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', true);
  }

  // Get current permission status for all permissions
  static Future<Map<ph.Permission, ph.PermissionStatus>> getPermissionStatuses() async {
    return {
      ph.Permission.camera: await ph.Permission.camera.status,
      ph.Permission.photos: await ph.Permission.photos.status,
      ph.Permission.notification: await ph.Permission.notification.status,
    };
  }

  // Request all permissions at once
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestAllPermissions() async {
    print('🔐 Requesting all permissions...');
    
    // Request permissions in order of importance
    final results = <ph.Permission, ph.PermissionStatus>{};
    
    // 1. Camera (most important for food scanning)
    print('📷 Requesting camera permission...');
    results[ph.Permission.camera] = await ph.Permission.camera.request();
    
    // 2. Photos (for saving scanned images)
    print('🖼️ Requesting photos permission...');
    results[ph.Permission.photos] = await ph.Permission.photos.request();
    
    // 3. Notifications (for reminders)
    print('🔔 Requesting notification permission...');
    results[ph.Permission.notification] = await ph.Permission.notification.request();
    
    // Mark as requested
    await _markPermissionsRequested();
    
    // Log results
    results.forEach((permission, status) {
      print('${permission.toString()}: $status');
    });
    
    return results;
  }

  // Check if this is first launch and permissions should be requested
  static Future<bool> shouldRequestPermissions() async {
    final hasRequested = await _hasRequestedPermissionsBefore();
    return !hasRequested;
  }

  // Request specific permission
  static Future<ph.PermissionStatus> requestPermission(ph.Permission permission) async {
    print('🔐 Requesting ${permission.toString()}...');
    final status = await permission.request();
    print('${permission.toString()}: $status');
    return status;
  }

  // Check if a specific permission is granted
  static Future<bool> isPermissionGranted(ph.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Open app settings if permission is denied
  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  // Show permission explanation dialog
  static Future<bool> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String permissionName,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Continue'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Comprehensive permission request with explanations
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissionsWithExplanation(
    BuildContext context,
  ) async {
    final results = <ph.Permission, ph.PermissionStatus>{};
    
    // Camera Permission
    if (!await isPermissionGranted(ph.Permission.camera)) {
      final shouldRequest = await showPermissionDialog(
        context,
        title: 'Camera Access',
        message: 'Yumie needs camera access to scan food items and help you log your meals accurately.',
        permissionName: 'Camera',
      );
      
      if (shouldRequest) {
        results[ph.Permission.camera] = await requestPermission(ph.Permission.camera);
      } else {
        results[ph.Permission.camera] = ph.PermissionStatus.denied;
      }
    } else {
      results[ph.Permission.camera] = ph.PermissionStatus.granted;
    }

    // Photos Permission - Always request this one
    final shouldRequestPhotos = await showPermissionDialog(
      context,
      title: 'Photo Library Access',
      message: 'Yumie needs access to your photo library to save scanned images and select photos for meal logging.',
      permissionName: 'Photos',
    );
    
    if (shouldRequestPhotos) {
      results[ph.Permission.photos] = await requestPermission(ph.Permission.photos);
    } else {
      results[ph.Permission.photos] = ph.PermissionStatus.denied;
    }

    // Notifications Permission
    if (!await isPermissionGranted(ph.Permission.notification)) {
      final shouldRequest = await showPermissionDialog(
        context,
        title: 'Notification Access',
        message: 'Yumie needs notification access to send you meal reminders, water intake alerts, and mindful walk prompts.',
        permissionName: 'Notifications',
      );
      
      if (shouldRequest) {
        results[ph.Permission.notification] = await requestPermission(ph.Permission.notification);
      } else {
        results[ph.Permission.notification] = ph.PermissionStatus.denied;
      }
    } else {
      results[ph.Permission.notification] = ph.PermissionStatus.granted;
    }

    await _markPermissionsRequested();
    return results;
  }

  // Get permission status summary for UI
  static String getPermissionStatusText(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return 'Granted';
      case ph.PermissionStatus.denied:
        return 'Denied';
      case ph.PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case ph.PermissionStatus.restricted:
        return 'Restricted';
      case ph.PermissionStatus.limited:
        return 'Limited';
      case ph.PermissionStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  // Get permission icon for UI
  static IconData getPermissionIcon(ph.Permission permission) {
    switch (permission) {
      case ph.Permission.camera:
        return Icons.camera_alt;
      case ph.Permission.photos:
        return Icons.photo_library;
      case ph.Permission.notification:
        return Icons.notifications;
      default:
        return Icons.security;
    }
  }

  // Get permission name for UI
  static String getPermissionName(ph.Permission permission) {
    switch (permission) {
      case ph.Permission.camera:
        return 'Camera';
      case ph.Permission.photos:
        return 'Photo Library';
      case ph.Permission.notification:
        return 'Notifications';
      default:
        return 'Unknown';
    }
  }
}
