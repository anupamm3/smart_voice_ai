import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/gemini_service.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  // Speech and TTS instances
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // Services
  final GeminiService _geminiService = GeminiService();

  // State variables
  String _lastWords = '';
  String? _generatedContent;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Speech settings
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  
  // Conversation context for multi-turn conversations
  List<Map<String, String>> _conversationContext = [];

  // Getters
  String get lastWords => _lastWords;
  String? get generatedContent => _generatedContent;
  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isLoading => _isLoading;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  bool get isInitialized => _isInitialized;
  List<Map<String, String>> get conversationContext => _conversationContext;

  // Initialize speech and TTS
  Future<void> initializeSpeech() async {
    if (_isInitialized) return;

    try {
      await _speechToText.initialize();
      await _setupTts();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing speech: $e');
    }
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage('en-US');
    
    _flutterTts.setStartHandler(() {
      debugPrint('TTS: Starting to speak');
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

  // Speech recognition methods
  Future<void> startListening() async {
    if (!_isInitialized) {
      await initializeSpeech();
    }
    
    if (_isSpeaking) {
      await stopSpeaking();
    }
    
    debugPrint('Starting to listen...');
    _lastWords = '';
    
    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      
      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting to listen: $e');
    }
  }

  Future<void> stopListening() async {
    debugPrint('Stopping listening...');
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
    
    if (result.finalResult) {
      debugPrint('Final result: $_lastWords');
      _processVoiceCommand(_lastWords);
    }
  }

  // Process voice commands
  Future<void> _processVoiceCommand(String command) async {
    if (command.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Add to conversation context
      _conversationContext.add({
        'role': 'user',
        'content': command,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Process with Gemini AI
      final response = await _geminiService.processWithContext(
        command, 
        _conversationContext,
      );

      _generatedContent = response;
      
      // Add AI response to context
      _conversationContext.add({
        'role': 'assistant',
        'content': response,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Limit conversation context to last 10 exchanges
      if (_conversationContext.length > 20) {
        _conversationContext = _conversationContext.sublist(_conversationContext.length - 20);
      }

      // Speak the response
      await speak(response);

    } catch (e) {
      debugPrint('Error processing voice command: $e');
      _generatedContent = 'Sorry, I encountered an error processing your request.';
      await speak(_generatedContent!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Text-to-speech methods
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initializeSpeech();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  // Utility methods
  void clearConversation() {
    _conversationContext.clear();
    _generatedContent = null;
    _lastWords = '';
    notifyListeners();
  }

  // Simple command processing for demo
  Future<void> processTextCommand(String command) async {
    await _processVoiceCommand(command);
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
