import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> regenerateAndSaveFcmTokenWhenLogin() async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token unavailable during login');
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('fcm_token', token);

      debugPrint('FCM token saved after login');

      // Optional:
      // Send token to your backend here.
    } catch (e, stackTrace) {
      debugPrint('FCM token regeneration failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      // IMPORTANT:
      // Do NOT throw.
      //
      // Login should continue even if FCM fails.
    }
  }

  // Future<void> initialize() async {
  //   await _requestPermission();
  //   await _getToken();
  //   _setupMessageHandlers();
  //   await _notificationService.initialize();
  // }

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
    } catch (e, stackTrace) {
      debugPrint('Local notification initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _requestPermission();
    } catch (e, stackTrace) {
      debugPrint('FCM permission request failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _getToken();
    } catch (e, stackTrace) {
      debugPrint('FCM token initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      _setupMessageHandlers();
    } catch (e, stackTrace) {
      debugPrint('FCM handlers setup failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('FCM permission: ${settings.authorizationStatus}');
    } catch (e, stackTrace) {
      debugPrint('Notification permission error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is null/empty');
        return;
      }

      debugPrint('FCM Token: $token');

      await _saveTokenToPrefs(token);
    } catch (e, stackTrace) {
      debugPrint('Failed to get FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Save FCM token to SharedPreferences
  Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('fcm_token', token);

      debugPrint('FCM token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('Failed to save FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Retrieve FCM token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ FCM token unavailable');
        return null;
      }

      await _saveTokenToPrefs(token);

      debugPrint('✅ Current FCM token: $token');

      return token;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to get FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        try {
          debugPrint('FCM foreground message received');
          debugPrint('Data: ${message.data}');

          final notification = message.notification;

          if (notification == null) {
            debugPrint('Foreground message has no notification payload');
            return;
          }

          await _showLocalNotification(notification);
        } catch (e, stackTrace) {
          debugPrint('Foreground notification error: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM onMessage stream error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        try {
          debugPrint('Notification opened: ${message.messageId}');

          _handleNotificationTap(message);
        } catch (e, stackTrace) {
          debugPrint('Notification tap error: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM onMessageOpenedApp error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification data: ${message.data}');

    final data = message.data;

    final type = data['type'];

    if (type == 'webinar') {
      // Open webinar screen
    } else if (type == 'message') {
      // Open message screen
    } else if (type == 'course') {
      // Open course screen
    }
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    await _notificationService.showNotification(
      0, // Notification ID
      notification.title ?? 'No Title',
      notification.body ?? 'No Body',
      null, // Optional payload
    );
  }
}
