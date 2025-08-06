import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativePlayIntegrityService {
  static const MethodChannel _channel = MethodChannel('play_integrity_channel');
  
  /// Get integrity token from native Android implementation
  static Future<String?> getIntegrityToken() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final String? token = await _channel.invokeMethod('getIntegrityToken');
        return token;
      }
      return null;
    } catch (e) {
      print('Error getting integrity token: $e');
      return null;
    }
  }
  
  /// Check device integrity using native Android implementation
  static Future<bool> checkDeviceIntegrity() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final bool result = await _channel.invokeMethod('checkDeviceIntegrity');
        return result;
      }
      return false;
    } catch (e) {
      print('Error checking device integrity: $e');
      return false;
    }
  }
}
