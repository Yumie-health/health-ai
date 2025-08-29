import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../providers/preferences_provider.dart';

class QuantitySelectionDialog extends StatefulWidget {
  final String foodName;
  final String foodType; // ingredient, meal, drink
  final int baseCalories;
  final int baseProtein;
  final int baseCarbs;
  final int baseFat;

  const QuantitySelectionDialog({
    Key? key,
    required this.foodName,
    required this.foodType,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
  }) : super(key: key);

  @override
  State<QuantitySelectionDialog> createState() => _QuantitySelectionDialogState();
}

class _QuantitySelectionDialogState extends State<QuantitySelectionDialog> 
    with TickerProviderStateMixin {
  final TextEditingController _quantityController = TextEditingController();
  int? _selectedQuantity;
  String? _selectedUnit;
  int _calculatedCalories = 0;
  int _calculatedProtein = 0;
  int _calculatedCarbs = 0;
  int _calculatedFat = 0;

  // Animation controllers
  late AnimationController _nutritionAnimationController;
  late AnimationController _valueAnimationController;
  late Animation<double> _nutritionScaleAnimation;
  late Animation<double> _valueFadeAnimation;
  late Animation<double> _valueSlideAnimation;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
    
    // Initialize animation controllers
    _nutritionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _valueAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Setup animations
    _nutritionScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nutritionAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _valueFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _valueAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _valueSlideAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _valueAnimationController,
      curve: Curves.easeOut,
    ));
    
    _updateCalculations();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _nutritionAnimationController.dispose();
    _valueAnimationController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final quantity = int.tryParse(_quantityController.text);
    setState(() {
      _selectedQuantity = quantity;
      _updateCalculations();
    });
    
    // Trigger animations when quantity changes
    if (quantity != null && quantity > 0) {
      _nutritionAnimationController.forward();
      _valueAnimationController.forward();
    }
  }

  void _updateCalculations() {
    final quantity = _selectedQuantity ?? 1;
    
    if (widget.foodType == 'drink') {
      // For drinks, assume base serving is 8 fl oz and calculate proportionally
      const baseServingSize = 8.0; // 8 fl oz is typical serving size
      final ratio = quantity / baseServingSize;
      _calculatedCalories = (widget.baseCalories * ratio).round();
      _calculatedProtein = (widget.baseProtein * ratio).round();
      _calculatedCarbs = (widget.baseCarbs * ratio).round();
      _calculatedFat = (widget.baseFat * ratio).round();
    } else {
      // For ingredients and meals, use simple multiplication
      _calculatedCalories = widget.baseCalories * quantity;
      _calculatedProtein = widget.baseProtein * quantity;
      _calculatedCarbs = widget.baseCarbs * quantity;
      _calculatedFat = widget.baseFat * quantity;
    }
  }

  String _getQuantityLabel() {
    switch (widget.foodType) {
      case 'ingredient':
        // Use servings for ingredients to avoid per-item confusion
        return AppLocalizations.of(context)!.servings;
      case 'meal':
        return AppLocalizations.of(context)!.servings;
      case 'drink':
        // Use unit system: US -> L, others -> fl oz
        final prefs = Provider.of<PreferencesProvider>(context, listen: false);
        final bool isUS = !prefs.useMetric;
        return isUS ? 'L' : AppLocalizations.of(context)!.fluidOunces;
      default:
        return AppLocalizations.of(context)!.quantity;
    }
  }

  String _getQuantityUnit() {
    switch (widget.foodType) {
      case 'ingredient':
        return AppLocalizations.of(context)!.servings;
      case 'meal':
        return AppLocalizations.of(context)!.servings;
      case 'drink':
        // Use unit system: US -> L, others -> fl oz
        final prefs = Provider.of<PreferencesProvider>(context, listen: false);
        final bool isUS = !prefs.useMetric;
        return isUS ? 'L' : 'fl oz';
      default:
        return '';
    }
  }

  String _getQuantityHint() {
    switch (widget.foodType) {
      case 'ingredient':
        return 'e.g., 1';
      case 'meal':
        return 'e.g., 2';
      case 'drink':
        return 'e.g., 16';
      default:
        return '';
    }
  }

  String _getFoodTypeLabel() {
    switch (widget.foodType) {
      case 'ingredient':
        return AppLocalizations.of(context)!.ingredient;
      case 'meal':
        return AppLocalizations.of(context)!.meal;
      case 'drink':
        return AppLocalizations.of(context)!.drink;
      default:
        return widget.foodType.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      widget.foodType == 'drink' ? Icons.local_drink : Icons.restaurant,
                      color: kPrimaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.foodName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.foodType == 'drink' 
                    ? '${_getFoodTypeLabel()} • ${widget.baseCalories} cal (per 8 fl oz)'
                    : '${_getFoodTypeLabel()} • ${widget.baseCalories} cal (per serving)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quantity Input with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedQuantity != null && _selectedQuantity! > 0
                        ? Border.all(color: kPrimaryGreen.withOpacity(0.3), width: 2)
                        : null,
                    boxShadow: _selectedQuantity != null && _selectedQuantity! > 0
                        ? [
                            BoxShadow(
                              color: kPrimaryGreen.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: _getQuantityHint(),
                      suffixText: _getQuantityUnit(),
                      filled: true,
                      fillColor: kPrimaryGreen.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kPrimaryGreen.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Calculated Nutrition with animations
                if (_selectedQuantity != null && _selectedQuantity! > 0) ...[
                  AnimatedBuilder(
                    animation: _nutritionAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _nutritionScaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kPrimaryGreen.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryGreen.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calculate,
                                    color: kPrimaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.totalNutrition,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AnimatedNutritionItem(
                                      label: AppLocalizations.of(context)!.calories,
                                      value: _calculatedCalories.toString(),
                                      color: Colors.green[700]!,
                                      animationController: _valueAnimationController,
                                      fadeAnimation: _valueFadeAnimation,
                                      slideAnimation: _valueSlideAnimation,
                                    ),
                                  ),
                                  Expanded(
                                    child: _AnimatedNutritionItem(
                                      label: AppLocalizations.of(context)!.protein,
                                      value: '${_calculatedProtein}g',
                                      color: Colors.blue[700]!,
                                      animationController: _valueAnimationController,
                                      fadeAnimation: _valueFadeAnimation,
                                      slideAnimation: _valueSlideAnimation,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AnimatedNutritionItem(
                                      label: AppLocalizations.of(context)!.carbs,
                                      value: '${_calculatedCarbs}g',
                                      color: Colors.orange[700]!,
                                      animationController: _valueAnimationController,
                                      fadeAnimation: _valueFadeAnimation,
                                      slideAnimation: _valueSlideAnimation,
                                    ),
                                  ),
                                  Expanded(
                                    child: _AnimatedNutritionItem(
                                      label: AppLocalizations.of(context)!.fat,
                                      value: '${_calculatedFat}g',
                                      color: Colors.red[400]!,
                                      animationController: _valueAnimationController,
                                      fadeAnimation: _valueFadeAnimation,
                                      slideAnimation: _valueSlideAnimation,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedQuantity != null && _selectedQuantity! > 0
                            ? () {
                                Navigator.of(context).pop({
                                  'quantity': _selectedQuantity,
                                  'unit': _getQuantityUnit(),
                                  'calories': _calculatedCalories,
                                  'protein': _calculatedProtein,
                                  'carbs': _calculatedCarbs,
                                  'fat': _calculatedFat,
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(AppLocalizations.of(context)!.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;

  const _AnimatedNutritionItem({
    required this.label,
    required this.value,
    required this.color,
    required this.animationController,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideAnimation.value),
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 