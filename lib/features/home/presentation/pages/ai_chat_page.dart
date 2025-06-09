import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../core/constants/app_constants.dart';

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
  String _userAvatarUrl = '';

  // Context-aware memory variables
  final List<Content> _conversationHistory = [];
  final int _maxHistoryLength = 10; // Keep last 10 exchanges for context
  // Session storage constants and variables for performance optimization
  static const String _chatSessionKey = 'harvesthub_chat_session';
  static const int _maxMessagesInSession = 50; // Limit for low-end devices
  static const int _saveThrottleMs = 1000; // Throttle save operations

  // Performance optimization variables
  bool _isSessionLoaded = false;
  DateTime _lastSaveTime = DateTime.now();
  bool _hasPendingSave = false; // Track if we have unsaved changes
  @override
  void initState() {
    super.initState();
    _initializeUserAvatar();
    _loadChatSession(); // Load previous session first
  }

  // Load chat session from SharedPreferences with error handling
  Future<void> _loadChatSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatData = prefs.getString(_chatSessionKey);

      if (chatData != null && chatData.isNotEmpty) {
        final List<dynamic> decodedMessages = json.decode(chatData);
        final List<Map<String, String>> loadedMessages =
            decodedMessages
                .map((msg) => Map<String, String>.from(msg))
                .toList();

        if (mounted) {
          setState(() {
            _messages.addAll(loadedMessages);
            _isSessionLoaded = true;
          });
        }

        // Rebuild conversation history from loaded messages
        _rebuildConversationHistory();
      } else {
        // No previous session, add welcome message
        _addWelcomeMessage();
        if (mounted) {
          setState(() {
            _isSessionLoaded = true;
          });
        }
      }
    } catch (e) {
      // If loading fails, start with welcome message
      // Failed to load chat session: $e
      _addWelcomeMessage();
      if (mounted) {
        setState(() {
          _isSessionLoaded = true;
        });
      }
    }
  }

  // Add welcome message
  void _addWelcomeMessage() {
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

  // Save chat session with throttling and size limits for performance
  Future<void> _saveChatSession() async {
    try {
      // Throttle saves to avoid excessive I/O on low-end devices
      final now = DateTime.now();
      if (now.difference(_lastSaveTime).inMilliseconds < _saveThrottleMs) {
        _hasPendingSave = true;
        return;
      }
      _lastSaveTime = now;
      _hasPendingSave = false;

      // Limit messages to prevent memory bloat on low-end devices
      final messagesToSave =
          _messages.length > _maxMessagesInSession
              ? _messages.sublist(_messages.length - _maxMessagesInSession)
              : _messages;

      final prefs = await SharedPreferences.getInstance();
      final String encodedMessages = json.encode(messagesToSave);

      // Only save if data has changed to reduce I/O operations
      final existingData = prefs.getString(_chatSessionKey);
      if (existingData != encodedMessages) {
        await prefs.setString(_chatSessionKey, encodedMessages);
      }
    } catch (e) {
      // Silently handle save errors to not disrupt user experience
      // Failed to save chat session: $e
    }
  }

  // Rebuild conversation history from loaded messages efficiently
  void _rebuildConversationHistory() {
    _conversationHistory.clear();

    // Take last few message pairs to rebuild context efficiently
    final int startIndex = _messages.length > 10 ? _messages.length - 10 : 0;

    for (int i = startIndex; i < _messages.length; i++) {
      final message = _messages[i];
      if (message['sender'] == 'user' || message['sender'] == 'ai') {
        _conversationHistory.add(Content.text(message['text']!));
      }
    }
  }

  // Clear chat session
  Future<void> _clearChatSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatSessionKey);

      if (mounted) {
        setState(() {
          _messages.clear();
          _conversationHistory.clear();
        });
      }

      // Add welcome message back
      _addWelcomeMessage();
      await _saveChatSession();
    } catch (e) {
      // Failed to clear chat session: $e
    }
  }

  // Get session size for debugging/monitoring (optional)
  int getSessionSizeKB() {
    try {
      final String encoded = json.encode(_messages);
      return (encoded.length / 1024).round();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _initializeUserAvatar() async {
    try {
      // Get the current user's phone number as the ID for consistent avatar
      final userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? 'user';
      final avatarUrl = await AvatarUtils.getAvatarWithFallback(userId: userId);

      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _userAvatarUrl = avatarUrl;
        });
      }
    } catch (e) {
      // Fallback to default avatar if there's an error
      if (mounted) {
        setState(() {
          _userAvatarUrl = 'https://avatar.iran.liara.run/public/1';
        });
      }
    }
  }

  Future<void> _sendMessage(String userMessage) async {
    if (mounted) {
      setState(() {
        _messages.add({'sender': 'user', 'text': userMessage});
        _isLoading = true;
      });
    }

    // Save session after adding user message
    await _saveChatSession();

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
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': responseText});
          _isLoading = false;
        });
      }

      // Add bot response to conversation history
      _addToConversationHistory('model', responseText);

      // Save session after AI response
      await _saveChatSession();

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
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': 'Error: $e'});
          _isLoading = false;
        });
      }
      // Save even error messages
      await _saveChatSession();
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
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_buildBotAvatar(), const SizedBox(width: 10)],
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
                color: isUser ? AppConstants.primaryGreen : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                  bottomRight:
                      isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                ),
                border:
                    isUser
                        ? null
                        : Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child:
                  isUser
                      ? Text(
                        message['text']!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      : DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        child: RichText(
                          text: parseBotResponse(message['text']!),
                          textAlign: TextAlign.left,
                        ),
                      ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 10), _buildUserAvatar()],
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
        border: Border.all(color: AppConstants.primaryGreen, width: 2),
        color: Colors.white,
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
              decoration: const BoxDecoration(
                color: AppConstants.primaryGreen,
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
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryGreen,
                  ),
                ),
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
      decoration: const BoxDecoration(
        color: AppConstants.primaryGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.eco, color: Colors.white, size: 18),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Colors.grey.shade200, width: 1),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: loc.talkToHarvestBot,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppConstants.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
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
    // Set system UI overlay style for consistent navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              loc.harvestBot,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.black87,
                size: 18,
              ),
            ),
            onPressed: () async {
              // Show confirmation dialog
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text(
                      'Are you sure you want to clear the chat history?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              );

              if (shouldClear == true) {
                await _clearChatSession();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isSessionLoaded
                    ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['sender'] == 'user';
                        return _buildMessageBubble(message, isUser);
                      },
                    )
                    : const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryGreen,
                      ),
                    ),
          ),
          if (_isLoading) _buildTypingIndicator(),
          _buildInputField(loc),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Save any pending changes before disposing
    if (_hasPendingSave) {
      _saveChatSession();
    }
    super.dispose();
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
          color: AppConstants.primaryGreen,
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
