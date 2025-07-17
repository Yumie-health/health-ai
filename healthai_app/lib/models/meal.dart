import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime timestamp;
  final String mealType; // breakfast, lunch, dinner, snack
  final String userId;
  final List<String> ingredients;
  final String? imageUrl;
  final String? foodType; // ingredient, meal, drink
  final int? quantity; // count for ingredients, servings for meals, fluid ounces for drinks
  final String? quantityUnit; // "count", "servings", "fl oz"

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
    required this.mealType,
    required this.userId,
    this.ingredients = const [],
    this.imageUrl,
    this.foodType,
    this.quantity,
    this.quantityUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': Timestamp.fromDate(timestamp),
      'mealType': mealType,
      'userId': userId,
      'ingredients': ingredients,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (foodType != null) 'foodType': foodType,
      if (quantity != null) 'quantity': quantity,
      if (quantityUnit != null) 'quantityUnit': quantityUnit,
    };
  }

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Defensive: skip meals with missing or empty required fields
    if (data['name'] == null || data['name'].toString().trim().isEmpty ||
        data['userId'] == null || data['userId'].toString().trim().isEmpty ||
        data['timestamp'] == null) {
      throw Exception('Invalid meal data: missing required fields');
    }
    return Meal(
      id: doc.id,
      name: data['name'] ?? '',
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fat: data['fat'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      mealType: data['mealType'] ?? '',
      userId: data['userId'] ?? '',
      ingredients: (data['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      imageUrl: data['imageUrl'] as String?,
      foodType: data['foodType'] as String?,
      quantity: data['quantity'] as int?,
      quantityUnit: data['quantityUnit'] as String?,
    );
  }
} 