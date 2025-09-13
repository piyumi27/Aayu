import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/child.dart';
import '../../models/notification.dart';
import '../database_service.dart';
import 'local_notification_service.dart';

/// Expert-level Push Notification Service with FCM integration
/// Handles foreground, background, and terminated app states
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final DatabaseService _databaseService = DatabaseService();

  String? _fcmToken;
  bool _isInitialized = false;

  FirebaseMessaging get firebaseMessaging {
    _firebaseMessaging ??= FirebaseMessaging.instance;
    return _firebaseMessaging!;
  }
  
  // Notification handlers
  Function(RemoteMessage)? _foregroundMessageHandler;
  Function(RemoteMessage)? _backgroundMessageHandler;
  Function(RemoteMessage)? _onMessageOpenedAppHandler;

  /// Initialize Firebase Cloud Messaging with comprehensive setup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ensure Firebase is initialized
      await Firebase.initializeApp();
      
      // Request notification permissions
      await _requestPermissions();
      
      // Get FCM token
      await _getFCMToken();
      
      // Setup message handlers
      await _setupMessageHandlers();
      
      // Setup notification channels
      await _setupNotificationChannels();
      
      // Handle notification taps when app is terminated
      await _handleTerminatedAppNotifications();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ Push Notification Service initialized successfully');
        print('📱 FCM Token: $_fcmToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Push Notification Service initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Request notification permissions with comprehensive setup
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('🔔 Notification permission status: ${settings.authorizationStatus}');
    }

    // Additional iOS setup
    if (Platform.isIOS) {
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Get and store FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await firebaseMessaging.getToken();
      
      if (_fcmToken != null) {
        // Store token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
        
        // Store in database for sync
        await _storeFCMTokenInDatabase(_fcmToken!);
      }
      
      // Listen for token refresh
      firebaseMessaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);
        await _storeFCMTokenInDatabase(newToken);
        
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
      }
    }
  }

  /// Store FCM token in database for backend communication
  Future<void> _storeFCMTokenInDatabase(String token) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'notification_tokens',
        {
          'id': 'fcm_token',
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store FCM token in database: $e');
      }
    }
  }

  /// Setup comprehensive message handlers for all app states
  Future<void> _setupMessageHandlers() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background messages (app in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// Handle foreground messages (app is active)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 Foreground message received: ${message.messageId}');
      print('📱 Title: ${message.notification?.title}');
      print('💬 Body: ${message.notification?.body}');
      print('📊 Data: ${message.data}');
    }

    // Process the message
    await _processNotificationMessage(message);
    
    // Show local notification for foreground messages
    await _localNotificationService.showNotificationFromRemote(message);
    
    // Store in database
    await _storeNotificationInDatabase(message, 'foreground');
    
    // Call custom handler if set
    _foregroundMessageHandler?.call(message);
  }

  /// Handle background messages (app opened from notification)
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('🔄 Background message opened: ${message.messageId}');
    }

    // Process the message
    await _processNotificationMessage(message);
    
    // Store in database
    await _storeNotificationInDatabase(message, 'background_opened');
    
    // Navigate to appropriate screen based on notification data
    await _handleNotificationNavigation(message);
    
    // Call custom handler if set
    _backgroundMessageHandler?.call(message);
  }

  /// Handle notifications when app is terminated
  Future<void> _handleTerminatedAppNotifications() async {
    RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      if (kDebugMode) {
        print('🚀 App opened from terminated state via notification: ${initialMessage.messageId}');
      }
      
      // Process the message
      await _processNotificationMessage(initialMessage);
      
      // Store in database
      await _storeNotificationInDatabase(initialMessage, 'terminated_opened');
      
      // Handle navigation
      await _handleNotificationNavigation(initialMessage);
      
      // Call custom handler if set
      _onMessageOpenedAppHandler?.call(initialMessage);
    }
  }

  /// Process notification message and extract health data
  Future<void> _processNotificationMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      final notificationType = data['type'] ?? 'general';
      
      switch (notificationType) {
        case 'health_alert':
          await _processHealthAlert(data);
          break;
        case 'vaccination_reminder':
          await _processVaccinationReminder(data);
          break;
        case 'growth_check':
          await _processGrowthCheckReminder(data);
          break;
        case 'milestone_check':
          await _processMilestoneCheckReminder(data);
          break;
        case 'feeding_reminder':
          await _processFeedingReminder(data);
          break;
        case 'medication_reminder':
          await _processMedicationReminder(data);
          break;
        default:
          await _processGeneralNotification(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing notification message: $e');
      }
    }
  }

  /// Process health alert notifications
  Future<void> _processHealthAlert(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final alertType = data['alertType'];
    final severity = data['severity'];
    
    if (childId != null) {
      // Update local health alert status
      await _updateHealthAlertStatus(childId, alertType, severity);
      
      // Trigger local follow-up notifications if needed
      if (severity == 'critical') {
        await _scheduleFollowUpAlerts(childId, alertType);
      }
    }
  }

  /// Process vaccination reminder notifications
  Future<void> _processVaccinationReminder(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final vaccineId = data['vaccineId'];
    final dueDate = data['dueDate'];
    
    if (childId != null && vaccineId != null) {
      await _updateVaccinationReminder(childId, vaccineId, dueDate);
    }
  }

  /// Process growth check reminder notifications
  Future<void> _processGrowthCheckReminder(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final checkType = data['checkType'] ?? 'routine';
    
    if (childId != null) {
      await _scheduleGrowthCheckReminder(childId, checkType);
    }
  }

  /// Process milestone check reminder notifications
  Future<void> _processMilestoneCheckReminder(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final milestoneType = data['milestoneType'];
    
    if (childId != null) {
      await _scheduleMilestoneCheckReminder(childId, milestoneType);
    }
  }

  /// Process feeding reminder notifications
  Future<void> _processFeedingReminder(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final feedingType = data['feedingType'];
    
    if (childId != null) {
      await _processFeedingSchedule(childId, feedingType);
    }
  }

  /// Process medication reminder notifications
  Future<void> _processMedicationReminder(Map<String, dynamic> data) async {
    final childId = data['childId'];
    final medicationId = data['medicationId'];
    
    if (childId != null) {
      await _updateMedicationStatus(childId, medicationId);
    }
  }

  /// Process general notifications
  Future<void> _processGeneralNotification(Map<String, dynamic> data) async {
    // Handle general app notifications
    final category = data['category'] ?? 'general';
    final action = data['action'];
    
    if (action != null) {
      await _handleGeneralAction(action, data);
    }
  }

  /// Store notification in local database for history and analytics
  Future<void> _storeNotificationInDatabase(RemoteMessage message, String receivedState) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();
      await db.insert('notification_history', {
        'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'push', // Required NOT NULL field
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': jsonEncode(message.data),
        'receivedState': receivedState,
        'receivedAt': now,
        'createdAt': now, // Required NOT NULL field
        'isProcessed': 1,
        'isRead': receivedState == 'foreground' ? 0 : 1,
        'isShown': 1, // Assuming push notifications are shown when received
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store notification in database: $e');
      }
    }
  }

  /// Handle navigation based on notification data
  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final data = message.data;
    final route = data['route'];
    final childId = data['childId'];
    
    if (route != null) {
      // This would typically use your app's navigation service
      // For now, we'll store the navigation intent
      await _storeNavigationIntent(route, childId, data);
    }
  }

  /// Setup notification channels for Android
  Future<void> _setupNotificationChannels() async {
    await _localNotificationService.createNotificationChannels();
  }

  /// Subscribe to topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to subscribe to topic $topic: $e');
      }
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to unsubscribe from topic $topic: $e');
      }
    }
  }

  /// Set custom message handlers
  void setForegroundMessageHandler(Function(RemoteMessage) handler) {
    _foregroundMessageHandler = handler;
  }

  void setBackgroundMessageHandler(Function(RemoteMessage) handler) {
    _backgroundMessageHandler = handler;
  }

  void setOnMessageOpenedAppHandler(Function(RemoteMessage) handler) {
    _onMessageOpenedAppHandler = handler;
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Helper methods for notification processing (implementation stubs)
  Future<void> _updateHealthAlertStatus(String childId, String alertType, String severity) async {
    // Implementation would update local health alert status
  }

  Future<void> _scheduleFollowUpAlerts(String childId, String alertType) async {
    // Implementation would schedule follow-up local notifications
  }

  Future<void> _updateVaccinationReminder(String childId, String vaccineId, String? dueDate) async {
    // Implementation would update vaccination reminder status
  }

  Future<void> _scheduleGrowthCheckReminder(String childId, String checkType) async {
    // Implementation would schedule growth check reminders
  }

  Future<void> _scheduleMilestoneCheckReminder(String childId, String? milestoneType) async {
    // Implementation would schedule milestone check reminders
  }

  Future<void> _processFeedingSchedule(String childId, String? feedingType) async {
    // Implementation would process feeding schedule updates
  }

  Future<void> _updateMedicationStatus(String childId, String? medicationId) async {
    // Implementation would update medication reminder status
  }

  Future<void> _handleGeneralAction(String action, Map<String, dynamic> data) async {
    // Implementation would handle general notification actions
  }

  Future<void> _storeNavigationIntent(String route, String? childId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_navigation', jsonEncode({
        'route': route,
        'childId': childId,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store navigation intent: $e');
      }
    }
  }

  /// Get and clear pending navigation intent
  Future<Map<String, dynamic>?> getPendingNavigationIntent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final intentString = prefs.getString('pending_navigation');
      
      if (intentString != null) {
        await prefs.remove('pending_navigation');
        return jsonDecode(intentString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get pending navigation intent: $e');
      }
    }
    return null;
  }

  /// Cleanup resources
  Future<void> dispose() async {
    _isInitialized = false;
    _fcmToken = null;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  if (kDebugMode) {
    print('🔄 Background message handler: ${message.messageId}');
  }
  
  // Store the message for processing when app opens
  try {
    final prefs = await SharedPreferences.getInstance();
    final pendingMessages = prefs.getStringList('pending_background_messages') ?? [];
    pendingMessages.add(jsonEncode({
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'receivedAt': DateTime.now().toIso8601String(),
    }));
    
    // Keep only last 10 background messages
    if (pendingMessages.length > 10) {
      pendingMessages.removeRange(0, pendingMessages.length - 10);
    }
    
    await prefs.setStringList('pending_background_messages', pendingMessages);
  } catch (e) {
    if (kDebugMode) {
      print('❌ Failed to store background message: $e');
    }
  }
}