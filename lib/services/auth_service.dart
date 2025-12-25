import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Initialize auth service - load saved token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken != null) {
      _apiService.setToken(savedToken);
    }
  }

  // Register new user
  Future<UserResponse> register(UserRegisterRequest request) async {
    try {
      final response = await _apiService.post(
        '/api/users/register',
        request.toJson(),
      );
      return UserResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  Future<LoginResponse> login(UserLoginRequest request) async {
    try {
      final response = await _apiService.post(
        '/api/users/login',
        request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response);

      // Save token in ApiService and persist
      _apiService.setToken(loginResponse.token);
      await _saveToken(loginResponse.token);

      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.post(
        '/api/users/logout',
        {},
        requiresAuth: false,
      );

      // Clear token from ApiService and storage
      _apiService.clearToken();
      await _clearToken();
    } catch (e) {
      // Even if request fails, clear local token
      _apiService.clearToken();
      await _clearToken();
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    // First check in-memory token
    if (_apiService.token != null) {
      return true;
    }
    // Then check persisted token
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken != null) {
      _apiService.setToken(savedToken);
      return true;
    }
    return false;
  }

  // Save token to persistent storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token from persistent storage
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get current token
  String? getToken() {
    return _apiService.token;
  }

  // Request password reset with new password
  Future<Map<String, dynamic>> requestPasswordReset({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/users/reset_request',
        {
          'username': username,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return response ?? {'message': 'Reset request submitted successfully'};
    } catch (e) {
      rethrow;
    }
  }
}
