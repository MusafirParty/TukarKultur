# TukarKultur AI API Documentation

## Overview

The TukarKultur backend now supports two AI providers:
- **Gemini AI** (Google): Available at `/api/v1/gemini/*`
- **OpenAI** (ChatGPT): Available at `/api/v1/openai/*`

Both providers offer similar functionality but with different strengths and pricing models.

## Endpoint Structure

```
/api/v1/
├── gemini/
│   ├── generate     # Text generation
│   ├── chat         # Chat conversations  
│   ├── models       # Available models
│   └── health       # Health check
└── openai/
    ├── generate     # Text generation
    ├── chat         # Chat conversations
    ├── models       # Available models
    └── health       # Health check
```

## API Comparison

| Feature | Gemini | OpenAI |
|---------|---------|---------|
| **Text Generation** | ✅ Fast | ✅ Multiple models |
| **Chat** | ✅ Context-aware | ✅ System prompts |
| **Models** | Flash, Pro | GPT-3.5, GPT-4 |
| **Pricing** | Free tier available | Pay-per-token |
| **Speed** | Very fast | Fast to moderate |

## Gemini API Endpoints

### 1. Generate Text
```bash
POST /api/v1/gemini/generate
```

**Request:**
```json
{
  "prompt": "Explain Balinese Hindu ceremonies",
  "context": "Cultural education platform",
  "user_id": "user123",
  "metadata": {
    "topic": "religion",
    "region": "Bali"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "gen_uuid",
    "response": "Balinese Hindu ceremonies are...",
    "prompt": "Explain Balinese Hindu ceremonies",
    "status": "completed",
    "model": "gemini-1.5-flash-latest",
    "usage": {
      "prompt_tokens": 25,
      "completion_tokens": 150,
      "total_tokens": 175
    }
  }
}
```

### 2. Chat Conversation
```bash
POST /api/v1/gemini/chat
```

**Request:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Tell me about Korean temple etiquette"
    }
  ],
  "context": "Temple visit preparation",
  "user_id": "user123"
}
```

### 3. Available Models
```bash
GET /api/v1/gemini/models
```

### 4. Health Check
```bash
GET /api/v1/gemini/health
```

## OpenAI API Endpoints

### 1. Generate Text
```bash
POST /api/v1/openai/generate
```

**Request:**
```json
{
  "prompt": "Create a guide for Japanese tea ceremony",
  "model": "gpt-3.5-turbo-instruct",
  "max_tokens": 200,
  "temperature": 0.7,
  "context": "Cultural preparation guide",
  "user_id": "user123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "gen_uuid",
    "response": "The Japanese tea ceremony...",
    "prompt": "Create a guide for Japanese tea ceremony",
    "status": "completed",
    "model": "gpt-3.5-turbo-instruct",
    "usage": {
      "prompt_tokens": 30,
      "completion_tokens": 200,
      "total_tokens": 230
    }
  }
}
```

### 2. Chat Conversation
```bash
POST /api/v1/openai/chat
```

**Request:**
```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a cultural exchange expert"
    },
    {
      "role": "user", 
      "content": "How do I greet elders in Thai culture?"
    }
  ],
  "model": "gpt-3.5-turbo",
  "max_tokens": 150,
  "temperature": 0.8
}
```

### 3. Available Models
```bash
GET /api/v1/openai/models
```

### 4. Health Check  
```bash
GET /api/v1/openai/health
```

## Quick Test Commands

### Health Checks
```bash
# Test both services
curl -X GET http://localhost:8080/api/v1/gemini/health
curl -X GET http://localhost:8080/api/v1/openai/health
```

### Simple Text Generation
```bash
# Gemini
curl -X POST http://localhost:8080/api/v1/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello world!"}'

# OpenAI  
curl -X POST http://localhost:8080/api/v1/openai/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello world!", "model": "gpt-3.5-turbo-instruct"}'
```

### Cultural Exchange Examples
```bash
# Ask about Indonesian culture (Gemini)
curl -X POST http://localhost:8080/api/v1/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What should I know about Indonesian hospitality customs?",
    "context": "TukarKultur cultural exchange preparation"
  }'

# Ask about Japanese business culture (OpenAI)
curl -X POST http://localhost:8080/api/v1/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Explain Japanese business card exchange etiquette"}
    ],
    "model": "gpt-3.5-turbo",
    "context": "Business cultural preparation"
  }'
```

## Running Tests

### Complete Test Suite
```bash
cd /home/kyomoto/TukarKultur/BE/server
./test_ai_apis.sh
```

### Individual Commands
See `CURL_TESTS.md` for comprehensive test commands.

## Environment Setup

1. **Add API Keys to `.env`:**
```bash
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
```

2. **Get API Keys:**
   - **Gemini**: [Google AI Studio](https://aistudio.google.com/app/apikey)
   - **OpenAI**: [OpenAI Platform](https://platform.openai.com/api-keys)

3. **Start Server:**
```bash
go run server.go
```

## Error Handling

Both APIs return consistent error formats:

```json
{
  "error": "Error description",
  "details": "Detailed error message"
}
```

Common errors:
- `400`: Missing required fields
- `401`: Invalid API key
- `500`: Service unavailable

## Use Cases for TukarKultur

### Cultural Education
- Generate cultural guides and explanations
- Create etiquette recommendations
- Explain cultural practices and traditions

### Language Assistance  
- Help with language barriers
- Provide translation context
- Explain cultural nuances in communication

### Travel Preparation
- Create destination-specific cultural guides
- Generate appropriate behavior recommendations
- Explain local customs and traditions

### Community Interaction
- Facilitate cross-cultural conversations
- Generate ice-breaker questions
- Help resolve cultural misunderstandings

## Model Recommendations

### For Speed (Real-time Chat)
- **Gemini**: `gemini-1.5-flash-latest`
- **OpenAI**: `gpt-3.5-turbo`

### For Quality (Detailed Content)
- **Gemini**: `gemini-1.5-pro-latest`  
- **OpenAI**: `gpt-4`

### For Cost Efficiency
- **Gemini**: Free tier available
- **OpenAI**: `gpt-3.5-turbo-instruct`
