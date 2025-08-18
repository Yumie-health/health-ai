import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final int dailyCalorieGoal;
  final int proteinGoal; // in grams
  final int carbsGoal; // in grams
  final int fatGoal; // in grams
  final double targetWeight; // in kg
  final double startingWeight; // in kg - the initial weight when user first started
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String photoUrl;
  final String? waterIntake;
  final int? waterLoggedMl;
  // Additional health data for comprehensive coaching
  final String activityLevel; // e.g., "Sedentary", "Lightly Active", "Moderately Active", "Very Active"
  final String bloodType; // e.g., "A+", "B-", "O+", etc.
  final bool isDiabetic;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.targetWeight,
    required this.startingWeight,
    required this.createdAt,
    required this.lastUpdated,
    this.photoUrl = '',
    this.waterIntake,
    this.waterLoggedMl,
    this.activityLevel = '',
    this.bloodType = '',
    this.isDiabetic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'heightCm': height, // Save with both field names for compatibility
      'weight': weight,
      'weightKg': weight, // Save with both field names for compatibility
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'targetWeight': targetWeight,
      'targetWeightKg': targetWeight, // Save with both field names for compatibility
      'startingWeight': startingWeight,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'photoUrl': photoUrl,
      'waterIntake': waterIntake,
      'waterLoggedMl': waterLoggedMl,
      'activityLevel': activityLevel,
      'bloodType': bloodType,
      'isDiabetic': isDiabetic,
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Handle both old field names and new field names from onboarding
    final heightValue = data['heightCm'] ?? data['height'] ?? 0;
    final weightValue = data['weightKg'] ?? data['weight'] ?? 0;
    final targetWeightValue = data['targetWeightKg'] ?? data['targetWeight'] ?? 0;
    
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      height: heightValue.toDouble(),
      weight: weightValue.toDouble(),
      dailyCalorieGoal: data['dailyCalorieGoal'] ?? 2000,
      proteinGoal: data['proteinGoal'] ?? 120,
      carbsGoal: data['carbsGoal'] ?? 250,
      fatGoal: data['fatGoal'] ?? 70,
      targetWeight: targetWeightValue.toDouble(),
      startingWeight: (data['startingWeight'] ?? weightValue ?? 0).toDouble(), // Default to current weight if not set
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'] ?? '',
      waterIntake: data['waterIntake'],
      waterLoggedMl: data['waterLoggedMl'],
      activityLevel: data['activityLevel'] ?? '',
      bloodType: data['bloodType'] ?? '',
      isDiabetic: data['isDiabetic'] ?? false,
    );
  }
} 