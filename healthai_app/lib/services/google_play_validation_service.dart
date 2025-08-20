
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/payment_config.dart';
import 'google_auth_service.dart';

class GooglePlayValidationService {
  static const String _baseUrl = 'https://androidpublisher.googleapis.com/androidpublisher/v3';
  
  // Use the licensing key from PaymentConfig
  static String? get _licenseKey => PaymentConfig.googlePlayLicenseKey;
  
  static Future<void> initialize() async {
    // Service is initialized with the licensing key
    print('Google Play Validation Service initialized');
  }
  
  // Check if service is properly configured
  static bool isConfigured() {
    // For full configuration, we need both license key and service account
    // We can't call async getAccessToken() in a sync method, so we'll check if credentials exist
    return _licenseKey != null && _licenseKey!.isNotEmpty;
  }
  
  // Check subscription validity (called by subscription service)
  static Future<bool> checkSubscriptionValidity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseToken = prefs.getString('purchaseToken');
      final subscriptionType = prefs.getString('subscriptionType');
      
      if (purchaseToken == null || subscriptionType == null) {
        print('Google Play Validation: Missing purchase data');
        return false;
      }
      
      // If Google Play API is not configured, fall back to local validation
      if (!isConfigured()) {
        print('Google Play Validation: Using fallback validation');
        return await _fallbackLocalValidation();
      }
      
      // Use real Google Play API validation
      final packageName = 'com.yumie.healthai'; // Your app's package name
      final result = await validateSubscription(
        packageName: packageName,
        productId: subscriptionType,
        purchaseToken: purchaseToken,
      );
      
      final isValid = result['isValid'];
      if (isValid == null) {
        // API returned null/unknown, use fallback validation
        print('Google Play Validation: API returned unknown, using fallback');
        return await _fallbackLocalValidation();
      } else {
        final validBool = isValid as bool? ?? false;
        print('Google Play Validation: API result - $validBool');
        return validBool;
      }
    } catch (e) {
      print('Error checking subscription validity: $e');
      // Fall back to local validation if API fails
      return await _fallbackLocalValidation();
    }
  }

  // Detailed check returning cancellation and expiry info
  static Future<Map<String, dynamic>> checkSubscriptionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseToken = prefs.getString('purchaseToken');
      final subscriptionType = prefs.getString('subscriptionType');
      if (purchaseToken == null || subscriptionType == null) {
        return { 'isActive': false };
      }
      if (!isConfigured()) {
        final fallbackActive = await _fallbackLocalValidation();
        return { 'isActive': fallbackActive };
      }
      final packageName = 'com.yumie.healthai';
      final result = await validateSubscription(
        packageName: packageName,
        productId: subscriptionType,
        purchaseToken: purchaseToken,
      );
      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) {
        final fallbackActive = await _fallbackLocalValidation();
        return { 'isActive': fallbackActive };
      }
      final paymentState = data['paymentState'] as int?; // 1 == received
      final cancelReason = data['cancelReason']; // null if not cancelled
      final expiryTimeMillis = data['expiryTimeMillis']?.toString();
      DateTime? expiry;
      if (expiryTimeMillis != null) {
        try {
          expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryTimeMillis));
        } catch (_) {}
      }
      final now = DateTime.now();
      final isActive = (paymentState == 1) && (expiry == null || expiry.isAfter(now));
      final isCancelled = cancelReason != null && expiry != null && expiry.isAfter(now);
      return {
        'isActive': isActive,
        'isCancelled': isCancelled,
        'expiryDate': expiry?.toIso8601String(),
      };
    } catch (e) {
      print('Error getting subscription details: $e');
      final fallbackActive = await _fallbackLocalValidation();
      return { 'isActive': fallbackActive };
    }
  }
  
  // Validate subscription with Google Play API
  static Future<Map<String, dynamic>> validateSubscription({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      // Get OAuth2 access token
      final accessToken = await GoogleAuthService.getAccessToken();
      final url = '$_baseUrl/applications/$packageName/purchases/subscriptions/$productId/tokens/$purchaseToken';
      
      print('Google Play API: Validating subscription at $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if subscription is active
        // paymentState: 0 = pending, 1 = received
        // cancelReason: null means not cancelled
        final paymentState = data['paymentState'] as int?;
        final cancelReason = data['cancelReason'] as int?;
        final expiryTimeMillis = data['expiryTimeMillis'] as String?;
        
        bool isValid = false;
        
        if (paymentState == 1 && cancelReason == null) {
          // Check if not expired
          if (expiryTimeMillis != null) {
            final expiryTime = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryTimeMillis));
            isValid = expiryTime.isAfter(DateTime.now());
          } else {
            isValid = true; // No expiry time means valid
          }
        }
        
        print('Google Play API: Validation result - $isValid');
        return {
          'isValid': isValid,
          'data': data,
        };
      } else {
        print('Google Play API: Error ${response.statusCode}: ${response.body}');
        return {
          'isValid': null, // null means "unknown, use fallback"
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('Error validating subscription: $e');
      return {
        'isValid': null, // null means "unknown, use fallback"
        'error': e.toString(),
      };
    }
  }
  
  // Fallback to local validation if Google Play API is not available
  static Future<bool> _fallbackLocalValidation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseDate = prefs.getString('purchaseDate');
      final subscriptionType = prefs.getString('subscriptionType');
      
      if (purchaseDate == null || subscriptionType == null) {
        print('Fallback validation: Missing purchase data');
        return false;
      }
      
      final purchaseDateTime = DateTime.parse(purchaseDate);
      final now = DateTime.now();
      final daysSincePurchase = now.difference(purchaseDateTime).inDays;
      
      print('Fallback validation: $daysSincePurchase days since purchase for $subscriptionType');
      
      if (subscriptionType == 'premium_monthly' && daysSincePurchase > 30) {
        print('Fallback validation: Monthly subscription expired');
        return false;
      } else if (subscriptionType == 'premium_yearly' && daysSincePurchase > 365) {
        print('Fallback validation: Yearly subscription expired');
        return false;
      }
      
      print('Fallback validation: Subscription still valid');
      return true;
    } catch (e) {
      print('Error in fallback validation: $e');
      return false;
    }
  }
}
