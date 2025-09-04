import 'package:hive/hive.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 2)
class ChatHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userMessage;

  @HiveField(2)
  String assistantResponse;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String messageType; // 'text', 'command', 'note', etc.

  ChatHistory({
    required this.id,
    required this.userMessage,
    required this.assistantResponse,
    required this.timestamp,
    required this.messageType,
  });

  ChatHistory copyWith({
    String? id,
    String? userMessage,
    String? assistantResponse,
    DateTime? timestamp,
    String? messageType,
  }) {
    return ChatHistory(
      id: id ?? this.id,
      userMessage: userMessage ?? this.userMessage,
      assistantResponse: assistantResponse ?? this.assistantResponse,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
    );
  }
}
