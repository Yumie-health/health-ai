# HealthAI - Flutter Mobile Application

> **AI-Powered Calorie Tracking & Nutrition Management App**

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7+-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Hosted-orange.svg)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Setup & Installation](#setup--installation)
- [Development](#development)
- [Firebase Configuration](#firebase-configuration)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

HealthAI is a comprehensive mobile application built with Flutter that helps users track their daily nutrition, log meals, and receive AI-powered insights for better health management. The app features photo-based food detection, personalized nutrition plans, and detailed progress tracking.

### Key Technologies

- **Frontend**: Flutter 3.7+ (Dart)
- **Backend**: Firebase (Firestore, Auth, Functions, Storage)
- **AI Services**: Custom AI models for food recognition
- **State Management**: Provider pattern
- **Local Storage**: SQLite, SharedPreferences, SecureStorage
- **Notifications**: Flutter Local Notifications
- **Payments**: In-app purchases with subscription management

## ✨ Features

### Core Features
- 🔐 **Authentication**: Email/password, Google Sign-In, Apple Sign-In
- 📸 **Photo Food Detection**: AI-powered meal recognition from photos
- 📊 **Nutrition Tracking**: Comprehensive calorie and macro tracking
- 🎯 **Goal Setting**: Personalized nutrition and weight goals
- 📱 **Cross-Platform**: Native experience on iOS and Android
- 🌍 **Multi-Language**: Internationalization support
- 🔒 **Privacy-First**: Secure data handling and storage

### Advanced Features
- 🤖 **AI Insights**: Smart nutrition recommendations
- 📈 **Progress Analytics**: Detailed health progress tracking
- 🔔 **Smart Notifications**: Personalized reminders and insights
- 💳 **Subscription Management**: Premium features with in-app purchases
- 📅 **Meal Planning**: Calendar-based meal organization
- 🔄 **Data Sync**: Cloud synchronization across devices

## 🏗️ Architecture

### Project Structure
```
healthai_app/
├── lib/
│   ├── config/                 # App configuration
│   ├── l10n/                   # Localization files
│   ├── models/                 # Data models
│   ├── providers/              # State management
│   ├── services/               # Business logic & API calls
│   ├── utils/                  # Utility functions
│   ├── widgets/                # Reusable UI components
│   └── main.dart              # App entry point
├── android/                    # Android-specific configuration
├── ios/                       # iOS-specific configuration
├── assets/                    # Static assets
└── test/                      # Test files
```

### State Management
- **Provider Pattern**: Used for app-wide state management
- **Local Storage**: SQLite for offline data, SharedPreferences for settings
- **Secure Storage**: Sensitive data encryption

### Service Layer
- **AuthService**: Authentication and user management
- **AIService**: AI-powered food recognition and insights
- **DatabaseService**: Local and cloud data operations
- **NotificationService**: Push and local notifications
- **PaymentService**: Subscription and billing management

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- Android Studio / Xcode
- Firebase project setup
- Google Cloud Platform account

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/health-ai.git
   cd health-ai/healthai_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place files in respective platform directories

4. **Set up environment variables**
   ```bash
   # Create .env file (if needed)
   cp .env.example .env
   # Edit with your configuration
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 34 (Android 14)
- Enable multidex support
- Configure signing for release builds

#### iOS
- Minimum iOS version: 12.0
- Configure signing certificates
- Set up App Store Connect for distribution

## 🔧 Development

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comprehensive comments for complex logic
- Implement proper error handling

### Key Dependencies
```yaml
# Core Flutter
flutter:
  sdk: flutter

# Firebase
firebase_core: ^3.15.1
firebase_auth: ^5.6.2
cloud_firestore: ^5.6.11
firebase_storage: ^12.4.9

# State Management
provider: ^6.1.2

# UI & UX
google_fonts: ^6.2.1
lottie: ^3.1.0
flutter_svg: ^2.0.10+1

# Local Storage
sqflite: ^2.3.2
shared_preferences: ^2.2.2
flutter_secure_storage: ^10.0.0-beta.4

# AI & ML
http: ^1.2.1
crypto: ^3.0.3

# Payments
in_app_purchase: ^3.1.13
in_app_review: ^2.0.9
```

### Development Workflow
1. Create feature branch from `main`
2. Implement feature with tests
3. Run linting and formatting
4. Submit pull request
5. Code review and merge

## 🔥 Firebase Configuration

### Required Services
- **Authentication**: Email/password, Google, Apple
- **Firestore**: User data, meals, nutrition info
- **Functions**: AI processing, notifications
- **Storage**: User photos and assets
- **Analytics**: User behavior tracking
- **Remote Config**: Feature flags and A/B testing

### Security Rules
```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/meals/{mealId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📚 API Documentation

### Authentication Endpoints
- `POST /auth/signup` - User registration
- `POST /auth/signin` - User login
- `POST /auth/signout` - User logout
- `POST /auth/reset-password` - Password reset

### Meal Management
- `GET /meals` - Get user meals
- `POST /meals` - Create new meal
- `PUT /meals/{id}` - Update meal
- `DELETE /meals/{id}` - Delete meal

### AI Services
- `POST /ai/analyze-photo` - Analyze food photo
- `GET /ai/suggestions` - Get nutrition suggestions
- `POST /ai/insights` - Generate health insights

## 🧪 Testing

### Test Structure
```
test/
├── unit/           # Unit tests
├── widget/         # Widget tests
├── integration/    # Integration tests
└── mocks/          # Mock data and services
```

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage
- Unit tests: Business logic and services
- Widget tests: UI components
- Integration tests: End-to-end workflows

## 🚀 Deployment

### Android Release
1. Update version in `pubspec.yaml`
2. Build release APK:
   ```bash
   flutter build apk --release
   ```
3. Upload to Google Play Console

### iOS Release
1. Update version in `pubspec.yaml`
2. Build release IPA:
   ```bash
   flutter build ios --release
   ```
3. Archive and upload to App Store Connect

### Firebase Functions Deployment
```bash
cd functions
npm install
firebase deploy --only functions
```

## 🔧 Troubleshooting

### Common Issues

#### Build Errors
- **Gradle issues**: Clean and rebuild project
- **Pod install failures**: Update CocoaPods and pods
- **Version conflicts**: Check dependency compatibility

#### Runtime Errors
- **Firebase connection**: Verify configuration files
- **Permission issues**: Check platform permissions
- **Memory leaks**: Monitor app performance

#### Testing Issues
- **Mock setup**: Ensure proper mock configuration
- **Async operations**: Handle async tests correctly
- **Platform differences**: Test on both platforms

### Debug Commands
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Format code
dart format .

# Run with verbose logging
flutter run --verbose
```

## 📞 Support

### Development Team
- **Lead Developer**: Ali Abbas
- **Product Manager**: Fadi Abbas
- **Contact**: info@maivenx.com

### Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Version**: 1.0.0+18  
**Last Updated**: December 2024  
**License**: Proprietary - All rights reserved
