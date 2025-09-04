class Joke {
  final String id;
  final String setup;
  final String punchline;
  final String category;

  Joke({
    required this.id,
    required this.setup,
    required this.punchline,
    required this.category,
  });

  static List<Joke> jokes = [
    Joke(
      id: '1',
      setup: 'Why don\'t scientists trust atoms?',
      punchline: 'Because they make up everything!',
      category: 'science',
    ),
    Joke(
      id: '2',
      setup: 'Why did the math book look so sad?',
      punchline: 'Because it was full of problems!',
      category: 'education',
    ),
    Joke(
      id: '3',
      setup: 'What do you call a fake noodle?',
      punchline: 'An impasta!',
      category: 'food',
    ),
    Joke(
      id: '4',
      setup: 'Why don\'t programmers like nature?',
      punchline: 'It has too many bugs!',
      category: 'technology',
    ),
    Joke(
      id: '5',
      setup: 'What do you call a bear with no teeth?',
      punchline: 'A gummy bear!',
      category: 'animals',
    ),
    Joke(
      id: '6',
      setup: 'Why did the coffee file a police report?',
      punchline: 'It got mugged!',
      category: 'food',
    ),
    Joke(
      id: '7',
      setup: 'What\'s the best thing about Switzerland?',
      punchline: 'I don\'t know, but the flag is a big plus!',
      category: 'geography',
    ),
    Joke(
      id: '8',
      setup: 'Why don\'t eggs tell jokes?',
      punchline: 'They\'d crack each other up!',
      category: 'food',
    ),
    Joke(
      id: '9',
      setup: 'What do you call a dinosaur that crashes his car?',
      punchline: 'Tyrannosaurus Wrecks!',
      category: 'animals',
    ),
    Joke(
      id: '10',
      setup: 'Why did the scarecrow win an award?',
      punchline: 'Because he was outstanding in his field!',
      category: 'work',
    ),
  ];

  static List<String> riddles = [
    'What has keys but no locks, space but no room, and you can enter but can\'t go inside? A keyboard!',
    'What gets wetter the more it dries? A towel!',
    'What has a face and two hands but no arms or legs? A clock!',
    'What can travel around the world while staying in a corner? A stamp!',
    'What has many teeth but can\'t bite? A zipper!',
    'What goes up but never comes down? Your age!',
    'What has a bottom at the top? Your legs!',
    'What gets broken without being held? A promise!',
    'What can fill a room but takes up no space? Light!',
    'What has cities, but no houses; forests, but no trees; and water, but no fish? A map!',
  ];
}
