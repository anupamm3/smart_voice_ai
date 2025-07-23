import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smart_voice_ai/feature_box.dart';
import 'package:smart_voice_ai/gemini_service.dart';
import 'package:smart_voice_ai/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final GeminiService geminiService = GeminiService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isSpeaking = false; // Add this to track TTS state

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    try {
      await flutterTts.setSharedInstance(true);
      
      // Reset speaking state
      setState(() {
        isSpeaking = false;
      });
      
      // Clear any existing handlers before setting new ones
      await flutterTts.stop();
      
      // Add TTS state listeners
      flutterTts.setStartHandler(() {
        debugPrint('TTS: Started speaking');
        if (mounted) {
          setState(() {
            isSpeaking = true;
          });
        }
      });

      flutterTts.setCompletionHandler(() {
        debugPrint('TTS: Finished speaking');
        if (mounted) {
          setState(() {
            isSpeaking = false;
          });
        }
      });

      flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        if (mounted) {
          setState(() {
            isSpeaking = false;
          });
        }
      });

      // Set TTS configuration
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      
      debugPrint('TTS initialized successfully');
      setState(() {});
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      setState(() {
        isSpeaking = false;
      });
    }
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    debugPrint('Speech recognition available: ${speechToText.isAvailable}');
    setState(() {});
  }

  Future<void> startListening() async {
    // Stop TTS if it's speaking
    if (isSpeaking) {
      await stopSpeaking();
    }
    
    debugPrint('Starting to listen...');
    
    // Clear previous results
    setState(() {
      lastWords = '';
    });
    
    // Start listening WITHOUT auto-timeout
    await speechToText.listen(
      onResult: onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
      ),
      // Remove listenFor and pauseFor to prevent auto-stopping
    );
    
    setState(() {});
    
    debugPrint('Is listening after start: ${speechToText.isListening}');
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> stopSpeaking() async {
    debugPrint('Stopping TTS...');
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  Future<void> _processRecognizedSpeech() async {
    if (lastWords.isEmpty) {
      setState(() {
        generatedContent = 'I didn\'t hear anything. Please try again.';
        generatedImageUrl = null;
      });
      return;
    }
    
    // Ensure we're not in listening state anymore
    setState(() {
      // Force update the listening state
    });
    
    // Show loading state
    setState(() {
      generatedContent = 'Processing your request...';
      generatedImageUrl = null;
    });
    
    try {
      final speech = await geminiService.isArtPromptAPI(lastWords);
      
      if (speech.contains('https')) {
        setState(() {
          generatedImageUrl = speech;
          generatedContent = null;
        });
      } else {
        setState(() {
          generatedImageUrl = null;
          generatedContent = speech;
        });
        
        // Only speak if we have valid content
        if (speech.isNotEmpty && !speech.startsWith('Error:')) {
          await systemSpeak(speech);
        }
      }
    } catch (e) {
      debugPrint('🎯 Error processing request: $e');
      setState(() {
        generatedContent = 'Sorry, there was an error: $e';
        generatedImageUrl = null;
      });
    }
    
    // Clear lastWords for next use
    setState(() {
      lastWords = '';
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    debugPrint('Recognized Words: ${result.recognizedWords}');
    // debugPrint('Final result: ${result.finalResult}');
    debugPrint('Is listening: ${speechToText.isListening}');
    
    setState(() {
      lastWords = result.recognizedWords;
    });
    
    // Show what's being recognized in real-time
    if (!result.finalResult && result.recognizedWords.isNotEmpty) {
      setState(() {
        generatedContent = 'I heard: "${result.recognizedWords}"...';
      });
    }
    
    // If this is a final result (speech auto-stopped), process automatically
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      
      // Add a small delay to ensure UI updates properly
      Future.delayed(Duration(milliseconds: 100), () {
        _processRecognizedSpeech();
      });
    }
  }

  Future<void> systemSpeak(String content) async {
    if (content.isNotEmpty) {
      await flutterTts.speak(content);
    }
  }

  Future<void> _refreshToMainScreen() async {
    debugPrint('🔄 Refreshing to main screen...');
    
    // Stop all ongoing operations
    await speechToText.stop();
    await flutterTts.stop();
    
    // Reset all state variables with animation
    setState(() {
      lastWords = '';
      generatedContent = null;
      generatedImageUrl = null;
      isSpeaking = false;
    });
    
    // Add a small delay for visual feedback
    await Future.delayed(Duration(milliseconds: 500));
    
    // Reinitialize services
    await initSpeechToText();
    await initTextToSpeech();
    
    debugPrint('🔄 Refresh complete - back to main screen');
    
    // Show success message with proper colors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '✨ Ready for a new conversation!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green.shade600, // Dark green background
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        elevation: 6,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          backgroundColor: Colors.green.shade800,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('Sage'),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
        actions: [
          if (generatedContent != null || generatedImageUrl != null)
            Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _refreshToMainScreen,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.blue.shade700,
                ),
                tooltip: 'Reset to main screen',
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshToMainScreen,
        color: Pallete.featureBox1Color,
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        displacement: 50.0,
        child: SingleChildScrollView(
          // Add physics to enable pull-to-refresh even when content doesn't fill screen
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // virtual assistant picture
              ZoomIn(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: speechToText.isListening 
                              ? Colors.green.withOpacity(0.3)  // Green when listening
                              : isSpeaking 
                                  ? Colors.blue.withOpacity(0.3)  // Blue when speaking
                                  : Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/virtualAssistant.png',
                          ),
                        ),
                      ),
                    ),
                    if (speechToText.isListening)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Refresh instruction text (shows only when there's content)
              if (generatedContent != null || generatedImageUrl != null)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pull down to refresh and start over',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // chat bubble
              FadeInRight(
                child: Visibility(
                  visible: generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                      top: 30,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: Radius.zero,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        generatedContent == null
                            ? 'Good Morning, what task can I do for you?'
                            : generatedContent!,
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: generatedContent == null 
                              ? Pallete.mainFontColor 
                              : Colors.grey.shade800,
                          fontSize: generatedContent == null ? 25 : 18,
                          fontWeight: generatedContent == null 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (generatedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!),
                  ),
                ),
              SlideInLeft(
                child: Visibility(
                  visible: generatedContent == null && generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 10, left: 22),
                    child: const Text(
                      'Here are a few features',
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // features list
              Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Column(
                  children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: const FeatureBox(
                        color: Pallete.featureBox1Color,
                        headerText: 'Gemini AI',
                        descriptionText:
                            'A smarter way to stay organized and informed with Gemini AI',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),
                      child: const FeatureBox(
                        color: Pallete.featureBox2Color,
                        headerText: 'Text Generation',
                        descriptionText:
                            'Get inspired and stay creative with your personal assistant powered by Gemini',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + 2 * delay),
                      child: const FeatureBox(
                        color: Pallete.featureBox3Color,
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Get the best of both worlds with a voice assistant powered by Gemini AI',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Add some bottom padding to ensure pull-to-refresh works
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main FAB
            FloatingActionButton.extended(
              backgroundColor: isSpeaking 
                  ? Colors.red.shade600
                  : speechToText.isListening 
                      ? Colors.red.shade600  // Red when listening
                      : Pallete.featureBox1Color,
              onPressed: () async {
                debugPrint('🚀 FAB pressed');
                debugPrint('🚀 Permission: ${await speechToText.hasPermission}');
                debugPrint('🚀 Listening: ${speechToText.isListening}');
                debugPrint('🚀 Speaking: $isSpeaking');
                
                // If TTS is speaking, stop it
                if (isSpeaking) {
                  debugPrint('🚀 Stopping TTS...');
                  await stopSpeaking();
                  return;
                }
                
                if (await speechToText.hasPermission && speechToText.isNotListening) {
                  // Start listening
                  debugPrint('🚀 Starting to listen...');
                  await startListening();
                } else if (speechToText.isListening) {
                  // Stop listening and process the speech manually
                  debugPrint('🚀 Manual stop - processing speech...');
                  await stopListening();
                  
                  // Small delay to ensure speech recognition has stopped
                  await Future.delayed(Duration(milliseconds: 200));
                  
                  await _processRecognizedSpeech();
                } else {
                  // Request permission or reinitialize
                  debugPrint('🚀 Reinitializing speech to text...');
                  await initSpeechToText();
                }
              },
              icon: Icon(
                isSpeaking 
                    ? Icons.volume_off
                    : speechToText.isListening 
                        ? Icons.stop
                        : Icons.mic,
                color: Colors.black,
              ),
              label: Text(
                isSpeaking 
                    ? 'Stop Speaking'
                    : speechToText.isListening 
                        ? 'Stop & Process'
                        : 'Speak',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Status indicator text
            if (speechToText.isListening || isSpeaking)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: speechToText.isListening 
                      ? Colors.green.shade700
                      : Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  speechToText.isListening 
                      ? '🎤 Listening...'
                      : '🔊 Speaking...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}