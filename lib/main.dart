import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/voice_assistant_provider.dart';
import 'modern_home_page.dart';
import 'screens/notes_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartVoiceAIApp());
}

class SmartVoiceAIApp extends StatelessWidget {
  const SmartVoiceAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppStateProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => VoiceAssistantProvider()..initialize(),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Smart Voice AI',
            debugShowCheckedModeBanner: false,
            theme: appState.lightTheme,
            darkTheme: appState.darkTheme,
            themeMode: appState.themeMode,
            home: const ModernHomePage(),
            routes: {
              '/home': (context) => const ModernHomePage(),
              '/settings': (context) => const SettingsScreen(),
              '/notes': (context) => const NotesScreen(),
              '/reminders': (context) => const RemindersScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ThemeMode>(
                        value: appState.themeMode,
                        decoration: const InputDecoration(
                          labelText: 'Theme Mode',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            appState.setThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accessibility',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Large Text'),
                        subtitle: const Text('Increase text size for better readability'),
                        value: appState.isLargeTextEnabled,
                        onChanged: (value) => appState.toggleLargeText(),
                      ),
                      SwitchListTile(
                        title: const Text('High Contrast'),
                        subtitle: const Text('Enhance visual contrast'),
                        value: appState.isHighContrastEnabled,
                        onChanged: (value) => appState.toggleHighContrast(),
                      ),
                      SwitchListTile(
                        title: const Text('Reduce Animations'),
                        subtitle: const Text('Minimize motion effects'),
                        value: appState.isReduceAnimationsEnabled,
                        onChanged: (value) => appState.toggleReduceAnimations(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Consumer<VoiceAssistantProvider>(
                        builder: (context, voiceProvider, child) {
                          return Column(
                            children: [
                              ListTile(
                                title: const Text('Speech Rate'),
                                subtitle: Slider(
                                  value: voiceProvider.speechRate,
                                  min: 0.1,
                                  max: 1.0,
                                  divisions: 9,
                                  label: '${(voiceProvider.speechRate * 100).round()}%',
                                  onChanged: voiceProvider.setSpeechRate,
                                ),
                              ),
                              ListTile(
                                title: const Text('Speech Pitch'),
                                subtitle: Slider(
                                  value: voiceProvider.speechPitch,
                                  min: 0.5,
                                  max: 2.0,
                                  divisions: 15,
                                  label: '${voiceProvider.speechPitch.toStringAsFixed(1)}',
                                  onChanged: voiceProvider.setSpeechPitch,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
