import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_voice_ai/secrets.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  final List<Map<String, dynamic>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      // Ask Gemini if this is an art/image request
      final artCheckPrompt = 'Does this message want to generate an AI picture, image, art or anything similar? "$prompt" Simply answer with a yes or no.';
      
      final response = await _callGeminiAPI(artCheckPrompt);
      
      if (response.toLowerCase().contains('yes')) {
        return 'I understand you want to create an image: "$prompt". However, Gemini API doesn\'t support image generation. I can help you with text responses instead!';
      } else {
        return await chatGeminiAPI(prompt);
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> chatGeminiAPI(String prompt) async {
    try {
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final response = await _callGeminiAPI(prompt);
      
      messages.add({
        'role': 'assistant',
        'content': response,
      });
      
      return response;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _callGeminiAPI(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$geminiAPIKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': prompt}]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('No response generated');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'API request failed');
    }
  }

  // Placeholder for image generation (Gemini doesn't support this)
  Future<String> dallEAPI(String prompt) async {
    return 'Image generation is not available with Gemini API. Here\'s a text description instead: $prompt';
  }
}