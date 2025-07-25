import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/simple_chat_service.dart';
import '../services/api_service.dart';
import 'chat_feedback_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatPartnerId;
  final String chatPartnerName;
  final String? chatPartnerDistance;

  const ChatScreen({
    Key? key,
    required this.chatPartnerId,
    required this.chatPartnerName,
    this.chatPartnerDistance,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SimpleChatService _chatService = SimpleChatService();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<ChatMessage> _messages = [];
  bool _isConnecting = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _addCulturalWelcomeMessage(); // Add this immediately
  }

  Future<void> _addCulturalWelcomeMessage() async {
    print('🔍 DEBUG: Starting _addCulturalWelcomeMessage');

    _addLocalMessage(
      ChatMessage(
        sender: 'AI Assistant',
        receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text:
            '🤖 Welcome! Let me share some cultural insights about ${widget.chatPartnerName}...',
        timestamp: DateTime.now(),
        isMe: false,
      ),
    );

    try {
      print('🔍 DEBUG: About to call _getCulturalInsight');
      final culturalInsight = await _getCulturalInsight();
      print(
        '🔍 DEBUG: Cultural insight result length: ${culturalInsight.length}',
      );
      print('🔍 DEBUG: Cultural insight content: "$culturalInsight"');

      _addLocalMessage(
        ChatMessage(
          sender: 'AI Assistant',
          receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text: culturalInsight,
          timestamp: DateTime.now(),
          isMe: false,
        ),
      );
    } catch (e, stackTrace) {
      print('🚨 ERROR in _addCulturalWelcomeMessage: $e');
      print('🚨 Stack trace: $stackTrace');
      _addLocalMessage(
        ChatMessage(
          sender: 'AI Assistant',
          receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text:
              '🌍 ${widget.chatPartnerName} is interested in cultural exchange! Here are some great conversation topics:\n\n• Ask about their local food traditions\n• Share your favorite cultural festivals\n• Discuss music from your regions\n• Exchange language learning tips\n• Talk about traditional arts and crafts',
          timestamp: DateTime.now(),
          isMe: false,
        ),
      );
    }
  }

  Future<String> _getCulturalInsight() async {
    print('🔍 DEBUG: Entering _getCulturalInsight');

    final culturalPrompt =
        '''
Based on the name "${widget.chatPartnerName}", provide cultural insights and interesting facts about their likely cultural background. Include:

1. Possible cultural traditions
2. Common greetings or phrases
3. Popular foods or dishes
4. Cultural values or customs
5. Interesting cultural facts

Keep it respectful, educational, and focused on cultural exchange. Make it conversational and engaging for someone wanting to connect cross-culturally.

If the name doesn't clearly indicate a specific culture, provide general tips for cross-cultural communication and common conversation topics for cultural exchange.
''';

    try {
      print('🔍 DEBUG: Creating AIRequest');
      final aiRequest = AIRequest(
        prompt: culturalPrompt,
        context:
            'TukarKultur cultural exchange platform - helping users connect across cultures',
        metadata: {
          'type': 'cultural_insight',
          'partner_name': widget.chatPartnerName,
        },
      );
      print('🔍 DEBUG: AIRequest created successfully');

      print('🔍 DEBUG: Calling _apiService.generateWithOpenAI');
      final response = await _apiService.generateWithOpenAI(aiRequest);
      print('🔍 DEBUG: API call completed');
      print('🔍 DEBUG: Response object: $response');

      if (response == null) {
        print('🚨 ERROR: Response is null - using fallback');
        return _getFallbackCulturalInsight();
      }

      print('🔍 DEBUG: Response.response field: "${response.response}"');
      print('🔍 DEBUG: Response.response length: ${response.response.length}');

      if (response.response.isEmpty) {
        print('🚨 ERROR: Response.response is empty - using fallback');
        return _getFallbackCulturalInsight();
      }

      print('🔍 DEBUG: Returning successful response');
      return response.response;
    } catch (e, stackTrace) {
      print('🚨 ERROR: Exception in _getCulturalInsight: $e');
      print('🚨 Stack trace: $stackTrace');
      return _getFallbackCulturalInsight();
    }
  }

  Future<String> _getConversationStarter() async {
    final starterPrompt =
        '''
Suggest 3-4 engaging conversation starters for someone wanting to chat with ${widget.chatPartnerName} for cultural exchange. Make them:

1. Respectful and culturally sensitive
2. Fun and engaging
3. Educational but not overwhelming
4. Focused on cultural sharing and learning

Format as a numbered list with brief explanations.
''';

    try {
      final response = await _apiService.generateWithOpenAI(
        AIRequest(
          prompt: starterPrompt,
          context: 'TukarKultur cultural exchange conversation starters',
          metadata: {
            'type': 'conversation_starter',
            'partner_name': widget.chatPartnerName,
          },
        ),
      );

      return response?.response ?? _getFallbackConversationStarters();
    } catch (e) {
      print('OpenAI conversation starter failed: $e');
      return _getFallbackConversationStarters();
    }
  }

  String _getFallbackCulturalInsight() {
    return '''
🌍 Great to see you connecting with ${widget.chatPartnerName} for cultural exchange!

Cultural exchange is a wonderful way to:
• Learn about different traditions and customs
• Practice languages and communication
• Share your own cultural experiences
• Build meaningful international friendships
• Expand your worldview

Every culture has unique stories, foods, festivals, and perspectives to share. Be curious, ask questions, and don't be afraid to share your own cultural background too!
''';
  }

  String _getFallbackConversationStarters() {
    return '''
1. "What's a traditional dish from your culture that you'd love to share with someone?"

2. "Are there any festivals or celebrations in your culture that are really special to you?"

3. "What's something about your culture that you think people often misunderstand?"

4. "If you could teach someone one phrase in your language, what would it be and why?"
''';
  }

  void _addLocalMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  Future<void> _initializeChat() async {
    // Start chat session
    final success = await _chatService.startChat(
      'user_${DateTime.now().millisecondsSinceEpoch}', // Generate a simple user ID
      widget.chatPartnerId,
    );

    if (success) {
      // Listen to message updates from WebSocket
      _chatService.messagesStream.listen((webSocketMessages) {
        // Merge WebSocket messages with local AI messages
        setState(() {
          // Keep AI messages and add WebSocket messages
          final aiMessages = _messages
              .where((msg) => msg.sender == 'AI Assistant')
              .toList();
          final wsMessages = webSocketMessages
              .where((msg) => msg.sender != 'AI Assistant')
              .toList();
          _messages = [...aiMessages, ...wsMessages]
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _isConnecting = false;
        });
        _scrollToBottom();
      });

      // Add connection success message
      await Future.delayed(Duration(seconds: 2));
      _addLocalMessage(
        ChatMessage(
          sender: 'System',
          receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text:
              '✅ Chat connected! You can now send messages to ${widget.chatPartnerName}.',
          timestamp: DateTime.now(),
          isMe: false,
        ),
      );
    } else {
      setState(() {
        _isConnecting = false;
      });
      _showConnectionError();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConnectionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to connect to chat. Please try again.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initializeChat,
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });

    // Send via WebSocket if connected
    final success = await _chatService.sendMessage(messageText);

    // If WebSocket fails, add as local message
    if (!success) {
      _addLocalMessage(
        ChatMessage(
          sender: 'user_${DateTime.now().millisecondsSinceEpoch}',
          receiver: widget.chatPartnerId, // Fixed: was chatPartnererId
          text: messageText,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );

      // Try to get an AI response to the message
      _tryAIResponse(messageText);
    }

    setState(() {
      _isTyping = false;
    });
  }

  Future<void> _tryAIResponse(String userMessage) async {
    try {
      final aiPrompt =
          '''
The user said: "$userMessage"

Respond as a helpful cultural exchange assistant. If they're asking about culture, provide insights. If they're being conversational, respond encouragingly and suggest cultural topics. Keep responses concise and engaging.
''';

      final response = await _apiService.generateWithOpenAI(
        AIRequest(
          prompt: aiPrompt,
          context:
              'TukarKultur cultural exchange assistant responding to user message',
          metadata: {'type': 'chat_response', 'user_message': userMessage},
        ),
      );

      if (response != null) {
        await Future.delayed(Duration(seconds: 1));
        _addLocalMessage(
          ChatMessage(
            sender: 'AI Assistant',
            receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
            text: '🤖 ${response.response}',
            timestamp: DateTime.now(),
            isMe: false,
          ),
        );
      }
    } catch (e) {
      print('AI response failed: $e');
    }
  }

  void _onCloseChat(BuildContext context) {
    // Navigate to feedback screen instead of directly going back
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatFeedbackScreen(
          chatPartnerName: widget.chatPartnerName,
          chatPartnerId: widget.chatPartnerId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatService.endChat();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onCloseChat(context);
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              Text(
                widget.chatPartnerName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (widget.chatPartnerDistance != null)
                Text(
                  widget.chatPartnerDistance!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showChatOptions(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildMessage(message),
                  );
                },
              ),
            ),
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(width: 8),
                    Text('Sending...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // End of WillPopScope child (Scaffold)
    ); // End of WillPopScope
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Get Cultural Tips'),
              subtitle: Text('Ask AI for more cultural insights'),
              onTap: () {
                Navigator.pop(context);
                _askForMoreCulturalTips();
              },
            ),
            ListTile(
              leading: Icon(Icons.translate),
              title: Text('Language Help'),
              subtitle: Text('Get help with language exchange'),
              onTap: () {
                Navigator.pop(context);
                _askForLanguageHelp();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Chat Info'),
              subtitle: Text('Connected to ${widget.chatPartnerName}'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('End Chat'),
              onTap: () {
                _onCloseChat(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _askForMoreCulturalTips() async {
    _addLocalMessage(
      ChatMessage(
        sender: 'AI Assistant',
        receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: '🤖 Getting more cultural insights for your conversation...',
        timestamp: DateTime.now(),
        isMe: false,
      ),
    );

    final tips = await _getCulturalInsight();
    _addLocalMessage(
      ChatMessage(
        sender: 'AI Assistant',
        receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: tips,
        timestamp: DateTime.now(),
        isMe: false,
      ),
    );
  }

  void _askForLanguageHelp() async {
    _addLocalMessage(
      ChatMessage(
        sender: 'AI Assistant',
        receiver: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: '''
🗣️ Language Exchange Tips:

• Start with simple greetings in each other's languages
• Share common phrases you use daily
• Explain cultural context behind certain expressions
• Practice pronunciation by describing how words sound
• Be patient and encouraging with each other's attempts
• Use voice messages if your app supports it
• Share songs or media in your languages

Remember: Making mistakes is part of learning! 😊
''',
        timestamp: DateTime.now(),
        isMe: false,
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isSystem = message.sender == 'System';
    final isAI = message.sender == 'AI Assistant';
    final isMe = message.isMe && !isSystem && !isAI;

    if (isSystem) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(fontSize: 12, color: Colors.green.shade700),
          ),
        ),
      );
    }

    if (isAI) {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.blue.shade600, size: 16),
                SizedBox(width: 4),
                Text(
                  'AI Cultural Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              message.text,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8C4A0),
            ),
            child: Center(
              child: Text(
                message.sender.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.sender,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? Color(0xFFE6B800) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8C4A0),
            ),
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
