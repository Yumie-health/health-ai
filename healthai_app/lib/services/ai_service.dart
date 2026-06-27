import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'error_handler.dart';
import 'logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // API key is securely stored in Firebase Functions
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static const _suggestedMealsCacheKey = 'suggested_meals_cache';
  static const _suggestedMealsCacheTimeKey = 'suggested_meals_cache_time';

  Future<String?> sendMessage(
    String message, {
    String model = 'gpt-4o-mini',
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      log.info('Sending AI message', {
        'model': model,
        'message_length': message.length,
        'language': language,
      });

      String languageInstruction = _getLanguageInstruction(language);

      final url =
          'https://us-central1-yumie-maivenx02.cloudfunctions.net/openaiProxyCallable';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Yumie, a friendly nutrition and wellness coach. When providing health or medical recommendations, include citations using [Source: Organization Name] format. Use reputable sources like CDC, NIH, AHA, WHO, Mayo Clinic, etc. Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.$languageInstruction',
            },
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      stopwatch.stop();
      log.logPerformance('AI message request', stopwatch.elapsed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        log.info('AI message response successful', {
          'response_length': content.length,
        });
        return content;
      } else {
        log.error(
          'AI message request failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      log.error('AI message request error', e);
      return null;
    }
  }

  // Helper method to get language instruction for all supported languages
  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'ar':
        return ' Respond in Modern Standard Arabic.';
      case 'es':
        return ' Respond in Spanish.';
      case 'hi':
        return ' Respond in Hindi.';
      case 'de':
        return ' Respond in German.';
      case 'fr':
        return ' Respond in French.';
      case 'it':
        return ' Respond in Italian.';
      case 'ja':
        return ' Respond in Japanese.';
      case 'ko':
        return ' Respond in Korean.';
      case 'nl':
        return ' Respond in Dutch.';
      case 'pt':
        return ' Respond in Portuguese.';
      case 'ru':
        return ' Respond in Russian.';
      case 'tr':
        return ' Respond in Turkish.';
      default:
        return ''; // English is default
    }
  }

  Future<String?> sendCoachMessage({
    required List<Map<String, dynamic>>
    chatHistory, // [{role: 'user'/'assistant', content: ...}]
    required String name,
    required int age,
    required int heightCm,
    required double weightKg,
    required double startingWeight,
    required double targetWeight,
    required String activityLevel,
    required int calorieGoal,
    required int caloriesConsumed,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
    required int proteinG,
    required int carbsG,
    required int fatG,
    required double waterIntakeL,
    required String bloodType,
    required bool isDiabetic,
    String model = 'gpt-4o-mini',
    String? specialInstruction,
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      log.info('Sending coach message', {
        'name': name,
        'age': age,
        'calorie_goal': calorieGoal,
        'calories_consumed': caloriesConsumed,
        'language': language,
      });

      final systemPrompt = buildYumiePrompt(
        name: name,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        startingWeight: startingWeight,
        targetWeight: targetWeight,
        activityLevel: activityLevel,
        calorieGoal: calorieGoal,
        caloriesConsumed: caloriesConsumed,
        proteinGoal: proteinGoal,
        carbsGoal: carbsGoal,
        fatGoal: fatGoal,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        waterIntakeL: waterIntakeL,
        bloodType: bloodType,
        isDiabetic: isDiabetic,
        specialInstruction: specialInstruction,
        language: language,
      );

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...chatHistory,
      ];

      final url =
          'https://us-central1-yumie-maivenx02.cloudfunctions.net/openaiProxyCallable';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      stopwatch.stop();
      log.logPerformance('Coach message request', stopwatch.elapsed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;
        log.info('Coach message response successful', {
          'response_length': content?.length ?? 0,
        });
        return content;
      } else {
        log.error(
          'Coach message request failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      log.error('Coach message request error', e);
      return null;
    }
  }

  String buildYumiePrompt({
    required String name,
    required int age,
    required int heightCm,
    required double weightKg,
    required double startingWeight,
    required double targetWeight,
    required String activityLevel,
    required int calorieGoal,
    required int caloriesConsumed,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
    required int proteinG,
    required int carbsG,
    required int fatG,
    required double waterIntakeL,
    required String bloodType,
    required bool isDiabetic,
    String? specialInstruction,
    String language = 'en',
  }) {
    // Convert height to ft/in
    final totalInches = (heightCm / 2.54).round();
    final heightFt = totalInches ~/ 12;
    final heightIn = totalInches % 12;
    // Convert weights to lb
    final weightLb = (weightKg * 2.20462).round();
    final startingWeightLb = (startingWeight * 2.20462).round();
    final targetWeightLb = (targetWeight * 2.20462).round();

    String languageInstruction = _getLanguageInstruction(language);

    // Calculate weight progress
    final weightLost = startingWeight - weightKg;
    final weightToGo = weightKg - targetWeight;

    return '''
You are Yumie, a friendly, expert-level virtual nutrition coach and personal health assistant. Your job is to provide clear, accurate, and supportive responses tailored to the user's COMPLETE health profile. You have access to ALL their data and can help with ANY health, nutrition, fitness, or wellness question.

Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.$languageInstruction

IMPORTANT: When providing health or medical recommendations, you MUST include citations to credible sources. Add citations naturally in your response using [Source: Name] format. Use reputable sources like:
- American Heart Association (AHA)
- Centers for Disease Control and Prevention (CDC)
- National Institutes of Health (NIH)
- Academy of Nutrition and Dietetics
- World Health Organization (WHO)
- Mayo Clinic
- Harvard Medical School
- Peer-reviewed nutrition journals

=== COMPLETE USER HEALTH PROFILE ===
👤 PERSONAL INFO:
- Name: $name
- Age: $age years old
- Height: $heightFt ft $heightIn in (${heightCm}cm)

⚖️ WEIGHT JOURNEY:
- Starting Weight: $startingWeightLb lb (${startingWeight.toStringAsFixed(1)}kg)
- Current Weight: $weightLb lb (${weightKg.toStringAsFixed(1)}kg)
- Target Weight: $targetWeightLb lb (${targetWeight.toStringAsFixed(1)}kg)
- Progress: ${weightLost > 0
        ? 'Lost ${weightLost.toStringAsFixed(1)}kg so far!'
        : weightLost < 0
        ? 'Gained ${(-weightLost).toStringAsFixed(1)}kg since starting'
        : 'No weight change yet'}
- Remaining: ${weightToGo > 0
        ? '${weightToGo.toStringAsFixed(1)}kg to goal'
        : weightToGo < 0
        ? '${(-weightToGo).toStringAsFixed(1)}kg below goal'
        : 'At target weight!'}

🏃 ACTIVITY & LIFESTYLE:
- Activity Level: ${activityLevel.isNotEmpty ? activityLevel : 'Not specified'}

🩺 HEALTH CONDITIONS:
- Blood Type: ${bloodType.isNotEmpty ? bloodType : 'Not specified'}
- Diabetic: ${isDiabetic ? 'Yes - requires special dietary considerations' : 'No'}

🎯 DAILY NUTRITION GOALS:
- Calorie Target: $calorieGoal kcal
- Protein Goal: ${proteinGoal}g
- Carbs Goal: ${carbsGoal}g
- Fat Goal: ${fatGoal}g

📊 TODAY'S PROGRESS:
- Calories Consumed: $caloriesConsumed kcal (${((caloriesConsumed / calorieGoal) * 100).round()}% of goal)
- Macros Today: Protein: ${proteinG}g, Carbs: ${carbsG}g, Fat: ${fatG}g
- Water Intake: ${waterIntakeL.toStringAsFixed(1)}L/2L (${((waterIntakeL / 2) * 100).round()}% of goal)

${specialInstruction ?? ''}

=== YOUR ROLE ===
You are the user's complete health assistant with access to ALL their data. You can help with:
✅ Personalized meal planning and recipes
✅ Weight loss/gain strategies based on their journey
✅ Exercise recommendations for their activity level
✅ Diabetic-friendly meal suggestions (if applicable)
✅ Macro and calorie tracking analysis
✅ Hydration and nutrition coaching
✅ Progress motivation and goal setting
✅ Blood type-specific nutrition guidance
✅ Any health, fitness, or wellness questions

Always use their complete profile to give personalized, accurate advice. Reference their specific goals, progress, health conditions, and current status in your responses.

CITATION REQUIREMENT: Include relevant citations [Source: Organization Name] when making health claims or medical recommendations. This ensures users receive evidence-based guidance.

Be encouraging, supportive, and motivating. Celebrate their progress and help them overcome challenges!
''';
  }

  Future<Map<String, dynamic>?> getNutritionPlanRecommendation({
    required int age,
    required int heightCm,
    required double weightKg,
    required int calorieGoal,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
    required String bloodType,
    required bool isDiabetic,
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      log.info('Getting AI nutrition plan recommendation', {
        'age': age,
        'calorie_goal': calorieGoal,
        'protein_goal': proteinGoal,
        'carbs_goal': carbsGoal,
        'fat_goal': fatGoal,
        'language': language,
      });

      final prompt = '''
Based on the user's calculated daily nutrition needs, provide a personalized nutrition plan:

User Profile:
- Age: $age
- Height: ${(heightCm / 2.54).round()} inches
- Weight: ${(weightKg * 2.20462).round()} lbs
- Daily calorie goal: $calorieGoal kcal
- Daily protein goal: ${proteinGoal}g
- Daily carbs goal: ${carbsGoal}g
- Daily fat goal: ${fatGoal}g
- Blood type: $bloodType
- Diabetic: $isDiabetic

Please provide a detailed nutrition plan that includes:

1. DAILY INTAKE SUMMARY:
   - Total calories: $calorieGoal kcal
   - Protein: ${proteinGoal}g
   - Carbs: ${carbsGoal}g
   - Fat: ${fatGoal}g

2. MEAL BREAKDOWN:
   - Breakfast: ${(calorieGoal * 0.25).round()} calories
   - Lunch: ${(calorieGoal * 0.35).round()} calories
   - Dinner: ${(calorieGoal * 0.30).round()} calories
   - Snacks: ${(calorieGoal * 0.10).round()} calories

3. SPECIFIC FOOD SUGGESTIONS for each meal with realistic portions

4. CONSIDERATIONS:
   - Foods suitable for blood type $bloodType
   - Diabetic-friendly options if applicable
   - Balanced nutrition
   - Realistic portion sizes
   - Variety and taste

IMPORTANT: Include citations [Source: Organization] when making health claims about:
- Blood type diets
- Diabetic nutrition guidelines
- Macro ratios for health
- Any specific health benefits

Provide specific food items with quantities for each meal.
''';

      final response = await sendMessage(prompt, language: language);

      if (response != null && response.isNotEmpty) {
        log.info('AI nutrition plan received', {
          'response_length': response.length,
          'duration_ms': stopwatch.elapsedMilliseconds,
        });

        // Return the DAILY INTAKE values that the final page expects
        return {
          'calories': calorieGoal,
          'protein': proteinGoal,
          'carbs': carbsGoal,
          'fat': fatGoal,
          'ai_plan': response,
        };
      } else {
        throw Exception('Empty AI response');
      }
    } catch (e) {
      log.warning('AI nutrition plan failed, using fallback calculation', {
        'error': e.toString(),
        'duration_ms': stopwatch.elapsedMilliseconds,
      });

      // Fallback to local calculation if AI fails
      return _getFallbackNutritionPlan(
        calorieGoal: calorieGoal,
        proteinGoal: proteinGoal,
        carbsGoal: carbsGoal,
        fatGoal: fatGoal,
        bloodType: bloodType,
        isDiabetic: isDiabetic,
      );
    }
  }

  // Fallback nutrition plan calculation
  Map<String, dynamic> _getFallbackNutritionPlan({
    required int calorieGoal,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
    required String bloodType,
    required bool isDiabetic,
  }) {
    // Return the DAILY INTAKE values that the final page expects
    return {
      'calories': calorieGoal,
      'protein': proteinGoal,
      'carbs': carbsGoal,
      'fat': fatGoal,
      'ai_plan': _generateFallbackPlan(bloodType, isDiabetic, calorieGoal),
    };
  }

  String _generateFallbackPlan(
    String bloodType,
    bool isDiabetic,
    int calorieGoal,
  ) {
    final breakfastCal = (calorieGoal * 0.25).round();
    final lunchCal = (calorieGoal * 0.35).round();
    final dinnerCal = (calorieGoal * 0.30).round();
    final snacksCal = (calorieGoal * 0.10).round();

    return '''
Personalized Nutrition Plan:

🥞 BREAKFAST ($breakfastCal calories)
• Oatmeal with berries and nuts
• Greek yogurt with honey
• Whole grain toast with avocado
• Green tea or coffee

🍽️ LUNCH ($lunchCal calories)
• Grilled chicken breast with quinoa
• Mixed green salad with olive oil
• Steamed vegetables
• Fresh fruit for dessert

🍽️ DINNER ($dinnerCal calories)
• Salmon or lean protein
• Brown rice or sweet potato
• Roasted vegetables
• Herbal tea

🍎 SNACKS ($snacksCal calories)
• Apple with almond butter
• Carrot sticks with hummus
• Mixed nuts and dried fruits
• Protein smoothie

💡 Tips:
• Stay hydrated with 8+ glasses of water daily
• Eat slowly and mindfully
• Include protein with every meal
• Choose whole foods over processed options
• Listen to your body's hunger cues
''';
  }

  /// Get nutritional information for a food item using AI
  Future<Map<String, dynamic>?> getFoodNutrition(
    String foodName, {
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      log.info('Getting nutrition for food', {
        'food_name': foodName,
        'language': language,
      });

      String languageInstruction = _getLanguageInstruction(language);

      final prompt = '''
Provide nutritional information for "$foodName" for ONE typical serving. Choose a realistic serving size automatically (do not assume 100g unless that is the standard). If the query includes a count (e.g., "7 blueberries"), IGNORE the count and normalize to one typical serving.

Language rule: The value of "name" MUST be in the SAME language as the query string "$foodName" (do not translate). This rule overrides any other localization instruction.

Include a serving descriptor in parentheses after the food name, for example: "Apple (1 whole)", "Watermelon (1 slice)", "Bread (1 slice)", "Rice (1 cup cooked)", "Almonds (1 oz)".

Spelling and casing rules:
- If the query contains obvious typos or misspellings (e.g., "appl"), correct them to the canonical food name while keeping the same language.
- Never return abbreviated or truncated names.
- For English names, use Title Case for the food name portion (e.g., "Apple", "Apple Pie").

Return ONLY a JSON object with this exact structure (values are per one serving):
{
  "name": "<food name in query language> (<serving descriptor>)",
  "calories": <number>,
  "protein": <number>,
  "carbs": <number>,
  "fat": <number>,
  "ingredients": ["<ingredient1>", "<ingredient2>", ...]
}

For ingredients field:
- For single ingredients: List the main ingredient itself and any common additives/preservatives if applicable
- For prepared foods: List the main ingredients that make up the dish
- For drinks: List the main ingredients
- Keep ingredients simple and in the same language as the query
- Limit to 3-8 most important ingredients

Use credible nutrition databases and realistic portions.
STRICT NUTRITION RULES: Ensure CALORIES ≈ 4*protein + 4*carbs + 9*fat (within ±10%). If inconsistent, adjust calories to match macros. Use realistic ranges (fresh fruits/vegetables per serving typically 20–150 kcal; nuts/seeds 150–220 kcal per 1 oz; plain cooked meats 100–300 kcal). Only return the JSON, no additional text or explanations.$languageInstruction
''';

      final response = await sendMessage(
        prompt,
        model: 'gpt-4o-mini',
        language: language,
      );

      stopwatch.stop();
      log.logPerformance('Food nutrition lookup', stopwatch.elapsed);

      if (response != null) {
        try {
          final data = jsonDecode(response);
          log.info('Food nutrition lookup successful', {'food_name': foodName});
          return _fixNutritionEntry(Map<String, dynamic>.from(data));
        } catch (e) {
          log.error('Failed to parse food nutrition JSON', e);
          return null;
        }
      } else {
        log.error('Food nutrition lookup failed', 'No response from AI');
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      log.error('Food nutrition lookup error', e);
      return null;
    }
  }

  /// Search for food items that match the query
  Future<List<Map<String, dynamic>>> searchFoodItems(
    String query, {
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      log.info('Searching for food items', {
        'query': query,
        'language': language,
      });

      String languageInstruction = _getLanguageInstruction(language);

      final prompt = '''
Search for food items that match "$query". Return a list of 5-10 relevant food items.

Rules:
- Language rule: Names MUST be in the SAME language as "$query" (do not translate). This overrides any localization instruction.
- Normalize queries that contain counts (e.g., "7 blueberries") to one typical serving; nutrition values must be per one serving.
- Auto-correct obvious typos/misspellings in "$query" and use the corrected canonical food name.
- The FIRST item must be the exact intended match for "$query" after correction (in the same language as the query).
- Remaining items must be CLOSELY RELATED to "$query":
  • If "$query" is an INGREDIENT, list the same item and very close variants (synonyms, forms, species, raw/cooked notes). Avoid unrelated dishes like pizza.
  • If "$query" implies a MEAL, list meals that include "$query" as the main ingredient or in the meal name (e.g., "Blueberry Pancakes", "Blueberry Oatmeal").
  • If "$query" implies a DRINK, list drink variants featuring "$query" (e.g., juices/smoothies with the ingredient in the name).
  • Prefer results whose names contain "$query" (after correction) or a direct synonym in the same language.
- Append a serving descriptor in parentheses to every name. Choose a realistic default:
  • fruits/vegetables: "1 whole" or "1 cup" as appropriate
  • bread/cake/pizza: "1 slice"
  • nuts/seeds: "1 oz"
  • cooked grains/pasta: "1 cup cooked"
  • drinks: "8 fl oz" or "250 ml" (pick one consistently per item)

Name formatting:
- Never return abbreviated or truncated names.
- For English, use Title Case for the name portion before the parentheses (e.g., "Apple", "Apple Pie").

Food type classification:
- For EACH item, infer and include a field "food_type" with one of: "ingredient" (single raw item like apple, egg, rice), "meal" (prepared dishes or multi-ingredient foods like pizza, salad, sandwich), or "drink" (beverages like juice, coffee, milk, smoothies).

STRICT NUTRITION RULES:
- Provide values PER ONE TYPICAL SERVING only
- Ensure CALORIES ≈ 4*protein + 4*carbs + 9*fat (within ±10%). If inconsistent, adjust calories to match macros.
- Use realistic ranges. For fresh fruits/vegetables per serving typically 20–150 kcal; for nuts/seeds 150–220 kcal per 1 oz; for plain cooked meats 100–300 kcal per serving; for desserts can be higher.

Return ONLY a JSON array with this exact structure (values per one serving):
[
  {
    "name": "<food name in query language> (<serving descriptor>)",
    "calories": <number>,
    "protein": <number>,
    "carbs": <number>,
    "fat": <number>,
    "food_type": "ingredient" | "meal" | "drink",
    "ingredients": ["<ingredient1>", "<ingredient2>", ...]
  }
]

For ingredients field:
- For "ingredient" food_type: List the main ingredient itself and any common additives/preservatives if applicable
- For "meal" food_type: List the main ingredients that make up the dish (e.g., ["chicken", "rice", "vegetables", "soy sauce"])
- For "drink" food_type: List the main ingredients (e.g., ["coffee", "milk", "sugar"] or ["orange juice"])
- Keep ingredients simple and in the same language as the query
- Limit to 3-8 most important ingredients per item

Do not add explanations or markdown. Only return the JSON array.$languageInstruction
''';

      final response = await sendMessage(
        prompt,
        model: 'gpt-4o-mini',
        language: language,
      );

      stopwatch.stop();
      log.logPerformance('Food search', stopwatch.elapsed);

      if (response != null) {
        try {
          final data = jsonDecode(response);
          final List<dynamic> results = data;
          log.info('Food search successful', {
            'query': query,
            'results_count': results.length,
          });
          final mapped =
              results.map((item) => Map<String, dynamic>.from(item)).toList();
          return _fixNutritionCalorieConsistency(mapped);
        } catch (e) {
          log.error('Failed to parse food search JSON', e);
          return [];
        }
      } else {
        log.error('Food search failed', 'No response from AI');
        return [];
      }
    } catch (e) {
      stopwatch.stop();
      log.error('Food search error', e);
      return [];
    }
  }

  /// Fast food search with minimal prompt for speed
  Future<List<Map<String, dynamic>>> searchFoodItemsFast(
    String query, {
    String? foodType,
    String language = 'en',
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      log.info('Fast searching for food items', {
        'query': query,
        'food_type': foodType,
        'language': language,
      });

      String languageInstruction = _getLanguageInstruction(language);

      String foodTypeInstruction = '';
      if (foodType != null) {
        switch (foodType) {
          case 'ingredient':
            foodTypeInstruction = '''
IMPORTANT: You are searching for RAW INGREDIENTS only. Focus on:
- Single food items: apple, banana, carrot, broccoli, spinach
- Multiple items: 3 bananas, 2 apples, 4 carrots (count accurately)
- Raw proteins: chicken breast, salmon, egg, tofu
- Nuts and seeds: almonds, walnuts, sunflower seeds
- Grains: rice, quinoa, oats, bread
- Raw vegetables and fruits
- Use realistic calorie ranges: fruits 30-80 cal, vegetables 10-50 cal, nuts 500-700 cal
- Be specific about quantity in food names
- Do NOT include prepared dishes, meals, or drinks''';
            break;
          case 'meal':
            foodTypeInstruction = '''
IMPORTANT: You are searching for PREPARED MEALS only. Focus on:
- Complete dishes: grilled chicken with rice, pasta carbonara, beef stir fry
- Prepared foods: pizza, burger, salad, soup, curry
- Restaurant dishes: pad thai, sushi roll, tacos, lasagna
- Fast food: McDonald's, Burger King, Subway, etc.
- Home-cooked meals: meatloaf, casserole, roasted vegetables
- Use realistic calorie ranges: light meals 200-400 cal, regular meals 400-800 cal, heavy meals 800-1200 cal
- Do NOT include raw ingredients or drinks''';
            break;
          case 'drink':
            foodTypeInstruction = '''
IMPORTANT: You are searching for BEVERAGES/DRINKS only. Focus on:
- Coffee shop drinks: Starbucks, Dunkin, coffee, latte, cappuccino, americano, espresso, mocha, iced coffee
- Tea drinks: green tea, black tea, herbal tea, iced tea, bubble tea, chai
- Juices and smoothies: orange juice, apple juice, smoothies, fresh juices, fruit smoothies, protein smoothies
- Milk and dairy drinks: whole milk, almond milk, soy milk, chocolate milk, milkshakes
- Energy drinks: Red Bull, Monster, energy drinks, sports drinks
- Soft drinks: soda, cola, lemonade, iced coffee, iced tea
- Alcoholic beverages: beer, wine, cocktails (if appropriate)
- Use realistic calorie ranges: coffee 0-50 cal, smoothies 100-300 cal, milkshakes 200-500 cal
- Do NOT include solid foods, meals, or raw ingredients''';
            break;
        }
      }

      String prompt = '''
Search for "$query" and return exactly 5 results.$foodTypeInstruction

CRITICAL RULES:
1. Auto-correct obvious typos/misspellings in "$query" (e.g., "appl" -> "apple") while keeping the same language. The FIRST item MUST be the exact intended match after correction (use the same language as the query). If the user typed a plural (e.g., blueberries), keep the natural singular/plural form for that language.
2. Normalize queries to a standard serving. If the query contains counts (e.g., "7 blueberries"), IGNORE the count and use one typical serving.
3. Follow the requested food type STRICTLY for items 2-5. The first exact-match item is REQUIRED even if it belongs to a different category (e.g., an ingredient while the UI is set to meals).
4. Provide nutrition per ONE typical serving (not per 100g unless that is the common serving for the item)
5. Names MUST be in the SAME language as the query and include a serving descriptor in parentheses (e.g., "Apple (1 whole)", "Pizza (1 slice)", "Rice (1 cup cooked)", "Almonds (1 oz)"). For English, use Title Case for the name portion; never return abbreviated or truncated names.
6. For EACH item, include a field "food_type" with one of: "ingredient", "meal", or "drink".
7. The remaining items (2-5) must be CLOSELY RELATED to "$query" as defined above. Avoid unrelated foods (e.g., do not include pizza for a berry query).
8. Return ONLY a valid JSON array, no text, no explanations
9. Use realistic values from credible sources

Example format (values per one serving):
[
  {"name": "$query (1 typical serving)", "calories": [value], "protein": [value], "carbs": [value], "fat": [value], "food_type": "ingredient", "ingredients": ["main ingredient", "additive1"]},
  {"name": "Similar Item 1 (serving)", "calories": [value], "protein": [value], "carbs": [value], "fat": [value], "food_type": "meal", "ingredients": ["ingredient1", "ingredient2", "ingredient3"]},
  {"name": "Similar Item 2 (serving)", "calories": [value], "protein": [value], "carbs": [value], "fat": [value], "food_type": "drink", "ingredients": ["ingredient1", "ingredient2"]},
  {"name": "Similar Item 3 (serving)", "calories": [value], "protein": [value], "carbs": [value], "fat": [value], "food_type": "ingredient", "ingredients": ["main ingredient"]},
  {"name": "Similar Item 4 (serving)", "calories": [value], "protein": [value], "carbs": [value], "fat": [value], "food_type": "meal", "ingredients": ["ingredient1", "ingredient2", "ingredient3", "ingredient4"]}
]$languageInstruction
''';
      String? response = await sendMessage(
        prompt,
        model: 'gpt-4o-mini',
        language: language,
      );
      stopwatch.stop();
      log.logPerformance('Fast food search', stopwatch.elapsed);
      List<Map<String, dynamic>>? parsedResults;
      if (response != null) {
        parsedResults = _tryParseFoodJson(response);
        if (parsedResults == null) {
          // Retry with even stricter prompt
          String retryPrompt = '''
List 5 foods similar to "$query".$foodTypeInstruction Correct any obvious misspelling in "$query" while keeping the same language. For each, give name (same language as the query, Title Case for English, include a serving descriptor in parentheses, never abbreviated), calories, protein, carbs, fat per ONE typical serving, food_type, and ingredients array. Use REALISTIC and ACCURATE nutritional values for each specific food item. Respond ONLY with a valid JSON array, no explanation, no text, no code block, just the array. DO NOT SAY ANYTHING ELSE. DO NOT USE MARKDOWN. JUST THE ARRAY.''';
          response = await sendMessage(
            retryPrompt,
            model: 'gpt-4o-mini',
            language: language,
          );
          parsedResults = response != null ? _tryParseFoodJson(response) : null;
        }
        if (parsedResults != null) {
          log.info('Fast food search successful', {
            'query': query,
            'results_count': parsedResults.length,
          });
          return _fixNutritionCalorieConsistency(parsedResults);
        } else {
          log.error(
            'Failed to parse fast food search JSON after retry',
            response,
          );
          return [];
        }
      } else {
        log.error('Fast food search failed', 'No response from AI');
        return [];
      }
    } catch (e) {
      stopwatch.stop();
      log.error('Fast food search error', e);
      return [];
    }
  }

  List<Map<String, dynamic>>? _tryParseFoodJson(String response) {
    try {
      // Try direct JSON parse
      final data = jsonDecode(response);
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (_) {}
    // Try extracting from code block
    final codeBlockRegex = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      multiLine: true,
      caseSensitive: false,
    );
    final match = codeBlockRegex.firstMatch(response);
    if (match != null) {
      final jsonString = match.group(1)!.trim();
      try {
        final data = jsonDecode(jsonString);
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      } catch (_) {}
    }
    // Try extracting first array in text
    final arrayRegex = RegExp(r'(\[\s*{[\s\S]*?}\s*\])', multiLine: true);
    final arrayMatch = arrayRegex.firstMatch(response);
    if (arrayMatch != null) {
      final jsonString = arrayMatch.group(1)!.trim();
      try {
        final data = jsonDecode(jsonString);
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      } catch (_) {}
    }
    return null;
  }

  // Fix obviously inconsistent nutrition by aligning calories with macros when wildly off
  List<Map<String, dynamic>> _fixNutritionCalorieConsistency(
    List<Map<String, dynamic>> items,
  ) {
    const double tolerance = 0.10; // 10%
    List<Map<String, dynamic>> fixed = [];
    for (final item in items) {
      final name = (item['name'] ?? '').toString();
      double? cal = _toNum(item['calories']);
      final double? p = _toNum(item['protein']);
      final double? c = _toNum(item['carbs']);
      final double? f = _toNum(item['fat']);
      if (p != null && c != null && f != null) {
        final double kcalFromMacros = 4 * p + 4 * c + 9 * f;
        if (cal == null ||
            (cal > 0 && (cal - kcalFromMacros).abs() / cal > tolerance)) {
          // Adjust calories to macro-derived value rounded sensibly
          cal = double.parse(kcalFromMacros.toStringAsFixed(0));
        }
      }
      fixed.add({...item, if (cal != null) 'calories': cal, 'name': name});
    }
    return fixed;
  }

  Map<String, dynamic> _fixNutritionEntry(Map<String, dynamic> item) {
    final list = _fixNutritionCalorieConsistency([item]);
    return list.isNotEmpty ? list.first : item;
  }

  double? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    return double.tryParse(s);
  }

  String _extractJson(String response) {
    final codeBlockRegex = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      multiLine: true,
      caseSensitive: false,
    );
    final match = codeBlockRegex.firstMatch(response);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return response.trim();
  }

  /// Analyze a meal image and return food name, macros, and ingredients.
  Future<Map<String, dynamic>?> analyzeMealImage(
    File imageFile, {
    String language = 'en',
  }) async {
    try {
      final url =
          'https://us-central1-yumie-maivenx02.cloudfunctions.net/openaiProxyCallable';
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';
      String languageInstruction = _getLanguageInstruction(language);
      final prompt = '''
You are a nutrition AI expert with EXTREME attention to detail. Analyze this food/drink image with meticulous care and return a JSON object with:
- food_name: string (be extremely specific and descriptive, include brand names if visible)
- calories: integer (PER ONE TYPICAL SERVING for ingredients/meals, per 8 fl oz for drinks). If serving size is unclear, infer a realistic serving.
- protein: integer (grams per serving; for drinks per 8 fl oz)
- carbs: integer (grams per serving; for drinks per 8 fl oz)
- fat: integer (grams per serving; for drinks per 8 fl oz)
- ingredients: array of strings (main ingredients only)
- food_type: string (must be one of: "ingredient", "meal", "drink")

CRITICAL ANALYSIS RULES:
1. EXAMINE THE IMAGE WITH EXTREME CARE:
   - Look for nutrition labels, ingredient lists, and serving size information
   - Read any visible text, numbers, or nutritional information
   - Pay attention to brand names, product names, and specific details
   - If you see a nutrition label, use those exact values
   - If you see "160 calories" on a bottle, use 160 calories

2. For DRINKS (coffee, tea, smoothies, juices, sodas, energy drinks):
   - Look for nutrition labels on bottles/cans
   - Recognize specific brands (Coca-Cola, Pepsi, Starbucks, etc.)
   - Use exact calorie values if visible on packaging
   - Base serving: 8 fl oz (240ml) for most drinks
   - If nutrition info is visible, use those exact numbers

3. For INGREDIENTS (fruits, vegetables, nuts, single items):
   - If the context shows counts (e.g., multiple berries), DO NOT multiply by count; normalize to a standard serving size (e.g., 1 cup of blueberries) unless a package label indicates otherwise
   - Look for packaging labels with nutrition info
   - Use realistic calorie ranges for a serving: fruits typically 50-120 cal per serving, vegetables 15-80 cal per serving, nuts ~160-220 cal per 1 oz serving
   - Be specific about serving in food_name when possible (e.g., "Blueberries (1 cup)")

4. For MEALS (prepared dishes, cooked food):
   - Look for restaurant packaging, nutrition labels
   - Recognize specific dishes and brands
   - Use realistic calorie ranges: light meals 200-400 cal, regular meals 400-800 cal, heavy meals 800-1200 cal
   - If nutrition info is visible, use those exact values

5. ACCURATE NUTRITION DATA:
   - ALWAYS prioritize visible nutrition labels and packaging information
   - If you see "160 calories" on a bottle, use 160 calories exactly
   - Do NOT guess or use placeholder values
   - Consider portion sizes and preparation methods
   - If nutrition info is unclear, provide realistic estimates based on similar products

6. CONSISTENCY RULE:
   - Ensure CALORIES ≈ 4*protein + 4*carbs + 9*fat (within ±10%). If inconsistent and no label is visible, adjust calories to match macros.

7. EXTREME ATTENTION TO DETAIL:
   - Read every visible word, number, and label
   - Look for serving size information
   - Check for brand names and product names
   - Examine the entire image carefully before responding
   - If you see nutritional information, use it exactly as shown

Respond ONLY with valid JSON.$languageInstruction
''';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'system', 'content': prompt},
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': prompt},
                    {
                      'type': 'image_url',
                      'image_url': {'url': dataUrl},
                    },
                  ],
                },
              ],
              'max_tokens': 512,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 35));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonString = _extractJson(content);
        final result = jsonDecode(jsonString);
        return result as Map<String, dynamic>;
      } else {
        log.error(
          'analyzeMealImage failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      log.error('analyzeMealImage error', e);
      return null;
    }
  }

  /// Analyze a fridge image and return a list of detected items.
  Future<List<String>?> analyzeFridgeImage(
    File imageFile, {
    String language = 'en',
  }) async {
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';
    String languageInstruction = _getLanguageInstruction(language);
    final prompt = '''
You are a kitchen assistant AI. Given this photo of a fridge, return a JSON array of all visible food items (ingredients). Use generic ingredient names. Do NOT infer quantities or servings here. Respond ONLY with a JSON array of strings.$languageInstruction
''';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': prompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': dataUrl},
              },
            ],
          },
        ],
        'max_tokens': 512,
        'temperature': 0.3,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        final jsonString = _extractJson(content);
        final items = jsonDecode(jsonString);
        return (items as List).map((e) => e.toString()).toList();
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Generate a meal suggestion from fridge items and user profile.
  Future<Map<String, dynamic>?> generateMealFromFridge({
    required List<String> fridgeItems,
    required Map<String, dynamic> userProfile,
    String language = 'en',
  }) async {
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    String languageInstruction = _getLanguageInstruction(language);
    final prompt = '''
You are a nutrition AI. Given this user profile: ${jsonEncode(userProfile)} and these fridge items: ${jsonEncode(fridgeItems)}, suggest a healthy meal the user can make, including:
- meal_name: string formatted as "<localized meal name> (<serving descriptor>)". Examples: "Chicken Salad (1 bowl)", "Veggie Wrap (1 wrap)", "Tomato Soup (1 cup)", "Stir Fry (1 plate)". Keep it under 18 characters excluding the parentheses where possible.
- ingredients: array of strings with realistic quantities and units for EACH item (e.g., "6 oz chicken breast", "2 cups lettuce", "1 cup cooked rice", "1 tbsp olive oil") in user's language.
- recipe: array of steps (strings in user's language)
- calories: integer (per one serving)
- protein: integer (per serving in grams)
- carbs: integer (per serving in grams)
- fat: integer (per serving in grams)

Rules:
- Names and ingredient text MUST be in the user's language.
- Choose a realistic default serving descriptor: bowl/plate/wrap/sandwich/cup/slice as appropriate.
- Use credible sources or typical values for nutrition; portions must be realistic.
CONSISTENCY RULE: Ensure CALORIES ≈ 4*protein + 4*carbs + 9*fat (within ±10%). Adjust calories if inconsistent. Respond ONLY with valid JSON.$languageInstruction
''';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 512,
        'temperature': 0.5,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        return jsonDecode(content);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Get AI-powered suggested meals for a given meal period, with persistent cache
  Future<List<Map<String, dynamic>>?> getSuggestedMeals({
    required String mealPeriod,
    String language = 'en',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_suggestedMealsCacheKey${mealPeriod}_$language';
    final cacheTimeKey = '$_suggestedMealsCacheTimeKey${mealPeriod}_$language';
    final now = DateTime.now();

    // Check cache (valid for current period only)
    final cachedData = prefs.getString(cacheKey);
    final cachedTimeStr = prefs.getString(cacheTimeKey);
    if (cachedData != null && cachedTimeStr != null) {
      final cachedTime = DateTime.tryParse(cachedTimeStr);
      if (cachedTime != null) {
        // Only use cache if still in the same period (e.g., breakfast)
        if (_isSameMealPeriod(now, cachedTime, mealPeriod)) {
          try {
            final meals = List<Map<String, dynamic>>.from(
              jsonDecode(cachedData),
            );
            return meals;
          } catch (_) {}
        }
      }
    }

    // Fetch new data if no valid cache
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    String languageInstruction = _getLanguageInstruction(language);
    final prompt = '''
You are a nutrition AI. Suggest 3 healthy $mealPeriod meals with maximum diversity and variety. Each meal should be completely different from the others in terms of:
- Cuisine type (e.g., Mediterranean, Asian, Mexican, Italian, American, etc.)
- Main ingredients (avoid repeating the same primary proteins or grains)
- Cooking methods (baked, grilled, sautéed, raw, etc.)
- Flavor profiles (sweet, savory, spicy, tangy, etc.)

Language rule: ALL text fields (meal_name, ingredients, recipe steps, benefits, time) MUST be in the SAME language as the user's chosen language. This rule overrides any other localization instruction.

Include a serving descriptor in parentheses after the meal name, for example: "Chicken Stir Fry (1 bowl)", "Greek Salad (1 plate)", "Vegetable Soup (1 cup)", "Turkey Sandwich (1 sandwich)", "Fruit Smoothie (8 fl oz)".

For each meal, provide values PER ONE SERVING:
- meal_name: string (max 18 characters, including serving descriptor in parentheses)
- time: string (e.g. "10 mins" in user's language)
- benefits: array of 2 short strings (e.g. ["High Protein", "Low Sugar"] in user's language)
- calories: integer (per serving)
- protein: integer (per serving in grams)
- fat: integer (per serving in grams)
- carbs: integer (per serving in grams)
- ingredients: array of strings (in user's language with quantities)
- recipe: array of steps (strings in user's language)

Ensure each meal is unique and offers different nutritional benefits. Use realistic serving sizes and nutrition values from credible sources. Respond ONLY with a JSON array of 3 objects, no extra text, no explanations, no markdown.$languageInstruction
''';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 900,
        'temperature': 0.7,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        final codeBlockRegex = RegExp(
          r'```(?:json)?\s*([\s\S]*?)\s*```',
          multiLine: true,
          caseSensitive: false,
        );
        final match = codeBlockRegex.firstMatch(content);
        final jsonString =
            match != null ? match.group(1)!.trim() : content.trim();
        final meals = jsonDecode(jsonString);
        if (meals is List) {
          // Fix nutrition consistency for each meal before caching
          final fixedMeals =
              (meals as List)
                  .map((m) => _fixNutritionEntry(Map<String, dynamic>.from(m)))
                  .toList();
          // Save to cache
          await prefs.setString(cacheKey, jsonEncode(fixedMeals));
          await prefs.setString(cacheTimeKey, now.toIso8601String());
          return fixedMeals.cast<Map<String, dynamic>>();
        }
        return null;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  // Helper to check if two DateTimes are in the same meal period
  bool _isSameMealPeriod(DateTime now, DateTime cached, String period) {
    // You can customize this logic based on your meal period time windows
    // Example: breakfast = 5-11, lunch = 11-16, dinner = 16-21, snacks = rest
    int hourNow = now.hour;
    int hourCached = cached.hour;
    String periodNow = _getMealPeriod(hourNow);
    String periodCached = _getMealPeriod(hourCached);
    return periodNow == periodCached && period == periodNow;
  }

  String _getMealPeriod(int hour) {
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 16) return 'lunch';
    if (hour >= 16 && hour < 21) return 'dinner';
    return 'snacks';
  }

  // Optionally, add a method to clear cache for a period (e.g., on manual refresh)
  Future<void> clearSuggestedMealsCache(
    String mealPeriod,
    String language,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_suggestedMealsCacheKey${mealPeriod}_$language';
    final cacheTimeKey = '$_suggestedMealsCacheTimeKey${mealPeriod}_$language';
    await prefs.remove(cacheKey);
    await prefs.remove(cacheTimeKey);
  }
}
