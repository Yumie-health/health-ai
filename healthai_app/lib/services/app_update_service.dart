import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  // Store URLs for both platforms
  static const String _iosAppStoreUrl = 'https://apps.apple.com/app/yumie-calorie-tracker/id6748360245';
  static const String _androidPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.yumie.healthai';

  // API endpoint to check for updates
  static const String _updateCheckUrl = 'https://us-central1-healthai-0001.cloudfunctions.net/checkAppUpdate';
  
  // For testing, you can use a GitHub raw URL:
  // static const String _updateCheckUrl = 'https://raw.githubusercontent.com/your-username/your-repo/main/app-updates.json';

  /// Check if app update is available
  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      
      print('📱 User app version: $currentVersion (Build $currentBuildNumber)');

      // Check for updates from your backend
      final updateInfo = await _fetchUpdateInfo();
      if (updateInfo == null) return null;

      // Compare versions
      if (_isUpdateAvailable(currentVersion, currentBuildNumber, updateInfo)) {
        // Additional check: Only show update if it's actually available in stores
        // This prevents showing updates that haven't been published yet
        if (await _isUpdateActuallyAvailable(updateInfo)) {
          return updateInfo;
        }
      }

      return null;
    } catch (e) {
      print('Error checking for app updates: $e');
      return null;
    }
  }

  /// Check if the update is actually available in the app stores
  static Future<bool> _isUpdateActuallyAvailable(AppUpdateInfo updateInfo) async {
    try {
      // Check if the update is marked as published in the backend
      // This prevents showing updates that haven't been published to stores yet
      return updateInfo.published ?? false;
    } catch (e) {
      print('Error checking if update is actually available: $e');
      return false;
    }
  }

  /// Fetch update information from backend
  static Future<AppUpdateInfo?> _fetchUpdateInfo() async {
    try {
      // Determine platform
      String platform = 'both';
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      }

      // Fetch update info from your backend API with platform parameter
      final response = await http.get(
        Uri.parse('$_updateCheckUrl?platform=$platform'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppUpdateInfo.fromJson(data);
      }

      // If backend is not available, return null (no update check)
      print('Backend not available or returned error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching update info: $e');
      return null;
    }
  }

  /// Compare versions to determine if update is needed
  static bool _isUpdateAvailable(String currentVersion, String currentBuildNumber, AppUpdateInfo updateInfo) {
    try {
      final current = _parseVersion(currentVersion);
      final latest = _parseVersion(updateInfo.latestVersion);
      
      // Compare major.minor.patch versions
      for (int i = 0; i < 3; i++) {
        if (latest[i] > current[i]) return true;
        if (latest[i] < current[i]) return false;
      }
      
      // If versions are equal, check build number
      final currentBuild = int.tryParse(currentBuildNumber) ?? 0;
      final latestBuild = updateInfo.latestBuildNumber;
      
      return latestBuild > currentBuild;
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  /// Parse version string into list of integers
  static List<int> _parseVersion(String version) {
    return version.split('.').map((v) => int.tryParse(v) ?? 0).toList();
  }

  /// Launch app store for update
  static Future<bool> launchAppStore() async {
    try {
      final url = Platform.isIOS ? _iosAppStoreUrl : _androidPlayStoreUrl;
      final uri = Uri.parse(url);
      
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching app store: $e');
      return false;
    }
  }

  /// Check if we should show update dialog (avoid showing too frequently)
  static Future<bool> shouldShowUpdateDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt('last_update_dialog_shown') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneDayInMs = 24 * 60 * 60 * 1000; // 24 hours
      
      // Show dialog if never shown before or if more than 24 hours have passed
      return (now - lastShown) > oneDayInMs;
    } catch (e) {
      print('Error checking update dialog timing: $e');
      return true; // Default to showing if there's an error
    }
  }

  /// Mark update dialog as shown
  static Future<void> markUpdateDialogShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_update_dialog_shown', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error marking update dialog as shown: $e');
    }
  }

  /// Skip update for this version
  static Future<void> skipUpdateForVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('skipped_update_version', version);
    } catch (e) {
      print('Error skipping update: $e');
    }
  }

  /// Check if update was skipped for current version
  static Future<bool> wasUpdateSkippedForVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skippedVersion = prefs.getString('skipped_update_version');
      return skippedVersion == version;
    } catch (e) {
      print('Error checking skipped update: $e');
      return false;
    }
  }
}

class AppUpdateInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final String title;
  final String description;
  final bool isForceUpdate;
  final String? releaseNotes;
  final bool? published;
  final String? platform;

  AppUpdateInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.title,
    required this.description,
    this.isForceUpdate = false,
    this.releaseNotes,
    this.published,
    this.platform,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: json['latestVersion'] ?? '',
      latestBuildNumber: json['latestBuildNumber'] ?? 0,
      title: json['title'] ?? 'Update Available',
      description: json['description'] ?? 'A new version of Yumie is available.',
      isForceUpdate: json['isForceUpdate'] ?? false,
      releaseNotes: json['releaseNotes'],
      published: json['published'],
      platform: json['platform'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'latestBuildNumber': latestBuildNumber,
      'title': title,
      'description': description,
      'isForceUpdate': isForceUpdate,
      'releaseNotes': releaseNotes,
      'published': published,
      'platform': platform,
    };
  }
}
