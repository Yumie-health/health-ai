import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'services/ai_service.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // For PreferencesProvider and kPrimaryGreen
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'l10n/app_localizations.dart';

class ScanResultPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic>? prefill;
  const ScanResultPage({Key? key, required this.imagePath, this.prefill}) : super(key: key);

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
  bool _isLoadingAI = true;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();
    _foodNameController.addListener(() => setState(() {}));
    if (widget.prefill != null) {
      final p = widget.prefill!;
      _foodNameController.text = p['food_name']?.toString() ?? '';
      _caloriesController.text = p['calories']?.toString() ?? '';
      _proteinController.text = p['protein']?.toString() ?? '';
      _carbsController.text = p['carbs']?.toString() ?? '';
      _fatController.text = p['fat']?.toString() ?? '';
      _ingredients = (p['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
      _isLoadingAI = false;
    } else {
      _runAIMealScan();
    }
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

  Future<void> _showCalmPopupIfNeeded(VoidCallback onContinue) async {
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    if (prefs.momentOfCalmEnabled) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFF1F8E9),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.15),
                    duration: Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimaryGreen.withOpacity(0.13),
                          ),
                          child: Center(
                            child: Text(
                              '🧘‍♀️',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.momentOfCalm,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kPrimaryGreen,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    AppLocalizations.of(context)!.practiceMindfulEating,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      child: Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    onContinue();
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
      if (widget.imagePath.isNotEmpty && File(widget.imagePath).existsSync()) {
      final file = File(widget.imagePath);
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('meal_images/${user.uid}/$fileName');
      final uploadTask = await ref.putFile(file);
      if (uploadTask.state == TaskState.success) {
        imageUrl = await ref.getDownloadURL();
      } else {
        throw Exception('Image upload failed');
        }
      } else {
        imageUrl = 'assets/meal_icon.png';
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
        await _showCalmPopupIfNeeded(() {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Fluttertoast.showToast(
          msg: "🎉 Meal saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 20.0,
        );
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _runAIMealScan() async {
    setState(() { _isLoadingAI = true; });
    final aiService = AIService();
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final language = prefs.language;
    final result = await aiService.analyzeMealImage(File(widget.imagePath), language: language);
    print('AI meal scan result:');
    print(result);
    if (result != null) {
      setState(() {
        _foodNameController.text = result['food_name']?.toString() ?? '';
        _caloriesController.text = result['calories']?.toString() ?? '';
        _proteinController.text = result['protein']?.toString() ?? '';
        _carbsController.text = result['carbs']?.toString() ?? '';
        _fatController.text = result['fat']?.toString() ?? '';
        _ingredients = (result['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
        _isLoadingAI = false;
      });
    } else {
      setState(() {
        _isLoadingAI = false;
        _error = "Could not analyze meal. Try again or enter details manually.";
      });
    }
  }

  Map<String, String> get _mealTypeLabels {
    final localizations = AppLocalizations.of(context)!;
    return {
      'breakfast': localizations.breakfast,
      'lunch': localizations.lunch,
      'dinner': localizations.dinner,
      'snack': localizations.snack,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
                  Text(AppLocalizations.of(context)!.retakeScan, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
        title: Text(AppLocalizations.of(context)!.reviewMeal, style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _isLoadingAI
        ? Center(
            child: Lottie.asset(
              'assets/animations/AI Loading spinner..json',
              width: 100,
              height: 100,
            ),
          )
        : Column(
        children: [
          // Image preview (only if imagePath is not empty)
          if (widget.imagePath.isNotEmpty)
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
                    child: Text(AppLocalizations.of(context)!.previewFullImage, style: TextStyle(fontWeight: FontWeight.bold)),
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
                      hintText: AppLocalizations.of(context)!.searchOrEnterFoodName,
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
                  Text(AppLocalizations.of(context)!.ingredients, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.addIngredient,
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
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 8),
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
                      child: Text(AppLocalizations.of(context)!.discard),
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
                          : Text(AppLocalizations.of(context)!.saveMeal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroField(String label, TextEditingController controller, {required Color color, String suffix = ''}) {
    final localizations = AppLocalizations.of(context)!;
    String localizedLabel = label;
    if (label == 'Calories') localizedLabel = localizations.calories;
    if (label == 'Protein (g)') localizedLabel = localizations.protein + ' (g)';
    if (label == 'Carbs (g)') localizedLabel = localizations.carbs + ' (g)';
    if (label == 'Fat (g)') localizedLabel = localizations.fat + ' (g)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(localizedLabel, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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