# TukarKultur AI API Testing Commands

## Base URL
BASE_URL="http://localhost:8080/api/v1"

## General Health Check
curl -X GET $BASE_URL/health

## GEMINI API ENDPOINTS

### 1. Gemini Health Check
curl -X GET $BASE_URL/gemini/health

### 2. Gemini Models
curl -X GET $BASE_URL/gemini/models

### 3. Gemini Text Generation
curl -X POST $BASE_URL/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain the importance of cultural sensitivity when traveling to Southeast Asia",
    "context": "TukarKultur cultural exchange guidance",
    "user_id": "user123",
    "metadata": {
      "region": "Southeast Asia",
      "topic": "cultural_sensitivity"
    }
  }'

### 4. Gemini Chat
curl -X POST $BASE_URL/gemini/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "I want to learn about Indonesian traditional music. Where should I start?"
      }
    ],
    "user_id": "user123",
    "context": "Learning about Indonesian culture through TukarKultur",
    "metadata": {
      "country": "Indonesia",
      "interest": "traditional_music"
    }
  }'

## OPENAI API ENDPOINTS

### 5. OpenAI Health Check
curl -X GET $BASE_URL/openai/health

### 6. OpenAI Models
curl -X GET $BASE_URL/openai/models

### 7. OpenAI Text Generation
curl -X POST $BASE_URL/openai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a beginner-friendly introduction to Japanese calligraphy and its cultural significance",
    "model": "gpt-3.5-turbo-instruct",
    "max_tokens": 200,
    "temperature": 0.7,
    "context": "TukarKultur educational content for cultural exchange",
    "user_id": "user123",
    "metadata": {
      "art_form": "calligraphy",
      "country": "Japan"
    }
  }'

### 8. OpenAI Chat
curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "I am hosting a guest from India. What are some important cultural considerations for hospitality?"
      }
    ],
    "model": "gpt-3.5-turbo",
    "max_tokens": 200,
    "temperature": 0.8,
    "user_id": "user123",
    "context": "TukarKultur hospitality guidance for cross-cultural hosting",
    "metadata": {
      "guest_origin": "India",
      "scenario": "hosting"
    }
  }'

### 9. OpenAI Advanced Chat with GPT-4
curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "system",
        "content": "You are a cultural exchange expert helping people understand and respect different cultures."
      },
      {
        "role": "user",
        "content": "What are the key differences between formal and informal communication styles in business settings across different cultures?"
      }
    ],
    "model": "gpt-4",
    "max_tokens": 300,
    "temperature": 0.6,
    "user_id": "user123",
    "context": "TukarKultur business cultural intelligence",
    "metadata": {
      "context": "business_communication",
      "focus": "cross_cultural"
    }
  }'

## COMPARISON TESTING

### 10. Same Prompt to Both APIs for Comparison

#### Gemini Version
curl -X POST $BASE_URL/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Describe the role of food in bringing people together across different cultures",
    "context": "TukarKultur cultural bonding through cuisine"
  }'

#### OpenAI Version  
curl -X POST $BASE_URL/openai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Describe the role of food in bringing people together across different cultures",
    "model": "gpt-3.5-turbo-instruct",
    "context": "TukarKultur cultural bonding through cuisine"
  }'

## ERROR TESTING

### Invalid Requests
curl -X POST $BASE_URL/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{"context": "missing prompt"}'

curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{"messages": []}'

## QUICK TEST COMMANDS

### Quick Gemini Test
curl -X POST $BASE_URL/gemini/generate -H "Content-Type: application/json" -d '{"prompt": "Hello, introduce yourself!"}'

### Quick OpenAI Test
curl -X POST $BASE_URL/openai/generate -H "Content-Type: application/json" -d '{"prompt": "Hello, introduce yourself!", "model": "gpt-3.5-turbo-instruct"}'

### Health Checks Only
curl -X GET $BASE_URL/gemini/health && echo && curl -X GET $BASE_URL/openai/health
