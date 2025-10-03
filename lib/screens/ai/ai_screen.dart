import 'package:flutter/material.dart';
import 'package:myapp/models/chat_message.dart' as chat_model;
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/database_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  late final AiService _aiService;
  final DatabaseService _dbService = DatabaseService();
  List<chat_model.ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // IMPORTANT: Replace with your actual Gemini API key
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyAlzjS2XqjiXzoCDBmTgMq0oR55-hxLU5I');
    _aiService = AiService(apiKey);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await _dbService.getChatHistory();
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final text = _controller.text;
      _controller.clear();

      setState(() {
        _messages.add(chat_model.ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = true;
      });

      final aiResponse = await _aiService.sendMessage(text);

      setState(() {
        _messages.add(chat_model.ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _aiService.clearChatHistory();
              _loadMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tanyakan sesuatu...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
