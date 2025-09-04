import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/voice_assistant_provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/notes_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/history_screen.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({super.key});

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: _buildDrawer(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        'Smart Voice AI',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return IconButton(
              icon: Icon(
                appState.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                appState.setThemeMode(
                  appState.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildVoiceInterface(provider),
              const SizedBox(height: 32),
              _buildResponseArea(provider),
              const SizedBox(height: 32),
              _buildFeatureGrid(),
              const SizedBox(height: 32),
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceInterface(VoiceAssistantProvider provider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Voice Animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse animation
                if (provider.isListening)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120 + (_pulseController.value * 20),
                        height: 120 + (_pulseController.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3 - _pulseController.value * 0.2),
                        ),
                      );
                    },
                  ),
                // Main microphone button
                GestureDetector(
                  onTap: () => _handleVoiceAction(provider),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: provider.isListening
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (provider.isListening ? Colors.red : Theme.of(context).colorScheme.primary)
                              .withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      provider.isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status text
            Text(
              provider.isListening
                  ? 'Listening...'
                  : provider.isSpeaking
                      ? 'Speaking...'
                      : 'Tap to speak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            if (provider.lastWords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.lastWords,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseArea(VoiceAssistantProvider provider) {
    if (provider.generatedContent == null) {
      return _buildWelcomeCard();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assistant,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Response',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.generatedContent!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Dynamic speak/stop button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (provider.isSpeaking) {
                        provider.stopSpeaking();
                      } else {
                        provider.systemSpeak(provider.generatedContent!);
                      }
                    },
                    icon: Icon(
                      provider.isSpeaking ? Icons.stop : Icons.volume_up,
                    ),
                    label: Text(
                      provider.isSpeaking ? 'Stop Speaking' : 'Speak',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isSpeaking 
                          ? Colors.red.shade600 
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: provider.generatedContent!));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Response copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    tooltip: 'Copy response',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature - Coming Soon!')),
                      );
                    },
                    tooltip: 'Share response',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.waving_hand,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to Smart Voice AI!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the microphone to start a conversation or use any of the features below.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      FeatureItem(
        icon: Icons.note_add,
        title: 'Voice Notes',
        description: 'Create notes with your voice',
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        ),
      ),
      FeatureItem(
        icon: Icons.alarm,
        title: 'Reminders',
        description: 'Set voice reminders & alarms',
        color: Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        ),
      ),
      FeatureItem(
        icon: Icons.history,
        title: 'History',
        description: 'View command history',
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        ),
      ),
      FeatureItem(
        icon: Icons.wb_sunny,
        title: 'Weather',
        description: 'Get weather updates',
        color: Colors.amber,
        onTap: () => _askForWeather(),
      ),
      FeatureItem(
        icon: Icons.emoji_emotions,
        title: 'Jokes & Fun',
        description: 'Tell jokes and riddles',
        color: Colors.pink,
        onTap: () => _tellJoke(),
      ),
      FeatureItem(
        icon: Icons.format_quote,
        title: 'Daily Quotes',
        description: 'Inspirational quotes',
        color: Colors.purple,
        onTap: () => _getQuote(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              child: _buildFeatureCard(feature),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                feature.color.withOpacity(0.1),
                feature.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature.icon,
                  size: 32,
                  color: feature.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickActionChip('Tell me a joke', Icons.sentiment_very_satisfied),
            _buildQuickActionChip('What\'s the weather?', Icons.wb_sunny),
            _buildQuickActionChip('Set a reminder', Icons.alarm),
            _buildQuickActionChip('Inspire me', Icons.format_quote),
            _buildQuickActionChip('Open calculator', Icons.calculate),
            _buildQuickActionChip('Fun fact', Icons.lightbulb),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(String text, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      onPressed: () => _executeQuickAction(text),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () => _handleVoiceAction(provider),
          icon: Icon(provider.isListening ? Icons.stop : Icons.mic),
          label: Text(provider.isListening ? 'Stop' : 'Speak'),
          backgroundColor: provider.isListening 
              ? Colors.red 
              : Theme.of(context).colorScheme.primary,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
              tooltip: 'Home',
            ),
            IconButton(
              icon: const Icon(Icons.note),
              onPressed: () => Navigator.pushNamed(context, '/notes'),
              tooltip: 'Notes',
            ),
            const SizedBox(width: 40), // Space for FAB
            IconButton(
              icon: const Icon(Icons.alarm),
              onPressed: () => Navigator.pushNamed(context, '/reminders'),
              tooltip: 'Reminders',
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, '/history'),
              tooltip: 'History',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Smart Voice AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your AI Assistant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Voice Notes'),
            onTap: () => Navigator.pushNamed(context, '/notes'),
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Reminders & Alarms'),
            onTap: () => Navigator.pushNamed(context, '/reminders'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Command History'),
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _handleVoiceAction(VoiceAssistantProvider provider) {
    if (provider.isListening) {
      provider.stopListening();
    } else {
      provider.startListening();
    }
  }

  Future<void> _executeQuickAction(String command) async {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    
    try {
      // Handle specific quick actions with URL launcher
      if (command.toLowerCase().contains('reminder')) {
        await _openClockApp();
      } else if (command.toLowerCase().contains('calculator')) {
        await _openCalculator();
      } else if (command.toLowerCase().contains('weather')) {
        _askForWeather();
      } else if (command.toLowerCase().contains('joke')) {
        _tellJoke();
      } else if (command.toLowerCase().contains('inspire')) {
        _getQuote();
      } else if (command.toLowerCase().contains('fact')) {
        _getFunFact();
      } else {
        // For other commands, just speak them
        provider.systemSpeak("Executing: $command");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error executing command: $e')),
      );
    }
  }

  Future<void> _openClockApp() async {
    try {
      // First, try to launch alarm/reminder setting directly with action intent
      const String setAlarmAction = 'android.intent.action.SET_ALARM';
      final Uri setAlarmIntent = Uri.parse('intent://#Intent;action=$setAlarmAction;end');
      
      try {
        await launchUrl(setAlarmIntent, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        // Continue to other methods if this fails
      }

      // Try Android Clock app intent
      final clockUri = Uri.parse('android-app://com.google.android.deskclock');
      if (await canLaunchUrl(clockUri)) {
        await launchUrl(clockUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try system clock app
      final systemClockUri = Uri.parse('android-app://com.android.deskclock');
      if (await canLaunchUrl(systemClockUri)) {
        await launchUrl(systemClockUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try generic time/alarm intent
      final timeIntent = Uri.parse('content://com.android.deskclock/alarms');
      if (await canLaunchUrl(timeIntent)) {
        await launchUrl(timeIntent, mode: LaunchMode.externalApplication);
        return;
      }

      // Show dialog to help user
      _showAppNotFoundDialog('Clock/Alarm', null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find a clock app. Please install one or open manually.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openCalculator() async {
    try {
      // First, try to open calculator with action intent (lets user choose)
      const String calcAction = 'android.intent.action.MAIN';
      const String calcCategory = 'android.intent.category.LAUNCHER';
      final Uri calcIntent = Uri.parse('intent://#Intent;action=$calcAction;category=$calcCategory;component=com.android.calculator2/.Calculator;end');
      
      try {
        await launchUrl(calcIntent, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        // Continue to other methods if this fails
      }

      // Try Google Calculator
      final googleCalcUri = Uri.parse('android-app://com.google.android.calculator');
      if (await canLaunchUrl(googleCalcUri)) {
        await launchUrl(googleCalcUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try Samsung Calculator
      final samsungCalcUri = Uri.parse('android-app://com.sec.android.app.popupcalculator');
      if (await canLaunchUrl(samsungCalcUri)) {
        await launchUrl(samsungCalcUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try system calculator
      final systemCalcUri = Uri.parse('android-app://com.android.calculator2');
      if (await canLaunchUrl(systemCalcUri)) {
        await launchUrl(systemCalcUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try generic calculator intent
      final calcUri = Uri.parse('calculator://');
      if (await canLaunchUrl(calcUri)) {
        await launchUrl(calcUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Final fallback - show dialog to let user choose
      _showAppNotFoundDialog('Calculator', 'https://www.google.com/search?q=calculator');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find calculator app. Please install one or use the web.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _askForWeather() {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    provider.systemSpeak('Getting weather information for you...');
    // TODO: Implement actual weather fetching
    Future.delayed(const Duration(seconds: 1), () {
      provider.systemSpeak('Weather feature is coming soon! Please check your weather app for current conditions.');
    });
  }

  void _tellJoke() {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    final jokes = [
      "Why don't scientists trust atoms? Because they make up everything!",
      "Why did the math book look so sad? Because it was full of problems!",
      "What do you call a fake noodle? An impasta!",
      "Why don't eggs tell jokes? They'd crack each other up!",
      "What do you call a bear with no teeth? A gummy bear!",
    ];
    final randomJoke = jokes[(DateTime.now().millisecondsSinceEpoch) % jokes.length];
    provider.systemSpeak(randomJoke);
  }

  void _getQuote() {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    final quotes = [
      "The only way to do great work is to love what you do. - Steve Jobs",
      "Innovation distinguishes between a leader and a follower. - Steve Jobs", 
      "Life is what happens to you while you're busy making other plans. - John Lennon",
      "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
      "It is during our darkest moments that we must focus to see the light. - Aristotle",
    ];
    final randomQuote = quotes[(DateTime.now().millisecondsSinceEpoch) % quotes.length];
    provider.systemSpeak(randomQuote);
  }

  void _getFunFact() {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    final facts = [
      "Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible.",
      "A group of flamingos is called a 'flamboyance'.",
      "Bananas are berries, but strawberries aren't.",
      "Octopuses have three hearts and blue blood.",
      "The shortest war in history lasted only 38-45 minutes between Britain and Zanzibar in 1896.",
    ];
    final randomFact = facts[(DateTime.now().millisecondsSinceEpoch) % facts.length];
    provider.systemSpeak("Here's a fun fact: $randomFact");
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Smart Voice AI'),
        content: const Text(
          'Smart Voice AI is an advanced voice assistant with 15+ features including voice notes, reminders, weather updates, jokes, quotes, and much more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAppNotFoundDialog(String appType, String? webFallbackUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$appType App Not Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No $appType app found on your device.'),
              const SizedBox(height: 16),
              Text('What would you like to do?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open Play Store to search for the app
                final playStoreUrl = 'https://play.google.com/store/search?q=${appType.toLowerCase()}';
                launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
              },
              child: const Text('Install App'),
            ),
            if (webFallbackUrl != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  launchUrl(Uri.parse(webFallbackUrl), mode: LaunchMode.externalApplication);
                },
                child: const Text('Use Web Version'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}
