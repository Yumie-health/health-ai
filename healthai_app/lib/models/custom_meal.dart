import 'package:cloud_firestore/cloud_firestore.dart';

class CustomMeal {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final String userId;

  CustomMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'userId': userId,
    };
  }

  factory CustomMeal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomMeal(
      id: doc.id,
      name: data['name'] ?? '',
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fat: data['fat'] ?? 0,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
} 