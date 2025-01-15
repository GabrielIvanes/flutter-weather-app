import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiKey;

  ChatbotService({required this.apiKey});

  Future<String> generateResponse(String query) async {
    const String url =
        'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': query,
          'parameters': {
            'max_new_tokens': 250,
            'temperature': 0.7,
            'top_p': 0.95,
            'do_sample': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          final String generatedText = jsonResponse[0]['generated_text'] ?? '';
          final int promptEnd = generatedText.indexOf(query) + query.length;
          return generatedText.substring(promptEnd).trim();
        }
      }

      if (response.statusCode == 503) {
        return 'Model is loading, please try again in a few seconds...';
      }

      print('Error: ${response.statusCode} - ${response.body}');
      return 'Failed to generate response. Please try again.';
    } catch (e) {
      print('Error generating response: $e');
      return 'An error occurred. Please try again.';
    }
  }
}
