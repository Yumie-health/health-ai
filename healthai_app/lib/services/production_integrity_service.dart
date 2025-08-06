import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'native_play_integrity_service.dart';

class ProductionIntegrityService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  /// Perform a production-ready integrity check
  static Future<bool> performIntegrityCheck() async {
    try {
      // Only perform integrity checks on Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        // Get the integrity token using native implementation
        final token = await NativePlayIntegrityService.getIntegrityToken();
        if (token == null) {
          print('Failed to get integrity token');
          return false;
        }

        // Verify with Firebase Functions
        final isValid = await _verifyWithBackend(token);
        return isValid;
      }
      
      // For non-Android platforms, return true (no integrity check needed)
      return true;
    } catch (e) {
      print('Error performing integrity check: $e');
      return false;
    }
  }

  /// Verify integrity token with Firebase Functions backend
  static Future<bool> _verifyWithBackend(String token) async {
    try {
      final callable = _functions.httpsCallable('verifyPlayIntegrityCallable');
      final result = await callable.call({
        'integrityToken': token,
      });
      
      final data = result.data as Map<String, dynamic>?;
      if (data == null) {
        return false;
      }

      // Check the verification result
      final isGenuine = data['isGenuine'] as bool? ?? false;
      final isInstalledFromGooglePlay = data['isInstalledFromGooglePlay'] as bool? ?? false;
      
      return isGenuine && isInstalledFromGooglePlay;
    } catch (e) {
      print('Error verifying integrity token with backend: $e');
      return false;
    }
  }

  /// Check integrity before sensitive operations
  static Future<bool> checkBeforeSensitiveOperation() async {
    final isIntegrityValid = await performIntegrityCheck();
    
    if (!isIntegrityValid) {
      print('Integrity check failed - app may be compromised');
      // Log the incident for monitoring
      _logIntegrityFailure();
    }
    
    return isIntegrityValid;
  }

  /// Check integrity before in-app purchases
  static Future<bool> checkBeforePurchase() async {
    return await checkBeforeSensitiveOperation();
  }

  /// Check integrity before accessing premium features
  static Future<bool> checkBeforePremiumAccess() async {
    return await checkBeforeSensitiveOperation();
  }

  /// Check integrity before user authentication
  static Future<bool> checkBeforeAuthentication() async {
    return await checkBeforeSensitiveOperation();
  }

  /// Log integrity failures for monitoring
  static void _logIntegrityFailure() {
    // In production, you might want to send this to your analytics service
    // or log it to Firebase Analytics
    print('INTEGRITY_FAILURE: App integrity check failed at ${DateTime.now().toIso8601String()}');
  }
}
