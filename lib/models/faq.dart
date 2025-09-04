import 'package:hive/hive.dart';

part 'faq.g.dart';

@HiveType(typeId: 3)
class FAQ extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  String answer;

  @HiveField(3)
  List<String> keywords;

  @HiveField(4)
  String category;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.keywords,
    required this.category,
  });

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    List<String>? keywords,
    String? category,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      keywords: keywords ?? this.keywords,
      category: category ?? this.category,
    );
  }
}
