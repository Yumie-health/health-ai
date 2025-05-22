import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ScanResultPage extends StatefulWidget {
  final String imagePath;
  const ScanResultPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal type segmented control
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      children: _mealTypes.map((type) {
                        final selected = _selectedMealType == type;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedMealType = type),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.green : Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Center(
                                  child: Text(
                                    _mealTypeLabels[type]!,
                                    style: TextStyle(
                                      color: selected ? Colors.white : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Text('Food Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      hintText: 'Search or enter food name',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _macroField('Calories', _caloriesController, color: Colors.green[700]!, suffix: ''),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _macroField('Protein (g)', _proteinController, color: Colors.blue[700]!, suffix: 'g'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _macroField('Carbs (g)', _carbsController, color: Colors.orange[700]!, suffix: 'g'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _macroField('Fat (g)', _fatController, color: Colors.red[400]!, suffix: 'g'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          decoration: InputDecoration(
                            hintText: 'Add ingredient',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: _addIngredient,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_ingredients.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: List.generate(_ingredients.length, (i) => Chip(
                        label: Text(_ingredients[i]),
                        onDeleted: () => _removeIngredient(i),
                      )),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _discard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving || _foodNameController.text.trim().isEmpty ? null : _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Meal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroField(String label, TextEditingController controller, {required Color color, String suffix = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
} 