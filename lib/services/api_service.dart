import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.18.8:8080';

  String? _token;

  // Getter for token
  String? get token => _token;

  // Setter for token
  void setToken(String? token) {
    _token = token;
  }

  // Clear token (logout)
  void clearToken() {
    _token = null;
  }

  // Get headers with optional auth
  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      final error = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Unknown error'};
      throw ApiException(
        statusCode: response.statusCode,
        message: error['message'] ?? error['error'] ?? 'Request failed',
      );
    }
  }

  // GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(includeAuth: requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // GET request with query parameters
  Future<dynamic> getWithParams(
    String endpoint,
    Map<String, String> queryParams, {
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(
        uri,
        headers: _getHeaders(includeAuth: requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}
