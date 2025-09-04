import 'dart:math';
import '../models/joke.dart';

class JokeService {
  static final JokeService _instance = JokeService._internal();
  factory JokeService() => _instance;
  JokeService._internal();

  final Random _random = Random();

  // Local jokes database
  final List<Joke> _jokes = [
    Joke(
      id: '1',
      setup: 'Why don\'t scientists trust atoms?',
      punchline: 'Because they make up everything!',
      category: 'science',
    ),
    Joke(
      id: '2',
      setup: 'I told my wife she was drawing her eyebrows too high.',
      punchline: 'She looked surprised.',
      category: 'general',
    ),
    Joke(
      id: '3',
      setup: 'Why did the scarecrow win an award?',
      punchline: 'He was outstanding in his field!',
      category: 'puns',
    ),
    Joke(
      id: '4',
      setup: 'I\'m reading a book about anti-gravity.',
      punchline: 'It\'s impossible to put down!',
      category: 'science',
    ),
    Joke(
      id: '5',
      setup: 'Did you hear about the mathematician who\'s afraid of negative numbers?',
      punchline: 'He\'ll stop at nothing to avoid them!',
      category: 'math',
    ),
    Joke(
      id: '6',
      setup: 'Why don\'t eggs tell jokes?',
      punchline: 'They\'d crack each other up!',
      category: 'food',
    ),
    Joke(
      id: '7',
      setup: 'What do you call a fake noodle?',
      punchline: 'An impasta!',
      category: 'food',
    ),
    Joke(
      id: '8',
      setup: 'Why did the coffee file a police report?',
      punchline: 'It got mugged!',
      category: 'food',
    ),
    Joke(
      id: '9',
      setup: 'How do you organize a space party?',
      punchline: 'You planet!',
      category: 'space',
    ),
    Joke(
      id: '10',
      setup: 'Why don\'t programmers like nature?',
      punchline: 'It has too many bugs!',
      category: 'tech',
    ),
    Joke(
      id: '11',
      setup: 'Why do Java developers wear glasses?',
      punchline: 'Because they can\'t C#!',
      category: 'tech',
    ),
    Joke(
      id: '12',
      setup: 'What did the ocean say to the beach?',
      punchline: 'Nothing, it just waved!',
      category: 'nature',
    ),
    Joke(
      id: '13',
      setup: 'Why don\'t skeletons fight each other?',
      punchline: 'They don\'t have the guts!',
      category: 'general',
    ),
    Joke(
      id: '14',
      setup: 'What do you call a dinosaur that crashes his car?',
      punchline: 'Tyrannosaurus Wrecks!',
      category: 'animals',
    ),
    Joke(
      id: '15',
      setup: 'Why did the bicycle fall over?',
      punchline: 'Because it was two tired!',
      category: 'general',
    ),
    Joke(
      id: '16',
      setup: 'What do you call a bear with no teeth?',
      punchline: 'A gummy bear!',
      category: 'animals',
    ),
    Joke(
      id: '17',
      setup: 'Why did the math book look so sad?',
      punchline: 'Because it had too many problems!',
      category: 'math',
    ),
    Joke(
      id: '18',
      setup: 'What do you call a sleeping bull?',
      punchline: 'A bulldozer!',
      category: 'animals',
    ),
    Joke(
      id: '19',
      setup: 'What do you call a fish wearing a crown?',
      punchline: 'A king fish!',
      category: 'animals',
    ),
    Joke(
      id: '20',
      setup: 'How does a penguin build its house?',
      punchline: 'Igloos it together!',
      category: 'animals',
    ),
  ];

  // Riddles database
  final List<Map<String, String>> _riddles = [
    {
      'question': 'What has keys but no locks, space but no room, and you can enter but not go inside?',
      'answer': 'A keyboard',
    },
    {
      'question': 'I\'m tall when I\'m young, and short when I\'m old. What am I?',
      'answer': 'A candle',
    },
    {
      'question': 'What gets wet while drying?',
      'answer': 'A towel',
    },
    {
      'question': 'What has one eye but can\'t see?',
      'answer': 'A needle',
    },
    {
      'question': 'The more you take, the more you leave behind. What am I?',
      'answer': 'Footsteps',
    },
    {
      'question': 'What has hands but can\'t clap?',
      'answer': 'A clock',
    },
    {
      'question': 'What goes up but never comes down?',
      'answer': 'Your age',
    },
    {
      'question': 'What has a head and a tail but no body?',
      'answer': 'A coin',
    },
    {
      'question': 'What can travel around the world while staying in a corner?',
      'answer': 'A stamp',
    },
    {
      'question': 'What has many teeth but can\'t bite?',
      'answer': 'A comb',
    },
  ];

  // Fun facts database
  final List<String> _funFacts = [
    'A group of pandas is called an "embarrassment".',
    'Penguins can jump as high as 6 feet in the air.',
    'A snail can sleep for three years.',
    'The shortest commercial flight in the world is 57 seconds long.',
    'A group of hedgehogs is called a "prickle".',
    'Kangaroos can\'t walk backwards.',
    'A shrimp\'s heart is in its head.',
    'Elephants are afraid of bees.',
    'A group of crows is called a "murder".',
    'Dolphins have names for each other.',
  ];

  Joke getRandomJoke() {
    return _jokes[_random.nextInt(_jokes.length)];
  }

