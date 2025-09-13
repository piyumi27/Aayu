import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/notification.dart';
import '../database_service.dart';
import '../firebase_initialization_service.dart';
import 'local_notification_service.dart';

/// Expert-level Push Notification Service
/// Handles Firebase Cloud Messaging (FCM) integration
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseInitializationService _firebaseService = FirebaseInitializationService();

  bool _isInitialized = false;
  String? _fcmToken;
  Function(RemoteMessage)? _onMessageReceived;
  Function(RemoteMessage)? _onMessageOpenedApp;

  /// Initialize push notification service
  Future<void> initialize({
    Function(RemoteMessage)? onMessageReceived,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_isInitialized) return;

    // Check if Firebase is initialized
    if (!_firebaseService.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Firebase not initialized, push notifications will not work');
      }
      return;
    }

    _onMessageReceived = onMessageReceived;
    _onMessageOpenedApp = onMessageOpenedApp;

    try {
      // Initialize Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Handle initial message (app opened from notification)
      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Push Notification Service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Push Notification Service initialization failed: $e');
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (_firebaseMessaging == null) return;

    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('📱 Notification permission status: ${settings.authorizationStatus}');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      if (_firebaseMessaging == null) return;

      _fcmToken = await _firebaseMessaging!.getToken();

      if (_fcmToken != null) {
        // Store token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);

        // Store token in database
        await _storeFCMToken(_fcmToken!);

        if (kDebugMode) {
          print('🔑 FCM Token: $_fcmToken');
        }
      }

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;

        // Update stored token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);

        // Update token in database
        await _storeFCMToken(newToken);

        if (kDebugMode) {
          print('🔑 FCM Token refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
      }
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Configure background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 Foreground message received: ${message.messageId}');
    }

    // Store message in database
    _storeRemoteMessage(message, 'foreground');

    // Show local notification
    _localNotificationService.showNotificationFromRemote(message);

    // Call custom handler if provided
    _onMessageReceived?.call(message);
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 App opened from notification: ${message.messageId}');
    }

    // Store interaction in database
    _storeNotificationInteraction(message.messageId ?? '', 'opened');

    // Call custom handler if provided
    _onMessageOpenedApp?.call(message);
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (_firebaseMessaging == null) return;

      await _firebaseMessaging!.subscribeToTopic(topic);

      // Store subscription
      final prefs = await SharedPreferences.getInstance();
      final topics = prefs.getStringList('fcm_topics') ?? [];
      if (!topics.contains(topic)) {
        topics.add(topic);
        await prefs.setStringList('fcm_topics', topics);
      }

      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to subscribe to topic: $e');
      }
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_firebaseMessaging == null) return;

      await _firebaseMessaging!.unsubscribeFromTopic(topic);

      // Remove subscription
      final prefs = await SharedPreferences.getInstance();
      final topics = prefs.getStringList('fcm_topics') ?? [];
      topics.remove(topic);
      await prefs.setStringList('fcm_topics', topics);

      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to unsubscribe from topic: $e');
      }
    }
  }

  /// Send notification to specific user (requires server implementation)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically call your server API to send the notification
    // The server would use Firebase Admin SDK to send the message

    if (kDebugMode) {
      print('📤 Notification request for user: $userId');
    }
  }

  /// Send notification to topic (requires server implementation)
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically call your server API to send the notification
    // The server would use Firebase Admin SDK to send the message

    if (kDebugMode) {
      print('📤 Notification request for topic: $topic');
    }
  }

  /// Store FCM token in database
  Future<void> _storeFCMToken(String token) async {
    try {
      final db = await _databaseService.database;

      // Check if token already exists
      final existing = await db.query(
        'fcm_tokens',
        where: 'token = ?',
        whereArgs: [token],
      );

      if (existing.isEmpty) {
        await db.insert('fcm_tokens', {
          'token': token,
          'isActive': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        await db.update(
          'fcm_tokens',
          {
            'isActive': 1,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          where: 'token = ?',
          whereArgs: [token],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store FCM token: $e');
      }
    }
  }

  /// Store remote message in database
  Future<void> _storeRemoteMessage(RemoteMessage message, String context) async {
    try {
      final db = await _databaseService.database;

      await db.insert('push_notifications', {
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': jsonEncode(message.data),
        'sentTime': message.sentTime?.toIso8601String(),
        'context': context,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store remote message: $e');
      }
    }
  }

  /// Store notification interaction
  Future<void> _storeNotificationInteraction(String messageId, String action) async {
    try {
      final db = await _databaseService.database;

      await db.insert('notification_interactions', {
        'messageId': messageId,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store notification interaction: $e');
      }
    }
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Background message received: ${message.messageId}');
  }

  // Initialize services if needed
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  // Show notification
  await localNotificationService.showNotificationFromRemote(message);
}