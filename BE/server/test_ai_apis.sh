#!/bin/bash
# AI API Testing Script for TukarKultur
# Tests both Gemini and OpenAI endpoints

echo "🤖 Testing TukarKultur AI API endpoints..."
echo "=================================================="

# Set base URL
BASE_URL="http://localhost:8080/api/v1"

echo ""
echo "🔍 1. Testing General Health Check..."
curl -X GET $BASE_URL/health \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "=================================================="
echo "🟡 GEMINI API TESTS"
echo "=================================================="

echo "2. Testing Gemini Health Check..."
curl -X GET $BASE_URL/gemini/health \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "3. Testing Gemini Models..."
curl -X GET $BASE_URL/gemini/models \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "4. Testing Gemini Text Generation..."
curl -X POST $BASE_URL/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain the cultural significance of Batik in Indonesian heritage and its role in cultural exchange",
    "context": "TukarKultur cultural exchange platform - providing educational content about Indonesian culture",
    "user_id": "test_user_gemini",
    "metadata": {
      "feature": "cultural_education",
      "topic": "batik",
      "country": "Indonesia"
    }
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "5. Testing Gemini Chat..."
curl -X POST $BASE_URL/gemini/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "I am planning to visit Bali for cultural exchange. What are the most important cultural etiquette rules I should know?"
      }
    ],
    "user_id": "test_user_gemini",
    "context": "TukarKultur - helping travelers understand Balinese culture for respectful cultural exchange",
    "metadata": {
      "destination": "Bali",
      "trip_type": "cultural_exchange",
      "topic": "etiquette"
    }
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "=================================================="
echo "🟢 OPENAI API TESTS"
echo "=================================================="

echo "6. Testing OpenAI Health Check..."
curl -X GET $BASE_URL/openai/health \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "7. Testing OpenAI Models..."
curl -X GET $BASE_URL/openai/models \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n\n"

echo "8. Testing OpenAI Text Generation..."
curl -X POST $BASE_URL/openai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Create a brief guide for someone participating in a Japanese tea ceremony for the first time",
    "model": "gpt-3.5-turbo-instruct",
    "max_tokens": 200,
    "temperature": 0.7,
    "context": "TukarKultur cultural exchange platform - preparing users for authentic cultural experiences",
    "user_id": "test_user_openai",
    "metadata": {
      "feature": "cultural_preparation",
      "activity": "tea_ceremony",
      "country": "Japan"
    }
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "9. Testing OpenAI Chat..."
curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "I want to learn about traditional Korean food culture. Can you recommend some dishes and explain their cultural significance?"
      }
    ],
    "model": "gpt-3.5-turbo",
    "max_tokens": 250,
    "temperature": 0.8,
    "user_id": "test_user_openai",
    "context": "TukarKultur - educational platform for Korean cultural exchange and food traditions",
    "metadata": {
      "cuisine": "Korean",
      "topic": "food_culture",
      "purpose": "cultural_learning"
    }
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "10. Testing OpenAI Multi-turn Chat..."
curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "What are some important festivals in Thailand?"
      },
      {
        "role": "assistant",
        "content": "Thailand has many beautiful festivals! Some of the most important ones include Songkran (Thai New Year water festival), Loy Krathong (Festival of Lights), and Phi Ta Khon (Ghost Festival). Each has deep cultural significance."
      },
      {
        "role": "user",
        "content": "Tell me more about Songkran and how tourists should participate respectfully"
      }
    ],
    "model": "gpt-3.5-turbo",
    "max_tokens": 200,
    "temperature": 0.7,
    "user_id": "test_user_openai",
    "context": "TukarKultur - helping tourists participate respectfully in Thai cultural celebrations",
    "metadata": {
      "festival": "Songkran",
      "country": "Thailand",
      "focus": "tourist_etiquette"
    }
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "=================================================="
echo "❌ ERROR TESTING"
echo "=================================================="

echo "11. Testing Invalid Gemini Request (missing prompt)..."
curl -X POST $BASE_URL/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "context": "missing prompt field",
    "user_id": "test_error"
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "12. Testing Invalid OpenAI Request (empty messages)..."
curl -X POST $BASE_URL/openai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": []
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "=================================================="
echo "✅ Testing completed!"
echo "=================================================="
echo ""
echo "📝 Expected Status Codes:"
echo "  - 200: Successful requests"
echo "  - 400: Bad requests (error testing)"
echo "  - 500: Server errors (if API keys are invalid)"
echo ""
echo "🔑 Note: Make sure to set your API keys in the .env file:"
echo "  - GEMINI_API_KEY=your_gemini_key"
echo "  - OPENAI_API_KEY=your_openai_key"
