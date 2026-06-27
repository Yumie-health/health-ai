import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'subscription_service.dart';
import 'consent_service.dart';

class ReceiptValidationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Validate subscription receipt with backend
  static Future<bool> validateReceipt(PurchaseDetails purchase) async {
    try {
      if (Platform.isIOS) {
        try {
          final isValid = await _validateIOSReceipt(purchase);
          // In simulator/dev builds, Apple's verifyReceipt won't validate StoreKit test receipts.
          // Allow purchases to proceed for development convenience. This never runs in release.
          if (!isValid && (kDebugMode || kProfileMode)) {
            print(
              'iOS receipt validation failed in debug/profile – treating as valid for simulator testing',
            );
            return true;
          }
          return isValid;
        } catch (e) {
          // Never hard-fail the flow on iOS. Log and allow UX to continue; backend/server will reconcile.
          print('iOS receipt validation threw error: $e');
          if (kDebugMode || kProfileMode) {
            return true;
          }
          return false;
        }
      } else if (Platform.isAndroid) {
        // Treat Google Play confirmation as sufficient in-app; backend validation is best-effort
        final backendValid = await _validateAndroidReceipt(purchase);
        return backendValid ||
            purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored;
      }
      return false;
    } catch (e) {
      print('Receipt validation error: $e');
      // For Android, if validation fails but Google Play confirmed the purchase,
      // we should still consider it valid. This handles cases where our backend
      // validation is temporarily unavailable or misconfigured.
      if (Platform.isAndroid && purchase.status == PurchaseStatus.purchased) {
        print(
          'Android purchase confirmed by Google Play - treating as valid despite validation error',
        );
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
        print(
          'Google Play confirmed purchase - treating as valid despite validation error',
        );
        return true;
      }

      return false;
    }
  }

  /// Save validated subscription to SharedPreferences
  static Future<void> saveValidatedSubscription(
    PurchaseDetails purchase, {
    bool isRestore = false,
  }) async {
    try {
      // For iOS, we should NOT save to local SharedPreferences directly
      // Instead, let SubscriptionService handle it to ensure user-specific storage

      print(
        '${isRestore ? "RESTORE" : "PURCHASE"} - Validated subscription: ${purchase.productID}',
      );
      print(
        'Purchase token: ${purchase.verificationData.serverVerificationData.substring(0, 10)}...',
      );
      print('Order ID: ${purchase.purchaseID}');

      // CRITICAL: For restores, we need to verify the purchase belongs to current user
      // This prevents cross-account premium access
      if (isRestore) {
        print('⚠️ RESTORE DETECTED - Verifying purchase ownership...');

        // For now, we'll store the purchase details locally but NOT grant premium
        // The user must have originally purchased with this account
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'lastRestoredPurchaseToken',
          purchase.verificationData.serverVerificationData,
        );
        await prefs.setString('lastRestoredOrderId', purchase.purchaseID ?? '');
        await prefs.setString('lastRestoredProductId', purchase.productID);

        print('❌ RESTORE BLOCKED - Purchase ownership verification required');
        print(
          'To restore purchases, you must use the same account that originally purchased',
        );
        return;
      }

      // Track purchase event in Firebase Analytics
      // Respect regional consent preferences for analytics/ads measurement
      final analyticsAllowed = ConsentService.instance.analyticsAllowed;
      if (analyticsAllowed) {
        await FirebaseAnalytics.instance.logEvent(
          name: 'purchase',
          parameters: {
            'product_id': purchase.productID,
            'transaction_id': purchase.purchaseID ?? '',
            'value':
                purchase.productID.contains('yearly')
                    ? 49.99
                    : 7.99, // Fallback value for analytics
            'currency': 'USD', // Fallback currency for analytics
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
      }

      // Only save subscription for NEW purchases, not restores
      try {
        await SubscriptionService().setSubscription(purchase.productID);

        // For iOS, also save the purchase token for future validation
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'purchaseToken',
          purchase.verificationData.serverVerificationData,
        );
        await prefs.setString('orderId', purchase.purchaseID ?? '');
      } catch (e) {
        print(
          'Non-fatal: setSubscription from saveValidatedSubscription failed: $e',
        );
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
        } else if (subscriptionType == 'premium_yearly' &&
            daysSincePurchase > 365) {
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
