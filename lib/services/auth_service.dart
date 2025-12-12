import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

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

      // Save token in ApiService
      _apiService.setToken(loginResponse.token);

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

      // Clear token from ApiService
      _apiService.clearToken();
    } catch (e) {
      // Even if request fails, clear local token
      _apiService.clearToken();
      rethrow;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _apiService.token != null;
  }

  // Get current token
  String? getToken() {
    return _apiService.token;
  }
}
