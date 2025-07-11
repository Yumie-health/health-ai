import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class PaymentConfig {
  static String? _appleMerchantId;
  static String? _googleGatewayMerchantId;

  /// Call this during app startup to fetch remote config values
  static Future<void> loadFromRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    _appleMerchantId = remoteConfig.getString('apple_merchant_id');
    _googleGatewayMerchantId = remoteConfig.getString('google_gateway_merchant_id');
  }

  /// For production: Only use Remote Config. If not available, throw an error.
  static String get appleMerchantId {
    if (_appleMerchantId != null && _appleMerchantId!.isNotEmpty) {
      return _appleMerchantId!;
    }
    throw Exception('Apple Merchant ID not configured in Remote Config.');
  }

  static String get googleGatewayMerchantId {
    if (_googleGatewayMerchantId != null && _googleGatewayMerchantId!.isNotEmpty) {
      return _googleGatewayMerchantId!;
    }
    throw Exception('Google Gateway Merchant ID not configured in Remote Config.');
  }

  static String get applePayConfig => '''
  {
    "provider": "apple_pay",
    "data": {
      "merchantIdentifier": "$appleMerchantId",
      "displayName": "HealthAI",
      "merchantCapabilities": ["3DS", "debit", "credit"],
      "supportedNetworks": ["masterCard", "visa"],
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
  ''';

  static String get googlePayConfig => '''
  {
    "provider": "google_pay",
    "data": {
      "environment": "TEST",
      "apiVersion": 2,
      "apiVersionMinor": 0,
      "allowedPaymentMethods": [
        {
          "type": "CARD",
          "parameters": {
            "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
            "allowedCardNetworks": ["MASTERCARD", "VISA"]
          },
          "tokenizationSpecification": {
            "type": "PAYMENT_GATEWAY",
            "parameters": {
              "gateway": "example",
              "gatewayMerchantId": "$googleGatewayMerchantId"
            }
          }
        }
      ],
      "merchantInfo": {
        "merchantName": "HealthAI"
      },
      "transactionInfo": {
        "totalPriceStatus": "FINAL",
        "totalPrice": "0.00",
        "currencyCode": "USD",
        "countryCode": "US"
      }
    }
  }
  ''';

  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'id': 'monthly_premium',
      'price': '9.99',
      'label': 'Monthly Premium',
      'description': 'Unlimited scans and premium features',
    },
    'yearly': {
      'id': 'yearly_premium',
      'price': '99.99',
      'label': 'Yearly Premium',
      'description': 'Unlimited scans and premium features (Save 17%)',
    },
  };
} 