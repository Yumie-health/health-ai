import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      
      // Initialize Google Play Validation Service (Android only)
      if (Platform.isAndroid) {
        await GooglePlayValidationService.initialize();
      }
      
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, cannot check premium status');
        return false;
      }

      // 1) Check Firestore first for user-specific premium status
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>? ?? {};
          final firestoreIsPremium = userData['isPremium'] ?? false;
          final firestoreSubscriptionType = userData['subscriptionType'];
          final firestorePurchaseDate = userData['purchaseDate'];
          
          print('Firestore premium status for ${user.email}: $firestoreIsPremium, type: $firestoreSubscriptionType');
          
          if (firestoreIsPremium && firestoreSubscriptionType != null) {
            // User has premium in Firestore - this is the source of truth
            // Sync to local storage for offline access
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isPremium', true);
            await prefs.setString('subscriptionType', firestoreSubscriptionType);
            if (firestorePurchaseDate != null) {
              await prefs.setString('purchaseDate', firestorePurchaseDate);
            }
            // Pull cancellation/expiry if present
            final cancelled = userData['subscriptionCancelled'] as bool? ?? false;
            final expiryIso = userData['subscriptionExpiryDate'] as String?;
            await prefs.setBool('subscriptionCancelled', cancelled);
            if (expiryIso != null) {
              await prefs.setString('subscriptionExpiryDate', expiryIso);
            } else {
              await prefs.remove('subscriptionExpiryDate');
            }
            premium.value = true;
            return true;
          }
        }
      } catch (e) {
        print('Error checking Firestore premium status: $e');
        // Continue to local check as fallback
      }

      // 2) For iOS, if no Firestore premium, clear any local premium status
      // This prevents cross-account premium access
      if (Platform.isIOS) {
        final prefs = await SharedPreferences.getInstance();
        final localIsPremium = prefs.getBool('isPremium') ?? false;
        if (localIsPremium) {
          print('Clearing local premium status as Firestore shows no premium');
          await clearLocalSubscriptionData();
        }
      }

      // 3) If no premium in Firestore, perform integrity check
      final isIntegrityValid = await ProductionIntegrityService.checkBeforePremiumAccess();
      if (!isIntegrityValid) {
        print('Integrity check failed and no Firestore premium present');
        return false;
      }

      // 4) No premium found
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
      final user = FirebaseAuth.instance.currentUser;
      
      // 1) Clear from Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isPremium': false,
          'subscriptionType': null,
          'purchaseDate': null,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      
      // 2) Clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isPremium');
      await prefs.remove('subscriptionType');
      await prefs.remove('purchaseDate');
      
      print('Subscription data cleared for user: ${user?.uid ?? 'unknown'}');
      premium.value = false;
    } catch (e) {
      print('Error clearing subscription: $e');
    }
  }

  // Clear local subscription data when user signs out (device-specific data)
  Future<void> clearLocalSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isPremium');
      await prefs.remove('subscriptionType');
      await prefs.remove('purchaseDate');
      await prefs.remove('hadPremiumEver');
      
      print('Local subscription data cleared on sign out');
      premium.value = false;
    } catch (e) {
      print('Error clearing local subscription data: $e');
    }
  }

  // Debug method to check current premium status
  Future<void> debugPremiumStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('=== DEBUG PREMIUM STATUS ===');
      print('Current user: ${user?.uid ?? 'none'}');
      print('Current user email: ${user?.email ?? 'none'}');
      
      // Check Firestore
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final userData = doc.data() as Map<String, dynamic>? ?? {};
            print('Firestore isPremium: ${userData['isPremium'] ?? false}');
            print('Firestore subscriptionType: ${userData['subscriptionType'] ?? 'none'}');
            print('Firestore purchaseDate: ${userData['purchaseDate'] ?? 'none'}');
          } else {
            print('Firestore: User document does not exist');
          }
        } catch (e) {
          print('Firestore error: $e');
        }
      }
      
      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      print('Local isPremium: ${prefs.getBool('isPremium') ?? false}');
      print('Local subscriptionType: ${prefs.getString('subscriptionType') ?? 'none'}');
      print('Local purchaseDate: ${prefs.getString('purchaseDate') ?? 'none'}');
      print('Local hadPremiumEver: ${prefs.getBool('hadPremiumEver') ?? false}');
      
      // Check current premium value
      print('Current premium.value: ${premium.value}');
      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }

  Future<void> setSubscription(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, cannot set subscription');
        return;
      }

      final purchaseDate = DateTime.now().toIso8601String();
      
      // 1) Save to Firestore (user-specific, source of truth)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isPremium': true,
        'subscriptionType': productId,
        'purchaseDate': purchaseDate,
        'subscriptionCancelled': false,
        'subscriptionExpiryDate': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // 2) Save to local storage (for immediate UX)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setString('subscriptionType', productId);
      await prefs.setString('purchaseDate', purchaseDate);
      await prefs.setBool('hadPremiumEver', true);
      await prefs.setBool('subscriptionCancelled', false);
      await prefs.remove('subscriptionExpiryDate');
      
      print('Subscription set: $productId for user: ${user.uid}');
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
        if (purchaseToken != null && subscriptionType != null) {
          if (Platform.isAndroid) {
            final details = await GooglePlayValidationService.checkSubscriptionDetails();
            final isActive = details['isActive'] as bool? ?? false;
            final isCancelled = details['isCancelled'] as bool? ?? false;
            final expiryIso = details['expiryDate'] as String?;
            if (!isActive) {
              await clearSubscription();
              print('Subscription expired - premium access removed');
            } else {
              // Persist cancellation and expiry info
              if (isCancelled || expiryIso != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'subscriptionCancelled': isCancelled,
                    'subscriptionExpiryDate': expiryIso,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });
                }
                await prefs.setBool('subscriptionCancelled', isCancelled);
                if (expiryIso != null) {
                  await prefs.setString('subscriptionExpiryDate', expiryIso);
                }
              } else {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'subscriptionCancelled': false,
                    'subscriptionExpiryDate': null,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });
                }
                await prefs.setBool('subscriptionCancelled', false);
                await prefs.remove('subscriptionExpiryDate');
              }
            }
          } else if (Platform.isIOS) {
            // iOS: server-side receipt validation occurs at purchase/restore time.
            // Periodic background checks are not required here, so skip.
          }
        } else {
          print('Subscription validation skipped - missing purchase data (purchaseToken: ${purchaseToken != null}, subscriptionType: ${subscriptionType != null})');
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