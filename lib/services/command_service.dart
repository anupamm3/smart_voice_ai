import 'package:url_launcher/url_launcher.dart';
import '../models/quote.dart';
import '../models/joke.dart';
import '../services/weather_service.dart';
import '../services/reminder_service.dart';
import 'dart:math';

class CommandService {
  final WeatherService _weatherService = WeatherService();
  final ReminderService _reminderService = ReminderService();

  Future<String?> processCommand(String command) async {
    final lowerCommand = command.toLowerCase().trim();
    
    // Check for various command patterns
    if (_isOpenAppCommand(lowerCommand)) {
      return await _handleOpenAppCommand(lowerCommand);
    } else if (_isTimerCommand(lowerCommand)) {
      return await _handleTimerCommand(lowerCommand);
    } else if (_isReminderCommand(lowerCommand)) {
      return await _handleReminderCommand(command);
    } else if (_isWeatherCommand(lowerCommand)) {
      return await _handleWeatherCommand();
    } else if (_isQuoteCommand(lowerCommand)) {
      return _handleQuoteCommand();
    } else if (_isJokeCommand(lowerCommand)) {
      return _handleJokeCommand(lowerCommand);
    } else if (_isFactCommand(lowerCommand)) {
      return _handleFactCommand();
    } else if (_isCalculatorCommand(lowerCommand)) {
      return await _handleCalculatorCommand();
    } else if (_isNavigationCommand(lowerCommand)) {
      return _handleNavigationCommand(lowerCommand);
    }
    
    return null; // Not a recognized command
  }

  // Command detection methods
  bool _isOpenAppCommand(String command) {
    return command.contains('open') && 
           (command.contains('calculator') || 
            command.contains('browser') || 
            command.contains('maps') ||
            command.contains('calendar') ||
            command.contains('settings'));
  }

  bool _isTimerCommand(String command) {
    return (command.contains('set') || command.contains('start')) && 
           (command.contains('timer') || command.contains('alarm'));
  }

  bool _isReminderCommand(String command) {
    return (command.contains('remind') || command.contains('reminder')) ||
           (command.contains('set') && (command.contains('reminder') || command.contains('remind')));
  }

  bool _isWeatherCommand(String command) {
    return command.contains('weather') || 
           command.contains('temperature') || 
           command.contains('forecast');
  }

  bool _isQuoteCommand(String command) {
    return command.contains('quote') || 
           command.contains('motivation') || 
           command.contains('inspire');
  }

  bool _isJokeCommand(String command) {
    return command.contains('joke') || 
           command.contains('funny') || 
           command.contains('riddle');
  }

  bool _isFactCommand(String command) {
    return command.contains('fact') || 
           command.contains('trivia') || 
           command.contains('interesting');
  }

  bool _isCalculatorCommand(String command) {
    return command.contains('calculator') || 
           command.contains('calculate') || 
           command.contains('math');
  }

  bool _isNavigationCommand(String command) {
    return (command.contains('go') || command.contains('show') || command.contains('open')) &&
           (command.contains('settings') || 
            command.contains('notes') || 
            command.contains('reminders') ||
            command.contains('history') ||
            command.contains('features'));
  }

