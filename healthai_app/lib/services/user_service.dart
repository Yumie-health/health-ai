import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user profile
  Stream<UserProfile?> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update(profile.toMap());
  }

  // Create initial user profile
  Future<void> createInitialUserProfile(String email, String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final profile = UserProfile(
      id: user.uid,
      email: email,
      name: name,
      age: 0,
      height: 0,
      weight: 0,
      targetWeight: 0,
      dailyCalorieGoal: 2000,
      proteinGoal: 120,
      carbsGoal: 250,
      fatGoal: 70,
      createdAt: now,
      lastUpdated: now,
    );

    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
  }

  // Update user goals
  Future<void> updateUserGoals({
    required int dailyCalorieGoal,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'lastUpdated': DateTime.now(),
    });
  }

  // Update user profile photo URL
  Future<void> updateUserPhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    await _firestore.collection('users').doc(user.uid).update({
      'photoUrl': photoUrl,
      'lastUpdated': DateTime.now(),
    });
  }
} 