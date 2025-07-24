import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart';
import '../config/app_config.dart';

class SimpleChatService {
  WebSocketChannel? _channel;
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  String? _currentUserId;
  String? _chatPartnerId;

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  bool get isConnected => _isConnected;

  Future<bool> startChat(String userId, String partnerId) async {
    try {
      _currentUserId = userId;
      _chatPartnerId = partnerId;
      
      // Connect to WebSocket
      final wsUrl = '${AppConfig.webSocketUrl}?id=$userId';
      print('Connecting to: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );

      _isConnected = true;
      
      // Add a welcome message
      _addMessage(ChatMessage(
        sender: 'System',
        receiver: userId,
        text: 'Chat connected! Start your conversation with $partnerId.',
        timestamp: DateTime.now(),
        isMe: false,
      ));

      return true;
    } catch (e) {
      print('Failed to start chat: $e');
      return false;
    }
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data);
      final message = ChatMessage.fromJson(jsonData);
      _addMessage(message);
    } catch (e) {
      print('Failed to parse incoming message: $e');
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _messagesController.add(List.from(_messages));
  }

  Future<bool> sendMessage(String text) async {
    if (!_isConnected || _channel == null || _currentUserId == null || _chatPartnerId == null) {
      return false;
    }

    try {
      final message = {
        'sender': _currentUserId,
        'receiver': _chatPartnerId,
        'text': text,
        'image_url': null,
      };

      // Add to local messages immediately
      _addMessage(ChatMessage(
        sender: _currentUserId!,
        receiver: _chatPartnerId!,
        text: text,
        timestamp: DateTime.now(),
        isMe: true,
      ));

      // Send via WebSocket
      _channel!.sink.add(jsonEncode(message));
      return true;
    } catch (e) {
      print('Failed to send message: $e');
      return false;
    }
  }

  void endChat() {
    _channel?.sink.close();
    _isConnected = false;
    _messagesController.close();
  }
}