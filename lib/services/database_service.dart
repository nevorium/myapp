import 'package:isar/isar.dart';
import 'package:myapp/models/chat_message.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Future<Isar> db;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    db = _init();
  }

  Future<Isar> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [UserProfileSchema, ChatMessageSchema],
      directory: dir.path,
    );
  }

  Future<void> saveUserProfile(UserProfile userProfile) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(userProfile);
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final isar = await db;
    return await isar.userProfiles.where().uidEqualTo(uid).findFirst();
  }

  // --- Chat Messages --- //

  Future<void> saveChatMessage(ChatMessage message) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatMessages.put(message);
    });
  }

  Future<List<ChatMessage>> getChatHistory() async {
    final isar = await db;
    return await isar.chatMessages.where().sortByTimestamp().findAll();
  }

  Future<void> deleteChatHistory() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatMessages.clear();
    });
  }

  Future<void> deleteSingleChatMessage(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatMessages.delete(id);
    });
  }
}
