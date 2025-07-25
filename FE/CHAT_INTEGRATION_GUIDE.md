# TukarKultur Flutter Chat Integration Setup

## Overview
This implementation integrates the TukarKultur Flutter frontend with the Go backend, featuring:
- Real-time WebSocket chat
- AI-powered conversation assistance (Gemini & OpenAI)
- Cultural insights and meetup suggestions
- Auto-triggered AI welcome messages

## Quick Setup

### 1. Install Dependencies
```bash
cd tukarkultur
flutter pub get
```

### 2. Update Backend URLs
Edit `lib/config/app_config.dart`:
```dart
// For local development
static const String baseApiUrl = 'http://localhost:8080/api/v1';
static const String webSocketUrl = 'ws://localhost:8080/api/v1/chat';

// For production
static const String baseApiUrl = 'https://your-api.com/api/v1';
static const String webSocketUrl = 'wss://your-api.com/api/v1/chat';
```

### 3. Start Backend Server
```bash
cd BE/server
go run server.go
```

### 4. Test Chat Integration
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      chatPartnerId: 'partner_user_id',
      chatPartnerName: 'Partner Name',
      chatPartnerDistance: '1.2 km away',
    ),
  ),
);
```

## Features Implemented

### 🔄 Real-time Chat
- WebSocket connection to backend
- Message sending/receiving
- Connection status handling
- Auto-reconnection on failure

### 🤖 AI Integration
- **Welcome Message**: AI greets users when chat starts
- **Smart Responses**: AI responds based on message keywords
- **Cultural Insights**: Request AI advice on cultural topics
- **Meetup Suggestions**: Get AI-powered activity recommendations
- **Conversation Starters**: AI suggests discussion topics

### 🎯 AI Trigger Patterns
- **"meet", "meetup", "activity"** → Meetup suggestions
- **"culture", "tradition", "food", "music"** → Cultural insights  
- **Short messages** → Conversation starters
- **Chat start** → Welcome message with ice-breaker

### 🎛️ User Controls
- Toggle AI assistant on/off
- Request specific cultural insights
- Get meetup ideas for location
- Share location
- View chat partner on map

## File Structure

```
lib/
├── config/
│   └── app_config.dart          # Configuration settings
├── models/
│   └── chat_models.dart         # Data models
├── services/
│   ├── api_service.dart         # HTTP API communication
│   ├── websocket_service.dart   # WebSocket management
│   └── chat_service.dart        # Combined chat logic
├── screens/
│   └── chat_screen.dart         # Chat UI with AI integration
└── examples/
    └── chat_example.dart        # Usage examples
```

## Backend API Endpoints Used

### Chat WebSocket
- `ws://localhost:8080/api/v1/chat?id=user_id`

### AI Endpoints
- `POST /api/v1/gemini/generate` - Text generation
- `POST /api/v1/gemini/chat` - Conversation
- `POST /api/v1/openai/generate` - Alternative AI provider

## Customization

### AI Behavior
Edit `chat_service.dart` to modify:
- Response triggers and keywords
- AI personality and tone
- Cultural context and suggestions

### UI Appearance
Edit `chat_screen.dart` to customize:
- Message bubble styling
- AI message indicators
- Color scheme and fonts

### Configuration
Edit `app_config.dart` for:
- Server URLs
- Timeout settings
- Default interests and topics

## Error Handling

The implementation includes:
- Connection failure detection
- Retry mechanisms
- User-friendly error messages
- Fallback for offline scenarios

## Testing

1. **Backend Connection**: Check health endpoint
2. **WebSocket**: Test real-time messaging
3. **AI Integration**: Verify AI responses
4. **Error Scenarios**: Test network failures

## Production Deployment

1. Update `app_config.dart` with production URLs
2. Configure HTTPS/WSS endpoints
3. Add authentication tokens
4. Enable proper error logging
5. Test with production AI API keys

## Next Steps

1. **Authentication**: Integrate user login/tokens
2. **Persistence**: Save chat history locally
3. **Push Notifications**: Add background message alerts
4. **File Sharing**: Implement image/document uploads
5. **Offline Mode**: Cache messages for offline viewing

## Troubleshooting

### Connection Issues
- Verify backend server is running
- Check firewall/network settings
- Confirm WebSocket URL format

### AI Not Responding
- Check API keys in backend
- Verify AI service endpoints
- Review request/response logs

### Messages Not Sending
- Check WebSocket connection status
- Verify user ID format
- Test with simple text messages first
