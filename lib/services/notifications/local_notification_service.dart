import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../models/child.dart';
import '../../models/notification.dart';
import '../../utils/notification_id_generator.dart';
import '../database_service.dart';

/// Expert-level Local Notification Service with comprehensive scheduling
/// Handles all local notifications, scheduling, and custom sounds
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();

  bool _isInitialized = false;
  Function(String?)? _onNotificationTapped;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  static const String _channelIdGeneral = 'general';
  static const String _channelIdHealth = 'health_alerts';
  static const String _channelIdVaccination = 'vaccination_reminders';
  static const String _channelIdGrowth = 'growth_reminders';
  static const String _channelIdMilestone = 'milestone_reminders';
  static const String _channelIdFeeding = 'feeding_reminders';
  static const String _channelIdMedication = 'medication_reminders';

  /// Initialize the notification service
  Future<void> initialize({Function(String?)? onNotificationTapped}) async {
    if (_isInitialized) return;

    _onNotificationTapped = onNotificationTapped;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Initialize plugin
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels
    await _createNotificationChannels();

    _isInitialized = true;

    if (kDebugMode) {
      print('✅ Local Notification Service initialized');
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    const channels = [
      AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'health_alerts',
        'Health Alerts',
        description: 'Critical health alerts and warnings',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'vaccination_reminders',
        'Vaccination Reminders',
        description: 'Vaccination schedule reminders',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'growth_reminders',
        'Growth Monitoring',
        description: 'Growth measurement reminders',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'milestone_reminders',
        'Milestone Tracking',
        description: 'Development milestone reminders',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'feeding_reminders',
        'Feeding Schedule',
        description: 'Feeding time reminders',
        importance: Importance.low,
      ),
      AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Medication schedule reminders',
        importance: Importance.high,
        enableVibration: true,
      ),
    ];

    for (final channel in channels) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// iOS specific notification callback
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    if (kDebugMode) {
      print('iOS notification received: $title');
    }
  }

  /// Handle notification tap
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && _onNotificationTapped != null) {
      _onNotificationTapped!(payload);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await plugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        final granted = await plugin?.requestNotificationsPermission();
        return granted ?? false;
      }
      return true; // Permissions granted by default on older Android versions
    }
    return false;
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    Map<String, dynamic>? payload,
    NotificationPriority priority = NotificationPriority.medium,
    String? imageUrl,
  }) async {
    final effectiveChannelId = channelId ?? _channelIdGeneral;

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      effectiveChannelId,
      _getChannelName(effectiveChannelId),
      channelDescription: _getChannelDescription(effectiveChannelId),
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      ticker: title,
      styleInformation: body.length > 40 ? BigTextStyleInformation(body) : null,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Platform notification details
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
    );

    // Store in database
    await _storeLocalNotification(id, title, body, effectiveChannelId, payload);

    if (kDebugMode) {
      print('📱 Local notification shown: $title');
    }
  }

  /// Show notification from FCM remote message
  Future<void> showNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final notificationType = data['type'] ?? 'general';

    await showNotification(
      id: await NotificationIdGenerator.generateUniqueId(),
      title: notification.title ?? 'Health Notification',
      body: notification.body ?? '',
      channelId: _getChannelIdFromNotificationType(notificationType),
      payload: {
        'type': notificationType,
        'messageId': message.messageId,
        'data': data,
      },
      imageUrl: notification.android?.imageUrl,
    );
  }

  /// Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
    Map<String, dynamic>? payload,
    NotificationPriority priority = NotificationPriority.medium,
    bool repeat = false,
    String? repeatInterval,
  }) async {
    final effectiveChannelId = channelId ?? _channelIdGeneral;

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      effectiveChannelId,
      _getChannelName(effectiveChannelId),
      channelDescription: _getChannelDescription(effectiveChannelId),
      importance: _getImportance(priority),
      priority: _getPriority(priority),
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Platform notification details
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload != null ? jsonEncode(payload) : null,
    );

    // Store scheduled notification in database
    await _storeScheduledNotification(
      id: id,
      title: title,
      body: body,
      channelId: effectiveChannelId,
      scheduledDate: scheduledDate,
      payload: payload,
      isRepeating: repeat,
      repeatInterval: repeatInterval,
    );

    if (kDebugMode) {
      print('⏰ Notification scheduled for: ${scheduledDate.toIso8601String()}');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);

    // Update database
    final db = await _databaseService.database;
    await db.update(
      'scheduled_notifications',
      {
        'isActive': 0,
        'cancelledAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id.toString()],
    );

    if (kDebugMode) {
      print('❌ Notification cancelled: $id');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Update database
    final db = await _databaseService.database;
    await db.update(
      'scheduled_notifications',
      {
        'isActive': 0,
        'cancelledAt': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('❌ All notifications cancelled');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Show a test notification for testing purposes
  Future<void> showTestNotification() async {
    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;

    await showNotification(
      id: id,
      title: 'Test Notification',
      body:
          'This is a test notification to verify your notification settings are working correctly.',
      channelId: _channelIdGeneral,
      priority: NotificationPriority.medium,
      payload: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🔔 Test notification sent with ID: $id');
    }
  }

  /// Store local notification in database
  Future<void> _storeLocalNotification(
    int id,
    String title,
    String body,
    String channelId,
    Map<String, dynamic>? payload,
  ) async {
    try {
      final db = await _databaseService.database;
      await db.insert('notification_history', {
        'id': id.toString(),
        'type': payload?['type'] ?? 'local',
        'title': title,
        'body': body,
        'payload': payload != null ? jsonEncode(payload) : null,
        'isShown': 1,
        'shownAt': DateTime.now().toIso8601String(),
        'source': 'local',
        'channelId': channelId,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store notification history: $e');
      }
    }
  }

  /// Store scheduled notification in database
  Future<void> _storeScheduledNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
    bool isRepeating = false,
    String? repeatInterval,
  }) async {
    try {
      final db = await _databaseService.database;
      await db.insert('scheduled_notifications', {
        'id': id.toString(),
        'type': payload?['type'] ?? 'scheduled',
        'childId': payload?['childId'],
        'title': title,
        'body': body,
        'channelId': channelId,
        'payload': payload != null ? jsonEncode(payload) : null,
        'scheduledDate': scheduledDate.toIso8601String(),
        'isRepeating': isRepeating ? 1 : 0,
        'repeatInterval': repeatInterval,
        'isActive': 1,
        'isSent': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store scheduled notification: $e');
      }
    }
  }

  /// Helper methods
  String _getChannelName(String channelId) {
    switch (channelId) {
      case _channelIdHealth:
        return 'Health Alerts';
      case _channelIdVaccination:
        return 'Vaccination Reminders';
      case _channelIdGrowth:
        return 'Growth Monitoring';
      case _channelIdMilestone:
        return 'Milestone Tracking';
      case _channelIdFeeding:
        return 'Feeding Schedule';
      case _channelIdMedication:
        return 'Medication Reminders';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _channelIdHealth:
        return 'Critical health alerts and warnings';
      case _channelIdVaccination:
        return 'Vaccination schedule reminders';
      case _channelIdGrowth:
        return 'Growth measurement reminders';
      case _channelIdMilestone:
        return 'Development milestone reminders';
      case _channelIdFeeding:
        return 'Feeding time reminders';
      case _channelIdMedication:
        return 'Medication schedule reminders';
      default:
        return 'General app notifications';
    }
  }

  String _getChannelIdFromNotificationType(String type) {
    if (type.contains('health') || type.contains('alert')) {
      return _channelIdHealth;
    } else if (type.contains('vaccination') || type.contains('vaccine')) {
      return _channelIdVaccination;
    } else if (type.contains('growth')) {
      return _channelIdGrowth;
    } else if (type.contains('milestone')) {
      return _channelIdMilestone;
    } else if (type.contains('feeding')) {
      return _channelIdFeeding;
    } else if (type.contains('medication')) {
      return _channelIdMedication;
    }
    return _channelIdGeneral;
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
    }
  }
}
