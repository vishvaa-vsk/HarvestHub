import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isLoading = true;
    });

    try {
      final model = GenerativeModel(
        model: 'models/gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );

      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': response.text ?? 'No response available',
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'Error: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(
                        backgroundColor: Colors.green.shade400,
                        child: const Icon(Icons.eco, color: Colors.white),
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                                isUser
                                    ? const Radius.circular(16)
                                    : const Radius.circular(0),
                            bottomRight:
                                isUser
                                    ? const Radius.circular(0)
                                    : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message['text']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (isUser) const SizedBox(width: 8),
                    if (isUser)
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade400,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                  ],
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
                    maxLines: null, // Allow the input field to grow vertically
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
