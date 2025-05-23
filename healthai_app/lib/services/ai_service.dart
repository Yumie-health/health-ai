import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // TODO: Move this to secure storage or env variable in production
  static const String _openAIApiKey = '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';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String?> sendMessage(String message, {String model = 'gpt-4o'}) async {
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
    String model = 'gpt-4o',
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
} 