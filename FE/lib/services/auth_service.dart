import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  String? _authToken;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize auth service - call this at app startup
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved token
      _authToken = prefs.getString(_tokenKey);
      
      if (_authToken != null) {
        // Set token in API service
        _apiService.setAuthToken(_authToken);
        
        // Load saved user data
        final userJson = prefs.getString(_userKey);
        if (userJson != null) {
          _currentUser = User.fromJson(jsonDecode(userJson));
        }
        
        // Validate token with server
        final isValid = await _apiService.validateToken();
        if (isValid) {
          _isLoggedIn = true;
          
          // Refresh user data if we only have cached data
          if (_currentUser == null) {
            await _refreshUserData();
          }
        } else {
          // Token is invalid, clear auth state
          await _clearAuthState();
        }
      }
    } catch (e) {
      print('Auth service initialization failed: $e');
      await _clearAuthState();
    }
  }

  // Register new user
  Future<AuthResult> register(RegisterRequest request) async {
    try {
      final response = await _apiService.register(request);
      
      if (response != null) {
        await _saveAuthState(response.token, response.user);
        return AuthResult.success(response.user, response.message);
      }
      
      return AuthResult.failure('Registration failed');
    } on AuthError catch (e) {
      return AuthResult.failure(e.toString());
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResult> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request);
      
      if (response != null) {
        await _saveAuthState(response.token, response.user);
        return AuthResult.success(response.user, response.message);
      }
      
      return AuthResult.failure('Login failed');
    } on AuthError catch (e) {
      return AuthResult.failure(e.toString());
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      await _clearAuthState();
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (!_isLoggedIn) {
        return AuthResult.failure('User not logged in');
      }

      final updatedUser = await _apiService.updateProfile(updates);
      
      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveUserData(updatedUser);
        return AuthResult.success(updatedUser, 'Profile updated successfully');
      }
      
      return AuthResult.failure('Profile update failed');
    } catch (e) {
      return AuthResult.failure('Profile update failed: ${e.toString()}');
    }
  }

  // Refresh user data
  Future<bool> refreshUserData() async {
    return await _refreshUserData();
  }

  // Private methods

  Future<bool> _refreshUserData() async {
    try {
      final user = await _apiService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        await _saveUserData(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Refresh user data failed: $e');
      return false;
    }
  }

  Future<void> _saveAuthState(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _authToken = token;
      _currentUser = user;
      _isLoggedIn = true;
      
      // Set token in API service
      _apiService.setAuthToken(token);
      
      // Save to persistent storage
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Save auth state failed: $e');
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUser = user;
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Save user data failed: $e');
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _authToken = null;
      _currentUser = null;
      _isLoggedIn = false;
      
      // Clear from API service
      _apiService.clearAuthToken();
      
      // Clear from persistent storage
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('Clear auth state failed: $e');
    }
  }
}

// Result class for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String message;

  AuthResult.success(this.user, this.message) : success = true;
  AuthResult.failure(this.message) : success = false, user = null;
}
