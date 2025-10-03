import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/models/chat_message.dart';
import 'package:myapp/services/database_service.dart';

class AiService {
  final DatabaseService _dbService = DatabaseService();
  final GenerativeModel _model;
  ChatSession? _chat;

  AiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // Corrected model name
          apiKey: apiKey,
        );

  Future<ChatSession> _getChatSession() async {
    if (_chat == null) {
      final history = await _dbService.getChatHistory();
      final contentHistory = <Content>[];
      for (var message in history) {
        if (message.isUser) {
          contentHistory.add(Content.text(message.text));
        } else {
          contentHistory.add(Content.model([TextPart(message.text)]));
        }
      }
      _chat = _model.startChat(history: contentHistory);
    }
    return _chat!;
  }

  Future<String> sendMessage(String text) async {
    final chat = await _getChatSession();

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await _dbService.saveChatMessage(userMessage);

    final response = await chat.sendMessage(Content.text(text));
    final aiResponseText = response.text ?? 'Maaf, saya tidak mengerti.';

    final aiMessage = ChatMessage(
      text: aiResponseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
    await _dbService.saveChatMessage(aiMessage);

    return aiResponseText;
  }

  Future<void> clearChatHistory() async {
    await _dbService.deleteChatHistory();
    // Start a new chat session with empty history
    _chat = _model.startChat();
  }

  // TODO: Implement RAG and partial history deletion
}
