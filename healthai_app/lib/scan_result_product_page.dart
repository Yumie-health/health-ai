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
			appBar: AppBar(title: Text(product.name.isEmpty ? product.barcode : product.name)),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						if (product.imageUrl.isNotEmpty)
							Center(
								child: Container(
									padding: const EdgeInsets.all(6),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(22),
										boxShadow: [
											if (risk.isUnsafe)
												BoxShadow(color: Colors.red.withOpacity(0.55), blurRadius: 28, spreadRadius: 1),
											if (!risk.isUnsafe)
												BoxShadow(color: Colors.green.withOpacity(0.45), blurRadius: 24, spreadRadius: 1),
										],
									),
								child: ClipRRect(
									borderRadius: BorderRadius.circular(16),
									child: Image.network(product.imageUrl, height: 180, fit: BoxFit.cover),
								),
							),
						),
						if (risk.messages.isNotEmpty) ...[
							const SizedBox(height: 10),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(risk.isUnsafe ? Icons.close_rounded : Icons.check_circle_rounded,
										color: risk.isUnsafe ? Colors.red : Colors.green,
										size: 20),
									const SizedBox(width: 6),
									Text(
										risk.isUnsafe
											? _riskMessageLocalized(context, risk.messages.first)
											: AppLocalizations.of(context)!.safetyGood,
										style: TextStyle(
											color: risk.isUnsafe ? Colors.red : Colors.green,
											fontWeight: FontWeight.w700,
										),
									),
								],
							),
						],
						const SizedBox(height: 16),
						Text(product.name.isEmpty ? product.barcode : product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
						if (product.brand.isNotEmpty) Padding(
							padding: const EdgeInsets.only(top: 6),
							child: Container(
								padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
								decoration: BoxDecoration(
									color: Colors.green.withOpacity(0.08),
									borderRadius: BorderRadius.circular(20),
									border: Border.all(color: Colors.green.withOpacity(0.25)),
								),
								child: Row(
									mainAxisSize: MainAxisSize.min,
									children: [
										const Icon(Icons.local_mall, size: 14, color: Colors.green),
										const SizedBox(width: 6),
										Text(product.brand, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
									],
								),
							),
						),
						const SizedBox(height: 16),
						Wrap(
							spacing: 10,
							runSpacing: 10,
							children: [
								_InfoChip(label: AppLocalizations.of(context)!.serving, value: product.servingSize.isEmpty ? '—' : product.servingSize),
								_InfoChip(label: AppLocalizations.of(context)!.kcalPer100g, value: _fmt(product.nutriments.energyKcal)),
								_InfoChip(label: AppLocalizations.of(context)!.protein, value: _fmt(product.nutriments.proteinG, suffix: ' g')),
								_InfoChip(label: AppLocalizations.of(context)!.carbs, value: _fmt(product.nutriments.carbsG, suffix: ' g')),
								_InfoChip(label: AppLocalizations.of(context)!.sugar, value: _fmt(product.nutriments.sugarsG, suffix: ' g')),
								_InfoChip(label: AppLocalizations.of(context)!.fat, value: _fmt(product.nutriments.fatG, suffix: ' g')),
								_InfoChip(label: AppLocalizations.of(context)!.satFat, value: _fmt(product.nutriments.satFatG, suffix: ' g')),
								_InfoChip(label: AppLocalizations.of(context)!.salt, value: _fmt(product.nutriments.saltG, suffix: ' g')),
							],
						),
						const SizedBox(height: 12),
						// Badges: Nutri-Score and NOVA
						Row(
							children: [
								_GradeBadge(label: AppLocalizations.of(context)!.badgeNutriScore, grade: product.nutriScoreGrade),
								const SizedBox(width: 10),
								_NovaBadge(label: AppLocalizations.of(context)!.badgeNova, group: product.novaGroup),
							],
						),
						const SizedBox(height: 20),
						if (product.ingredients.isNotEmpty) ...[
							Row(
								children: [
									const Icon(Icons.shopping_basket, color: Colors.green, size: 20),
									const SizedBox(width: 6),
									Text(AppLocalizations.of(context)!.ingredientsTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green)),
								],
							),
							const SizedBox(height: 8),
							_ExpandableIngredients(ingredients: product.ingredients),
						],
						const SizedBox(height: 16),
						// Allergens section
						Row(
							children: [
								Icon(Icons.warning_amber_rounded, color: risk.isUnsafe ? Colors.red : Colors.orange[700], size: 20),
								const SizedBox(width: 6),
								Text(AppLocalizations.of(context)!.allergensTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
							],
						),
						const SizedBox(height: 8),
						Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(12),
								boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
							),
							child: Builder(
								builder: (_) {
									final allergens = _humanizeTags(product.allergensTags);
									final traces = product.traces.trim();
									final items = [
										...allergens.map((a) => '${AppLocalizations.of(context)!.contains} $a'),
										if (traces.isNotEmpty) '${AppLocalizations.of(context)!.contains} $traces'
									];
									if (items.isEmpty) {
										return Text(AppLocalizations.of(context)!.allergensNone, style: const TextStyle(color: Colors.black54));
									}
									return Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: items.map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(t))).toList(),
									);
								},
							),
						),
						const SizedBox(height: 20),
						SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								icon: const Icon(Icons.check),
								label: Text(loc.logMeal),
								onPressed: () async {
									await _handleLog(context);
								},
							),
						),
					],
				),
			),
		);
	}

	Future<void> _handleLog(BuildContext context) async {
		// For meals and ingredients, prompt for quantity; for drinks, auto-use fl oz based on serving or default
		final inferred = _inferFoodTypeAndQuantity(product);
		final foodType = inferred['foodType'] as String?;
		if (foodType == 'meal' || foodType == 'ingredient') {
			final loc = AppLocalizations.of(context)!;
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green)),
        ],
      ),
    );
  }
}

