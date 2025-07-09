# iOS Setup Instructions

## Prerequisites
- macOS with Xcode installed
- CocoaPods installed (`sudo gem install cocoapods`)
- Flutter SDK installed

## Setup Steps

1. **Install CocoaPods dependencies:**
   ```bash
   cd ios
   pod install
   ```

2. **Open the project in Xcode:**
   ```bash
   open Runner.xcworkspace
   ```

3. **Configure your Bundle Identifier:**
   - In Xcode, select the Runner project
   - Go to the "Signing & Capabilities" tab
   - Update the Bundle Identifier to match your app (e.g., `com.yourcompany.yumie`)

4. **Configure Google Sign-In:**
   - Replace `YOUR_REVERSED_CLIENT_ID` in `Info.plist` with your actual reversed client ID from Google Services
   - Add your `GoogleService-Info.plist` file to the Runner project

5. **Configure Firebase:**
   - Add your `GoogleService-Info.plist` file to the Runner project
   - Make sure it's added to the Runner target

## Common Issues and Solutions

### Permission Issues
The app requires the following permissions:
- Camera access for scanning food items
- Photo library access for selecting images
- Microphone access for video features
- Location access for personalized recommendations

All permissions are configured in `Info.plist` with appropriate usage descriptions.

### Build Issues
If you encounter build issues:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Install pods: `cd ios && pod install`
4. Clean Xcode build: Product → Clean Build Folder in Xcode

### iOS Deployment Target
The minimum iOS version is set to 13.0. This is configured in:
- `Podfile` (platform :ios, '13.0')
- Build settings in Xcode

## Testing on iOS Simulator
```bash
flutter run -d ios
```

## Building for iOS Device
1. Connect your iOS device
2. In Xcode, select your device as the target
3. Build and run the project

## App Store Deployment
1. Archive the project in Xcode
2. Upload to App Store Connect
3. Configure app metadata and screenshots
4. Submit for review 