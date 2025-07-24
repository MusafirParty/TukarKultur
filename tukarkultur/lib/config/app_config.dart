import 'dart:io';

class AppConfig {
  // Backend API Configuration
  // Dynamic URL based on platform
  static String get baseApiUrl {
    if (Platform.isAndroid) {
      // For containerized environment, use the machine's IP
      // If using standard Android emulator, change to 10.0.2.2
      return 'http://172.24.2.221:3000/api/v1';
    } else if (Platform.isIOS) {
      // For iOS simulator, localhost works
      return 'http://localhost:3000/api/v1';
    } else {
      // For desktop (Linux, Windows, macOS)
      return 'http://localhost:3000/api/v1';
    }
  }
  
  static String get webSocketUrl {
    if (Platform.isAndroid) {
      return 'ws://172.24.2.221:3000/api/v1/chat';
    } else if (Platform.isIOS) {
      return 'ws://localhost:3000/api/v1/chat';
    } else {
      return 'ws://localhost:3000/api/v1/chat';
    }
  }
  
  // AI Configuration - CHANGED TO OPENAI
  static const bool enableAI = true;
  static const String defaultAIProvider = 'openai'; // Changed from 'gemini' to 'openai'
  
  // Chat Configuration
  static const int messageTimeout = 30; // seconds
  static const int reconnectDelay = 5; // seconds
  static const bool autoScrollToNewMessages = true;
  
  // Cultural Context for AI
  static const Map<String, String> culturalContext = {
    'platform': 'TukarKultur cultural exchange platform',
    'purpose': 'Facilitate meaningful cultural connections and meetups',
    'tone': 'Friendly, respectful, and culturally sensitive',
  };
  
  // Default interests for AI suggestions
  static const List<String> defaultInterests = [
    'cultural exchange',
    'local food',
    'traditional music',
    'festivals',
    'history',
    'language learning',
    'art',
    'travel',
  ];
  
  // Meetup suggestion categories
  static const List<String> meetupCategories = [
    'Food & Dining',
    'Cultural Sites',
    'Festivals & Events',
    'Art & Museums',
    'Music & Dance',
    'Language Exchange',
    'Outdoor Activities',
    'Religious Sites',
  ];
}
