import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'scan_result_page.dart';
import 'package:lottie/lottie.dart';
import 'services/ai_service.dart';
import './generated_meal_fridge_page.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/preferences_provider.dart';
import 'utils/constants.dart';

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
  bool _isLoadingAI = true;
  bool _isGeneratingMeal = false;
  Map<String, dynamic>? _generatedMeal;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
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
  void initState() {
    super.initState();
    _foodNameController.addListener(() => setState(() {}));
    _runAIFridgeScan();
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
        await _showCalmPopupIfNeeded(() {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal saved!')),
        );
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _runAIFridgeScan() async {
    setState(() { _isLoadingAI = true; });
    final aiService = AIService();
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final language = prefs.language;
    final result = await aiService.analyzeFridgeImage(File(widget.imagePath), language: language);
    if (result != null) {
      setState(() {
        _ingredients = result;
        _isLoadingAI = false;
      });
    } else {
      setState(() { _isLoadingAI = false; });
    }
  }

  Future<void> _generateMealFromFridge() async {
    setState(() { _isGeneratingMeal = true; });
    final aiService = AIService();
    // Example user profile, replace with actual user data if available
    final userProfile = {
      'age': 25,
      'sex': 'female',
      'height_cm': 165,
      'weight_kg': 60,
      'goal': 'maintenance',
      // Add more fields as needed
    };
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final language = prefs.language;
    final result = await aiService.generateMealFromFridge(fridgeItems: _ingredients, userProfile: userProfile, language: language);
    setState(() {
      _generatedMeal = result;
      _isGeneratingMeal = false;
    });
    if (result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GeneratedMealFromFridgePage(meal: result),
        ),
      );
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
                    child: Text(AppLocalizations.of(context)!.previewFullImage, style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onPressed: _ingredients.isEmpty || _isGeneratingMeal ? null : _generateMealFromFridge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                    child: _isGeneratingMeal
                      ? SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(AppLocalizations.of(context)!.generateMeal),
              ),
            ),
          ),
          // Fridge items box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
              padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.detectedFridgeItems, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green[700])),
                        SizedBox(height: 10),
                        _ingredients.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noFridgeItemsDetected, style: TextStyle(color: Colors.grey)))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _ingredients.map((item) => Chip(label: Text(item))).toList(),
                            ),
                      ],
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
                child: Text(AppLocalizations.of(context)!.discard),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 