import 'dart:math';
import '../models/quote.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  final Random _random = Random();

  // Local quotes database
  final List<Quote> _quotes = [
    Quote(
      id: '1',
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      category: 'motivation',
    ),
    Quote(
      id: '2',
      text: 'Innovation distinguishes between a leader and a follower.',
      author: 'Steve Jobs',
      category: 'innovation',
    ),
    Quote(
      id: '3',
      text: 'Your time is limited, don\'t waste it living someone else\'s life.',
      author: 'Steve Jobs',
      category: 'life',
    ),
    Quote(
      id: '4',
      text: 'The future belongs to those who believe in the beauty of their dreams.',
      author: 'Eleanor Roosevelt',
      category: 'dreams',
    ),
    Quote(
      id: '5',
      text: 'It is during our darkest moments that we must focus to see the light.',
      author: 'Aristotle',
      category: 'perseverance',
    ),
    Quote(
      id: '6',
      text: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      author: 'Winston Churchill',
      category: 'success',
    ),
    Quote(
      id: '7',
      text: 'The only impossible journey is the one you never begin.',
      author: 'Tony Robbins',
      category: 'motivation',
    ),
    Quote(
      id: '8',
      text: 'In the middle of difficulty lies opportunity.',
      author: 'Albert Einstein',
      category: 'opportunity',
    ),
    Quote(
      id: '9',
      text: 'Believe you can and you\'re halfway there.',
      author: 'Theodore Roosevelt',
      category: 'belief',
    ),
    Quote(
      id: '10',
      text: 'The way to get started is to quit talking and begin doing.',
      author: 'Walt Disney',
      category: 'action',
    ),
    Quote(
      id: '11',
      text: 'Don\'t be afraid to give up the good to go for the great.',
      author: 'John D. Rockefeller',
      category: 'excellence',
    ),
    Quote(
      id: '12',
      text: 'If you are not willing to risk the usual, you will have to settle for the ordinary.',
      author: 'Jim Rohn',
      category: 'risk',
    ),
    Quote(
      id: '13',
      text: 'Logic will get you from A to Z; imagination will get you everywhere.',
      author: 'Albert Einstein',
      category: 'creativity',
    ),
    Quote(
      id: '14',
      text: 'Try not to become a person of success, but rather try to become a person of value.',
      author: 'Albert Einstein',
      category: 'values',
    ),
    Quote(
      id: '15',
      text: 'A person who never made a mistake never tried anything new.',
      author: 'Albert Einstein',
      category: 'learning',
    ),
    Quote(
      id: '16',
      text: 'The greatest glory in living lies not in never falling, but in rising every time we fall.',
      author: 'Nelson Mandela',
      category: 'resilience',
    ),
    Quote(
      id: '17',
      text: 'Life is what happens to you while you\'re busy making other plans.',
      author: 'John Lennon',
      category: 'life',
    ),
    Quote(
      id: '18',
      text: 'The only thing we have to fear is fear itself.',
      author: 'Franklin D. Roosevelt',
      category: 'courage',
    ),
    Quote(
      id: '19',
      text: 'Those who dare to fail miserably can achieve greatly.',
      author: 'John F. Kennedy',
      category: 'courage',
    ),
    Quote(
      id: '20',
      text: 'I have not failed. I\'ve just found 10,000 ways that won\'t work.',
      author: 'Thomas A. Edison',
      category: 'perseverance',
    ),
  ];

  // Interesting facts database
  final List<String> _facts = [
    'Octopuses have three hearts and blue blood.',
    'Bananas are berries, but strawberries aren\'t.',
    'A group of flamingos is called a "flamboyance".',
    'Honey never spoils. Archaeologists have found edible honey in ancient Egyptian tombs.',
    'A shrimp\'s heart is in its head.',
    'Butterflies taste with their feet.',
    'The human brain uses about 20% of the body\'s energy.',
    'A day on Venus is longer than its year.',
    'Sharks have been around longer than trees.',
    'The shortest war in history lasted only 38-45 minutes.',
    'A group of owls is called a "parliament".',
    'Cats have 32 muscles in each ear.',
    'The Great Wall of China isn\'t visible from space with the naked eye.',
    'Lightning strikes the Earth about 100 times per second.',
    'The human body contains about 37.2 trillion cells.',
    'Dolphins have names for each other.',
    'A group of pugs is called a "grumble".',
    'The dot over a lowercase i or j is called a "tittle".',
    'Wombat poop is cube-shaped.',
    'The longest word in English has 189,819 letters.',
  ];

  // Daily tips database
  final List<String> _tips = [
    'Drink a glass of water first thing in the morning to kickstart your metabolism.',
    'Take a 5-minute break every hour to rest your eyes and stretch.',
    'Write down 3 things you\'re grateful for each day.',
    'Do a 2-minute breathing exercise to reduce stress.',
    'Keep your phone away from your bedside to improve sleep quality.',
    'Learn one new word each day to expand your vocabulary.',
    'Take the stairs instead of the elevator for better fitness.',
    'Organize your workspace at the end of each day.',
    'Listen to a podcast or audiobook during your commute.',
    'Practice the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.',
    'Prepare your clothes the night before to save morning time.',
    'Use the "two-minute rule": if a task takes less than 2 minutes, do it now.',
    'Keep a water bottle nearby to stay hydrated.',
    'Do a quick 10-minute walk after meals to aid digestion.',
    'Use a standing desk for part of your workday.',
    'Practice mindfulness for 5 minutes each day.',
    'Keep healthy snacks at your desk to avoid junk food.',
    'Set a timer for tasks to improve focus and productivity.',
    'Read for 15 minutes before bed instead of using screens.',
    'Smile at yourself in the mirror each morning - it boosts mood!',
  ];

  Quote getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  Quote? getQuoteById(String id) {
    try {
      return _quotes.firstWhere((quote) => quote.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Quote> getQuotesByCategory(String category) {
    return _quotes.where((quote) => 
        quote.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Quote> getQuotesByAuthor(String author) {
    return _quotes.where((quote) => 
        quote.author.toLowerCase().contains(author.toLowerCase())).toList();
  }

  List<Quote> searchQuotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _quotes.where((quote) =>
        quote.text.toLowerCase().contains(lowerQuery) ||
        quote.author.toLowerCase().contains(lowerQuery) ||
        quote.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  String getRandomFact() {
    return _facts[_random.nextInt(_facts.length)];
  }

  String getRandomTip() {
    return _tips[_random.nextInt(_tips.length)];
  }

  List<String> getAvailableCategories() {
    return _quotes.map((quote) => quote.category).toSet().toList()..sort();
  }

  List<String> getAvailableAuthors() {
    return _quotes.map((quote) => quote.author).toSet().toList()..sort();
  }

  Quote getDailyQuote() {
    // Use the current date as seed for consistent daily quote
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _quotes.length;
    return _quotes[index];
  }

  String getDailyFact() {
    // Use the current date as seed for consistent daily fact
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _facts.length;
    return _facts[index];
  }

  String getDailyTip() {
    // Use the current date as seed for consistent daily tip
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _tips.length;
    return _tips[index];
  }

  // Get motivational quote for specific situations
  Quote getMotivationalQuote() {
    final motivationalQuotes = getQuotesByCategory('motivation');
    if (motivationalQuotes.isNotEmpty) {
      return motivationalQuotes[_random.nextInt(motivationalQuotes.length)];
    }
    return getRandomQuote();
  }

  Quote getSuccessQuote() {
    final successQuotes = getQuotesByCategory('success');
    if (successQuotes.isNotEmpty) {
      return successQuotes[_random.nextInt(successQuotes.length)];
    }
    return getRandomQuote();
  }

  Quote getCourageQuote() {
    final courageQuotes = getQuotesByCategory('courage');
    if (courageQuotes.isNotEmpty) {
      return courageQuotes[_random.nextInt(courageQuotes.length)];
    }
    return getRandomQuote();
  }

  // Get quote based on time of day
  Quote getTimeBasedQuote() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning - motivational quotes
      return getMotivationalQuote();
    } else if (hour >= 12 && hour < 18) {
      // Afternoon - success/productivity quotes
      return getSuccessQuote();
    } else if (hour >= 18 && hour < 22) {
      // Evening - reflection/life quotes
      final lifeQuotes = getQuotesByCategory('life');
      if (lifeQuotes.isNotEmpty) {
        return lifeQuotes[_random.nextInt(lifeQuotes.length)];
      }
    } else {
      // Night - peaceful/calming quotes
      final peacefulCategories = ['dreams', 'belief', 'values'];
      final availableCategories = peacefulCategories.where((cat) => 
          getQuotesByCategory(cat).isNotEmpty).toList();
      
      if (availableCategories.isNotEmpty) {
        final category = availableCategories[_random.nextInt(availableCategories.length)];
        final quotes = getQuotesByCategory(category);
        return quotes[_random.nextInt(quotes.length)];
      }
    }
    
    return getRandomQuote();
  }

  // Statistics
  int getTotalQuotes() => _quotes.length;
  int getTotalFacts() => _facts.length;
  int getTotalTips() => _tips.length;
  int getTotalAuthors() => getAvailableAuthors().length;
  int getTotalCategories() => getAvailableCategories().length;

  Map<String, dynamic> getStatistics() {
    return {
      'totalQuotes': getTotalQuotes(),
      'totalFacts': getTotalFacts(),
      'totalTips': getTotalTips(),
      'totalAuthors': getTotalAuthors(),
      'totalCategories': getTotalCategories(),
      'categories': getAvailableCategories(),
      'authors': getAvailableAuthors(),
    };
  }
}
