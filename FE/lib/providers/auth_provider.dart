import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    await _authService.initialize();
    
    _currentUser = _authService.currentUser;
    _isLoggedIn = _authService.isLoggedIn;
    
    _setLoading(false);
  }

    // Login
  Future<AuthResult> login(LoginRequest request) async {
    _setLoading(true);
    
    try {
      final result = await _authService.login(request);
      
      // ADD THESE DEBUG PRINTS
      print('🔍 Login result debug:');
      print('🔍 result.success: ${result.success}');
      print('🔍 result.user: ${result.user}');
      print('🔍 result.user?.id: ${result.user?.id}');
      
      if (result.success) {
        _currentUser = result.user;
        _isLoggedIn = true;
        
        // ADD MORE DEBUG
        print('🔍 AuthProvider after login:');
        print('🔍 _currentUser: $_currentUser');
        print('🔍 _currentUser?.id: ${_currentUser?.id}');
        
        notifyListeners();
      }
      
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<AuthResult> register(RegisterRequest request) async {
    _setLoading(true);
    
    try {
      final result = await _authService.register(request);
      
      if (result.success) {
        _currentUser = result.user;
        _isLoggedIn = true;
        notifyListeners();
      }
      
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    await _authService.logout();
    
    _currentUser = null;
    _isLoggedIn = false;
    
    _setLoading(false);
    notifyListeners();
  }

  // Update profile
  Future<AuthResult> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    
    try {
      final result = await _authService.updateProfile(updates);
      
      if (result.success) {
        _currentUser = result.user;
        notifyListeners();
      }
      
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<bool> refreshUserData() async {
    final success = await _authService.refreshUserData();
    
    if (success) {
      _currentUser = _authService.currentUser;
      notifyListeners();
    }
    
    return success;
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
