import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/chat_message.dart';
import 'package:myapp/models/user_profile.dart';


class DatabaseService {
  static const String _userProfileBoxName = 'userProfile';
  static const String _chatMessageBoxName = 'chatMessages';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(ChatMessageAdapter());

    await Hive.openBox<UserProfile>(_userProfileBoxName);
    await Hive.openBox<ChatMessage>(_chatMessageBoxName);
  }

  Future<void> saveUserProfile(UserProfile userProfile) async {
    final box = Hive.box<UserProfile>(_userProfileBoxName);
    // In a key-value store like Hive, we need a consistent key.
    // The UID is perfect for this.
    await box.put(userProfile.uid, userProfile);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final box = Hive.box<UserProfile>(_userProfileBoxName);
    return box.get(uid);
  }

  // --- Chat Messages --- //

  Future<void> saveChatMessage(ChatMessage message) async {
    final box = Hive.box<ChatMessage>(_chatMessageBoxName);
    await box.add(message);
  }

  Future<List<ChatMessage>> getChatHistory() async {
    final box = Hive.box<ChatMessage>(_chatMessageBoxName);
    final messages = box.values.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  Future<void> deleteChatHistory() async {
    final box = Hive.box<ChatMessage>(_chatMessageBoxName);
    await box.clear();
  }

  // Note: Deleting a single message in Hive is typically done by key.
  // Since we use auto-incrementing keys with .add(), we'd need to find the key first.
  // For simplicity, we'll stick to clearing the whole history as requested.
  Future<void> deleteSingleChatMessage(dynamic key) async {
    final box = Hive.box<ChatMessage>(_chatMessageBoxName);
    await box.delete(key);
  }
}
