import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'native_play_integrity_service.dart';

class ProductionIntegrityService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static DateTime? _lastAttemptAt;
  static int _consecutiveFailures = 0;
  static DateTime? _lastSuccessfulCheckAt;

  // Don't call the API more than once every 15 seconds even on success
  static const Duration _minIntervalBetweenChecks = Duration(seconds: 15);

  // Cache a successful integrity result for 10 minutes
  static const Duration _successCacheTtl = Duration(minutes: 10);

  // Base backoff of 3 seconds, doubles with each failure, capped
  static const Duration _baseBackoff = Duration(seconds: 3);
  static const Duration _maxBackoff = Duration(minutes: 2);

  /// Perform a production-ready integrity check
  static Future<bool> performIntegrityCheck() async {
    try {
      // Only perform integrity checks on Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final now = DateTime.now();

        // 1) If we had a recent successful check, trust it for the TTL
        if (_lastSuccessfulCheckAt != null &&
            now.difference(_lastSuccessfulCheckAt!) < _successCacheTtl) {
          return true;
        }

        // 2) Rate limit: avoid calling more often than the minimum interval
        if (_lastAttemptAt != null &&
            now.difference(_lastAttemptAt!) < _minIntervalBetweenChecks) {
          // Too soon; skip and preserve previous outcome (default to false)
          return false;
        }

        // 3) Exponential backoff after failures to avoid Integrity -8 throttling
        if (_consecutiveFailures > 0) {
          final backoffMs =
              _baseBackoff.inMilliseconds * (1 << (_consecutiveFailures - 1));
          final computed = Duration(milliseconds: backoffMs);
          final backoff = (computed > _maxBackoff) ? _maxBackoff : computed;
          if (_lastAttemptAt != null &&
              now.difference(_lastAttemptAt!) < backoff) {
            // Still in backoff window; skip
            return false;
          }
        }

        _lastAttemptAt = now;
        // Get the integrity token using native implementation
        final token = await NativePlayIntegrityService.getIntegrityToken();
        if (token == null) {
          print('Failed to get integrity token');
          _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 10);
          return false;
        }

        // Verify with Firebase Functions
        final isValid = await _verifyWithBackend(token);
        if (isValid) {
          _consecutiveFailures = 0;
          _lastSuccessfulCheckAt = DateTime.now();
        } else {
          _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 10);
        }
        return isValid;
      }

      // For non-Android platforms, return true (no integrity check needed)
      return true;
    } catch (e) {
      print('Error performing integrity check: $e');
      _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 10);
      return false;
    }
  }

  /// Verify integrity token with Firebase Functions backend
  static Future<bool> _verifyWithBackend(String token) async {
    try {
      final callable = _functions.httpsCallable('verifyPlayIntegrityCallable');
      final result = await callable.call({'integrityToken': token});

      final data = result.data as Map<String, dynamic>?;
      if (data == null) {
        return false;
      }

      // Check the verification result
      final isGenuine = data['isGenuine'] as bool? ?? false;
      final isInstalledFromGooglePlay =
          data['isInstalledFromGooglePlay'] as bool? ?? false;

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
    print(
      'INTEGRITY_FAILURE: App integrity check failed at ${DateTime.now().toIso8601String()}',
    );
  }
}
