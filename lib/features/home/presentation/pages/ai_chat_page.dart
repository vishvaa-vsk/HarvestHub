import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../../../../core/utils/avatar_utils.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late String _userAvatarUrl;

  // Context-aware memory variables
  final List<Content> _conversationHistory = [];
  final int _maxHistoryLength = 10; // Keep last 10 exchanges for context

  @override
  void initState() {
    super.initState();
    // Generate a random user avatar
    _userAvatarUrl = _generateRandomAvatar();

    // Add welcome message when the chat page is initialized
    _messages.add({
      'sender': 'ai',
      'text': '''नमस्ते! 🌾 வணக்கம்! నమస్కారం! നമസ്കാരം! Hello!

Welcome to **HarvestBot** - your multilingual farming assistant! 🚜

I'm here to help Indian farmers with:
• **Crop Management** - Planting, growing, harvesting advice
• **Pest & Disease Control** - Identification and treatment
• **Weather & Seasonal Planning** - Best practices for each season
• **Soil Health** - Testing, fertilizers, and improvement tips
• **Market Information** - Crop prices and selling strategies
• **Sustainable Farming** - Organic and eco-friendly methods

**Supported Languages:** Hindi (हिंदी), Tamil (தமிழ்), Telugu (తెలుగు), Malayalam (മലയാളം), English

Just ask me anything in your preferred language! 🌱''',
    });
  }

  String _generateRandomAvatar() {
    return AvatarUtils.generateRandomAvatar();
  }

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isLoading = true;
    });

    // Add user message to conversation history
    _addToConversationHistory('user', userMessage);

    // Auto-scroll to bottom when new message is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final model = GenerativeModel(
        model: 'models/gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
        systemInstruction: Content.text(
          '''You are HarvestBot, an expert agricultural AI assistant specifically designed for Indian farmers. Your core expertise includes:

**AGRICULTURAL SPECIALIZATION:**
• Crop cultivation techniques for Indian climate zones (tropical, subtropical, arid, semi-arid)
• Traditional and modern farming practices suitable for small to medium-scale farms
• Pest and disease identification and management using IPM (Integrated Pest Management)
• Soil health assessment, organic farming, and sustainable agriculture
• Seasonal crop planning based on monsoon patterns and regional conditions
• Post-harvest management, storage, and value addition
• Government schemes, subsidies, and agricultural policies in India
• Market linkages, pricing strategies, and cooperative farming

**REGIONAL EXPERTISE:**
• Crops: Rice, wheat, sugarcane, cotton, pulses, oilseeds, spices, vegetables, fruits
• Regional specialties: Punjab wheat, Kerala spices, Maharashtra sugarcane, Tamil Nadu rice
• Water management: Drip irrigation, rainwater harvesting, watershed management
• Climate adaptation strategies for changing weather patterns

**MULTILINGUAL COMMUNICATION:**
CRITICAL: Always respond in the SAME LANGUAGE the user writes in. Language detection and matching is essential:

• **Hindi (हिंदी)**: Use for users writing in Devanagari script
• **Tamil (தமிழ்)**: Use for users writing in Tamil script  
• **Telugu (తెలుగు)**: Use for users writing in Telugu script
• **Malayalam (മലയാളം)**: Use for users writing in Malayalam script
• **English**: Use for users writing in Latin script

**CONTEXT AWARENESS & MEMORY:**
• Remember previous questions and answers in this conversation
• Build upon earlier discussions and refer back to them when relevant
• Maintain context about the farmer's specific crops, location, or farming methods mentioned
• Provide follow-up suggestions based on conversation history
• If the user asks "what about...", "and then...", or similar, refer to previous context

**RESPONSE GUIDELINES:**
1. **Language Matching**: Automatically detect user's language and respond in the same language
2. **Practical Focus**: Provide actionable, cost-effective solutions suitable for Indian farming conditions
3. **Cultural Sensitivity**: Respect traditional knowledge while introducing scientific methods
4. **Economic Awareness**: Consider budget constraints and suggest affordable alternatives
5. **Seasonal Relevance**: Factor in current season and regional weather patterns
6. **Safety First**: Always prioritize farmer safety and environmental protection
7. **Response Length**: Keep responses concise and well-structured (3-6 paragraphs max). Avoid overly lengthy explanations. Focus on the most important and actionable information first.
8. **Context Continuity**: Reference previous parts of the conversation when relevant to provide better assistance

**FORMATTING:**
• Use clear headings and bullet points for better readability
• Include relevant emojis for crops, weather, and farming activities
• Provide step-by-step instructions when explaining procedures (max 5-7 steps)
• Suggest 1-2 follow-up questions to help farmers get more specific guidance
• Prioritize essential information over comprehensive details

Remember: You're helping real farmers improve their livelihoods. Be practical, encouraging, and always consider local Indian agricultural contexts.

**RESPONSE STRUCTURE:**
• Start with a brief, direct answer (1-2 sentences)
• Provide 2-4 key actionable points
• End with a helpful tip or follow-up question
• Total response should be readable in 30-45 seconds
• Avoid overwhelming farmers with too much information at once''',
        ),
      );

      // Build conversation history for context
      final conversationHistory = _buildConversationHistory();
      final content = [Content.text(conversationHistory + userMessage)];
      final response = await model.generateContent(content);

      final responseText = response.text ?? 'No response available';

      setState(() {
        _messages.add({'sender': 'ai', 'text': responseText});
        _isLoading = false;
      });

      // Add bot response to conversation history
      _addToConversationHistory('model', responseText);

      // Auto-scroll to bottom when AI responds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'Error: $e'});
        _isLoading = false;
      });
    }
  }

  String _buildConversationHistory() {
    if (_conversationHistory.isEmpty) {
      return "";
    }

    StringBuffer history = StringBuffer();
    history.writeln("\n\nRecent conversation context:");

    for (int i = 0; i < _conversationHistory.length; i++) {
      final content = _conversationHistory[i];
      if (content.role == 'user') {
        // Extract text from Content object
        String userText = '';
        if (content.parts.isNotEmpty && content.parts.first is TextPart) {
          userText = (content.parts.first as TextPart).text;
        }
        history.writeln("Farmer asked: $userText");
      } else if (content.role == 'model') {
        // Extract text from Content object
        String botText = '';
        if (content.parts.isNotEmpty && content.parts.first is TextPart) {
          botText = (content.parts.first as TextPart).text;
        }
        String response = botText;
        if (response.length > 200) {
          response = "${response.substring(0, 200)}...";
        }
        history.writeln("I responded: $response");
      }
    }

    history.writeln(
      "\nBased on this conversation context, provide a relevant response that builds upon our previous discussion.",
    );
    return history.toString();
  }

  void _addToConversationHistory(String role, String message) {
    _conversationHistory.add(Content.text(message));

    // Maintain history length limit (keep recent conversations)
    while (_conversationHistory.length > _maxHistoryLength * 2) {
      // *2 for user+bot pairs
      _conversationHistory.removeAt(0);
    }
  }

  // Utility to parse *bold* and _italic_ markdown-like text
  TextSpan parseBotResponse(String text) {
    final List<InlineSpan> spans = [];
    final RegExp exp = RegExp(r'(\*\*|\*|__|_)(.+?)\1');
    int start = 0;
    final matches = exp.allMatches(text);
    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }
      final marker = match.group(1);
      final content = match.group(2);
      if (marker == '*' || marker == '**') {
        spans.add(
          TextSpan(
            text: content,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      } else if (marker == '_' || marker == '__') {
        spans.add(
          TextSpan(
            text: content,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
            ),
          ),
        );
      }
      start = match.end;
    }
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: const TextStyle(color: Colors.black),
        ),
      );
    }
    return TextSpan(
      style: const TextStyle(color: Colors.black),
      children: spans,
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_buildBotAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.green.shade600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                  bottomRight:
                      isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  isUser
                      ? Text(
                        message['text']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      )
                      : DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        child: RichText(
                          text: parseBotResponse(message['text']!),
                          textAlign: TextAlign.left,
                        ),
                      ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), _buildUserAvatar()],
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          _userAvatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.eco, color: Colors.white, size: 18),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDot(),
                const SizedBox(width: 4),
                AnimatedDot(delay: const Duration(milliseconds: 200)),
                const SizedBox(width: 4),
                AnimatedDot(delay: const Duration(milliseconds: 400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: loc.talkToHarvestBot,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    _sendMessage(_controller.text.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.eco, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Text(
                loc.harvestBot,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true, // Ensures the entire row is centered
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white, Colors.green.shade50],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return _buildMessageBubble(message, isUser);
                },
              ),
            ),
            if (_isLoading) _buildTypingIndicator(),
            _buildInputField(loc),
          ],
        ),
      ),
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final Duration delay;

  const AnimatedDot({super.key, this.delay = Duration.zero});

  @override
  AnimatedDotState createState() => AnimatedDotState();
}

class AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
