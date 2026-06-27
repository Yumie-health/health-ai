import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeBillingService {
  static const MethodChannel _channel = MethodChannel('billing_channel');

  /// Initialize the billing service
  static Future<bool> initializeBilling() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final bool result = await _channel.invokeMethod('initializeBilling');
        return result;
      }
      return false;
    } catch (e) {
      print('Error initializing billing: $e');
      return false;
    }
  }

  /// Purchase a subscription
  static Future<String?> purchaseSubscription(String productId) async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final String? result = await _channel.invokeMethod(
          'purchaseSubscription',
          {'productId': productId},
        );
        return result;
      }
      return null;
    } catch (e) {
      print('Error purchasing subscription: $e');
      return null;
    }
  }

  /// Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final bool result = await _channel.invokeMethod('restorePurchases');
        return result;
      }
      return false;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
}
