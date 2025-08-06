# Android Subscription Setup Guide

## Overview
This guide will help you set up Google Play subscriptions for your HealthAI app using the native Android Billing Library.

## 1. Google Play Console Setup

### Create Subscription Products
1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to **Monetization** > **Products** > **Subscriptions**
3. Create two subscription products:

#### Monthly Premium
- **Product ID**: `premium_monthly`
- **Name**: Monthly Premium
- **Description**: No ads, unlimited scans
- **Price**: $7.99/month
- **Billing period**: Monthly

#### Yearly Premium  
- **Product ID**: `premium_yearly`
- **Name**: Yearly Premium
- **Description**: No ads, unlimited scans (Save 37%)
- **Price**: $49.99/year
- **Billing period**: Yearly

### Configure Subscription Details
1. Set **Free trial** (optional): 7 days
2. Set **Grace period**: 3 days
3. Enable **Auto-renewal**
4. Set **Subscription period**: Monthly/Yearly
5. Configure **Pricing**: Your chosen prices

## 2. App Configuration

### Update AndroidManifest.xml
Add billing permission:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### Update build.gradle.kts
The billing library is already added:
```kotlin
implementation("com.android.billingclient:billing-ktx:6.2.1")
```

## 3. Testing

### Test Accounts
1. Create test accounts in Google Play Console
2. Add test accounts to your app's testing track
3. Use test accounts to make purchases without real money

### Test Products
Use these test product IDs during development:
- `android.test.purchased` - Always returns success
- `android.test.canceled` - Always returns canceled
- `android.test.item_unavailable` - Always returns unavailable

## 4. Production Deployment

### Before Release
1. **Remove test products** from your code
2. **Use real product IDs**: `premium_monthly`, `premium_yearly`
3. **Test with real accounts** (not test accounts)
4. **Verify billing flow** works correctly
5. **Test subscription restoration**

### Release Checklist
- [ ] Real product IDs configured
- [ ] Billing permissions added
- [ ] Subscription validation working
- [ ] Purchase restoration working
- [ ] Integrity checks integrated
- [ ] Error handling implemented
- [ ] Tested with real accounts

## 5. Integration with Your App

### Initialize Billing
```dart
// In your main.dart or app initialization
await SubscriptionService().initializeBilling();
```

### Check Premium Status
```dart
final isPremium = await SubscriptionService().isPremiumUser();
if (isPremium) {
  // Show premium features
} else {
  // Show paywall
}
```

### Handle Purchases
```dart
// In your subscription page
final result = await NativeBillingService.purchaseSubscription('premium_monthly');
if (result != null) {
  // Handle successful purchase
}
```

## 6. Server-Side Verification

### Firebase Functions
Your `verifyPlayIntegrityCallable` function is already set up to verify purchases server-side.

### Purchase Verification
```dart
// Verify purchase with your backend
final isValid = await ProductionIntegrityService.checkBeforePurchase();
if (isValid) {
  // Proceed with purchase
}
```

## 7. Common Issues & Solutions

### Issue: "Product not found"
**Solution**: 
- Verify product IDs match Google Play Console
- Ensure app is published to testing track
- Check that test accounts are added

### Issue: "Billing not available"
**Solution**:
- Verify billing permission is added
- Check device has Google Play Services
- Ensure app is signed with correct key

### Issue: "Purchase not acknowledged"
**Solution**:
- Check that `acknowledgePurchase()` is called
- Verify purchase token is valid
- Ensure billing client is connected

## 8. Monitoring & Analytics

### Google Play Console
- Monitor subscription metrics
- Track conversion rates
- Analyze churn rates

### Firebase Analytics
- Track purchase events
- Monitor subscription status
- Analyze user behavior

## 9. Security Best Practices

### Integrity Checks
- Always verify device integrity before purchases
- Use Play Integrity API for validation
- Verify purchases server-side

### Purchase Validation
- Validate purchase tokens server-side
- Check subscription status regularly
- Implement proper error handling

## 10. Testing Checklist

### Development Testing
- [ ] Test with test accounts
- [ ] Verify billing flow works
- [ ] Test subscription restoration
- [ ] Check error handling
- [ ] Validate integrity checks

### Production Testing
- [ ] Test with real accounts
- [ ] Verify real product IDs
- [ ] Test purchase flow end-to-end
- [ ] Validate server-side verification
- [ ] Check subscription management

## 11. Support & Troubleshooting

### Debug Logs
Enable debug logging to troubleshoot issues:
```dart
// Add to your billing service
print('Billing debug: $message');
```

### Common Error Codes
- `BILLING_UNAVAILABLE`: Billing not available
- `DEVELOPER_ERROR`: Invalid product ID
- `ITEM_NOT_OWNED`: Product not purchased
- `ITEM_UNAVAILABLE`: Product not available

### Getting Help
- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Flutter in_app_purchase Documentation](https://pub.dev/packages/in_app_purchase)
- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)

## 12. Next Steps

1. **Set up products** in Google Play Console
2. **Test with test accounts** 
3. **Deploy to testing track**
4. **Test with real accounts**
5. **Deploy to production**

Your Android subscription system is now ready! 🎉
