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
      
      final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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

      final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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
    required String sex,
    required int heightFt,
    required int heightIn,
    required int weightLb,
    required String goal,
    required String activityLevel,
    required String bloodType,
    required bool isDiabetic,
    String? waterIntake,
    String? motivation,
    double? targetWeightKg,
    List<String>? eatingHabits,
  }) async {
    final prompt = '''
You are Yumie, a smart nutrition AI trained to create personalized daily intake plans based on individual health data.

Use the following user inputs from the onboarding flow:

Age: $age
Sex: $sex
Height: $heightFt ft $heightIn in
Weight: $weightLb lb
Goal: $goal
Activity Level: $activityLevel
Blood Type: $bloodType
Diabetic: ${isDiabetic ? 'Yes' : 'No'}
${waterIntake != null ? "Water Intake: $waterIntake" : ""}
${motivation != null ? "Motivation: $motivation" : ""}
${targetWeightKg != null ? "Target Weight: ${(targetWeightKg * 2.20462).round()} lb" : ""}
${eatingHabits != null && eatingHabits.isNotEmpty ? "Eating Habits:\n${eatingHabits.map((h) => "- $h").join('\n')}" : ""}

Based on this information:
- Calculate Total Daily Energy Expenditure (TDEE) using Mifflin-St Jeor formula.
- Adjust caloric target according to their goal:
  - Weight Loss: TDEE - 500 kcal
  - Muscle Gain: TDEE + 300 kcal
  - Maintenance: TDEE
- Distribute macros based on standard ratios (or adjust smartly):
  - Protein: 1g per pound of body weight (or 1.2g if muscle gain)
  - Fat: 0.3–0.4g per pound
  - Carbs = Remaining calories / 4
- Consider their eating habits and motivation when suggesting meal timing and composition
- Account for their target weight in the calorie deficit/surplus calculation
- Adjust recommendations based on their blood type and diabetic status

Output ONLY like this (no extra text, no units, no emojis, no explanations):
Calories: <number>
Protein: <number>
Fat: <number>
Carbs: <number>

Example:
Calories: 2200
Protein: 120
Fat: 70
Carbs: 250
''';
    final response = await sendMessage(prompt);
    if (response == null) return null;

    // Parse the response for numbers (simple regex, can be improved)
    final caloriesMatch = RegExp(r'Calories:\s*([\d,]+)').firstMatch(response);
    final proteinMatch = RegExp(r'Protein:\s*(\d+)').firstMatch(response);
    final fatMatch = RegExp(r'Fat:\s*(\d+)').firstMatch(response);
    final carbsMatch = RegExp(r'Carbs:\s*(\d+)').firstMatch(response);
    if (caloriesMatch == null || proteinMatch == null || fatMatch == null || carbsMatch == null) {
      return null;
    }
    return {
      'calories': int.parse(caloriesMatch.group(1)!.replaceAll(',', '')),
      'protein': int.parse(proteinMatch.group(1)!),
      'fat': int.parse(fatMatch.group(1)!),
      'carbs': int.parse(carbsMatch.group(1)!),
    };
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
    final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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
    final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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
    final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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
    final cacheKey = '$_suggestedMealsCacheKey");${mealPeriod}_$language';
    final cacheTimeKey = '$_suggestedMealsCacheTimeKey");${mealPeriod}_$language';
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
    final url = 'https://us-central1-healthai-0001.cloudfunctions.net/openaiProxyCallable';
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
    final cacheKey = '$_suggestedMealsCacheKey");${mealPeriod}_$language';
    final cacheTimeKey = '$_suggestedMealsCacheTimeKey");${mealPeriod}_$language';
    await prefs.remove(cacheKey);
    await prefs.remove(cacheTimeKey);
  }
} 