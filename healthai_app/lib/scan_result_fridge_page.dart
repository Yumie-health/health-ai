import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'scan_result_page.dart';

class ScanResultFridgePage extends StatefulWidget {
  final String imagePath;
  const ScanResultFridgePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ScanResultFridgePage> createState() => _ScanResultFridgePageState();
}

class _ScanResultFridgePageState extends State<ScanResultFridgePage> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredients = [];
  String _selectedMealType = 'breakfast';
  bool _isSaving = false;
  String? _error;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  final Map<String, String> _mealTypeLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };

  @override
  void initState() {
    super.initState();
    _foodNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _discard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveMeal() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      String? imageUrl;
      // Upload image to Firebase Storage
      final file = File(widget.imagePath);
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('meal_images/${user.uid}/$fileName');
      final uploadTask = await ref.putFile(file);
      if (uploadTask.state == TaskState.success) {
        imageUrl = await ref.getDownloadURL();
      } else {
        throw Exception('Image upload failed');
      }
      final meal = Meal(
        id: '',
        name: _foodNameController.text.trim(),
        calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
        protein: int.tryParse(_proteinController.text.trim()) ?? 0,
        carbs: int.tryParse(_carbsController.text.trim()) ?? 0,
        fat: int.tryParse(_fatController.text.trim()) ?? 0,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
        userId: user.uid,
        ingredients: List<String>.from(_ingredients),
        imageUrl: imageUrl,
      );
      await MealService().addMeal(meal);
      setState(() { _ingredients.clear(); });
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal saved!')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.green, size: 22),
                  const SizedBox(width: 4),
                  Text('Retake Scan', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
        title: Text('Review Meal', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image preview
          Container(
            width: double.infinity,
            color: Colors.black,
            height: 220,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.black,
                          child: InteractiveViewer(
                            child: Image.file(File(widget.imagePath)),
                          ),
                        ),
                      );
                    },
                    child: const Text('Preview Full Image', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          // Generate Meal button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ScanResultPage(imagePath: widget.imagePath),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Generate Meal'),
              ),
            ),
          ),
          // Fridge items box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 80, maxHeight: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _ingredients.isEmpty
                  ? const Center(child: Text('No fridge items detected.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _ingredients.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(_ingredients[i], style: const TextStyle(fontSize: 16)),
                      ),
                    ),
            ),
          ),
          // Discard button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _discard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Discard'),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 