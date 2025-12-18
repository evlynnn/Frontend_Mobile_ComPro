import 'api_service.dart';

/// Model for Face User
class FaceUser {
  final String name;
  final String role;
  final int numSamples;

  FaceUser({
    required this.name,
    required this.role,
    required this.numSamples,
  });

  factory FaceUser.fromJson(Map<String, dynamic> json) {
    return FaceUser(
      name: json['name'] ?? '',
      role: json['role'] ?? 'Guest',
      numSamples: json['num_samples'] ?? 1,
    );
  }
}

/// Response for list users
class FaceUsersResponse {
  final bool success;
  final int totalUsers;
  final List<FaceUser> users;

  FaceUsersResponse({
    required this.success,
    required this.totalUsers,
    required this.users,
  });

  factory FaceUsersResponse.fromJson(Map<String, dynamic> json) {
    final usersList = (json['users'] as List<dynamic>?)
            ?.map((u) => FaceUser.fromJson(u as Map<String, dynamic>))
            .toList() ??
        [];

    return FaceUsersResponse(
      success: json['success'] ?? false,
      totalUsers: json['total_users'] ?? usersList.length,
      users: usersList,
    );
  }
}

/// Response for enroll/add sample operations
class FaceEnrollResponse {
  final bool success;
  final String message;
  final FaceUser? user;
  final String? error;

  FaceEnrollResponse({
    required this.success,
    required this.message,
    this.user,
    this.error,
  });

  factory FaceEnrollResponse.fromJson(Map<String, dynamic> json) {
    return FaceEnrollResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null
          ? FaceUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

/// Response for delete operation
class FaceDeleteResponse {
  final bool success;
  final String message;
  final String? error;

  FaceDeleteResponse({
    required this.success,
    required this.message,
    this.error,
  });

  factory FaceDeleteResponse.fromJson(Map<String, dynamic> json) {
    return FaceDeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }
}

/// Service for Face User Management
class FaceUserService {
  final ApiService _apiService;

  FaceUserService(this._apiService);

  /// Get all enrolled face users
  Future<FaceUsersResponse> listUsers() async {
    try {
      final response = await _apiService.get(
        '/api/faces',
        requiresAuth: true,
      );
      return FaceUsersResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Enroll new user with base64 images
  /// [name] - User name (will be lowercased)
  /// [images] - List of base64 encoded images
  /// [role] - Optional role (e.g., "Aslab", "Guest")
  Future<FaceEnrollResponse> enrollUser({
    required String name,
    required List<String> images,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'images': images,
      };

      if (role != null && role.isNotEmpty) {
        body['role'] = role;
      }

      final response = await _apiService.post(
        '/api/faces/enroll',
        body,
        requiresAuth: true,
      );
      return FaceEnrollResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Enroll user from single captured image (webcam snapshot)
  /// [name] - User name
  /// [image] - Base64 encoded image
  /// [role] - Optional role
  Future<FaceEnrollResponse> enrollFromCapture({
    required String name,
    required String image,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'image': image,
      };

      if (role != null && role.isNotEmpty) {
        body['role'] = role;
      }

      final response = await _apiService.post(
        '/api/faces/enroll/capture',
        body,
        requiresAuth: true,
      );
      return FaceEnrollResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user from face database
  /// [name] - User name to delete
  Future<FaceDeleteResponse> deleteUser(String name) async {
    try {
      final response = await _apiService.delete(
        '/api/faces/$name',
        requiresAuth: true,
      );
      return FaceDeleteResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Add more face samples to existing user
  /// [name] - User name
  /// [image] - Base64 encoded image
  Future<FaceEnrollResponse> addSample({
    required String name,
    required String image,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/faces/$name/add-sample',
        {'image': image},
        requiresAuth: true,
      );
      return FaceEnrollResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