  Joke? getJokeById(String id) {
    try {
      return _jokes.firstWhere((joke) => joke.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Joke> getJokesByCategory(String category) {
    return _jokes.where((joke) => 
        joke.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Joke> searchJokes(String query) {
    final lowerQuery = query.toLowerCase();
    return _jokes.where((joke) =>
        joke.setup.toLowerCase().contains(lowerQuery) ||
        joke.punchline.toLowerCase().contains(lowerQuery) ||
        joke.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Map<String, String> getRandomRiddle() {
    return _riddles[_random.nextInt(_riddles.length)];
  }

  String getRandomFunFact() {
    return _funFacts[_random.nextInt(_funFacts.length)];
  }

  List<String> getAvailableCategories() {
    return _jokes.map((joke) => joke.category).toSet().toList()..sort();
  }

  List<Joke> getRandomJokes({int limit = 10}) {
    final shuffledJokes = List<Joke>.from(_jokes)..shuffle(_random);
    return shuffledJokes.take(limit).toList();
  }

  Joke getDailyJoke() {
    // Use the current date as seed for consistent daily joke
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _jokes.length;
    return _jokes[index];
  }

  Map<String, String> getDailyRiddle() {
    // Use the current date as seed for consistent daily riddle
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _riddles.length;
    return _riddles[index];
  }

  String getDailyFunFact() {
    // Use the current date as seed for consistent daily fun fact
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _funFacts.length;
    return _funFacts[index];
  }

  // Get jokes based on mood or context
  Joke getHappyJoke() {
    final categories = ['general', 'puns', 'animals'];
    final availableJokes = _jokes.where((joke) => 
        categories.contains(joke.category)).toList();
    
    if (availableJokes.isNotEmpty) {
      return availableJokes[_random.nextInt(availableJokes.length)];
    }
    return getRandomJoke();
  }

  Joke getNerdyJoke() {
    final categories = ['tech', 'science', 'math'];
    final availableJokes = _jokes.where((joke) => 
        categories.contains(joke.category)).toList();
    
    if (availableJokes.isNotEmpty) {
      return availableJokes[_random.nextInt(availableJokes.length)];
    }
    return getRandomJoke();
  }

  Joke getCleanJoke() {
    // Return a random joke from family-friendly categories
    final familyCategories = ['general', 'puns', 'animals', 'food'];
    final familyJokes = _jokes.where((joke) => 
        familyCategories.contains(joke.category)).toList();
    
    if (familyJokes.isNotEmpty) {
      return familyJokes[_random.nextInt(familyJokes.length)];
    }
    return getRandomJoke();
  }

  // Get entertainment content based on time of day
  Map<String, dynamic> getTimeBasedContent() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning - light and positive content
      return {
        'type': 'fact',
        'content': getRandomFunFact(),
        'context': 'Start your day with something interesting!',
      };
    } else if (hour >= 12 && hour < 18) {
      // Afternoon - engaging riddles
      final riddle = getRandomRiddle();
      return {
        'type': 'riddle',
        'content': riddle,
        'context': 'Time for a brain teaser!',
      };
    } else if (hour >= 18 && hour < 22) {
      // Evening - light jokes
      final joke = getHappyJoke();
      return {
        'type': 'joke',
        'content': joke,
        'context': 'Let\'s unwind with some humor!',
      };
    } else {
      // Night - calming content
      return {
        'type': 'fact',
        'content': getDailyFunFact(),
        'context': 'Here\'s something peaceful to end your day.',
      };
    }
  }

  // Statistics and analytics
  int getTotalJokes() => _jokes.length;
  int getTotalRiddles() => _riddles.length;
  int getTotalFunFacts() => _funFacts.length;
  int getTotalCategories() => getAvailableCategories().length;

  Map<String, int> getCategoryDistribution() {
    final distribution = <String, int>{};
    for (final joke in _jokes) {
      distribution[joke.category] = (distribution[joke.category] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, dynamic> getStatistics() {
    return {
      'totalJokes': getTotalJokes(),
      'totalRiddles': getTotalRiddles(),
      'totalFunFacts': getTotalFunFacts(),
      'totalCategories': getTotalCategories(),
      'categoryDistribution': getCategoryDistribution(),
      'categories': getAvailableCategories(),
    };
  }

  // Interactive features
  String formatJoke(Joke joke, {bool includeCategory = false}) {
    String formatted = '${joke.setup}\n\n${joke.punchline}';
    if (includeCategory) {
      formatted += '\n\nCategory: ${joke.category}';
    }
    return formatted;
  }

  String formatRiddle(Map<String, String> riddle, {bool showAnswer = false}) {
    String formatted = 'Riddle: ${riddle['question']}';
    if (showAnswer) {
      formatted += '\n\nAnswer: ${riddle['answer']}';
    }
    return formatted;
  }

  // Voice-friendly responses
  String getVoiceFriendlyJoke(Joke joke) {
    return '${joke.setup}... ${joke.punchline}';
  }

  String getVoiceFriendlyRiddle(Map<String, String> riddle, {bool withAnswer = false}) {
    String response = 'Here\'s a riddle for you: ${riddle['question']}';
    if (withAnswer) {
      response += '... The answer is: ${riddle['answer']}';
    }
    return response;
  }
}
