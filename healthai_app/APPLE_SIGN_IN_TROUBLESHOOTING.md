# Apple Sign-In Troubleshooting Guide

## Current Issues Identified

Based on your logs and configuration, here are the main issues:

### 1. Firebase Console Configuration
- **Error**: `[firebase_auth/internal-error] http://localhost?providerId=apple`
- **Issue**: Firebase is redirecting to localhost instead of your configured auth domain
- **Solution**: Verify Firebase Console Apple Sign-In configuration

### 2. Apple Developer Console Configuration
- **Services ID**: `com.yumie.healthai.signin` (should match your bundle ID)
- **Primary App ID**: `YumieAppiOS (BT7WG9ZHD3.com.yumie.healthai)`
- **Domain**: `healthai-0001.firebaseapp.com`
- **Return URL**: `https://healthai-0001.firebaseapp.com/__/auth/handler`

## Step-by-Step Configuration Checklist

### Firebase Console Configuration

1. **Enable Apple Sign-In Provider**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable Apple provider
   - Add the following configuration:
     - **Services ID**: `com.yumie.healthai.signin`
     - **Apple Team ID**: `BT7WG9ZHD3`
     - **Key ID**: `CLV527A2J9`
     - **Private Key**: (The private key from your screenshot)

2. **Verify Auth Domain**
   - Ensure auth domain is set to: `healthai-0001.firebaseapp.com`
   - Check that it's not redirecting to localhost

### Apple Developer Console Configuration

1. **Update Services ID**
   - Current: `com.yumie.healthai.signin`
   - Should be: `com.yumie.healthai` (to match your app's bundle ID)
   - Or update your app's bundle ID to match the Services ID

2. **Verify Primary App ID**
   - Ensure it's correctly set to: `YumieAppiOS (BT7WG9ZHD3.com.yumie.healthai)`

3. **Check Web Authentication Configuration**
   - Domain: `healthai-0001.firebaseapp.com`
   - Return URL: `https://healthai-0001.firebaseapp.com/__/auth/handler`

### iOS App Configuration

1. **Bundle ID Consistency**
   - Ensure your app's bundle ID matches the Services ID
   - Current bundle ID: `com.yumie.healthai`
   - Services ID: `com.yumie.healthai.signin`

2. **Info.plist Configuration**
   - Apple Sign-In capability is properly configured
   - URL schemes are set up correctly

## Code Implementation

The updated code now includes:
- Better nonce generation and SHA256 hashing
- Enhanced error logging
- Proper validation of Apple credentials
- Detailed debugging information

## Testing Steps

1. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   flutter build ios
   ```

2. **Test Apple Sign-In**
   - Run the app on a physical iOS device
   - Try Apple Sign-In
   - Check the logs for detailed error information

3. **Verify Logs**
   - Look for the new debugging information
   - Check for specific error messages
   - Verify nonce generation and hashing

## Common Error Solutions

### Error: "Internal Error"
- Check Firebase Console Apple Sign-In configuration
- Verify all credentials (Services ID, Team ID, Key ID, Private Key)
- Ensure Apple Sign-In is enabled in Firebase Console

### Error: "Invalid OAuth Response"
- Verify Services ID matches between Firebase and Apple Developer Console
- Check that the private key is correctly formatted
- Ensure the Team ID and Key ID are correct

### Error: "MissingOrInvalidNonce"
- Verify SHA256 hashing implementation
- Check that the nonce is properly generated and hashed
- Ensure the raw nonce is passed to Firebase

### Error: "localhost redirect"
- Check Firebase auth domain configuration
- Verify Firebase Console settings
- Ensure proper auth domain is set

## Next Steps

1. **Update Apple Services ID** to match your bundle ID
2. **Verify Firebase Console** configuration
3. **Test with updated code** and enhanced logging
4. **Check logs** for specific error messages
5. **Update configuration** based on error messages

## Resources

- [Firebase Apple Sign-In Documentation](https://firebase.google.com/docs/auth/ios/apple)
- [Apple Developer Documentation](https://developer.apple.com/documentation/sign_in_with_apple)
- [Flutter sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple) 

