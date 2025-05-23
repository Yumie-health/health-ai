import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // TODO: Move this to secure storage or env variable in production
  static const String _openAIApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String?> sendMessage(String message, {String model = 'gpt-3.5-turbo'}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_openAIApiKey',
    };
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'You are Yumie, a friendly nutrition and wellness coach.'},
        {'role': 'user', 'content': message},
      ],
      'max_tokens': 256,
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
} 