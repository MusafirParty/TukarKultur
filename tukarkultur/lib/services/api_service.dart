import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseApiUrl;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    // Add authorization header if needed
    // 'Authorization': 'Bearer $token',
  };

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Gemini AI text generation
  Future<AIResponse?> generateWithGemini(AIRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gemini/generate'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return AIResponse.fromJson(jsonData['data']);
        }
      }
      print('Gemini API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Gemini API request failed: $e');
      return null;
    }
  }

  // OpenAI text generation
  Future<AIResponse?> generateWithOpenAI(AIRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/openai/generate'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return AIResponse.fromJson(jsonData['data']);
        }
      }
      print('OpenAI API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('OpenAI API request failed: $e');
      return null;
    }
  }

  // Chat with Gemini AI
  Future<AIResponse?> chatWithGemini(List<Map<String, String>> messages, {
    String? userId,
    String? context,
  }) async {
    try {
      final requestBody = {
        'messages': messages,
        if (userId != null) 'user_id': userId,
        if (context != null) 'context': context,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/gemini/chat'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return AIResponse.fromJson(jsonData['data']);
        }
      }
      print('Gemini Chat API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Gemini Chat API request failed: $e');
      return null;
    }
  }

  // Get cultural insights (custom prompt for TukarKultur)
  Future<String?> getCulturalInsight(String topic, String? userLocation) async {
    final context = userLocation != null 
        ? 'User is located in $userLocation and interested in cultural exchange'
        : 'User is interested in cultural exchange and meetups';
    
    final request = AIRequest(
      prompt: 'Provide cultural insights about: $topic. Give practical advice for cultural exchange and meaningful connections.',
      context: context,
      userId: 'current_user', // Replace with actual user ID
      metadata: {
        'type': 'cultural_insight',
        'topic': topic,
        if (userLocation != null) 'location': userLocation,
      },
    );

    final response = await generateWithGemini(request);
    return response?.response;
  }

  // Get conversation starter suggestions
  Future<String?> getConversationStarter(String userInterests, String? partnerBackground) async {
    final prompt = partnerBackground != null
        ? 'Suggest a cultural conversation starter for someone interested in "$userInterests" meeting someone from "$partnerBackground". Make it engaging and respectful.'
        : 'Suggest a cultural conversation starter for someone interested in "$userInterests". Focus on cultural exchange topics.';

    final request = AIRequest(
      prompt: prompt,
      context: 'TukarKultur cultural exchange conversation assistance',
      metadata: {
        'type': 'conversation_starter',
        'interests': userInterests,
        if (partnerBackground != null) 'partner_background': partnerBackground,
      },
    );

    final response = await generateWithGemini(request);
    return response?.response;
  }

  // Get meetup activity suggestions
  Future<String?> getMeetupSuggestions(String location, List<String> commonInterests) async {
    final interests = commonInterests.join(', ');
    final request = AIRequest(
      prompt: 'Suggest cultural meetup activities in $location for people interested in: $interests. Provide specific, actionable suggestions.',
      context: 'TukarKultur meetup planning assistance',
      metadata: {
        'type': 'meetup_suggestions',
        'location': location,
        'interests': interests,
      },
    );

    final response = await generateWithGemini(request);
    return response?.response;
  }
}
