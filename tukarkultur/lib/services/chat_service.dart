import 'dart:async';
import '../models/chat_models.dart';
import 'api_service.dart';
import 'websocket_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();
  
  // Chat state
  final List<ChatMessage> _messages = [];
  final StreamController<List<ChatMessage>> _messagesController = 
      StreamController<List<ChatMessage>>.broadcast();
  
  String? _currentUserId;
  String? _chatPartnerId;
  bool _isAIAssistantEnabled = true;

  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal() {
    _initializeWebSocketListener();
  }

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  bool get isConnected => _webSocketService.isConnected;

  // Initialize WebSocket message listener
  void _initializeWebSocketListener() {
    _webSocketService.messageStream?.listen((message) {
      _addMessage(message);
    });
  }

  // Start chat session
  Future<bool> startChat(String currentUserId, String chatPartnerId) async {
    _currentUserId = currentUserId;
    _chatPartnerId = chatPartnerId;
    
    // Connect to WebSocket
    final connected = await _webSocketService.connect(currentUserId);
    
    if (connected) {
      // Trigger AI assistant welcome message
      await _triggerAIWelcome();
    }
    
    return connected;
  }

  // Add message to local list and notify listeners
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _messagesController.add(List.from(_messages));
  }

  // Send text message
  Future<bool> sendMessage(String text) async {
    if (_currentUserId == null || _chatPartnerId == null) {
      return false;
    }

    // Send via WebSocket
    final success = await _webSocketService.sendTextMessage(_chatPartnerId!, text);
    
    if (success && _isAIAssistantEnabled) {
      // Trigger AI response after a delay
      Timer(Duration(seconds: 2), () => _triggerAIResponse(text));
    }
    
    return success;
  }

  // Send image message
  Future<bool> sendImageMessage(String imageUrl, {String? text}) async {
    if (_currentUserId == null || _chatPartnerId == null) {
      return false;
    }

    return await _webSocketService.sendImageMessage(
      _chatPartnerId!, 
      imageUrl, 
      text: text,
    );
  }

  // Trigger AI welcome message
  Future<void> _triggerAIWelcome() async {
    try {
      // Get conversation starter from AI
      final aiResponse = await _apiService.getConversationStarter(
        'cultural exchange, travel, local traditions',
        'international background',
      );

      if (aiResponse != null) {
        // Add AI message to chat
        final aiMessage = ChatMessage(
          sender: 'AI_Assistant',
          receiver: _currentUserId!,
          text: '🤖 Welcome to TukarKultur! Here\'s a great conversation starter:\n\n$aiResponse',
          timestamp: DateTime.now(),
          isMe: false,
        );
        
        _addMessage(aiMessage);
      }
    } catch (e) {
      print('Failed to trigger AI welcome: $e');
    }
  }

  // Trigger AI response based on user message
  Future<void> _triggerAIResponse(String userMessage) async {
    try {
      // Determine response type based on message content
      String? aiResponse;

      if (userMessage.toLowerCase().contains(RegExp(r'\b(meet|meetup|activity|do|plan)\b'))) {
        // Meetup suggestion
        aiResponse = await _apiService.getMeetupSuggestions(
          'your location', // Replace with actual location
          ['cultural exchange', 'food', 'music'],
        );
        aiResponse = '💡 Meetup Suggestion:\n\n$aiResponse';
        
      } else if (userMessage.toLowerCase().contains(RegExp(r'\b(culture|tradition|custom|food|music|festival)\b'))) {
        // Cultural insight
        final topic = _extractTopicFromMessage(userMessage);
        aiResponse = await _apiService.getCulturalInsight(topic, 'Indonesia');
        aiResponse = '🌍 Cultural Insight:\n\n$aiResponse';
        
      } else if (userMessage.length < 20) {
        // Short message - provide conversation starter
        aiResponse = await _apiService.getConversationStarter(
          'general cultural topics',
          null,
        );
        aiResponse = '💬 Try this topic:\n\n$aiResponse';
      }

      // Send AI response if generated
      if (aiResponse != null) {
        final aiMessage = ChatMessage(
          sender: 'AI_Assistant',
          receiver: _currentUserId!,
          text: aiResponse,
          timestamp: DateTime.now(),
          isMe: false,
        );
        
        _addMessage(aiMessage);
      }
    } catch (e) {
      print('Failed to trigger AI response: $e');
    }
  }

  // Extract topic from user message
  String _extractTopicFromMessage(String message) {
    final culturalWords = [
      'food', 'music', 'dance', 'festival', 'tradition', 'custom',
      'religion', 'language', 'art', 'history', 'culture', 'wedding',
      'holiday', 'celebration', 'ceremony'
    ];
    
    final messageLower = message.toLowerCase();
    for (final word in culturalWords) {
      if (messageLower.contains(word)) {
        return word;
      }
    }
    
    return 'cultural exchange';
  }

  // Request specific AI assistance
  Future<void> requestCulturalInsight(String topic) async {
    final response = await _apiService.getCulturalInsight(topic, 'user_location');
    
    if (response != null) {
      final aiMessage = ChatMessage(
        sender: 'AI_Assistant',
        receiver: _currentUserId!,
        text: '🌍 Cultural Insight about $topic:\n\n$response',
        timestamp: DateTime.now(),
        isMe: false,
      );
      
      _addMessage(aiMessage);
    }
  }

  // Request meetup suggestions
  Future<void> requestMeetupSuggestions(String location, List<String> interests) async {
    final response = await _apiService.getMeetupSuggestions(location, interests);
    
    if (response != null) {
      final aiMessage = ChatMessage(
        sender: 'AI_Assistant',
        receiver: _currentUserId!,
        text: '💡 Meetup Ideas for $location:\n\n$response',
        timestamp: DateTime.now(),
        isMe: false,
      );
      
      _addMessage(aiMessage);
    }
  }

  // Toggle AI assistant
  void toggleAIAssistant() {
    _isAIAssistantEnabled = !_isAIAssistantEnabled;
    
    final statusMessage = ChatMessage(
      sender: 'System',
      receiver: _currentUserId!,
      text: _isAIAssistantEnabled 
          ? '🤖 AI Assistant enabled' 
          : '🤖 AI Assistant disabled',
      timestamp: DateTime.now(),
      isMe: false,
    );
    
    _addMessage(statusMessage);
  }

  // Clear chat
  void clearChat() {
    _messages.clear();
    _messagesController.add([]);
  }

  // End chat session
  Future<void> endChat() async {
    await _webSocketService.disconnect();
    _currentUserId = null;
    _chatPartnerId = null;
    clearChat();
  }

  // Dispose resources
  void dispose() {
    _webSocketService.dispose();
    _messagesController.close();
  }
}
