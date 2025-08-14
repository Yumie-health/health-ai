import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'native_billing_service.dart';
import 'production_integrity_service.dart';
import 'google_play_validation_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();
  
  Timer? _subscriptionCheckTimer;
  final ValueNotifier<bool> premium = ValueNotifier<bool>(false);

  bool get isPremiumCached => premium.value;
  ValueListenable<bool> watchPremium() => premium;

  Future<void> _initializeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      premium.value = isPremium;
    } catch (e) {
      // Best-effort; keep default false
    }
  }

  // Initialize billing service
  Future<void> initializeBilling() async {
    try {
      // Load cached premium status immediately for offline UX
      await _initializeCache();
      if (Platform.isAndroid) {
        await NativeBillingService.initializeBilling();
      }
      
      // Initialize Google Play Validation Service
      await GooglePlayValidationService.initialize();
      
      // Start periodic subscription checking (every 24 hours)
      _startPeriodicSubscriptionCheck();
    } catch (e) {
      print('Error initializing billing: $e');
    }
  }
  
  // Start periodic subscription status checking
  void _startPeriodicSubscriptionCheck() {
    _subscriptionCheckTimer?.cancel();
    _subscriptionCheckTimer = Timer.periodic(Duration(hours: 24), (timer) async {
      await refreshSubscriptionStatus();
    });
  }
  
  // Start real-time subscription monitoring (checks every 6 hours)
  void startRealTimeMonitoring() {
    _subscriptionCheckTimer?.cancel();
    _subscriptionCheckTimer = Timer.periodic(Duration(hours: 6), (timer) async {
      await refreshSubscriptionStatus();
    });
  }
  
  // Force immediate subscription check
  Future<void> forceSubscriptionCheck() async {
    await refreshSubscriptionStatus();
  }
  
  // Force refresh subscription status and return current status
  Future<bool> forceRefreshAndCheck() async {
    try {
      await refreshSubscriptionStatus();
      return await isPremiumUser();
    } catch (e) {
      print('Error in force refresh and check: $e');
      return false;
    }
  }

  // Check if user has premium subscription
  Future<bool> isPremiumUser() async {
    try {
      // 1) Trust local entitlement immediately for a smooth UX (especially after restore)
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      final subscriptionType = prefs.getString('subscriptionType');
      print('Checking premium status - local isPremium: $isPremium, type: $subscriptionType');

      if (isPremium) {
        // Background validation will correct stale/invalid entitlements if needed
        return true;
      }

      // 2) If no local entitlement, perform integrity check as an additional guard
      //    but do NOT block users who legitimately restored purchases earlier.
      final isIntegrityValid = await ProductionIntegrityService.checkBeforePremiumAccess();
      if (!isIntegrityValid) {
        print('Integrity check failed and no local entitlement present');
        return false;
      }

      // 3) No local entitlement and integrity OK → not premium
      return false;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }





  Future<String?> getSubscriptionType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('subscriptionType');
    } catch (e) {
      print('Error getting subscription type: $e');
      return null;
    }
  }

  Future<DateTime?> getPurchaseDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseDateString = prefs.getString('purchaseDate');
      if (purchaseDateString != null) {
        return DateTime.parse(purchaseDateString);
      }
      return null;
    } catch (e) {
      print('Error getting purchase date: $e');
      return null;
    }
  }



  Future<void> clearSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isPremium');
      await prefs.remove('subscriptionType');
      await prefs.remove('purchaseDate');
      print('Subscription data cleared');
      premium.value = false;
    } catch (e) {
      print('Error clearing subscription: $e');
    }
  }

  Future<void> setSubscription(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setString('subscriptionType', productId);
      await prefs.setString('purchaseDate', DateTime.now().toIso8601String());
      await prefs.setBool('hadPremiumEver', true);
      print('Subscription set: $productId');
      premium.value = true;
      
      // Track subscription event in Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'subscription_start',
        parameters: {
          'product_id': productId,
          'subscription_type': productId.contains('yearly') ? 'yearly' : 'monthly',
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      
      // Do not invalidate immediately; reflect premium now and validate later
    } catch (e) {
      print('Error setting subscription: $e');
    }
  }

  // Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'isPremium': prefs.getBool('isPremium') ?? false,
        'subscriptionType': prefs.getString('subscriptionType'),
        'purchaseDate': prefs.getString('purchaseDate'),
      };
    } catch (e) {
      print('Error getting subscription status: $e');
      return {};
    }
  }

  // Refresh subscription status from Google Play
  Future<void> refreshSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      
      if (isPremium) {
        final purchaseToken = prefs.getString('purchaseToken');
        final subscriptionType = prefs.getString('subscriptionType');
        
        // Only validate if we have complete purchase data
        // This prevents clearing valid subscriptions due to missing purchase tokens
        if (purchaseToken != null && subscriptionType != null) {
          final isValid = await GooglePlayValidationService.checkSubscriptionValidity();
          if (!isValid) {
            await clearSubscription();
            print('Subscription expired - premium access removed');
          }
        } else {
          print('Subscription validation skipped - missing purchase data (purchaseToken: ${purchaseToken != null}, subscriptionType: ${subscriptionType != null})');
          // Don't clear subscription if we just don't have the purchase token
          // This can happen for restored purchases or existing subscriptions
        }
      }
    } catch (e) {
      print('Error refreshing subscription status: $e');
    }
  }

  // Check if subscription is about to expire (within 7 days)
  Future<bool> isSubscriptionExpiringSoon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseDate = prefs.getString('purchaseDate');
      final subscriptionType = prefs.getString('subscriptionType');
      
      if (purchaseDate == null || subscriptionType == null) {
        return false;
      }
      
      final purchaseDateTime = DateTime.parse(purchaseDate);
      final now = DateTime.now();
      final daysSincePurchase = now.difference(purchaseDateTime).inDays;
      
      if (subscriptionType == 'premium_monthly') {
        return daysSincePurchase >= 23; // Warn 7 days before expiry
      } else if (subscriptionType == 'premium_yearly') {
        return daysSincePurchase >= 358; // Warn 7 days before expiry
      }
      
      return false;
    } catch (e) {
      print('Error checking if subscription is expiring soon: $e');
      return false;
    }
  }


  void dispose() {
    _subscriptionCheckTimer?.cancel();
  }
} 