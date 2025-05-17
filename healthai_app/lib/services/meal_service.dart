import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal.dart';

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get meals for today
  Stream<List<Meal>> getTodayMeals() {
    final user = _auth.currentUser;
    if (user == null) {
      print('No authenticated user!');
      return Stream.value([]);
    }

    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('getTodayMeals: userId=${user.uid}, startOfDay=$startOfDay, endOfDay=$endOfDay');

    return _firestore
        .collection('meals')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print('getTodayMeals: Query returned ${snapshot.docs.length} docs');
          for (var doc in snapshot.docs) {
            print('Meal doc: ${doc.data()}');
          }
          return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
        });
  }

  // Add a new meal
  Future<void> addMeal(Meal meal) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('meals').add(meal.toMap());
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    await _firestore.collection('meals').doc(mealId).delete();
  }

  // Get daily nutrition summary
  Future<Map<String, int>> getDailyNutritionSummary() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('meals')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (var doc in snapshot.docs) {
      final meal = Meal.fromFirestore(doc);
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
} 