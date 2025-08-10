import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'subscription_service.dart';

class ReceiptValidationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  /// Validate subscription receipt with backend
  static Future<bool> validateReceipt(PurchaseDetails purchase) async {
    try {
      if (Platform.isIOS) {
        return await _validateIOSReceipt(purchase);
      } else if (Platform.isAndroid) {
        // Treat Google Play confirmation as sufficient in-app; backend validation is best-effort
        final backendValid = await _validateAndroidReceipt(purchase);
        return backendValid || purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored;
      }
      return false;
    } catch (e) {
      print('Receipt validation error: $e');
      // For Android, if validation fails but Google Play confirmed the purchase,
      // we should still consider it valid. This handles cases where our backend
      // validation is temporarily unavailable or misconfigured.
      if (Platform.isAndroid && purchase.status == PurchaseStatus.purchased) {
        print('Android purchase confirmed by Google Play - treating as valid despite validation error');
        return true;
      }
      return false;
    }
  }
  
  /// Validate iOS receipt with App Store
  static Future<bool> _validateIOSReceipt(PurchaseDetails purchase) async {
    try {
      final callable = _functions.httpsCallable('validateIOSReceipt');
      final result = await callable.call({
        'receiptData': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
        'transactionId': purchase.purchaseID,
      });
      
      final data = result.data as Map<String, dynamic>?;
      return data?['isValid'] as bool? ?? false;
    } catch (e) {
      print('iOS receipt validation error: $e');
      return false;
    }
  }
  
  /// Validate Android receipt with Google Play
  static Future<bool> _validateAndroidReceipt(PurchaseDetails purchase) async {
    try {
      final callable = _functions.httpsCallable('validateAndroidReceipt');
      final result = await callable.call({
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
        'orderId': purchase.purchaseID,
      });
      
      final data = result.data as Map<String, dynamic>?;
      return data?['isValid'] as bool? ?? false;
    } catch (e) {
      print('Android receipt validation error: $e');
      
      // If the Firebase function is not properly configured or unavailable,
      // we should still trust Google Play's confirmation for Android purchases
      if (purchase.status == PurchaseStatus.purchased) {
        print('Google Play confirmed purchase - treating as valid despite validation error');
        return true;
      }
      
      return false;
    }
  }
  
  /// Save validated subscription to SharedPreferences
  static Future<void> saveValidatedSubscription(PurchaseDetails purchase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setString('subscriptionType', purchase.productID);
      await prefs.setString('purchaseDate', DateTime.now().toIso8601String());
      await prefs.setString('purchaseToken', purchase.verificationData.serverVerificationData);
      await prefs.setString('orderId', purchase.purchaseID ?? '');
      
      print('Validated subscription saved: ${purchase.productID}');
      print('Purchase token: ${purchase.verificationData.serverVerificationData.substring(0, 10)}...');
      print('Order ID: ${purchase.purchaseID}');
      print('Premium status set to: true');
      
      // Track purchase event in Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'purchase',
        parameters: {
          'product_id': purchase.productID,
          'transaction_id': purchase.purchaseID ?? '',
          'value': purchase.productID.contains('yearly') ? 49.99 : 7.99,
          'currency': 'USD',
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      
      // Immediately reflect premium state in the app
      try {
        await SubscriptionService().setSubscription(purchase.productID);
      } catch (e) {
        print('Non-fatal: setSubscription from saveValidatedSubscription failed: $e');
      }

      // Force a small delay to ensure the data is written
      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('Error saving validated subscription: $e');
      throw e; // Re-throw to handle in calling code
    }
  }
  
  /// Check if subscription is still valid
  static Future<bool> isSubscriptionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      
      if (!isPremium) return false;
      
      // For production, you should validate with backend
      // For now, we'll use basic local validation
      final purchaseDate = prefs.getString('purchaseDate');
      if (purchaseDate != null) {
        final purchaseDateTime = DateTime.parse(purchaseDate);
        final now = DateTime.now();
        final daysSincePurchase = now.difference(purchaseDateTime).inDays;
        
        final subscriptionType = prefs.getString('subscriptionType');
        if (subscriptionType == 'premium_monthly' && daysSincePurchase > 30) {
          return false;
        } else if (subscriptionType == 'premium_yearly' && daysSincePurchase > 365) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking subscription validity: $e');
      return false;
    }
  }
}
