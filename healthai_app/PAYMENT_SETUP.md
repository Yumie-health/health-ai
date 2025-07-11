# Payment Setup Guide

## Overview
This app uses Apple Pay and Google Pay for subscription payments. Follow these steps to configure your payment providers.

## 1. Apple Pay Setup

### Prerequisites
- Apple Developer Account
- iOS App ID configured for Apple Pay
- Payment Processing Certificate

### Steps
1. **Create Merchant Identifier**
   - Go to [Apple Developer Portal](https://developer.apple.com)
   - Navigate to Certificates, Identifiers & Profiles
   - Create a new Merchant ID
   - Note down your Merchant ID (format: merchant.com.yourcompany.appname)

2. **Create Payment Processing Certificate**
   - In the same portal, create a Payment Processing Certificate
   - Download and install the certificate

3. **Update Configuration**
   - Open `lib/config/payment_config.dart`
   - Replace `YOUR_APPLE_MERCHANT_ID` with your actual Merchant ID

## 2. Google Pay Setup

### Prerequisites
- Google Pay Business Console Account
- Payment Gateway (Stripe, Square, etc.)

### Steps
1. **Sign up for Google Pay Business Console**
   - Go to [Google Pay Business Console](https://pay.google.com/business)
   - Create your business account

2. **Configure Payment Gateway**
   - Set up with your preferred payment processor (Stripe recommended)
   - Get your Gateway Merchant ID

3. **Update Configuration**
   - Open `lib/config/payment_config.dart`
   - Replace `YOUR_GOOGLE_GATEWAY_MERCHANT_ID` with your actual Gateway Merchant ID

## 3. Testing

### Test Cards
- **Apple Pay**: Use test cards from Apple's documentation
- **Google Pay**: Use test cards from your payment processor

### Test Environment
- Set `environment: "TEST"` in Google Pay config for testing
- Change to `"PRODUCTION"` for live payments

## 4. Production Deployment

### Before Going Live
1. Update merchant IDs in `payment_config.dart`
2. Change Google Pay environment to "PRODUCTION"
3. Test with real cards
4. Ensure your server can handle payment tokens

### Server Integration
The payment tokens need to be processed on your server. You'll need to:
1. Set up a payment processing endpoint
2. Validate payment tokens
3. Activate subscriptions in your database
4. Handle subscription renewals

## 5. Configuration File

The main configuration is in `lib/config/payment_config.dart`:

```dart
class PaymentConfig {
  static const String appleMerchantId = 'YOUR_APPLE_MERCHANT_ID';
  static const String googleGatewayMerchantId = 'YOUR_GOOGLE_GATEWAY_MERCHANT_ID';
  
  // Update these values with your actual merchant IDs
}
```

## 6. Subscription Plans

Current subscription plans are defined in the config:
- **Monthly**: $9.99/month
- **Yearly**: $99.99/year (17% savings)

You can modify these in `payment_config.dart`.

## 7. Troubleshooting

### Common Issues
1. **Apple Pay not showing**: Ensure device supports Apple Pay and user has cards added
2. **Google Pay not showing**: Check if Google Pay is available on the device
3. **Payment fails**: Verify merchant IDs and test with valid test cards

### Debug Mode
Enable debug logging in the subscription service to troubleshoot payment issues.

## 8. Security Notes

- Never commit real merchant IDs to version control
- Use environment variables for production
- Validate all payment tokens on your server
- Implement proper error handling for failed payments

## 9. Next Steps

1. Replace placeholder merchant IDs with your actual IDs
2. Test the payment flow with test cards
3. Set up server-side payment processing
4. Deploy to production with real merchant IDs 