import 'api_service.dart';
import 'auth_service.dart';
import 'biometric_service.dart';
import 'log_service.dart';
import 'notification_service.dart';

/// Service Locator for managing service instances
/// Usage:
///
/// // Initialize once in main.dart
/// ServiceLocator.setup();
///
/// // Access services anywhere
/// final authService = ServiceLocator.authService;
/// final logService = ServiceLocator.logService;
class ServiceLocator {
  static final ApiService _apiService = ApiService();
  static late final AuthService _authService;
  static late final LogService _logService;
  static final BiometricService _biometricService = BiometricService();
  static final NotificationService _notificationService = NotificationService();

  /// Initialize all services
  static void setup() {
    _authService = AuthService(_apiService);
    _logService = LogService(_apiService);
  }

  /// Get AuthService instance
  static AuthService get authService => _authService;

  /// Get LogService instance
  static LogService get logService => _logService;

  /// Get ApiService instance (if needed directly)
  static ApiService get apiService => _apiService;

  /// Get BiometricService instance
  static BiometricService get biometricService => _biometricService;

  /// Get NotificationService instance
  static NotificationService get notificationService => _notificationService;
}
