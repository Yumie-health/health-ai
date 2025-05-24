import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class AIService {
  // TODO: Move this to secure storage or env variable in production
  static const String _openAIApiKey = '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';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String?> sendMessage(String message, {String model = 'gpt-4o-mini'}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'You are Yumie, a friendly nutrition and wellness coach. Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.'},
        {'role': 'user', 'content': message},
      ],
      'max_tokens': 1024,
      'temperature': 0.7,
    });
    final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content;
    } else {
      print('AI API error: ${response.statusCode} ${response.body}');
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
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
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
    );
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...chatHistory,
    ];
    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'max_tokens': 1024,
      'temperature': 0.7,
    });
    final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String?;
    } else {
      print('OpenAI error: ${response.body}');
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
  }) {
    // Convert height to ft/in
    final totalInches = (heightCm / 2.54).round();
    final heightFt = totalInches ~/ 12;
    final heightIn = totalInches % 12;
    // Convert weight to lb
    final weightLb = (weightKg * 2.20462).round();

    return '''
You are Yumie, a friendly, expert-level virtual nutrition coach. Your job is to provide clear, accurate, and supportive responses tailored to the user's unique profile. Use the following user data to guide every answer:

Respond in clear, friendly, plain English. Avoid Markdown formatting (like **bold** or lists) unless the user specifically asks for it.

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
    print('[AI RAW RESPONSE] $response');
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
  Future<Map<String, dynamic>?> analyzeMealImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';
    final prompt = '''
You are a nutrition AI. Given this photo of a meal, return a JSON object with:
- food_name: string
- calories: integer
- protein: integer
- carbs: integer
- fat: integer
- ingredients: array of strings
Respond ONLY with valid JSON.
''';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
    final body = jsonEncode({
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
    });
    final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final jsonString = _extractJson(content);
      final result = jsonDecode(jsonString);
      return result as Map<String, dynamic>;
    } else {
      print('AI meal scan error: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  /// Analyze a fridge image and return a list of detected items.
  Future<List<String>?> analyzeFridgeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';
    final prompt = '''
You are a kitchen assistant AI. Given this photo of a fridge, return a JSON array of all visible food items (ingredients). Respond ONLY with a JSON array of strings.
''';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
    final body = jsonEncode({
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
    });
    final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        final jsonString = _extractJson(content);
        final items = jsonDecode(jsonString);
        return (items as List).map((e) => e.toString()).toList();
      } catch (e) {
        print('Failed to parse fridge scan JSON: $e\n$content');
        return null;
      }
    } else {
      print('AI fridge scan error: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  /// Generate a meal suggestion from fridge items and user profile.
  Future<Map<String, dynamic>?> generateMealFromFridge({
    required List<String> fridgeItems,
    required Map<String, dynamic> userProfile,
  }) async {
    final prompt = '''
You are a nutrition AI. Given this user profile: ${jsonEncode(userProfile)} and these fridge items: ${jsonEncode(fridgeItems)}, suggest a healthy meal the user can make, including:
- meal_name: string
- ingredients: array of strings (all ingredients needed for the meal)
- recipe: array of steps (strings)
- calories: integer
- protein: integer
- carbs: integer
- fat: integer
Respond ONLY with valid JSON.
''';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': prompt},
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': 512,
      'temperature': 0.5,
    });
    final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        return jsonDecode(content);
      } catch (e) {
        print('Failed to parse generated meal JSON: $e\n$content');
        return null;
      }
    } else {
      print('AI generate meal error: ${response.statusCode} ${response.body}');
      return null;
    }
  }
} 