class AppConfig {
  // Backend API Configuration
  static const String baseApiUrl = 'http://localhost:8080/api/v1';
  static const String webSocketUrl = 'ws://localhost:8080/api/v1/chat';
  
  // For production, update these URLs:
  // static const String baseApiUrl = 'https://your-api.com/api/v1';
  // static const String webSocketUrl = 'wss://your-api.com/api/v1/chat';
  
  // AI Configuration
  static const bool enableAI = true;
  static const String defaultAIProvider = 'gemini'; // 'gemini' or 'openai'
  
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
