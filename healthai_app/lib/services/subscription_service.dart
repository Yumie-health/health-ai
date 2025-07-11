import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:pay/pay.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logging_service.dart';
import '../config/payment_config.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  late Pay _payClient;
  StreamSubscription? _paymentResultSubscription;
  bool _isInitialized = false;

  // Subscription plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = PaymentConfig.subscriptionPlans;

  // Payment configurations
  static const String _applePayConfig = PaymentConfig.applePayConfig;
  static const String _googlePayConfig = PaymentConfig.googlePayConfig;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize payment configurations
      final applePayConfig = PaymentConfiguration.fromJsonString(_applePayConfig);
      final googlePayConfig = PaymentConfiguration.fromJsonString(_googlePayConfig);

      _payClient = Pay({
        PayProvider.apple_pay: applePayConfig,
        PayProvider.google_pay: googlePayConfig,
      });

      // Set up payment result listener for Android
      if (Platform.isAndroid) {
        _setupPaymentResultListener();
      }

      _isInitialized = true;
      log.info('Subscription service initialized successfully');
    } catch (e) {
      log.error('Failed to initialize subscription service', e);
      rethrow;
    }
  }

  void _setupPaymentResultListener() {
    const eventChannel = EventChannel('plugins.flutter.io/pay/payment_result');
    _paymentResultSubscription = eventChannel
        .receiveBroadcastStream()
        .map((result) => jsonDecode(result as String) as Map<String, dynamic>)
        .listen(
      (result) {
        _handlePaymentResult(result);
      },
      onError: (error) {
        log.error('Payment result error', error);
      },
    );
  }

  void _handlePaymentResult(Map<String, dynamic> result) {
    log.info('Payment result received', result);
    
    // Handle the payment result
    // You'll need to send this to your server for processing
    _processPaymentResult(result);
  }

  Future<void> _processPaymentResult(Map<String, dynamic> result) async {
    try {
      // Send payment result to your server
      // This is where you'd validate the payment and activate the subscription
      await _activateSubscription(result);
    } catch (e) {
      log.error('Failed to process payment result', e);
    }
  }

  Future<void> _activateSubscription(Map<String, dynamic> paymentResult) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log.warning('No authenticated user for subscription activation');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'subscriptionStatus': 'active',
        'subscriptionType': paymentResult['plan'] ?? 'premium',
        'subscriptionStartDate': FieldValue.serverTimestamp(),
        'paymentToken': paymentResult['token'] ?? '',
        'lastPaymentDate': FieldValue.serverTimestamp(),
      });

      // Save subscription status locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setString('subscriptionType', paymentResult['plan'] ?? 'premium');

      log.info('Subscription activated successfully');
    } catch (e) {
      log.error('Failed to activate subscription', e);
      rethrow;
    }
  }

  Future<bool> userCanPay(PayProvider provider) async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _payClient.userCanPay(provider);
    } catch (e) {
      log.error('Error checking if user can pay', e);
      return false;
    }
  }

  Future<void> processPayment(PayProvider provider, String planId) async {
    if (!_isInitialized) await initialize();

    final plan = subscriptionPlans[planId];
    if (plan == null) {
      throw Exception('Invalid plan ID: $planId');
    }

    final paymentItems = [
      PaymentItem(
        label: plan['label'],
        amount: plan['price'],
        status: PaymentItemStatus.final_price,
      )
    ];

    try {
      final result = await _payClient.showPaymentSelector(provider, paymentItems);
      
      // For iOS, the result is returned directly
      if (Platform.isIOS && result != null) {
        _handlePaymentResult({
          'token': result['token'],
          'plan': planId,
          'amount': plan['price'],
        });
      }
      // For Android, the result comes through the event channel
    } catch (e) {
      log.error('Payment failed', e);
      rethrow;
    }
  }

  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  Future<String?> getSubscriptionType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('subscriptionType');
  }

  Future<void> checkSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final subscriptionStatus = data['subscriptionStatus'] as String?;
        final subscriptionType = data['subscriptionType'] as String?;

        if (subscriptionStatus == 'active') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isPremium', true);
          await prefs.setString('subscriptionType', subscriptionType ?? 'premium');
        }
      }
    } catch (e) {
      log.error('Failed to check subscription status', e);
    }
  }

  void dispose() {
    _paymentResultSubscription?.cancel();
    _paymentResultSubscription = null;
  }
} 