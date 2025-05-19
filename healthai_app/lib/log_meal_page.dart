import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'main.dart'; // For color constants and _MacroTag
import 'models/custom_meal.dart';

class LogMealPage extends StatefulWidget {
  const LogMealPage({Key? key}) : super(key: key);

  @override
  State<LogMealPage> createState() => _LogMealPageState();
}

class _LogMealPageState extends State<LogMealPage> with TickerProviderStateMixin {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController(text: '0');
  final TextEditingController _proteinController = TextEditingController(text: '0');
  final TextEditingController _carbsController = TextEditingController(text: '0');
  final TextEditingController _fatController = TextEditingController(text: '0');
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

  late AnimationController _tabsController;
  late AnimationController _foodNameControllerAnim;
  late AnimationController _macrosController;
  late AnimationController _recentController;

  int _foodTabIndex = 0; // 0: Recent, 1: My Foods

  @override
  void initState() {
    super.initState();
    _tabsController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _foodNameControllerAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _macrosController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _recentController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _playEntranceAnimations();
  }

  void _playEntranceAnimations() async {
    await Future.delayed(Duration(milliseconds: 80));
    _tabsController.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _foodNameControllerAnim.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _macrosController.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _recentController.forward();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ingredientController.dispose();
    _tabsController.dispose();
    _foodNameControllerAnim.dispose();
    _macrosController.dispose();
    _recentController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      final meal = Meal(
        id: '',
        name: _foodNameController.text.trim(),
        calories: int.tryParse(_caloriesController.text.trim().isEmpty ? '0' : _caloriesController.text.trim()) ?? 0,
        protein: int.tryParse(_proteinController.text.trim().isEmpty ? '0' : _proteinController.text.trim()) ?? 0,
        carbs: int.tryParse(_carbsController.text.trim().isEmpty ? '0' : _carbsController.text.trim()) ?? 0,
        fat: int.tryParse(_fatController.text.trim().isEmpty ? '0' : _fatController.text.trim()) ?? 0,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
        userId: user.uid,
        ingredients: List<String>.from(_ingredients),
      );
      await MealService().addMeal(meal);
      setState(() { _ingredients.clear(); });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildMealTypeTabs() {
    return FadeTransition(
      opacity: _tabsController,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _tabsController, curve: Curves.easeOutCubic)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _mealTypes.map((type) {
            final selected = _selectedMealType == type;
            final color = selected ? kPrimaryGreen : Colors.grey[200];
            final textColor = selected ? Colors.white : Colors.grey[600];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMealType = type),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: selected
                        ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _mealTypeLabels[type]!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMacrosInputs() {
    return FadeTransition(
      opacity: _macrosController,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.10), end: Offset.zero).animate(CurvedAnimation(parent: _macrosController, curve: Curves.easeOutCubic)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _macroField('Calories', _caloriesController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _macroField('Protein (g)', _proteinController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _macroField('Carbs (g)', _carbsController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _macroField('Fat (g)', _fatController),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroField(String label, TextEditingController controller) {
    Color color;
    if (label.contains('Protein')) {
      color = kSecondaryBlue;
    } else if (label.contains('Carbs')) {
      color = kAccentOrange;
    } else if (label.contains('Fat')) {
      color = kWarningRed;
    } else {
      color = kPrimaryGreen;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            filled: true,
            fillColor: color.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFoods() {
    return FadeTransition(
      opacity: _recentController,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.10), end: Offset.zero).animate(CurvedAnimation(parent: _recentController, curve: Curves.easeOutCubic)),
        child: StreamBuilder<List<Meal>>(
          stream: MealService().getTodayMeals(),
          builder: (context, snapshot) {
            final meals = snapshot.data ?? [];
            if (meals.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No recent foods.')),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ...List<Meal>.from(meals.take(5)).asMap().entries.map((entry) {
                  final int i = entry.key;
                  final meal = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + i * 80),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 24),
                        child: child,
                      ),
                    ),
                    child: _recentFoodTile(meal),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _recentFoodTile(Meal meal) {
    return _ExpandableMealTile(
      name: meal.name,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      calories: meal.calories,
      ingredients: meal.ingredients,
      icon: Icons.restaurant_menu,
      iconColor: kPrimaryGreen,
      onAdd: () {
        setState(() {
          _foodNameController.text = meal.name;
          _caloriesController.text = meal.calories.toString();
          _proteinController.text = meal.protein.toString();
          _carbsController.text = meal.carbs.toString();
          _fatController.text = meal.fat.toString();
          _ingredients = List<String>.from(meal.ingredients);
        });
      },
      isCustomMeal: false,
    );
  }

  // For custom meal creation
  Future<void> _showCustomMealDialog() async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController(text: '0');
    final proteinController = TextEditingController(text: '0');
    final carbsController = TextEditingController(text: '0');
    final fatController = TextEditingController(text: '0');
    final ingredientController = TextEditingController();
    List<String> ingredients = [];
    bool isSaving = false;
    String? error;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Build a Custom Meal', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: kPrimaryGreen)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
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
                        Expanded(child: _macroField('Calories', caloriesController)),
                        const SizedBox(width: 16),
                        Expanded(child: _macroField('Protein (g)', proteinController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _macroField('Carbs (g)', carbsController)),
                        const SizedBox(width: 16),
                        Expanded(child: _macroField('Fat (g)', fatController)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: kPrimaryGreen)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ingredientController,
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
                          icon: Icon(Icons.add, color: kPrimaryGreen),
                          onPressed: () {
                            if (ingredientController.text.trim().isNotEmpty) {
                              setState(() {
                                ingredients.add(ingredientController.text.trim());
                                ingredientController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: ingredients.map((ing) => Chip(
                        label: Text(ing),
                        onDeleted: () => setState(() => ingredients.remove(ing)),
                        backgroundColor: kPrimaryGreen.withOpacity(0.13),
                        labelStyle: TextStyle(color: kPrimaryGreen),
                      )).toList(),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(error!, style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: kPrimaryGreen)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() => isSaving = true);
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) throw Exception('Not signed in');
                            final customMeal = CustomMeal(
                              id: '',
                              name: nameController.text.trim(),
                              calories: int.tryParse(caloriesController.text) ?? 0,
                              protein: int.tryParse(proteinController.text) ?? 0,
                              carbs: int.tryParse(carbsController.text) ?? 0,
                              fat: int.tryParse(fatController.text) ?? 0,
                              ingredients: ingredients,
                              userId: user.uid,
                            );
                            await MealService().addCustomMeal(customMeal);
                            Navigator.pop(context);
                          } catch (e) {
                            setState(() {
                              error = e.toString();
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _foodTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      'Recent',
                      style: TextStyle(
                        color: _foodTabIndex == 0 ? kPrimaryGreen : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _foodTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      'My Foods',
                      style: TextStyle(
                        color: _foodTabIndex == 1 ? kPrimaryGreen : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyFoods() {
    return StreamBuilder<List<CustomMeal>>(
      stream: MealService().getCustomMeals(),
      builder: (context, snapshot) {
        final customMeals = snapshot.data ?? [];
        if (customMeals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Text("You haven't saved any custom foods yet", style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _showCustomMealDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryGreen,
                    side: BorderSide(color: kPrimaryGreen.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Add Custom Food', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _showCustomMealDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryGreen,
                    side: BorderSide(color: kPrimaryGreen.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Build a Custom Meal', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...customMeals.map((meal) => _customMealTile(meal)).toList(),
          ],
        );
      },
    );
  }

  Widget _customMealTile(CustomMeal meal) {
    return _ExpandableMealTile(
      name: meal.name,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      calories: meal.calories,
      ingredients: meal.ingredients,
      icon: Icons.star,
      iconColor: kPrimaryGreen,
      onAdd: () {
        setState(() {
          _foodNameController.text = meal.name;
          _caloriesController.text = meal.calories.toString();
          _proteinController.text = meal.protein.toString();
          _carbsController.text = meal.carbs.toString();
          _fatController.text = meal.fat.toString();
          _ingredients = List<String>.from(meal.ingredients);
        });
      },
      onCustomize: () async {
        final nameController = TextEditingController(text: meal.name);
        final caloriesController = TextEditingController(text: meal.calories.toString());
        final proteinController = TextEditingController(text: meal.protein.toString());
        final carbsController = TextEditingController(text: meal.carbs.toString());
        final fatController = TextEditingController(text: meal.fat.toString());
        final ingredientController = TextEditingController();
        List<String> ingredients = List<String>.from(meal.ingredients);
        bool isSaving = false;
        String? error;

        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, anim1, anim2) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(anim1.value),
              child: Opacity(
                opacity: anim1.value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Edit Custom Meal', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meal Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: kPrimaryGreen)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
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
                            Expanded(child: _macroField('Calories', caloriesController)),
                            const SizedBox(width: 16),
                            Expanded(child: _macroField('Protein (g)', proteinController)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _macroField('Carbs (g)', carbsController)),
                            const SizedBox(width: 16),
                            Expanded(child: _macroField('Fat (g)', fatController)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ingredientController,
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
                              icon: Icon(Icons.add, color: kPrimaryGreen),
                              onPressed: () {
                                if (ingredientController.text.trim().isNotEmpty) {
                                  setState(() {
                                    ingredients.add(ingredientController.text.trim());
                                    ingredientController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 6,
                          children: ingredients.map((ing) => Chip(
                            label: Text(ing),
                            onDeleted: () => setState(() => ingredients.remove(ing)),
                            backgroundColor: kPrimaryGreen.withOpacity(0.13),
                            labelStyle: TextStyle(color: kPrimaryGreen),
                          )).toList(),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(error!, style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: kPrimaryGreen)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
                      onPressed: isSaving
                          ? null
                          : () async {
                              setState(() => isSaving = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) throw Exception('Not signed in');
                                final updatedMeal = CustomMeal(
                                  id: meal.id,
                                  name: nameController.text.trim(),
                                  calories: int.tryParse(caloriesController.text) ?? 0,
                                  protein: int.tryParse(proteinController.text) ?? 0,
                                  carbs: int.tryParse(carbsController.text) ?? 0,
                                  fat: int.tryParse(fatController.text) ?? 0,
                                  ingredients: ingredients,
                                  userId: user.uid,
                                );
                                await MealService().updateCustomMeal(updatedMeal);
                                Navigator.pop(context);
                              } catch (e) {
                                setState(() {
                                  error = e.toString();
                                  isSaving = false;
                                });
                              }
                            },
                      child: isSaving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      isCustomMeal: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: kPrimaryGreen, size: 28, weight: 800),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryGreen,
        elevation: 0.5,
      ),
      backgroundColor: kBackgroundWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildMealTypeTabs(),
            const SizedBox(height: 24),
            // --- FORM SECTION: always visible, no tabs ---
            FadeTransition(
              opacity: _foodNameControllerAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.10), end: Offset.zero).animate(CurvedAnimation(parent: _foodNameControllerAnim, curve: Curves.easeOutCubic)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Food Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                        OutlinedButton.icon(
                          onPressed: () {
                            _foodNameController.clear();
                            _caloriesController.text = '0';
                            _proteinController.text = '0';
                            _carbsController.text = '0';
                            _fatController.text = '0';
                            setState(() {
                              _ingredients.clear();
                            });
                          },
                          icon: Icon(Icons.delete_outline, color: kPrimaryGreen, size: 18),
                          label: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: kPrimaryGreen)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kPrimaryGreen, width: 1.4),
                            shape: StadiumBorder(),
                            foregroundColor: kPrimaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMacrosInputs(),
            const SizedBox(height: 24),
            // Ingredient input section
            Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: kPrimaryGreen)),
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
                  icon: Icon(Icons.add, color: kPrimaryGreen),
                  onPressed: () {
                    final text = _ingredientController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _ingredients.add(text);
                        _ingredientController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: _ingredients.map((ing) => Chip(
                label: Text(ing),
                onDeleted: () => setState(() => _ingredients.remove(ing)),
                backgroundColor: kPrimaryGreen.withOpacity(0.13),
                labelStyle: TextStyle(color: kPrimaryGreen),
              )).toList(),
            ),
            const SizedBox(height: 24),
            // --- ONLY ONE FOOD PICKER TAB (TOP) ---
            _buildFoodTabs(),
            if (_foodTabIndex == 0)
              _buildRecentFoods()
            else
              _buildMyFoods(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ElevatedButton(
          onPressed: _foodNameController.text.trim().isEmpty || _isSaving ? null : _saveMeal,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
            shadowColor: kPrimaryGreen.withOpacity(0.18),
          ),
          child: _isSaving
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Meal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// Macro Tag widget for macros display
class _MacroTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroTag({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 2),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ExpandableMealTile extends StatefulWidget {
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;
  final List<String> ingredients;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onAdd;
  final VoidCallback? onCustomize;
  final bool isCustomMeal;
  const _ExpandableMealTile({
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.ingredients,
    required this.icon,
    required this.iconColor,
    required this.onAdd,
    this.onCustomize,
    this.isCustomMeal = false,
    Key? key,
  }) : super(key: key);
  @override
  State<_ExpandableMealTile> createState() => _ExpandableMealTileState();
}

class _ExpandableMealTileState extends State<_ExpandableMealTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreen.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: kPrimaryGreen.withOpacity(0.13),
              child: Icon(widget.icon, color: widget.iconColor),
            ),
            title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: widget.isCustomMeal ? null : Row(
              children: [
                _MacroTag(label: 'P', value: '${widget.protein}g', color: kSecondaryBlue),
                const SizedBox(width: 6),
                _MacroTag(label: 'C', value: '${widget.carbs}g', color: kAccentOrange),
                const SizedBox(width: 6),
                _MacroTag(label: 'F', value: '${widget.fat}g', color: kWarningRed),
              ],
            ),
            trailing: Flexible(
              child: Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!widget.isCustomMeal)
                    Text('${widget.calories} cal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: kPrimaryGreen, size: 26),
                    onPressed: widget.onAdd,
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  if (widget.onCustomize != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: kPrimaryGreen, size: 22),
                      tooltip: 'Customize meal',
                      onPressed: widget.onCustomize,
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  IconButton(
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kPrimaryGreen, size: 24),
                    tooltip: _expanded ? 'Hide ingredients' : 'Show ingredients',
                    onPressed: () => setState(() => _expanded = !_expanded),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 18, right: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) {
                    final ingredients = widget.ingredients;
                    if (ingredients.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen)),
                          ...ingredients.map((ing) => Text('• $ing', style: TextStyle(color: Colors.black87))).toList(),
                        ],
                      );
                    } else {
                      return Text('No ingredients listed.', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
} 