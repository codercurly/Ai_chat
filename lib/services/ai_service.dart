import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatAiService {
  final String apiKey = '';

  Future<String> connectAi(String userMessage) async {
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": [
          {"role": "user", "content": userMessage}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('AI yanıtı başarısız oldu: ${response.statusCode}');
    }
  }
}
