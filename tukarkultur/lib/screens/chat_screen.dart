import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

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
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isConnecting = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Start chat session with AI welcome trigger
    final success = await _chatService.startChat(
      'current_user_id', // Replace with actual current user ID
      widget.chatPartnerId,
    );

    if (success) {
      // Listen to message updates
      _chatService.messagesStream.listen((messages) {
        setState(() {
          _messages = messages;
          _isConnecting = false;
        });
        _scrollToBottom();
      });
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

    final success = await _chatService.sendMessage(messageText);

    setState(() {
      _isTyping = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    return Scaffold(
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.location_on_outlined, color: Colors.black),
            onPressed: () => _showLocationOptions(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'cultural_insight',
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Cultural Insight'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'meetup_ideas',
                child: Row(
                  children: [
                    Icon(Icons.event, size: 20),
                    SizedBox(width: 8),
                    Text('Meetup Ideas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_ai',
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, size: 20),
                    SizedBox(width: 8),
                    Text('Toggle AI Assistant'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isConnecting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to chat...'),
                ],
              ),
            )
          : Column(
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
                  child: Column(
                    children: [
                      Row(
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Share Current Location'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement location sharing
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('View on Map'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open map view
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'cultural_insight':
        _requestCulturalInsight();
        break;
      case 'meetup_ideas':
        _requestMeetupIdeas();
        break;
      case 'toggle_ai':
        _chatService.toggleAIAssistant();
        break;
    }
  }

  void _requestCulturalInsight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cultural Insight'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter a cultural topic (e.g., food, music, traditions)',
          ),
          onSubmitted: (topic) {
            Navigator.pop(context);
            if (topic.isNotEmpty) {
              _chatService.requestCulturalInsight(topic);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _requestMeetupIdeas() {
    _chatService.requestMeetupSuggestions(
      'Your City', // Replace with actual location
      ['cultural exchange', 'food', 'music', 'art'],
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isAI = message.sender == 'AI_Assistant' || message.sender == 'System';
    final isMe = message.isMe && !isAI;
    
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
              color: isAI ? Colors.blue.shade300 : Color(0xFFE8C4A0),
            ),
            child: ClipOval(
              child: Center(
                child: Text(
                  isAI ? '🤖' : message.sender.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: isAI ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    isAI ? 'AI Assistant' : message.sender,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: isAI ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe 
                      ? Color(0xFFE6B800)
                      : isAI 
                          ? Colors.blue.shade50
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: isAI ? Border.all(color: Colors.blue.shade200) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    if (message.imageUrl != null) ...[
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.imageUrl!,
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 150,
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Icon(Icons.broken_image),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
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
            child: ClipOval(
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
