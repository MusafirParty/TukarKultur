# Gemini AI Agent Integration

This directory contains the Gemini AI agent integration for the TukarKultur backend API.

## Features

- **Text Generation**: Generate text responses using Google's Gemini AI
- **Chat Conversations**: Handle multi-turn conversations with context
- **Model Management**: Support for multiple Gemini models
- **Error Handling**: Comprehensive error handling and validation
- **Rate Limiting**: Built-in timeout and request management

## API Endpoints

### Generate Text
```
POST /api/v1/ai/generate
```

Request body:
```json
{
  "prompt": "Tell me about Indonesian culture",
  "context": "Cultural exchange platform",
  "user_id": "optional-user-id",
  "metadata": {
    "session_id": "session-123"
  }
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "response-uuid",
    "response": "Generated text response...",
    "prompt": "Tell me about Indonesian culture",
    "status": "completed",
    "model": "gemini-1.5-flash-latest",
    "usage": {
      "prompt_tokens": 15,
      "completion_tokens": 150,
      "total_tokens": 165
    }
  }
}
```

### Chat Conversation
```
POST /api/v1/ai/chat
```

Request body:
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello, I'm interested in learning about Balinese culture"
    },
    {
      "role": "model",
      "content": "I'd be happy to help you learn about Balinese culture..."
    },
    {
      "role": "user",
      "content": "What are some traditional festivals?"
    }
  ],
  "user_id": "optional-user-id",
  "context": "Cultural exchange platform",
  "metadata": {
    "conversation_id": "conv-123"
  }
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "chat-uuid",
    "messages": [
      // All messages including the new AI response
    ],
    "response": "Traditional Balinese festivals include...",
    "status": "completed",
    "model": "gemini-1.5-flash-latest",
    "usage": {
      "prompt_tokens": 50,
      "completion_tokens": 120,
      "total_tokens": 170
    }
  }
}
```

### Get Available Models
```
GET /api/v1/ai/models
```

Response:
```json
{
  "success": true,
  "data": {
    "models": [
      {
        "id": "gemini-1.5-flash-latest",
        "name": "Gemini 1.5 Flash",
        "description": "Fast and efficient text generation model",
        "type": "text-generation"
      },
      {
        "id": "gemini-1.5-pro-latest",
        "name": "Gemini 1.5 Pro",
        "description": "Advanced text generation with enhanced reasoning",
        "type": "text-generation"
      }
    ]
  }
}
```

### Health Check
```
GET /api/v1/ai/health
```

Response:
```json
{
  "status": "ok",
  "service": "Gemini AI Agent",
  "version": "1.0.0"
}
```

## Setup

1. **Get a Gemini API Key**:
   - Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Create a new API key
   - Copy the key to your environment variables

2. **Environment Variables**:
   ```bash
   GEMINI_API_KEY=your_gemini_api_key_here
   GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta
   ```

3. **Start the Server**:
   ```bash
   cd BE/server
   go run server.go
   ```

## Usage Examples

### Simple Text Generation
```bash
curl -X POST http://localhost:8080/api/v1/ai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain the significance of Batik in Indonesian culture"
  }'
```

### Chat Conversation
```bash
curl -X POST http://localhost:8080/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "I want to learn about traditional Indonesian food"
      }
    ]
  }'
```

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid request format or missing required fields
- `500 Internal Server Error`: Issues with the Gemini API or server

Example error response:
```json
{
  "error": "Invalid request format",
  "details": "Prompt is required"
}
```

## Integration with TukarKultur

This Gemini agent can be used to:

1. **Cultural Information**: Provide information about different cultures and traditions
2. **Language Translation**: Help with language barriers in cultural exchange
3. **Recommendation Engine**: Suggest cultural activities and meetups
4. **Chat Assistant**: Facilitate conversations between users from different cultures
5. **Content Generation**: Create educational content about cultural topics

## Rate Limits and Best Practices

- The service has a 30-second timeout for API requests
- Use the `context` field to provide relevant background information
- Keep prompts concise but descriptive
- Use the chat endpoint for multi-turn conversations
- Monitor token usage to optimize costs

## Development

The Gemini integration consists of:

- **Models** (`models/gemini.go`): Request/response structures
- **Service** (`services/gemini_service.go`): Core API integration logic
- **Handler** (`handlers/gemini_handler.go`): HTTP request handling
- **Routes** (`routes/routes.go`): API endpoint routing
