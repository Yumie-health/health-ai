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
  final DateTime createdAt;
  final DateTime lastUpdated;

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
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'targetWeight': targetWeight,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      dailyCalorieGoal: data['dailyCalorieGoal'] ?? 2000,
      proteinGoal: data['proteinGoal'] ?? 120,
      carbsGoal: data['carbsGoal'] ?? 250,
      fatGoal: data['fatGoal'] ?? 70,
      targetWeight: (data['targetWeight'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
} 