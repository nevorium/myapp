import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@Collection()
class ChatMessage {
  Id id = Isar.autoIncrement;

  String text;
  bool isUser;
  DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
