import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_locator.dart';

class NotificationService {
  static const String _notificationsKey = 'saved_notifications';
  static const String _fcmTokenKey = 'fcm_token';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize notification service
  Future<void> init() async {
    // Request permission
    await requestPermission();

    // Get FCM token
    final token = await getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      // Send new token to server if user is logged in
      await sendTokenToServer(newToken);
    });
  }

  /// Send FCM token to backend server
  Future<bool> sendTokenToServer(String? token) async {
    if (token == null) return false;

    try {
      // Check if user is logged in
      final isLoggedIn = await ServiceLocator.authService.isLoggedIn();
      if (!isLoggedIn) {
        if (kDebugMode) {
          print('User not logged in, skipping FCM token upload');
        }
        return false;
      }

      // Send token to backend
      await ServiceLocator.apiService.post(
        '/api/users/fcm-token',
        {'fcm_token': token},
        requiresAuth: true,
      );

      // Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);

      if (kDebugMode) {
        print('FCM token sent to server successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send FCM token to server: $e');
      }
      return false;
    }
  }

  /// Register FCM token after login
  Future<void> registerTokenAfterLogin() async {
    final fcmToken = await getToken();
    if (fcmToken == null) {
      if (kDebugMode) {
        print('FCM token is null, cannot register');
      }
      return;
    }

    // Debug: check if JWT token is set
    final jwtToken = ServiceLocator.apiService.token;
    if (kDebugMode) {
      print(
          'JWT token in ApiService: ${jwtToken != null ? "SET (${jwtToken.substring(0, 20)}...)" : "NULL"}');
    }

    if (jwtToken == null) {
      if (kDebugMode) {
        print('JWT token is null, cannot send FCM token');
      }
      return;
    }

    try {
      // Directly send token without checking isLoggedIn (we know user just logged in)
      await ServiceLocator.apiService.post(
        '/api/users/fcm-token',
        {'fcm_token': fcmToken},
        requiresAuth: true,
      );

      // Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, fcmToken);

      if (kDebugMode) {
        print('FCM token registered successfully after login');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register FCM token after login: $e');
      }
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Save notification to local storage
  Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getSavedNotifications();

    final notification = {
      'id':
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'New Notification',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    notifications.insert(0, notification);

    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }

    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Get saved notifications
  Future<List<Map<String, dynamic>>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getSavedNotifications();

    for (var notification in notifications) {
      if (notification['id'] == id) {
        notification['read'] = true;
        break;
      }
    }

    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getSavedNotifications();

    for (var notification in notifications) {
      notification['read'] = true;
    }

    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getSavedNotifications();

    notifications.removeWhere((n) => n['id'] == id);

    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final notifications = await getSavedNotifications();
    return notifications.where((n) => n['read'] == false).length;
  }
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Save notification when app is in background/terminated
  final service = NotificationService();
  await service.saveNotification(message);
}
