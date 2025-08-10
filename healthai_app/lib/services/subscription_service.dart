import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'logging_service.dart';
import 'native_billing_service.dart';
import 'production_integrity_service.dart';
import 'receipt_validation_service.dart';
import 'google_play_validation_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();
  
  Timer? _subscriptionCheckTimer;

  // Initialize billing service
  Future<void> initializeBilling() async {
    try {
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

  // Check if user has premium subscription
  Future<bool> isPremiumUser() async {
    try {
      // First check integrity before subscription operations
      final isIntegrityValid = await ProductionIntegrityService.checkBeforePremiumAccess();
      if (!isIntegrityValid) {
        print('Integrity check failed - denying premium access');
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      
      if (isPremium) {
        // Check with Google Play for real-time subscription status
        final isValid = await GooglePlayValidationService.checkSubscriptionValidity();
        if (!isValid) {
          // Subscription is no longer valid, clear premium status
          await clearSubscription();
          return false;
        }
      }
      
      return isPremium;
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
      print('Subscription set: $productId');
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
        final isValid = await GooglePlayValidationService.checkSubscriptionValidity();
        if (!isValid) {
          await clearSubscription();
          print('Subscription expired - premium access removed');
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