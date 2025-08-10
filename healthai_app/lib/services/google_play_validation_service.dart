import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/payment_config.dart';

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
      
      final isValid = result['isValid'] as bool? ?? false;
      print('Google Play Validation: API result - $isValid');
      return isValid;
    } catch (e) {
      print('Error checking subscription validity: $e');
      // Fall back to local validation if API fails
      return await _fallbackLocalValidation();
    }
  }
  
  // Validate subscription with Google Play API
  static Future<Map<String, dynamic>> validateSubscription({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      // For now, we'll use a simplified validation approach
      // In production, you'd implement proper OAuth2 with service account
      
      final url = '$_baseUrl/applications/$packageName/purchases/subscriptions/$productId/tokens/$purchaseToken';
      
      // Since we don't have proper OAuth2 setup, we'll use fallback validation
      print('Google Play API: Would validate at $url');
      
      return {
        'isValid': false,
        'error': 'API not fully configured - using fallback',
      };
    } catch (e) {
      print('Error validating subscription: $e');
      return {
        'isValid': false,
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
