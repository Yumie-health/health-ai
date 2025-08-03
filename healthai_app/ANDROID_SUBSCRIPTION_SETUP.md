# Android Subscription Setup Guide

## Overview
This guide helps you set up Android subscriptions using Google Play Billing Library. The `in_app_purchase` package automatically handles both iOS and Android, so most of your existing code will work without changes!

## Current Implementation Status

### ✅ What's Already Working
1. **Cross-Platform Package**: `in_app_purchase: ^3.1.13` works on both iOS and Android
2. **Same Product IDs**: `premium_monthly` and `premium_yearly` work on both platforms
3. **Same Purchase Flow**: Your existing subscription page works on Android
4. **Same Error Handling**: All error handling works on Android
5. **Same Local Storage**: Subscription status is stored the same way

### 🔧 What Needs Setup

## 1. Google Play Console Setup

### Step 1: Create Subscription Products
1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to **Monetization** → **Products** → **Subscriptions**
3. Create two subscription products:

**Monthly Subscription:**
- Product ID: `premium_monthly`
- Name: "Monthly Premium"
- Description: "No ads"
- Price: $7.99/month
- Billing period: Monthly

**Yearly Subscription:**
- Product ID: `premium_yearly`
- Name: "Yearly Premium"
- Description: "No ads (Save 37%)"
- Price: $49.99/year
- Billing period: Yearly

### Step 2: Configure App
1. In Google Play Console, go to **Setup** → **App content**
2. Ensure your app is configured for in-app purchases
3. Add your app to the **Testing** track for testing

## 2. Android Configuration

### Step 1: Update AndroidManifest.xml
Add billing permission (if not already present):

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### Step 2: Test Account Setup
1. Create test accounts in Google Play Console
2. Add test accounts to your app's testing track
3. Use these accounts for testing purchases

## 3. Testing Android Subscriptions

### Step 1: Build for Android
```bash
flutter build apk --release
```

### Step 2: Install on Test Device
```bash
flutter install
```

### Step 3: Test Purchase Flow
1. Use a test Google account
2. Navigate to subscription page
3. Attempt to purchase
4. Verify subscription activation

## 4. Android-Specific Considerations

### Testing Environment
- **Internal Testing**: Use Google Play Console internal testing
- **Closed Testing**: Use closed testing for beta users
- **Open Testing**: Use open testing for wider audience

### Test Accounts
- Create test accounts in Google Play Console
- Use these accounts on test devices
- Test with different payment methods

### Debug Information
Monitor these logs for Android:
```
IAP Available: true
Loaded products: [premium_monthly: Monthly Premium - $7.99, premium_yearly: Yearly Premium - $49.99]
Purchase status: purchased for product: premium_monthly
```

## 5. Production Checklist

### Google Play Console:
- [ ] Subscription products are created and active
- [ ] Pricing is set correctly
- [ ] App is configured for in-app purchases
- [ ] App is published to production track
- [ ] Test accounts are set up

### Code Verification:
- [ ] Product IDs match Google Play Console exactly
- [ ] Error handling works on Android
- [ ] Purchase restoration works
- [ ] Subscription status is properly managed

### Testing:
- [ ] Test with Google Play test accounts
- [ ] Test purchase flow end-to-end
- [ ] Test restore purchases
- [ ] Test subscription expiration
- [ ] Test on multiple Android devices

## 6. Common Android Issues

### Issue: "Products not found"
**Solution**:
- Verify product IDs match exactly in Google Play Console
- Ensure products are active and approved
- Check that you're using the correct package name

### Issue: "In-app purchases are not available"
**Solution**:
- Test on a physical Android device
- Ensure device has Google Play Services
- Check that the device supports in-app purchases

### Issue: Purchase fails
**Solution**:
- Use a valid Google Play test account
- Ensure the test account has a valid payment method
- Check that the app is signed with the correct key

## 7. Cross-Platform Testing

### Same Code, Both Platforms
Your existing subscription code works on both platforms:

```dart
// This works on both iOS and Android
final InAppPurchase _iap = InAppPurchase.instance;
final Set<String> _kProductIds = {'premium_monthly', 'premium_yearly'};

// Purchase flow is the same
_iap.buyNonConsumable(purchaseParam: purchaseParam);

// Error handling is the same
if (purchase.status == PurchaseStatus.purchased) {
  // Handle successful purchase
}
```

### Platform-Specific Features
The `in_app_purchase` package automatically handles:
- iOS: App Store integration
- Android: Google Play Billing integration
- Error messages are platform-appropriate
- Purchase restoration works on both platforms

## 8. Testing Commands

### Build for Android:
```bash
flutter build apk --release
flutter install
```

### Test on Android Device:
```bash
flutter run --release
```

### Check Android Logs:
```bash
flutter logs
```

## 9. Next Steps

1. **Set up Google Play Console**: Create subscription products
2. **Test on Android Device**: Verify purchase flow works
3. **Publish to Testing Track**: Use internal testing
4. **Submit for Review**: Once testing is complete

## 10. Support Resources

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Flutter in_app_purchase Package](https://pub.dev/packages/in_app_purchase)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

## Current Implementation Files

- `lib/subscription_page.dart` - Works on both iOS and Android
- `lib/services/subscription_service.dart` - Works on both platforms
- `lib/subscription_test.dart` - Test page for verification
- `lib/config/payment_config.dart` - Product configuration

## Testing on Android

To test the subscription functionality on Android:

1. **Run the test page**:
   ```dart
   Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionTest()));
   ```

2. **Check subscription status**:
   ```dart
   final subscriptionService = SubscriptionService();
   final status = await subscriptionService.getSubscriptionStatus();
   print('Subscription status: $status');
   ```

3. **Test premium status**:
   ```dart
   final isPremium = await subscriptionService.isPremiumUser();
   print('Is premium: $isPremium');
   ```

## Summary

The great news is that your existing subscription implementation will work on Android with minimal changes! The `in_app_purchase` package handles the platform differences automatically. You just need to:

1. Set up the products in Google Play Console
2. Test on an Android device
3. Ensure your app is properly configured

Your subscription code is already cross-platform ready! 🎉 