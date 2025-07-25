class ChatMessage {
  final String sender;
  final String receiver;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      timestamp: DateTime.now(), // WebSocket doesn't send timestamp
      isMe: false, // Will be determined in service
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}

class AIRequest {
  final String prompt;
  final String? context;
  final String? userId;
  final Map<String, String>? metadata;

  AIRequest({
    required this.prompt,
    this.context,
    this.userId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      if (context != null) 'context': context,
      if (userId != null) 'user_id': userId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class AIResponse {
  final String id;
  final String response;
  final String prompt;
  final String status;
  final String model;

  AIResponse({
    required this.id,
    required this.response,
    required this.prompt,
    required this.status,
    required this.model,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'] ?? '',
      response: json['response'] ?? '',
      prompt: json['prompt'] ?? '',
      status: json['status'] ?? '',
      model: json['model'] ?? '',
    );
  }
}
