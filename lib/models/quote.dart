class Quote {
  final String id;
  final String text;
  final String author;
  final String category;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
  });

  static List<Quote> dailyQuotes = [
    Quote(
      id: '1',
      text: 'The future belongs to those who believe in the beauty of their dreams.',
      author: 'Eleanor Roosevelt',
      category: 'motivation',
    ),
    Quote(
      id: '2',
      text: 'It is during our darkest moments that we must focus to see the light.',
      author: 'Aristotle',
      category: 'inspiration',
    ),
    Quote(
      id: '3',
      text: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      author: 'Winston Churchill',
      category: 'motivation',
    ),
    Quote(
      id: '4',
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      category: 'work',
    ),
    Quote(
      id: '5',
      text: 'Innovation distinguishes between a leader and a follower.',
      author: 'Steve Jobs',
      category: 'innovation',
    ),
    Quote(
      id: '6',
      text: 'Life is what happens to you while you\'re busy making other plans.',
      author: 'John Lennon',
      category: 'life',
    ),
    Quote(
      id: '7',
      text: 'The way to get started is to quit talking and begin doing.',
      author: 'Walt Disney',
      category: 'action',
    ),
    Quote(
      id: '8',
      text: 'Don\'t let yesterday take up too much of today.',
      author: 'Will Rogers',
      category: 'motivation',
    ),
    Quote(
      id: '9',
      text: 'You learn more from failure than from success.',
      author: 'Unknown',
      category: 'learning',
    ),
    Quote(
      id: '10',
      text: 'If you are working on something that you really care about, you don\'t have to be pushed.',
      author: 'Steve Jobs',
      category: 'passion',
    ),
  ];

  static List<String> funFacts = [
    'Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible.',
    'Octopuses have three hearts and blue blood.',
    'A group of flamingos is called a "flamboyance".',
    'Bananas are berries, but strawberries aren\'t.',
    'There are more possible games of chess than there are atoms in the observable universe.',
    'A cloud can weigh more than a million pounds.',
    'Butterflies taste with their feet.',
    'The shortest war in history was between Britain and Zanzibar in 1896. It lasted only 38-45 minutes.',
    'A single strand of spaghetti is called a "spaghetto".',
    'Dolphins have names for each other.',
  ];
}
