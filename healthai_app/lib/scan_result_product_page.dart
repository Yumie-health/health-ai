import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'services/product_lookup_service.dart';
import 'widgets/quantity_selection_dialog.dart';

class ScanResultProductPage extends StatelessWidget {
	final Product product;
	const ScanResultProductPage({super.key, required this.product});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		final risk = _deriveRisk(product);
		return Scaffold(
			backgroundColor: const Color(0xFFF8F9FA),
			appBar: AppBar(
				title: Text(product.brand.isNotEmpty ? product.brand : 'Product'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => Navigator.of(context).pop(),
					tooltip: loc.cancel,
				),
			),
			body: Column(
				children: [
					Expanded(
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Product Image with Risk Indicator
									if (product.imageUrl.isNotEmpty)
										Center(
											child: Container(
												padding: const EdgeInsets.all(8),
												decoration: BoxDecoration(
													borderRadius: BorderRadius.circular(24),
													boxShadow: [
														if (risk.isUnsafe)
															BoxShadow(color: Colors.red.withValues(alpha: 0.15), blurRadius: 32, spreadRadius: 2),
														if (!risk.isUnsafe)
															BoxShadow(color: Colors.green.withValues(alpha: 0.12), blurRadius: 28, spreadRadius: 2),
													],
												),
												child: ClipRRect(
													borderRadius: BorderRadius.circular(20),
													child: Image.network(product.imageUrl, height: 200, fit: BoxFit.cover),
												),
											),
										),
									
									// Risk Status Banner
									if (risk.messages.isNotEmpty) ...[
										const SizedBox(height: 16),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
											decoration: BoxDecoration(
												color: risk.isUnsafe ? Colors.red.withValues(alpha: 0.08) : Colors.green.withValues(alpha: 0.08),
												borderRadius: BorderRadius.circular(16),
												border: Border.all(
													color: risk.isUnsafe ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
													width: 1,
												),
											),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													Icon(
														risk.isUnsafe ? Icons.warning_rounded : Icons.check_circle_rounded,
														color: risk.isUnsafe ? Colors.red : Colors.green,
														size: 24,
													),
													const SizedBox(width: 12),
													Expanded(
														child: Text(
															risk.isUnsafe
																? _riskMessageLocalized(context, risk.messages.first)
																: AppLocalizations.of(context)!.safetyGood,
															style: TextStyle(
																color: risk.isUnsafe ? Colors.red : Colors.green,
																fontWeight: FontWeight.w600,
																fontSize: 16,
															),
															textAlign: TextAlign.center,
														),
													),
												],
											),
										),
									],
									
									const SizedBox(height: 24),
									
									// Product Name
									Text(
										product.name.isEmpty ? product.barcode : product.name,
										style: const TextStyle(
											fontSize: 28,
											fontWeight: FontWeight.w800,
											letterSpacing: -0.5,
											color: Color(0xFF1A1A1A),
										),
									),
									
									// Brand Tag
									if (product.brand.isNotEmpty) ...[
										const SizedBox(height: 12),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
											decoration: BoxDecoration(
												color: Colors.green.withValues(alpha: 0.1),
												borderRadius: BorderRadius.circular(20),
												border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													const Icon(Icons.business, size: 16, color: Colors.green),
													const SizedBox(width: 8),
													Text(
														product.brand,
														style: const TextStyle(
															color: Colors.green,
															fontSize: 14,
															fontWeight: FontWeight.w600,
														),
													),
												],
											),
										),
									],
									
									const SizedBox(height: 24),
									
									// Nutrition Information Card
									Container(
										padding: const EdgeInsets.all(20),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(20),
											boxShadow: [
												BoxShadow(
													color: Colors.black.withValues(alpha: 0.05),
													blurRadius: 20,
													offset: const Offset(0, 8),
												),
											],
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														Icon(Icons.monitor_heart, color: Colors.green[600], size: 24),
														const SizedBox(width: 12),
														Text(
															'Nutrition Information',
															style: const TextStyle(
																fontSize: 20,
																fontWeight: FontWeight.w700,
																color: Color(0xFF1A1A1A),
															),
														),
													],
												),
												const SizedBox(height: 20),
												Wrap(
													spacing: 12,
													runSpacing: 12,
													children: [
														_NutritionChip(
															label: AppLocalizations.of(context)!.serving,
															value: product.servingSize.isEmpty ? '—' : product.servingSize,
															icon: Icons.restaurant,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.kcalPer100g,
															value: _fmt(product.nutriments.energyKcal),
															icon: Icons.local_fire_department,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.protein,
															value: _fmt(product.nutriments.proteinG, suffix: ' g'),
															icon: Icons.fitness_center,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.carbs,
															value: _fmt(product.nutriments.carbsG, suffix: ' g'),
															icon: Icons.grain,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.sugar,
															value: _fmt(product.nutriments.sugarsG, suffix: ' g'),
															icon: Icons.cake,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.fat,
															value: _fmt(product.nutriments.fatG, suffix: ' g'),
															icon: Icons.opacity,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.satFat,
															value: _fmt(product.nutriments.satFatG, suffix: ' g'),
															icon: Icons.water_drop,
														),
														_NutritionChip(
															label: AppLocalizations.of(context)!.salt,
															value: _fmt(product.nutriments.saltG, suffix: ' g'),
															icon: Icons.water_drop,
														),
													],
												),
											],
										),
									),
									
									const SizedBox(height: 20),
									
									// Health Score Badges
									Row(
										children: [
											Expanded(
												child: _HealthScoreBadge(
													label: AppLocalizations.of(context)!.badgeNutriScore,
													grade: product.nutriScoreGrade,
													icon: Icons.health_and_safety,
												),
											),
											const SizedBox(width: 12),
											Expanded(
												child: _HealthScoreBadge(
													label: AppLocalizations.of(context)!.badgeNova,
													grade: 'NOVA ${product.novaGroup ?? 0}',
													icon: Icons.science,
													isNova: true,
													novaGroup: product.novaGroup ?? 0,
												),
											),
										],
									),
									
									const SizedBox(height: 24),
									
									// Ingredients Section
									if (product.ingredients.isNotEmpty) ...[
										Container(
											padding: const EdgeInsets.all(20),
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(20),
												boxShadow: [
													BoxShadow(
														color: Colors.black.withValues(alpha: 0.05),
														blurRadius: 20,
														offset: const Offset(0, 8),
													),
												],
											),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															Icon(Icons.shopping_basket, color: Colors.green[600], size: 24),
															const SizedBox(width: 12),
															Text(
																AppLocalizations.of(context)!.ingredientsTitle,
																style: const TextStyle(
																	fontSize: 20,
																	fontWeight: FontWeight.w700,
																	color: Color(0xFF1A1A1A),
																),
															),
														],
													),
													const SizedBox(height: 16),
													// Note: Ingredients come from product database and cannot be translated
													// as they represent the actual ingredients listed on the product packaging
													_ModernIngredientsList(ingredients: product.ingredients),
												],
											),
										),
										const SizedBox(height: 20),
									],
									
									// Allergens Section
									Container(
										padding: const EdgeInsets.all(20),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(20),
											boxShadow: [
												BoxShadow(
													color: Colors.black.withValues(alpha: 0.05),
													blurRadius: 20,
													offset: const Offset(0, 8),
												),
											],
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														Icon(
															Icons.warning_amber_rounded,
															color: risk.isUnsafe ? Colors.red : Colors.orange[600],
															size: 24,
														),
														const SizedBox(width: 12),
														Text(
															AppLocalizations.of(context)!.allergensTitle,
															style: const TextStyle(
																fontSize: 20,
																fontWeight: FontWeight.w700,
																color: Color(0xFF1A1A1A),
															),
														),
													],
												),
												const SizedBox(height: 16),
												Builder(
													builder: (_) {
														final allergens = _humanizeTags(product.allergensTags);
														final traces = product.traces.trim();
														final items = [
															...allergens.map((a) => '${AppLocalizations.of(context)!.contains} $a'),
															if (traces.isNotEmpty) '${AppLocalizations.of(context)!.contains} $traces'
														];
														if (items.isEmpty) {
															return Container(
																padding: const EdgeInsets.all(16),
																decoration: BoxDecoration(
																	color: Colors.green.withValues(alpha: 0.08),
																	borderRadius: BorderRadius.circular(12),
																	border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
																),
																child: Row(
																	children: [
																		Icon(Icons.check_circle, color: Colors.green, size: 20),
																		const SizedBox(width: 12),
																		Text(
																			AppLocalizations.of(context)!.allergensNone,
																			style: TextStyle(
																				color: Colors.green[700],
																				fontWeight: FontWeight.w600,
																			),
																		),
																	],
																),
															);
														}
														return Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: items.map((t) => Padding(
																padding: const EdgeInsets.symmetric(vertical: 6),
																child: Row(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Icon(Icons.fiber_manual_record, color: Colors.red, size: 8),
																		const SizedBox(width: 12),
																		Expanded(child: Text(t, style: const TextStyle(fontSize: 15))),
																	],
																),
															)).toList(),
														);
													},
												),
											],
										),
									),
									
									const SizedBox(height: 20),
								],
							),
						),
					),
					// Fixed bottom buttons with safe area
					Container(
						padding: EdgeInsets.only(
							left: 20,
							right: 20,
							top: 20,
							bottom: MediaQuery.of(context).padding.bottom + 20,
						),
						decoration: BoxDecoration(
							color: const Color(0xFFF8F9FA),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.1),
									blurRadius: 20,
									offset: const Offset(0, -4),
								),
							],
						),
						child: Row(
							children: [
								Expanded(
									child: ElevatedButton(
										onPressed: () => Navigator.of(context).pop(),
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.red,
											foregroundColor: Colors.white,
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
											elevation: 0,
										),
										child: Text(
											loc.cancel,
											style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
										),
									),
								),
								const SizedBox(width: 16),
								Expanded(
									child: ElevatedButton.icon(
										icon: const Icon(Icons.check, size: 20),
										label: Text(
											loc.log,
											style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
										),
										onPressed: () async {
											await _handleLog(context);
										},
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.green,
											foregroundColor: Colors.white,
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
											elevation: 0,
										),
									),
								),
							],
						),
					),
				],
			),
		);
	}

	Future<void> _handleLog(BuildContext context) async {
		// For meals and ingredients, prompt for quantity; for drinks, auto-use fl oz based on serving or default
		final inferred = _inferFoodTypeAndQuantity(product);
		final foodType = inferred['foodType'] as String?;
		if (foodType == 'meal' || foodType == 'ingredient') {
			final nutr = product.nutriments;
			final result = await showDialog<Map<String, dynamic>>(
				context: context,
				builder: (context) => QuantitySelectionDialog(
					foodName: product.name.isEmpty ? product.barcode : product.name,
					foodType: foodType!,
					baseCalories: (nutr.energyKcal ?? 0).round(),
					baseProtein: (nutr.proteinG ?? 0).round(),
					baseCarbs: (nutr.carbsG ?? 0).round(),
					baseFat: (nutr.fatG ?? 0).round(),
				),
			);
			final quantity = result?['quantity'] as int?;
			final unit = result?['unit'] as String?;
			final calories = result?['calories'] as int?;
			final protein = result?['protein'] as int?;
			final carbs = result?['carbs'] as int?;
			final fat = result?['fat'] as int?;
			await _logProductAsMeal(context,
				foodType: foodType,
				quantity: quantity,
				unit: unit,
				overrideCalories: calories,
				overrideProtein: protein,
				overrideCarbs: carbs,
				overrideFat: fat,
			);
		} else {
			await _logProductAsMeal(context,
				foodType: foodType,
				quantity: inferred['quantity'] as int?,
				unit: inferred['unit'] as String?,
			);
		}
	}

	Future<void> _logProductAsMeal(BuildContext context, {
		String? foodType,
		int? quantity,
		String? unit,
		int? overrideCalories,
		int? overrideProtein,
		int? overrideCarbs,
		int? overrideFat,
	}) async {
		final user = FirebaseAuth.instance.currentUser;
		if (user == null) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not signed in')));
			return;
		}
		final nutr = product.nutriments;
		final meal = Meal(
			id: '',
			name: product.name.isEmpty ? product.barcode : product.name,
			calories: (overrideCalories ?? (nutr.energyKcal ?? 0)).round(),
			protein: (overrideProtein ?? (nutr.proteinG ?? 0)).round(),
			carbs: (overrideCarbs ?? (nutr.carbsG ?? 0)).round(),
			fat: (overrideFat ?? (nutr.fatG ?? 0)).round(),
			timestamp: DateTime.now(),
			mealType: 'snack',
			userId: user.uid,
			imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : null,
			foodType: foodType ?? 'ingredient',
			quantity: quantity ?? (foodType == 'drink' ? 8 : 1),
			quantityUnit: unit ?? (foodType == 'drink' ? 'fl oz' : foodType == 'meal' ? 'servings' : 'count'),
			ingredients: product.ingredients,
		);
		await MealService().addMeal(meal);
		if (context.mounted) {
			Navigator.of(context).popUntil((r) => r.isFirst);
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged')));
		}
	}
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _NutritionChip({
    required this.label,
    required this.value,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green[600], size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthScoreBadge extends StatelessWidget {
  final String label;
  final String grade;
  final IconData icon;
  final bool isNova;
  final int novaGroup;
  
  const _HealthScoreBadge({
    required this.label,
    required this.grade,
    required this.icon,
    this.isNova = false,
    this.novaGroup = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    final isUnknown = grade.isEmpty || grade == 'unknown' || grade.contains('UNKNOWN');
    Color badgeColor;
    
    if (isNova) {
      badgeColor = novaGroup == 4 ? Colors.red : 
                   novaGroup == 3 ? Colors.orange : 
                   novaGroup == 2 ? Colors.yellow[700]! : Colors.green;
    } else {
      badgeColor = isUnknown ? Colors.grey : Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: badgeColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isUnknown ? 'UNKNOWN' : grade.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: badgeColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModernIngredientsList extends StatefulWidget {
  final List<String> ingredients;
  const _ModernIngredientsList({required this.ingredients});
  
  @override
  State<_ModernIngredientsList> createState() => _ModernIngredientsListState();
}

class _ModernIngredientsListState extends State<_ModernIngredientsList> {
  bool _expanded = false;
  static const int _previewCount = 6;
  
  @override
  Widget build(BuildContext context) {
    final total = widget.ingredients.length;
    final preview = widget.ingredients.take(_previewCount).toList();
    final displayIngredients = _expanded ? widget.ingredients : preview;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayIngredients.map((ingredient) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              ingredient,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
          )).toList(),
        ),
        if (total > _previewCount) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _expanded 
                  ? AppLocalizations.of(context)!.hideIngredients 
                  : AppLocalizations.of(context)!.showIngredients,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Helper functions
String _fmt(dynamic value, {String? suffix}) {
  if (value == null || value == 0) return '—';
  final str = value.toString();
  if (str.contains('.')) {
    final parts = str.split('.');
    if (parts[1].length > 1) {
      return '${parts[0]}.${parts[1].substring(0, 1)}${suffix ?? ''}';
    }
  }
  return '$str${suffix ?? ''}';
}

List<String> _humanizeTags(List<String> tags) {
  return tags.map((tag) {
    final parts = tag.split(':');
    if (parts.length > 1) {
      return parts[1].replaceAll('-', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    }
    return tag.replaceAll('-', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }).toList();
}

class _RiskAssessment {
  final bool isUnsafe;
  final List<String> messages;
  const _RiskAssessment({required this.isUnsafe, required this.messages});
}

_RiskAssessment _deriveRisk(Product product) {
  final messages = <String>[];
  bool isUnsafe = false;
  
  // Check for allergens
  if (product.allergensTags.isNotEmpty) {
    messages.add('allergen');
    isUnsafe = true;
  }
  
  // Check for ultra-processed (NOVA 4)
  if (product.novaGroup == 4) {
    messages.add('ultraProcessed');
    isUnsafe = true;
  }
  
  // Check for high additives
  if ((product.additivesN ?? 0) > 5) {
    messages.add('highAdditives');
    isUnsafe = true;
  }
  
  // Check for low Nutri-Score
  if (product.nutriScoreGrade.isNotEmpty && ['d', 'e'].contains(product.nutriScoreGrade.toLowerCase())) {
    messages.add('lowNutriScore');
    isUnsafe = true;
  }
  
  // Check for vegan/vegetarian preferences
  if (product.ingredients.any((i) => i.toLowerCase().contains('milk') || i.toLowerCase().contains('egg') || i.toLowerCase().contains('meat'))) {
    messages.add('veganFriendly');
  }
  
  if (product.ingredients.any((i) => i.toLowerCase().contains('meat'))) {
    messages.add('vegetarian');
  }
  
  if (messages.isEmpty) {
    messages.add('looksGood');
  }
  
  return _RiskAssessment(isUnsafe: isUnsafe, messages: messages);
}

String _riskMessageLocalized(BuildContext context, String risk) {
  final loc = AppLocalizations.of(context)!;
  switch (risk) {
    case 'allergen':
      return loc.riskAllergen;
    case 'ultraProcessed':
      return loc.riskUltraProcessed;
    case 'highAdditives':
      return loc.riskHighAdditives;
    case 'lowNutriScore':
      return loc.riskLowNutri;
    case 'veganFriendly':
      return loc.riskVegan;
    case 'vegetarian':
      return loc.riskVegetarian;
    case 'looksGood':
    default:
      return loc.riskLooksGood;
  }
}

Map<String, Object?> _inferFoodTypeAndQuantity(Product p) {
  // Simple inference based on categories and serving text
  final cats = p.categoriesTags.map((e) => e.toLowerCase()).toList();
  final serving = p.servingSize.toLowerCase();
  bool isDrink = cats.any((c) => c.contains('beverages') || c.contains('drinks') || c.contains('beverage')) || serving.contains('ml') || serving.contains('fl oz');
  bool isIngredient = cats.any((c) => c.contains('ingredients') || c.contains('spices') || c.contains('condiments'));
  final String foodType = isDrink ? 'drink' : (isIngredient ? 'ingredient' : 'meal');
  if (foodType == 'drink') {
    // Default 8 fl oz if we cannot parse
    int quantity = 8;
    if (serving.contains('fl oz')) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*fl\s*oz').firstMatch(serving);
      if (match != null) quantity = double.parse(match.group(1)!).round();
    } else if (serving.contains('ml')) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*ml').firstMatch(serving);
      if (match != null) {
        final ml = double.parse(match.group(1)!);
        quantity = (ml / 29.5735).round();
      }
    }
    return {'foodType': 'drink', 'quantity': quantity, 'unit': 'fl oz'};
  }
  if (foodType == 'meal') {
    return {'foodType': 'meal', 'quantity': 1, 'unit': 'servings'};
  }
  return {'foodType': 'ingredient', 'quantity': 1, 'unit': 'count'};
}
