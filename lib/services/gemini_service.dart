import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

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

  // New method for processing with conversation context
  Future<String> processWithContext(String prompt, List<Map<String, String>> context) async {
    try {
      // Check if it's an art/image request
      final artCheckPrompt = 'Does this message want to generate an AI picture, image, art or anything similar? "$prompt" Simply answer with a yes or no.';
      
      final artResponse = await _callGeminiAPI(artCheckPrompt);
      
      if (artResponse.toLowerCase().contains('yes')) {
        return 'I understand you want to create an image: "$prompt". However, Gemini API doesn\'t support image generation. I can help you with text responses instead!';
      } else {
        return await _chatWithContext(prompt, context);
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _chatWithContext(String prompt, List<Map<String, String>> context) async {
    try {
      // Build the conversation context
      String contextualPrompt = '';
      
      if (context.isNotEmpty) {
        contextualPrompt = 'Previous conversation:\n';
        for (var message in context) {
          contextualPrompt += '${message['role']}: ${message['content']}\n';
        }
        contextualPrompt += '\nCurrent question: $prompt\n\nPlease respond considering the conversation context above.';
      } else {
        contextualPrompt = prompt;
      }

      final response = await _callGeminiAPI(contextualPrompt);
      return response;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Method for text summarization
  Future<String> summarizeText(String text) async {
    try {
      final prompt = 'Please provide a clear and concise summary of the following text:\n\n$text';
      final response = await _callGeminiAPI(prompt);
      return response;
    } catch (e) {
      return 'Error summarizing text: ${e.toString()}';
    }
  }

  Future<String> _callGeminiAPI(String prompt) async {
    final currentDate = DateTime.now();
    final formattedDate = "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    
    // Add current date context to the prompt
    final contextualPrompt = '''
Today's date: $formattedDate

User question: $prompt

Please provide accurate information. If the question is about very recent events (especially ${currentDate.year} onwards) that may not be in your training data, please mention that your knowledge may be outdated and suggest checking current sources.
''';

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$geminiAPIKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': contextualPrompt}]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        }
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
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
