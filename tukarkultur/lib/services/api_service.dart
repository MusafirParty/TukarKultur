import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';
import '../models/auth_models.dart';
import '../config/app_config.dart';

class ApiService {
  // Get baseUrl dynamically at runtime
  static String get baseUrl => AppConfig.baseApiUrl;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Authentication token
  String? _authToken;

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get current auth token
  String? get authToken => _authToken;

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
        Uri.parse('${AppConfig.baseApiUrl}/openai/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AIResponse.fromJson(jsonData);
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('OpenAI generation error: $e');
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

  // AUTHENTICATION METHODS

    // User registration
  Future<AuthResponse?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        // Backend returns: {"token": "...", "user": {...}, "message": "..."}
        if (jsonData['token'] != null && jsonData['user'] != null) {
          final authResponse = AuthResponse.fromJson(jsonData);
          setAuthToken(authResponse.token);
          return authResponse;
        }
      }
      
      // Handle error response
      if (response.statusCode >= 400) {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData);
      }
      
      return null;
    } catch (e) {
      if (e is AuthError) rethrow;
      print('Registration failed: $e');
      throw AuthError(error: 'Registration failed', details: e.toString());
    }
  }

  // User login
  Future<AuthResponse?> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Backend returns: {"token": "...", "user": {...}, "message": "..."}
        if (jsonData['token'] != null && jsonData['user'] != null) {
          final authResponse = AuthResponse.fromJson(jsonData);
          setAuthToken(authResponse.token);
          return authResponse;
        }
      }
      
      // Handle error response
      if (response.statusCode >= 400) {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData);
      }
      
      return null;
    } catch (e) {
      if (e is AuthError) rethrow;
      print('Login failed: $e');
      throw AuthError(error: 'Login failed', details: e.toString());
    }
  }

  // User logout
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      );

      // Clear token regardless of response
      clearAuthToken();
      
      return response.statusCode == 200;
    } catch (e) {
      print('Logout failed: $e');
      // Still clear token on error
      clearAuthToken();
      return false;
    }
  }

  // Get current user profile
  Future<User?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return User.fromJson(jsonData['data']);
        }
      }
      
      // If unauthorized, clear token
      if (response.statusCode == 401) {
        clearAuthToken();
      }
      
      return null;
    } catch (e) {
      print('Get current user failed: $e');
      return null;
    }
  }

  // Update user profile
  Future<User?> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return User.fromJson(jsonData['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Update profile failed: $e');
      return null;
    }
  }

  // Validate token
  Future<bool> validateToken() async {
    if (_authToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        clearAuthToken();
        return false;
      }
      
      return false;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }
}
