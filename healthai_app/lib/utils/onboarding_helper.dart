import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Consolidated onboarding completion check
/// This replaces the multiple different implementations in main.dart
bool hasCompletedOnboarding(Map<String, dynamic>? userData) {
  if (userData == null) return false;
  // Only the explicit final-step flag counts. This ensures users
  // reach the AI-generated Nutrition Summary before entering the app.
  return userData['hasCompletedOnboarding'] == true;
}

/// Helper to get current user
Future<User?> getCurrentUser() async {
  return FirebaseAuth.instance.currentUser;
}
