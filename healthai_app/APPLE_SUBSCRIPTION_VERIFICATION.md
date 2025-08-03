# Apple Subscription Verification Guide

## Overview
This guide helps you verify that Apple subscriptions are properly configured and working in your Flutter app.

## Current Implementation Status

### ✅ What's Working
1. **In-App Purchase Package**: Using `in_app_purchase: ^3.1.13`
2. **Product Configuration**: Two subscription products defined:
   - `premium_monthly` ($7.99/month)
   - `premium_yearly` ($49.99/year)
3. **Purchase Flow**: Basic purchase and restore functionality
4. **Local Storage**: Subscription status stored in SharedPreferences
5. **Error Handling**: Improved error handling and user feedback

### ⚠️ What Needs Verification

## 1. App Store Connect Configuration

### Required Setup in App Store Connect:
1. **Create Subscription Products**:
   - Product ID: `premium_monthly`
   - Product ID: `premium_yearly`
   - Set pricing and availability
   - Configure subscription groups

2. **App Configuration**:
   - Ensure your app is configured for in-app purchases
   - Add sandbox testers for testing

## 2. Testing Steps

### Step 1: Verify Product Loading
1. Run the app on a physical iOS device (not simulator)
2. Navigate to the subscription page
3. Check console logs for:
   ```
   IAP Available: true
   Loaded products: [premium_monthly: Monthly Premium - $7.99, premium_yearly: Yearly Premium - $49.99]
   ```

### Step 2: Test Purchase Flow
1. Use a sandbox test account
2. Attempt to purchase a subscription
3. Verify the purchase completes successfully
4. Check that premium status is activated

### Step 3: Test Restore Purchases
1. Clear app data or reinstall
2. Use the "Restore Purchases" button
3. Verify subscription status is restored

## 3. Common Issues and Solutions

### Issue: "Products not found"
**Solution**: 
- Verify product IDs match exactly in App Store Connect
- Ensure products are approved and active
- Check that you're using the correct bundle identifier

### Issue: "In-app purchases are not available"
**Solution**:
- Test on a physical device (not simulator)
- Ensure device has internet connection
- Check that the device supports in-app purchases

### Issue: Purchase fails
**Solution**:
- Use a valid sandbox test account
- Ensure the test account has a valid payment method
- Check that the app is signed with the correct provisioning profile

## 4. Debug Information

### Console Logs to Monitor:
```
IAP Available: [true/false]
Loaded products: [product list]
Products not found: [missing products]
Purchase status: [status] for product: [product_id]
Subscription activated: [product_id]
```

### Test Subscription Status:
Use the `SubscriptionTest` page to verify:
- Local storage is working
- Subscription service is functioning
- Status updates are working

## 5. Production Checklist

Before going live, ensure:

### App Store Connect:
- [ ] Subscription products are created and approved
- [ ] Pricing is set correctly
- [ ] App is configured for in-app purchases
- [ ] App review is completed

### Code Verification:
- [ ] Product IDs match App Store Connect exactly
- [ ] Error handling is implemented
- [ ] Purchase restoration works
- [ ] Subscription status is properly managed

### Testing:
- [ ] Test with sandbox accounts
- [ ] Test purchase flow end-to-end
- [ ] Test restore purchases
- [ ] Test subscription expiration
- [ ] Test on multiple devices

## 6. Troubleshooting Commands

### Check Flutter Setup:
```bash
flutter doctor
flutter clean
flutter pub get
```

### Test on iOS Device:
```bash
flutter run --release
```

### Check Logs:
```bash
flutter logs
```

## 7. Next Steps

1. **Test with Sandbox Accounts**: Create test accounts in App Store Connect
2. **Verify Product Loading**: Ensure products load from App Store Connect
3. **Test Purchase Flow**: Complete end-to-end purchase testing
4. **Submit for Review**: Once testing is complete, submit for App Store review

## 8. Support Resources

- [Apple In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [Flutter in_app_purchase Package](https://pub.dev/packages/in_app_purchase)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Current Implementation Files

- `lib/subscription_page.dart` - Main subscription UI
- `lib/services/subscription_service.dart` - Subscription logic
- `lib/subscription_test.dart` - Test page for verification
- `lib/config/payment_config.dart` - Product configuration

## Testing Commands

To test the subscription functionality:

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