import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import '../l10n/app_localizations.dart';

class PermissionService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Check if device is Android 13+ (API 33+)
  // On Android 13+, photo picker doesn't need READ_MEDIA_IMAGES permission
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  // Check if this is the first time the app has been launched
  static Future<bool> _isFirstTimeLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('first_launch_completed') ?? false);
  }

  // Mark first launch as completed
  static Future<void> _markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch_completed', true);
  }

  // Check if permissions have been requested before (kept for backward compatibility)
  static Future<bool> _hasRequestedPermissionsBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permissions_requested') ?? false;
  }

  // Mark permissions as requested (kept for backward compatibility)
  static Future<void> _markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', true);
  }

  // Get current permission status for all permissions
  static Future<Map<ph.Permission, ph.PermissionStatus>> getPermissionStatuses() async {
    final isAndroid13Plus = await _isAndroid13OrHigher();
    final statuses = {
      ph.Permission.camera: await ph.Permission.camera.status,
      ph.Permission.notification: await ph.Permission.notification.status,
    };
    
    // Only check photos permission on iOS or Android 12 and below
    // Android 13+ uses photo picker which doesn't need permission
    if (!isAndroid13Plus) {
      statuses[ph.Permission.photos] = await ph.Permission.photos.status;
    }
    
    return statuses;
  }

  // Request all permissions at once
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestAllPermissions() async {
    print('🔐 Requesting all permissions...');
    
    final isAndroid13Plus = await _isAndroid13OrHigher();
    
    // Request permissions in order of importance
    final results = <ph.Permission, ph.PermissionStatus>{};
    
    // 1. Camera (most important for food scanning)
    print('📷 Requesting camera permission...');
    results[ph.Permission.camera] = await ph.Permission.camera.request();
    
    // 2. Photos (for saving scanned images)
    // Skip on Android 13+ as photo picker doesn't need permission
    if (!isAndroid13Plus) {
      print('🖼️ Requesting photos permission...');
      results[ph.Permission.photos] = await ph.Permission.photos.request();
    } else {
      print('🖼️ Skipping photos permission on Android 13+ (uses photo picker)');
    }
    
    // 3. Notifications (for reminders)
    print('🔔 Requesting notification permission...');
    if (Platform.isIOS) {
      // Ask via Firebase Messaging; iOS will present system prompt when undetermined
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }
    results[ph.Permission.notification] = await ph.Permission.notification.request();
    
    // Mark as requested
    await _markFirstLaunchCompleted();
    await _markPermissionsRequested(); // Keep for backward compatibility
    
    // Log results
    results.forEach((permission, status) {
      print('${permission.toString()}: $status');
    });
    
    return results;
  }

  // Check if this is first launch and permissions should be requested
  static Future<bool> shouldRequestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the first time launch
    final isFirstLaunch = await _isFirstTimeLaunch();
    
    // If not first launch, don't show permissions page
    if (!isFirstLaunch) {
      return false;
    }
    
    final isAndroid13Plus = await _isAndroid13OrHigher();
    
    // Check if permissions have already been granted
    final cameraGranted = await isPermissionGranted(ph.Permission.camera);
    final notificationsGranted = await isPermissionGranted(ph.Permission.notification);
    
    // Only check photos permission on iOS or Android 12 and below
    bool photosGranted = true; // Default to true for Android 13+ (no permission needed)
    if (!isAndroid13Plus) {
      photosGranted = await isPermissionGranted(ph.Permission.photos);
    }
    
    // If all permissions are already granted, don't show permissions page
    if (cameraGranted && photosGranted && notificationsGranted) {
      // Mark first launch as completed since permissions are already granted
      await _markFirstLaunchCompleted();
      return false;
    }
    
    return true;
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
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.continueButton),
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
    final isAndroid13Plus = await _isAndroid13OrHigher();
    
    // Camera Permission
    if (!await isPermissionGranted(ph.Permission.camera)) {
      final shouldRequest = await showPermissionDialog(
        context,
        title: AppLocalizations.of(context)!.cameraAccess,
        message: AppLocalizations.of(context)!.cameraAccessMessage,
        permissionName: AppLocalizations.of(context)!.camera,
      );
      
      if (shouldRequest) {
        results[ph.Permission.camera] = await requestPermission(ph.Permission.camera);
      } else {
        results[ph.Permission.camera] = ph.PermissionStatus.denied;
      }
    } else {
      results[ph.Permission.camera] = ph.PermissionStatus.granted;
    }

    // Photos Permission - Skip on Android 13+ (uses photo picker)
    if (!isAndroid13Plus) {
      final shouldRequestPhotos = await showPermissionDialog(
        context,
        title: AppLocalizations.of(context)!.photoLibraryAccess,
        message: AppLocalizations.of(context)!.photoLibraryAccessMessage,
        permissionName: AppLocalizations.of(context)!.photoLibrary,
      );
      
      if (shouldRequestPhotos) {
        results[ph.Permission.photos] = await requestPermission(ph.Permission.photos);
      } else {
        results[ph.Permission.photos] = ph.PermissionStatus.denied;
      }
    }

    // Notifications Permission
    if (!await isPermissionGranted(ph.Permission.notification)) {
      final shouldRequest = await showPermissionDialog(
        context,
        title: AppLocalizations.of(context)!.notificationAccess,
        message: AppLocalizations.of(context)!.notificationAccessMessage,
        permissionName: AppLocalizations.of(context)!.notifications,
      );
      
      if (shouldRequest) {
        if (Platform.isIOS) {
          await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
        }
        results[ph.Permission.notification] = await requestPermission(ph.Permission.notification);
      } else {
        results[ph.Permission.notification] = ph.PermissionStatus.denied;
      }
    } else {
      results[ph.Permission.notification] = ph.PermissionStatus.granted;
    }

    await _markFirstLaunchCompleted();
    await _markPermissionsRequested(); // Keep for backward compatibility
    return results;
  }

  // Get permission status summary for UI
  static String getPermissionStatusText(ph.PermissionStatus status, [BuildContext? context]) {
    if (context != null) {
      final localizations = AppLocalizations.of(context)!;
      switch (status) {
        case ph.PermissionStatus.granted:
          return localizations.granted;
        case ph.PermissionStatus.denied:
          return localizations.denied;
        case ph.PermissionStatus.permanentlyDenied:
          return localizations.denied;
        case ph.PermissionStatus.restricted:
          return localizations.denied;
        case ph.PermissionStatus.limited:
          return localizations.granted;
        case ph.PermissionStatus.provisional:
          return localizations.granted;
        default:
          return localizations.unknown;
      }
    } else {
      // Fallback for when context is not available
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
  static String getPermissionName(ph.Permission permission, [BuildContext? context]) {
    if (context != null) {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        switch (permission) {
          case ph.Permission.camera:
            return localizations.camera;
          case ph.Permission.photos:
            return localizations.photoLibrary;
          case ph.Permission.notification:
            return localizations.notifications;
          default:
            return localizations.unknown;
        }
      }
    }
    
    // Fallback to English if no context or localization
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
