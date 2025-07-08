import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Consolidated onboarding completion check
/// This replaces the multiple different implementations in main.dart
bool hasCompletedOnboarding(Map<String, dynamic>? userData) {
  if (userData == null) return false;
  
  // Check the explicit flag first
  if (userData['hasCompletedOnboarding'] == true) return true;
  
  // Fallback: check required fields
  return userData['age'] != null &&
         userData['height'] != null &&
         userData['weight'] != null &&
         userData['targetWeight'] != null &&
         userData['activityLevel'] != null &&
         userData['dailyCalorieGoal'] != null;
}

/// Helper to get current user
Future<User?> getCurrentUser() async {
  return FirebaseAuth.instance.currentUser;
} 