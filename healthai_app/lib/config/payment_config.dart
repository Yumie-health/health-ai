class PaymentConfig {
  // Replace these with your actual merchant identifiers
  static const String appleMerchantId = 'merchant.me.yumie.yumie';
  static const String googleGatewayMerchantId = 'BCR2DN4TTXY5F72E';
  
  // Apple Pay configuration
  static const String applePayConfig = '''
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

  // Google Pay configuration
  static const String googlePayConfig = '''
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

  // Subscription plans
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

  // Update these values when you have your merchant IDs
  static void updateMerchantIds({
    required String appleMerchantId,
    required String googleGatewayMerchantId,
  }) {
    // This method can be used to dynamically update merchant IDs
    // For now, you'll need to manually update the constants above
  }
} 