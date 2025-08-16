import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple Open Food Facts product lookup.
/// - Uses API v2: GET /api/v2/product/{barcode}.json
/// - Adds required User-Agent per OFF guidelines
class ProductLookupService {
	final String userAgent;
	final Uri Function(String barcode) _endpoint;

	ProductLookupService({
		required this.userAgent,
		Uri Function(String barcode)? endpointBuilder,
	}) : _endpoint = endpointBuilder ?? ((code) => Uri.parse('https://world.openfoodfacts.org/api/v2/product/$code.json'));

	Future<ProductLookupResult> fetchByBarcode(String barcode) async {
		final uri = _endpoint(barcode);
		final res = await http.get(uri, headers: {
			'User-Agent': userAgent,
		});

		if (res.statusCode != 200) {
			return ProductLookupResult.notFound();
		}
		final body = json.decode(res.body) as Map<String, dynamic>;
		if (body['status'] != 1 || body['product'] == null) {
			return ProductLookupResult.notFound();
		}
		final p = body['product'] as Map<String, dynamic>;
		return ProductLookupResult.found(
			Product(
				barcode: barcode,
				name: (p['product_name'] ?? p['generic_name'] ?? '') as String,
				brand: (p['brands'] ?? '') as String,
				imageUrl: (p['image_front_url'] ?? p['image_url'] ?? '') as String,
				servingSize: (p['serving_size'] ?? '') as String,
				nutriments: _parseNutriments(p['nutriments'] as Map<String, dynamic>?),
				ingredients: _parseIngredients(p),
				allergensTags: _parseStringList(p['allergens_tags']),
				traces: (p['traces'] ?? '') as String,
				ingredientsAnalysisTags: _parseStringList(p['ingredients_analysis_tags']),
				additivesN: _parseInt(p['additives_n']),
				novaGroup: _parseInt(p['nova_group']),
				nutriScoreGrade: (p['nutriscore_grade'] ?? '') as String,
				categoriesTags: _parseStringList(p['categories_tags']),
			),
		);
	}

	static Nutriments _parseNutriments(Map<String, dynamic>? n) {
		if (n == null) return const Nutriments();
		double? _num(String key) {
			final v = n[key];
			if (v == null) return null;
			return (v is num) ? v.toDouble() : double.tryParse(v.toString());
		}
		return Nutriments(
			energyKcal: _num('energy-kcal_100g') ?? _num('energy-kcal'),
			proteinG: _num('proteins_100g'),
			carbsG: _num('carbohydrates_100g'),
			sugarsG: _num('sugars_100g'),
			fatG: _num('fat_100g'),
			satFatG: _num('saturated-fat_100g'),
			saltG: _num('salt_100g'),
			sodiumG: _num('sodium_100g'),
			fiberG: _num('fiber_100g'),
		);
	}
}

class ProductLookupResult {
	final Product? product;
	final bool found;
	const ProductLookupResult._(this.product, this.found);
	factory ProductLookupResult.found(Product p) => ProductLookupResult._(p, true);
	factory ProductLookupResult.notFound() => const ProductLookupResult._(null, false);
}

class Product {
	final String barcode;
	final String name;
	final String brand;
	final String imageUrl;
	final String servingSize;
	final Nutriments nutriments;
	final List<String> ingredients;
	final List<String> allergensTags;
	final String traces;
	final List<String> ingredientsAnalysisTags;
	final int? additivesN;
	final int? novaGroup;
	final String nutriScoreGrade;
	final List<String> categoriesTags;
	const Product({
		required this.barcode,
		required this.name,
		required this.brand,
		required this.imageUrl,
		required this.servingSize,
		required this.nutriments,
		required this.ingredients,
		required this.allergensTags,
		required this.traces,
		required this.ingredientsAnalysisTags,
		this.additivesN,
		this.novaGroup,
		required this.nutriScoreGrade,
		required this.categoriesTags,
	});
}

class Nutriments {
	final double? energyKcal;
	final double? proteinG;
	final double? carbsG;
	final double? sugarsG;
	final double? fatG;
	final double? satFatG;
	final double? saltG;
	final double? sodiumG;
	final double? fiberG;
	const Nutriments({
		this.energyKcal,
		this.proteinG,
		this.carbsG,
		this.sugarsG,
		this.fatG,
		this.satFatG,
		this.saltG,
		this.sodiumG,
		this.fiberG,
	});
}

List<String> _parseStringList(dynamic v) {
	if (v is List) {
		return v.map((e) => e.toString()).toList();
	}
	return const [];
}

int? _parseInt(dynamic v) {
	if (v == null) return null;
	if (v is int) return v;
	return int.tryParse(v.toString());
}

List<String> _parseIngredients(Map<String, dynamic> p) {
	final List<String> items = [];
	// ingredients_text in various locales; prefer English if present
	final text = (p['ingredients_text_en'] ?? p['ingredients_text'] ?? '') as String;
	if (text.isNotEmpty) {
		items.addAll(text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
	}
	// fallback to structured list
	final list = p['ingredients'] as List<dynamic>?;
	if (list != null && items.isEmpty) {
		for (final e in list) {
			final m = e as Map<String, dynamic>;
			final n = (m['text'] ?? m['id'] ?? '').toString();
			if (n.isNotEmpty) items.add(n);
		}
	}
	return items;
}