String _fmt(double? v, {String suffix = ''}) {
  if (v == null) return '—';
  return v.toStringAsFixed(1) + suffix;
}

class _RiskSummary {
  final bool isUnsafe;
  final List<String> messages;
  const _RiskSummary(this.isUnsafe, this.messages);
}

_RiskSummary _deriveRisk(Product p) {
  // Heuristic: unsafe if allergens present or NOVA=4 or additives high
  final hasAllergens = p.allergensTags.isNotEmpty || (p.traces.trim().isNotEmpty);
  final ultraProcessed = (p.novaGroup ?? 0) >= 4;
  final manyAdditives = (p.additivesN ?? 0) >= 5;
  final poorNutri = ['d', 'e'].contains(p.nutriScoreGrade.toLowerCase());

  final warnings = <String>[];
  if (hasAllergens) warnings.add('allergenRisk');
  if (ultraProcessed) warnings.add('ultraProcessed');
  if (manyAdditives) warnings.add('highAdditives');
  if (poorNutri) warnings.add('lowNutriScore');

  if (warnings.isNotEmpty) return _RiskSummary(true, warnings);

  final positives = <String>[];
  if (p.ingredientsAnalysisTags.any((t) => t.contains('vegan'))) positives.add('veganFriendly');
  if (p.ingredientsAnalysisTags.any((t) => t.contains('vegetarian'))) positives.add('vegetarian');
  if (positives.isNotEmpty) return _RiskSummary(false, positives);
  return const _RiskSummary(false, ['looksGood']);
}

List<String> _humanizeTags(List<String> tags) {
  return tags
      .map((t) => t.split(':').last.replaceAll('-', ' '))
      .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
      .toList();
}

class _GradeBadge extends StatelessWidget {
  final String label;
  final String grade; // a-e
  const _GradeBadge({required this.label, required this.grade});
  @override
  Widget build(BuildContext context) {
    final g = grade.isEmpty ? '?' : grade.toUpperCase();
    final color = {
      'A': Colors.green,
      'B': Colors.lightGreen,
      'C': Colors.orange,
      'D': Colors.deepOrange,
      'E': Colors.red,
    }[g] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(width: 6),
          Text(g, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _NovaBadge extends StatelessWidget {
  final String label;
  final int? group; // 1-4
  const _NovaBadge({required this.label, required this.group});
  @override
  Widget build(BuildContext context) {
    final g = group ?? 0;
    final color = {
      1: Colors.green,
      2: Colors.lightGreen,
      3: Colors.orange,
      4: Colors.red,
    }[g] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(width: 6),
          Text(g == 0 ? '?' : g.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

String _riskMessageLocalized(BuildContext context, String code) {
  final loc = AppLocalizations.of(context)!;
  switch (code) {
    case 'allergenRisk':
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

class _ExpandableIngredients extends StatefulWidget {
  final List<String> ingredients;
  const _ExpandableIngredients({required this.ingredients});
  @override
  State<_ExpandableIngredients> createState() => _ExpandableIngredientsState();
}

class _ExpandableIngredientsState extends State<_ExpandableIngredients> {
  bool _expanded = false;
  static const int _previewCount = 8;
  @override
  Widget build(BuildContext context) {
    final total = widget.ingredients.length;
    final preview = widget.ingredients.take(_previewCount).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_expanded ? widget.ingredients : preview)
                .map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(i, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ),
          if (total > _previewCount) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? AppLocalizations.of(context)!.hideIngredients : AppLocalizations.of(context)!.showIngredients),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
