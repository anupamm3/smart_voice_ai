import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => provider.systemSpeak(provider.generatedContent!),
                    tooltip: 'Speak response',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // TODO: Implement copy to clipboard
                    },
                    tooltip: 'Copy response',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share functionality
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

  void _executeQuickAction(String command) {
    final provider = Provider.of<VoiceAssistantProvider>(context, listen: false);
    // For now, just speak the command action
    provider.systemSpeak("Executing: $command");
    
    // TODO: Implement proper command execution
    // This would need a new method in VoiceAssistantProvider
  }

  void _askForWeather() {
    _executeQuickAction('What\'s the weather like today?');
  }

  void _tellJoke() {
    _executeQuickAction('Tell me a joke');
  }

  void _getQuote() {
    _executeQuickAction('Give me an inspirational quote');
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
