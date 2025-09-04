import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/gemini_service.dart';
import '../services/command_service.dart';
import '../services/database_service.dart';
import '../models/chat_history.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  // Speech and TTS instances
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // Services
  final GeminiService _geminiService = GeminiService();
  final CommandService _commandService = CommandService();
  final DatabaseService _databaseService = DatabaseService();

  // State variables
  String _lastWords = '';
  String? _generatedContent;
  String? _generatedImageUrl;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Speech settings
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  
  // Conversation context for multi-turn conversations
  List<Map<String, String>> _conversationContext = [];
  
  // Current session
  String? _currentSessionId;

  // Getters
  String get lastWords => _lastWords;
  String? get generatedContent => _generatedContent;
  String? get generatedImageUrl => _generatedImageUrl;
  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isLoading => _isLoading;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  String? get currentSessionId => _currentSessionId;
  bool get isInitialized => _isInitialized;
  List<Map<String, String>> get conversationContext => _conversationContext;
  SpeechToText get speechToText => _speechToText;
  FlutterTts get flutterTts => _flutterTts;

  // Initialize services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _initializeSpeechToText();
      await _initializeTextToSpeech();
      await _databaseService.initialize();
      _startNewSession();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing voice assistant: $e');
    }
  }

  Future<void> _initializeSpeechToText() async {
    await _speechToText.initialize();
    debugPrint('Speech recognition available: ${_speechToText.isAvailable}');
  }

  Future<void> _initializeTextToSpeech() async {
    await _flutterTts.setSharedInstance(true);
    
    _flutterTts.setStartHandler(() {
      debugPrint('TTS: Started speaking');
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint('TTS: Finished speaking');
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });

    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(_speechPitch);
  }

  // Speech settings methods
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch;
    await _flutterTts.setPitch(pitch);
    notifyListeners();
  }

  void _startNewSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _conversationContext.clear();
  }

  // Speech recognition methods
  Future<void> startListening() async {
    if (_isSpeaking) {
      await stopSpeaking();
    }
    
    debugPrint('Starting to listen...');
    _lastWords = '';
    
    await _speechToText.listen(
      onResult: _onSpeechResult,
      partialResults: true,
    );
    
    _isListening = true;
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(result) {
    debugPrint('Recognized Words: ${result.recognizedWords}');
    _lastWords = result.recognizedWords;
    
    // Show real-time recognition
    if (!result.finalResult && result.recognizedWords.isNotEmpty) {
      _generatedContent = 'I heard: "${result.recognizedWords}"...';
      notifyListeners();
    }
    
    // Auto-process when speech is final
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      debugPrint('Auto-processing final result: ${result.recognizedWords}');
      Future.delayed(const Duration(milliseconds: 100), () {
        processRecognizedSpeech();
      });
    }
  }

  // Process recognized speech
  Future<void> processRecognizedSpeech() async {
    if (_lastWords.isEmpty) {
      _generatedContent = 'I didn\'t hear anything. Please try again.';
      _generatedImageUrl = null;
      notifyListeners();
      return;
    }

    debugPrint('Processing speech: "$_lastWords"');
    
    _isLoading = true;
    _generatedContent = 'Processing your request...';
    _generatedImageUrl = null;
    notifyListeners();
    
    try {
      // Check if it's a command first
      final commandResult = await _commandService.processCommand(_lastWords);
      if (commandResult != null) {
        _generatedContent = commandResult;
        await _saveToHistory(_lastWords, commandResult, 'command');
      } else {
        // Process with Gemini API including conversation context
        final response = await _geminiService.processWithContext(_lastWords, _conversationContext);
        
        if (response.contains('https')) {
          _generatedImageUrl = response;
          _generatedContent = null;
        } else {
          _generatedImageUrl = null;
          _generatedContent = response;
          
          // Add to conversation context
          _conversationContext.add({'role': 'user', 'content': _lastWords});
          _conversationContext.add({'role': 'assistant', 'content': response});
          
          // Keep only last 6 messages (3 exchanges) for context
          if (_conversationContext.length > 6) {
            _conversationContext = _conversationContext.sublist(_conversationContext.length - 6);
          }
          
          // Speak the response if it's valid
          if (response.isNotEmpty && !response.startsWith('Error:')) {
            await systemSpeak(response);
          }
        }
        
        await _saveToHistory(_lastWords, response, 'text');
      }
    } catch (e) {
      debugPrint('Error processing request: $e');
      _generatedContent = 'Sorry, there was an error: $e';
      _generatedImageUrl = null;
    }
    
    _isLoading = false;
    _lastWords = '';
    notifyListeners();
  }

  // TTS methods
  Future<void> systemSpeak(String content) async {
    if (content.isNotEmpty) {
      // Clean markdown for TTS
      String cleanContent = _cleanMarkdownForTTS(content);
      await _flutterTts.speak(cleanContent);
    }
  }

  Future<void> stopSpeaking() async {
    debugPrint('Stopping TTS...');
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  String _cleanMarkdownForTTS(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Remove **bold**
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')     // Remove *italic*
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')       // Remove `code`
        .replaceAll(RegExp(r'#{1,6}\s'), '')         // Remove # headers
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // Remove [links](url)
        .replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '') // Remove bullet points
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), '') // Remove numbered lists
        .replaceAll(RegExp(r'\n\s*\n'), '\n')       // Clean extra newlines
        .trim();
  }

  // Save conversation to history
  Future<void> _saveToHistory(String userMessage, String assistantResponse, String messageType) async {
    final chatHistory = ChatHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userMessage: userMessage,
      assistantResponse: assistantResponse,
      timestamp: DateTime.now(),
      messageType: messageType,
    );
    
    await _databaseService.saveChatHistory(chatHistory);
  }

  // Reset conversation
  Future<void> resetConversation() async {
    await _speechToText.stop();
    await _flutterTts.stop();
    
    _lastWords = '';
    _generatedContent = null;
    _generatedImageUrl = null;
    _isSpeaking = false;
    _isListening = false;
    _isLoading = false;
    _conversationContext.clear();
    _startNewSession();
    
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
