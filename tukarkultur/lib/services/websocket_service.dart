import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chat_models.dart';
import '../config/app_config.dart';

class WebSocketService {
  // Get baseUrl dynamically at runtime
  static String get baseUrl => AppConfig.webSocketUrl;
  
  WebSocketChannel? _channel;
  StreamController<ChatMessage>? _messageController;
  String? _currentUserId;
  bool _isConnected = false;

  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Getters
  bool get isConnected => _isConnected;
  Stream<ChatMessage>? get messageStream => _messageController?.stream;

  // Connect to WebSocket
  Future<bool> connect(String userId) async {
    try {
      if (_isConnected && _currentUserId == userId) {
        return true; // Already connected with same user
      }

      // Disconnect if already connected
      await disconnect();

      _currentUserId = userId;
      _messageController = StreamController<ChatMessage>.broadcast();

      // Create WebSocket connection with user ID as query parameter
      final uri = Uri.parse('$baseUrl?id=$userId');
      _channel = WebSocketChannel.connect(uri);

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          try {
            final messageData = jsonDecode(data);
            final message = ChatMessage.fromJson(messageData);
            
            // Determine if message is from current user
            final isMe = message.sender == _currentUserId;
            final processedMessage = ChatMessage(
              sender: message.sender,
              receiver: message.receiver,
              text: message.text,
              imageUrl: message.imageUrl,
              timestamp: DateTime.now(),
              isMe: isMe,
            );

            _messageController?.add(processedMessage);
          } catch (e) {
            print('Error processing incoming message: $e');
          }
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
      print('WebSocket connected for user: $userId');
      return true;

    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _isConnected = false;
      return false;
    }
  }

  // Send message
  Future<bool> sendMessage(ChatMessage message) async {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return false;
    }

    try {
      final messageJson = jsonEncode(message.toJson());
      _channel!.sink.add(messageJson);
      
      // Add message to local stream (for sender)
      final localMessage = ChatMessage(
        sender: message.sender,
        receiver: message.receiver,
        text: message.text,
        imageUrl: message.imageUrl,
        timestamp: DateTime.now(),
        isMe: true,
      );
      _messageController?.add(localMessage);

      return true;
    } catch (e) {
      print('Failed to send message: $e');
      return false;
    }
  }

  // Send text message
  Future<bool> sendTextMessage(String receiverId, String text) async {
    if (_currentUserId == null) {
      print('User not connected');
      return false;
    }

    final message = ChatMessage(
      sender: _currentUserId!,
      receiver: receiverId,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    return await sendMessage(message);
  }

  // Send image message
  Future<bool> sendImageMessage(String receiverId, String imageUrl, {String? text}) async {
    if (_currentUserId == null) {
      print('User not connected');
      return false;
    }

    final message = ChatMessage(
      sender: _currentUserId!,
      receiver: receiverId,
      text: text ?? '',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isMe: true,
    );

    return await sendMessage(message);
  }

  // Disconnect WebSocket
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _channel?.sink.close(status.goingAway);
      await _messageController?.close();
      _channel = null;
      _messageController = null;
      _currentUserId = null;
      print('WebSocket disconnected');
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
    }
  }

  // Dispose resources
  void dispose() {
    disconnect();
  }
}
