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

  Future<String?> sendMessage(String message, {String model = 'gpt-4o-mini'}) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      log.info('Sending AI message', {'model': model, 'message_length': message.length});
      
      final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': 'You are Yumie, a friendly nutrition and wellness coach. Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.'},
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
        log.info('AI message response successful', {'response_length': content.length});
        return content;
      } else {
        log.error('AI message request failed', 'HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      log.error('AI message request error', e);
      return null;
    }
  }

  Future<String?> sendCoachMessage({
    required List<Map<String, dynamic>> chatHistory, // [{role: 'user'/'assistant', content: ...}]
    required String name,
    required int age,
    required int heightCm,
    required double weightKg,
    required int calorieGoal,
    required int caloriesConsumed,
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
        calorieGoal: calorieGoal,
        caloriesConsumed: caloriesConsumed,
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

      final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
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
        log.info('Coach message response successful', {'response_length': content?.length ?? 0});
        return content;
      } else {
        log.error('Coach message request failed', 'HTTP ${response.statusCode}: ${response.body}');
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
    required int calorieGoal,
    required int caloriesConsumed,
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
    // Convert weight to lb
    final weightLb = (weightKg * 2.20462).round();
    String languageInstruction = '';
    if (language == 'ar') {
      languageInstruction = '\nRespond in Modern Standard Arabic.';
    } else if (language == 'es') {
      languageInstruction = '\nRespond in Spanish.';
    }
    return '''
You are Yumie, a friendly, expert-level virtual nutrition coach. Your job is to provide clear, accurate, and supportive responses tailored to the user's unique profile. Use the following user data to guide every answer:

Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.$languageInstruction

- Name: $name
- Age: $age
- Height: $heightFt ft $heightIn in
- Weight: $weightLb lb
- Daily calorie goal: $calorieGoal kcal
- Calories consumed today: $caloriesConsumed kcal
- Macronutrients today: Protein: ${proteinG}g, Carbs: ${carbsG}g, Fat: ${fatG}g
- Water intake: ${waterIntakeL.toStringAsFixed(1)}/2L
- Blood Type: $bloodType
- Diabetic: ${isDiabetic ? 'Yes' : 'No'}
${specialInstruction ?? ''}
For this health insight, respond as exactly 3 concise bullet points, each 1 sentence only. No intro, no extra text, no paragraphs.
You can suggest:
- Balanced meals or snacks based on what they've eaten so far.
- Ways to reach their daily macronutrient or hydration goals.
- Adjustments if they are under or over their calorie targets.
- Weekly meal planning tips that suit their age, metabolism, and goals.

Respond in a motivating and friendly tone, like a helpful nutrition buddy. If the user asks, also analyze recent meals, explain food choices, or recommend what to eat next based on their progress.

✅ Always personalize your answer.
✅ Always reflect the current calorie/macronutrient balance.
✅ Encourage smart and realistic choices.
''';
  }

  Future<Map<String, int>?> getNutritionPlanRecommendation({
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
      log.info('Getting nutrition plan recommendation', {
        'age': age,
        'calorie_goal': calorieGoal,
        'language': language,
      });

    final prompt = '''
Given the following user profile, provide a personalized nutrition plan recommendation:

- Age: $age
- Height: ${(heightCm / 2.54).round()} inches
- Weight: ${(weightKg * 2.20462).round()} lbs
- Daily calorie goal: $calorieGoal kcal
- Protein goal: ${proteinGoal}g
- Carbs goal: ${carbsGoal}g
- Fat goal: ${fatGoal}g
- Blood Type: $bloodType
- Diabetic: ${isDiabetic ? 'Yes' : 'No'}

Provide a JSON response with the following structure:
{
  "breakfast": {
    "calories": <number>,
    "protein": <number>,
    "carbs": <number>,
    "fat": <number>
  },
  "lunch": {
    "calories": <number>,
    "protein": <number>,
    "carbs": <number>,
    "fat": <number>
  },
  "dinner": {
    "calories": <number>,
    "protein": <number>,
    "carbs": <number>,
    "fat": <number>
  },
  "snack": {
    "calories": <number>,
    "protein": <number>,
    "carbs": <number>,
    "fat": <number>
  }
}

Only return the JSON, no additional text.
''';

      final response = await sendMessage(prompt, model: 'gpt-4o-mini');
      
      stopwatch.stop();
      log.logPerformance('Nutrition plan recommendation', stopwatch.elapsed);
      
      if (response != null) {
        try {
          final data = jsonDecode(response);
          log.info('Nutrition plan recommendation successful');
          return Map<String, int>.from(data);
        } catch (e) {
          log.error('Failed to parse nutrition plan JSON', e);
          return null;
        }
      } else {
        log.error('Nutrition plan recommendation failed', 'No response from AI');
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      log.error('Nutrition plan recommendation error', e);
      return null;
    }
  }

  /// Get nutritional information for a food item using AI
  Future<Map<String, dynamic>?> getFoodNutrition(String foodName) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      log.info('Getting nutrition for food', {'food_name': foodName});

      final prompt = '''
Provide nutritional information for "$foodName" per 100g serving.

Return ONLY a JSON object with this exact structure:
{
  "name": "$foodName",
  "calories": <number>,
  "protein": <number>,
  "carbs": <number>,
  "fat": <number>
}

Use standard nutritional databases. Only return the JSON, no additional text or explanations.
''';

      final response = await sendMessage(prompt, model: 'gpt-4o-mini');
      
      stopwatch.stop();
      log.logPerformance('Food nutrition lookup', stopwatch.elapsed);
      
      if (response != null) {
        try {
          final data = jsonDecode(response);
          log.info('Food nutrition lookup successful', {'food_name': foodName});
          return Map<String, dynamic>.from(data);
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
  Future<List<Map<String, dynamic>>> searchFoodItems(String query) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      log.info('Searching for food items', {'query': query});

      final prompt = '''
Search for food items that match "$query". Return a list of 5-10 relevant food items.

Return ONLY a JSON array with this exact structure:
[
  {
    "name": "<food name>",
    "calories": <number per 100g>,
    "protein": <number per 100g>,
    "carbs": <number per 100g>,
    "fat": <number per 100g>
  }
]

Include common variations and similar foods. Only return the JSON array, no additional text.
''';

      final response = await sendMessage(prompt, model: 'gpt-4o-mini');
      
      stopwatch.stop();
      log.logPerformance('Food search', stopwatch.elapsed);
      
      if (response != null) {
        try {
          final data = jsonDecode(response);
          final List<dynamic> results = data;
          log.info('Food search successful', {'query': query, 'results_count': results.length});
          return results.map((item) => Map<String, dynamic>.from(item)).toList();
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
  Future<List<Map<String, dynamic>>> searchFoodItemsFast(String query) async {
    final stopwatch = Stopwatch()..start();
    try {
      print('🤖 AI: Starting fast search for: $query'); // Debug log
      log.info('Fast searching for food items', {'query': query});
      String prompt = '''
List 5 foods for "$query". The first result MUST be the exact food "$query" (if it exists), followed by 4 similar foods. For each, give name, calories, protein, carbs, fat per 100g. Respond ONLY with a valid JSON array, no explanation, no text, no code block, just the array. Example:
[
  {"name": "$query", "calories": 32, "protein": 0.7, "carbs": 7.7, "fat": 0.3},
  {"name": "Raspberry", "calories": 52, "protein": 1.2, "carbs": 12, "fat": 0.7},
  {"name": "Blackberry", "calories": 43, "protein": 1.4, "carbs": 10, "fat": 0.5},
  {"name": "Blueberry", "calories": 57, "protein": 0.7, "carbs": 14, "fat": 0.3},
  {"name": "Gooseberry", "calories": 44, "protein": 1.0, "carbs": 10, "fat": 0.6}
]
''';
      print('🤖 AI: Sending prompt to AI...'); // Debug log
      String? response = await sendMessage(prompt, model: 'gpt-4o-mini');
      print('🤖 AI: Got response: '+(response?.substring(0, 100) ?? "null")+'...'); // Debug log
      stopwatch.stop();
      log.logPerformance('Fast food search', stopwatch.elapsed);
      List<Map<String, dynamic>>? parsedResults;
      if (response != null) {
        parsedResults = _tryParseFoodJson(response);
        if (parsedResults == null) {
          // Retry with even stricter prompt
          print('🤖 AI: First response not valid JSON, retrying with stricter prompt...');
          String retryPrompt = '''
List 5 foods similar to "$query". For each, give name, calories, protein, carbs, fat per 100g. Respond ONLY with a valid JSON array, no explanation, no text, no code block, just the array. DO NOT SAY ANYTHING ELSE. DO NOT USE MARKDOWN. JUST THE ARRAY.''';
          response = await sendMessage(retryPrompt, model: 'gpt-4o-mini');
          print('🤖 AI: Retry response: '+(response?.substring(0, 100) ?? "null")+'...'); // Debug log
          parsedResults = response != null ? _tryParseFoodJson(response) : null;
        }
        if (parsedResults != null) {
          print('🤖 AI: Parsed '+parsedResults.length.toString()+' results'); // Debug log
          log.info('Fast food search successful', {'query': query, 'results_count': parsedResults.length});
          return parsedResults;
        } else {
          print('🤖 AI: JSON parse error after retry'); // Debug log
          log.error('Failed to parse fast food search JSON after retry', response);
          return [];
        }
      } else {
        print('🤖 AI: No response from AI'); // Debug log
        log.error('Fast food search failed', 'No response from AI');
        return [];
      }
    } catch (e) {
      stopwatch.stop();
      print('🤖 AI: Search error: $e'); // Debug log
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
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', multiLine: true, caseSensitive: false);
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

  String _extractJson(String response) {
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', multiLine: true, caseSensitive: false);
    final match = codeBlockRegex.firstMatch(response);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return response.trim();
  }

  /// Analyze a meal image and return food name, macros, and ingredients.
  Future<Map<String, dynamic>?> analyzeMealImage(File imageFile, {String language = 'en'}) async {
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';
    String languageInstruction = '';
    if (language == 'ar') {
      languageInstruction = '\nRespond in Modern Standard Arabic.';
    } else if (language == 'es') {
      languageInstruction = '\nRespond in Spanish.';
    }
    final prompt = '''
You are a nutrition AI. Given this photo of a meal, return a JSON object with:
- food_name: string
- calories: integer
- protein: integer
- carbs: integer
- fat: integer
- ingredients: array of strings
Respond ONLY with valid JSON.$languageInstruction
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
              {'type': 'image_url', 'image_url': {'url': dataUrl}},
            ]
          },
        ],
        'max_tokens': 512,
        'temperature': 0.3,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final jsonString = _extractJson(content);
      final result = jsonDecode(jsonString);
      return result as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// Analyze a fridge image and return a list of detected items.
  Future<List<String>?> analyzeFridgeImage(File imageFile, {String language = 'en'}) async {
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';
    String languageInstruction = '';
    if (language == 'ar') {
      languageInstruction = '\nRespond in Modern Standard Arabic.';
    } else if (language == 'es') {
      languageInstruction = '\nRespond in Spanish.';
    }
    final prompt = '''
You are a kitchen assistant AI. Given this photo of a fridge, return a JSON array of all visible food items (ingredients). Respond ONLY with a JSON array of strings.$languageInstruction
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
              {'type': 'image_url', 'image_url': {'url': dataUrl}},
            ]
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
    String languageInstruction = '';
    if (language == 'ar') {
      languageInstruction = '\nRespond in Modern Standard Arabic.';
    } else if (language == 'es') {
      languageInstruction = '\nRespond in Spanish.';
    }
    final prompt = '''
You are a nutrition AI. Given this user profile: ${jsonEncode(userProfile)} and these fridge items: ${jsonEncode(fridgeItems)}, suggest a healthy meal the user can make, including:
- meal_name: string
- ingredients: array of strings (all ingredients needed for the meal)
- recipe: array of steps (strings)
- calories: integer
- protein: integer
- carbs: integer
- fat: integer
Respond ONLY with valid JSON.$languageInstruction
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
  Future<List<Map<String, dynamic>>?> getSuggestedMeals({required String mealPeriod, String language = 'en'}) async {
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
            final meals = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
            return meals;
          } catch (_) {}
        }
      }
    }

    // Fetch new data if no valid cache
    final url = 'https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app';
    String languageInstruction = '';
    if (language == 'ar') {
      languageInstruction = '\nRespond in Modern Standard Arabic.';
    } else if (language == 'es') {
      languageInstruction = '\nRespond in Spanish.';
    }
    final prompt = '''
You are a nutrition AI. Suggest 3 healthy $mealPeriod meals with maximum diversity and variety. Each meal should be completely different from the others in terms of:
- Cuisine type (e.g., Mediterranean, Asian, Mexican, Italian, American, etc.)
- Main ingredients (avoid repeating the same primary proteins or grains)
- Cooking methods (baked, grilled, sautéed, raw, etc.)
- Flavor profiles (sweet, savory, spicy, tangy, etc.)

For each meal, provide:
- meal_name: string (max 30 characters)
- time: string (e.g. "10 mins")
- benefits: array of 2 short strings (e.g. ["High Protein", "Low Sugar"])
- calories: integer
- protein: integer
- fat: integer
- carbs: integer
- ingredients: array of strings
- recipe: array of steps (strings)

Ensure each meal is unique and offers different nutritional benefits. Respond ONLY with a JSON array of 3 objects, no extra text, no explanations, no markdown.$languageInstruction
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
        final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', multiLine: true, caseSensitive: false);
        final match = codeBlockRegex.firstMatch(content);
        final jsonString = match != null ? match.group(1)!.trim() : content.trim();
        final meals = jsonDecode(jsonString);
        if (meals is List) {
          // Save to cache
          await prefs.setString(cacheKey, jsonEncode(meals));
          await prefs.setString(cacheTimeKey, now.toIso8601String());
          return meals.cast<Map<String, dynamic>>();
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
  Future<void> clearSuggestedMealsCache(String mealPeriod, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_suggestedMealsCacheKey${mealPeriod}_$language';
    final cacheTimeKey = '$_suggestedMealsCacheTimeKey${mealPeriod}_$language';
    await prefs.remove(cacheKey);
    await prefs.remove(cacheTimeKey);
  }
} 