  // Command handler methods
  Future<String> _handleOpenAppCommand(String command) async {
    try {
      if (command.contains('calculator')) {
        final uri = Uri.parse('calculator:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return 'Opening calculator...';
        } else {
          // Try alternative
          final altUri = Uri.parse('https://www.google.com/search?q=calculator');
          await launchUrl(altUri, mode: LaunchMode.externalApplication);
          return 'Opening web calculator...';
        }
      } else if (command.contains('browser')) {
        final uri = Uri.parse('https://www.google.com');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return 'Opening browser...';
      } else if (command.contains('maps')) {
        final uri = Uri.parse('geo:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return 'Opening maps...';
        } else {
          final altUri = Uri.parse('https://maps.google.com');
          await launchUrl(altUri, mode: LaunchMode.externalApplication);
          return 'Opening Google Maps...';
        }
      } else if (command.contains('calendar')) {
        final uri = Uri.parse('calendar:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return 'Opening calendar...';
        } else {
          final altUri = Uri.parse('https://calendar.google.com');
          await launchUrl(altUri, mode: LaunchMode.externalApplication);
          return 'Opening Google Calendar...';
        }
      } else if (command.contains('settings')) {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return 'Opening settings...';
        } else {
          return 'Cannot open device settings from this app.';
        }
      }
    } catch (e) {
      return 'Sorry, I couldn\'t open that app. Error: $e';
    }
    return 'App not recognized.';
  }

  Future<String> _handleTimerCommand(String command) async {
    try {
      // Extract time from command
      final minutes = _extractTimeFromCommand(command);
      if (minutes > 0) {
        await _reminderService.setTimer(minutes);
        return 'Timer set for $minutes minute${minutes > 1 ? 's' : ''}!';
      } else {
        return 'Please specify a time for the timer, like "set timer for 5 minutes".';
      }
    } catch (e) {
      return 'Sorry, I couldn\'t set the timer. Error: $e';
    }
  }

  Future<String> _handleReminderCommand(String command) async {
    try {
      // Basic reminder parsing
      final reminderText = _extractReminderText(command);
      if (reminderText.isNotEmpty) {
        await _reminderService.setReminder(reminderText);
        return 'Reminder set: $reminderText';
      } else {
        return 'Please tell me what you want to be reminded about.';
      }
    } catch (e) {
      return 'Sorry, I couldn\'t set the reminder. Error: $e';
    }
  }

  Future<String> _handleWeatherCommand() async {
    try {
      final weather = await _weatherService.getCurrentWeather();
      return weather;
    } catch (e) {
      return 'Sorry, I couldn\'t get the weather information right now. Error: $e';
    }
  }

  String _handleQuoteCommand() {
    final random = Random();
    final quote = Quote.dailyQuotes[random.nextInt(Quote.dailyQuotes.length)];
    return '"${quote.text}"\n\n- ${quote.author}';
  }

  String _handleJokeCommand(String command) {
    final random = Random();
    
    if (command.contains('riddle')) {
      final riddle = Joke.riddles[random.nextInt(Joke.riddles.length)];
      return riddle;
    } else {
      final joke = Joke.jokes[random.nextInt(Joke.jokes.length)];
      return '${joke.setup}\n\n${joke.punchline}';
    }
  }

  String _handleFactCommand() {
    final random = Random();
    final fact = Quote.funFacts[random.nextInt(Quote.funFacts.length)];
    return 'Here\'s a fun fact: $fact';
  }

  Future<String> _handleCalculatorCommand() async {
    return await _handleOpenAppCommand('open calculator');
  }

  String _handleNavigationCommand(String command) {
    if (command.contains('settings')) {
      return 'navigation:settings';
    } else if (command.contains('notes')) {
      return 'navigation:notes';
    } else if (command.contains('reminders')) {
      return 'navigation:reminders';
    } else if (command.contains('history')) {
      return 'navigation:history';
    } else if (command.contains('features')) {
      return 'navigation:features';
    }
    return 'I\'m not sure which screen you want to navigate to.';
  }

  // Helper methods
  int _extractTimeFromCommand(String command) {
    // Look for patterns like "5 minutes", "10 mins", "1 hour"
    final regex = RegExp(r'(\d+)\s*(minute|min|hour|hr)s?', caseSensitive: false);
    final match = regex.firstMatch(command);
    
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '0') ?? 0;
      final unit = match.group(2)?.toLowerCase() ?? '';
      
      if (unit.startsWith('hour') || unit.startsWith('hr')) {
        return number * 60; // Convert hours to minutes
      } else {
        return number; // Already in minutes
      }
    }
    
    return 0;
  }

  String _extractReminderText(String command) {
    // Remove common reminder prefixes
    String text = command
        .replaceAll(RegExp(r'^(remind me to|remind me|set reminder to|set reminder)', caseSensitive: false), '')
        .trim();
    
    return text;
  }
}
