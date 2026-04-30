import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import '../../../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Check if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        // TODO: Validate token with backend
        // For now, we'll just keep the user logged in
        final userId = prefs.getString('user_id');
        final userEmail = prefs.getString('user_email');
        final userName = prefs.getString('user_name');
        
        if (userId != null && userEmail != null) {
          _currentUser = User(
            id: userId,
            email: userEmail,
            name: userName ?? '',
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call backend API for login
      // Simulating login for now
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_id', 'user_123');
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', 'User');

      _currentUser = User(
        id: 'user_123',
        email: email,
        name: 'User',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Call backend API for registration
      // Simulating registration for now
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_id', 'user_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');

      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
