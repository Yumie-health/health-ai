import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class PaymentConfig {
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'id': 'premium_monthly',
      'price': '7.99',
      'label': 'Monthly Premium',
      'description': 'No ads',
    },
    'yearly': {
      'id': 'premium_yearly',
      'price': '49.99',
      'label': 'Yearly Premium',
      'description': 'No ads (Save 37%)',
    },
  };
} 