import 'dart:convert';
import 'dart:io';
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
import '../database_service.dart';

/// Expert-level Local Notification Service with comprehensive scheduling
/// Handles all local notifications, scheduling, and custom sounds
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isInitialized = false;
  
  // Notification action handlers
  Function(NotificationResponse)? _onNotificationTap;
  Function(NotificationResponse)? _onSelectNotification;

  /// Initialize local notifications with comprehensive setup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Setup platform-specific initialization
      await _initializePlatformSpecific();
      
      // Create notification channels
      await createNotificationChannels();
      
      // Setup notification handlers
      await _setupNotificationHandlers();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ Local Notification Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Local Notification Service initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Platform-specific initialization
  Future<void> _initializePlatformSpecific() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    // Request permissions for iOS
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }
  }

  /// Create notification channels for Android
  Future<void> createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final List<AndroidNotificationChannel> channels = [
      // Critical Health Alerts
      const AndroidNotificationChannel(
        'critical_health_alerts',
        'Critical Health Alerts',
        description: 'Urgent health notifications requiring immediate attention',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
        showBadge: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('critical_alert'),
      ),

      // Health Alerts
      const AndroidNotificationChannel(
        'health_alerts',
        'Health Alerts',
        description: 'Important health notifications and warnings',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.orange,
        showBadge: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('health_alert'),
      ),

      // Vaccination Reminders
      const AndroidNotificationChannel(
        'vaccination_reminders',
        'Vaccination Reminders',
        description: 'Vaccination schedule reminders and overdue alerts',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.blue,
        showBadge: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('vaccination_reminder'),
      ),

      // Growth Check Reminders
      const AndroidNotificationChannel(
        'growth_reminders',
        'Growth Check Reminders',
        description: 'Monthly growth measurement reminders',
        importance: Importance.defaultImportance,
        enableVibration: true,
        showBadge: true,
        playSound: true,
      ),

      // Milestone Reminders
      const AndroidNotificationChannel(
        'milestone_reminders',
        'Milestone Reminders',
        description: 'Development milestone check reminders',
        importance: Importance.defaultImportance,
        enableVibration: true,
        showBadge: true,
        playSound: true,
      ),

      // Feeding Reminders
      const AndroidNotificationChannel(
        'feeding_reminders',
        'Feeding Reminders',
        description: 'Feeding schedule and nutrition reminders',
        importance: Importance.defaultImportance,
        enableVibration: false,
        showBadge: false,
        playSound: true,
      ),

      // Medication Reminders
      const AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Medication and supplement reminders',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.green,
        showBadge: true,
        playSound: true,
      ),

      // Tips and Guidance
      const AndroidNotificationChannel(
        'tips_guidance',
        'Tips & Guidance',
        description: 'Helpful tips and guidance for child care',
        importance: Importance.low,
        enableVibration: false,
        showBadge: false,
        playSound: false,
      ),

      // General Notifications
      const AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'General app notifications and updates',
        importance: Importance.low,
        enableVibration: false,
        showBadge: false,
        playSound: false,
      ),
    ];

    // Create all channels
    for (final channel in channels) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    if (kDebugMode) {
      print('✅ Created ${channels.length} notification channels');
    }
  }

  /// Setup notification tap handlers
  Future<void> _setupNotificationHandlers() async {
    // Handle notification taps when app is running
    // This is handled in the initialization above
  }

  /// Handle notification response (when user taps notification)
  Future<void> _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (kDebugMode) {
      print('📱 Notification tapped: ${response.id}');
      print('🔗 Payload: ${response.payload}');
    }

    await _handleNotificationTap(response);
    _onNotificationTap?.call(response);
  }

  /// Handle background notification response
  @pragma('vm:entry-point')
  static Future<void> _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
    if (kDebugMode) {
      print('🔄 Background notification tapped: ${response.id}');
    }
    
    // Store for later processing when app opens
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_notification_tap', jsonEncode({
        'id': response.id,
        'payload': response.payload,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store background notification tap: $e');
      }
    }
  }

  /// Handle notification tap actions
  Future<void> _handleNotificationTap(NotificationResponse response) async {
    try {
      if (response.payload != null) {
        final payload = jsonDecode(response.payload!);
        final type = payload['type'];
        final data = payload['data'] ?? {};

        switch (type) {
          case 'health_alert':
            await _handleHealthAlertTap(data);
            break;
          case 'vaccination_reminder':
            await _handleVaccinationReminderTap(data);
            break;
          case 'growth_reminder':
            await _handleGrowthReminderTap(data);
            break;
          case 'milestone_reminder':
            await _handleMilestoneReminderTap(data);
            break;
          case 'feeding_reminder':
            await _handleFeedingReminderTap(data);
            break;
          case 'medication_reminder':
            await _handleMedicationReminderTap(data);
            break;
          default:
            await _handleGeneralNotificationTap(data);
        }

        // Mark as tapped in database
        await _markNotificationAsTapped(response.id!.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling notification tap: $e');
      }
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? payload,
    String? imageUrl,
    List<AndroidNotificationAction>? actions,
  }) async {
    if (!_isInitialized) await initialize();

    final effectiveChannelId = channelId ?? _getChannelIdFromPriority(priority);
    
    final androidDetails = AndroidNotificationDetails(
      effectiveChannelId,
      _getChannelNameFromId(effectiveChannelId),
      channelDescription: _getChannelDescriptionFromId(effectiveChannelId),
      importance: _getImportanceFromPriority(priority),
      priority: _getPriorityFromPriority(priority),
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      enableVibration: priority.index >= NotificationPriority.medium.index,
      enableLights: priority.index >= NotificationPriority.high.index,
      ledColor: _getLedColorFromPriority(priority),
      actions: actions,
      largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
      styleInformation: body.length > 50 
          ? BigTextStyleInformation(body, htmlFormatBigText: true)
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

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
      id: message.hashCode,
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
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? payload,
    bool repeat = false,
    String? repeatInterval,
  }) async {
    if (!_isInitialized) await initialize();

    final effectiveChannelId = channelId ?? _getChannelIdFromPriority(priority);
    final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      effectiveChannelId,
      _getChannelNameFromId(effectiveChannelId),
      channelDescription: _getChannelDescriptionFromId(effectiveChannelId),
      importance: _getImportanceFromPriority(priority),
      priority: _getPriorityFromPriority(priority),
      showWhen: true,
      enableVibration: priority.index >= NotificationPriority.medium.index,
      enableLights: priority.index >= NotificationPriority.high.index,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (repeat && repeatInterval != null) {
      await _scheduleRepeatingNotification(
        id, title, body, scheduledTz, _getRepeatInterval(repeatInterval), details, payload,
      );
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload != null ? jsonEncode(payload) : null,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // Store scheduled notification
    await _storeScheduledNotification(id, title, body, scheduledDate, effectiveChannelId, payload, repeat);

    if (kDebugMode) {
      print('⏰ Notification scheduled: $title at $scheduledDate');
    }
  }

  /// Schedule repeating notification
  Future<void> _scheduleRepeatingNotification(
    int id, String title, String body, tz.TZDateTime scheduledDate,
    RepeatInterval repeatInterval, NotificationDetails details, Map<String, dynamic>? payload,
  ) async {
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    
    // Update database
    await _cancelScheduledNotification(id);
    
    if (kDebugMode) {
      print('❌ Notification cancelled: $id');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    
    // Update database
    await _cancelAllScheduledNotifications();
    
    if (kDebugMode) {
      print('❌ All notifications cancelled');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Get active notifications
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (Platform.isAndroid) {
      return await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications() ?? [];
    }
    return [];
  }

  /// Set notification tap handler
  void setNotificationTapHandler(Function(NotificationResponse) handler) {
    _onNotificationTap = handler;
  }

  /// Helper methods for channel management
  String _getChannelIdFromPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'critical_health_alerts';
      case NotificationPriority.high:
        return 'health_alerts';
      case NotificationPriority.medium:
        return 'growth_reminders';
      case NotificationPriority.low:
        return 'tips_guidance';
    }
  }

  String _getChannelIdFromNotificationType(String type) {
    switch (type) {
      case 'health_alert':
        return 'health_alerts';
      case 'critical_health_alert':
        return 'critical_health_alerts';
      case 'vaccination_reminder':
        return 'vaccination_reminders';
      case 'growth_reminder':
        return 'growth_reminders';
      case 'milestone_reminder':
        return 'milestone_reminders';
      case 'feeding_reminder':
        return 'feeding_reminders';
      case 'medication_reminder':
        return 'medication_reminders';
      default:
        return 'general';
    }
  }

  String _getChannelNameFromId(String channelId) {
    final channelMap = {
      'critical_health_alerts': 'Critical Health Alerts',
      'health_alerts': 'Health Alerts',
      'vaccination_reminders': 'Vaccination Reminders',
      'growth_reminders': 'Growth Reminders',
      'milestone_reminders': 'Milestone Reminders',
      'feeding_reminders': 'Feeding Reminders',
      'medication_reminders': 'Medication Reminders',
      'tips_guidance': 'Tips & Guidance',
      'general': 'General Notifications',
    };
    return channelMap[channelId] ?? 'General Notifications';
  }

  String _getChannelDescriptionFromId(String channelId) {
    final descriptionMap = {
      'critical_health_alerts': 'Urgent health notifications requiring immediate attention',
      'health_alerts': 'Important health notifications and warnings',
      'vaccination_reminders': 'Vaccination schedule reminders and overdue alerts',
      'growth_reminders': 'Monthly growth measurement reminders',
      'milestone_reminders': 'Development milestone check reminders',
      'feeding_reminders': 'Feeding schedule and nutrition reminders',
      'medication_reminders': 'Medication and supplement reminders',
      'tips_guidance': 'Helpful tips and guidance for child care',
      'general': 'General app notifications and updates',
    };
    return descriptionMap[channelId] ?? 'General app notifications';
  }

  Importance _getImportanceFromPriority(NotificationPriority priority) {
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

  Priority _getPriorityFromPriority(NotificationPriority priority) {
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

  Color _getLedColorFromPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.green;
    }
  }

  RepeatInterval _getRepeatInterval(String interval) {
    switch (interval.toLowerCase()) {
      case 'daily':
        return RepeatInterval.daily;
      case 'weekly':
        return RepeatInterval.weekly;
      case 'hourly':
        return RepeatInterval.hourly;
      default:
        return RepeatInterval.daily;
    }
  }

  // Database operations (implementation stubs)
  Future<void> _storeLocalNotification(int id, String title, String body, String channelId, Map<String, dynamic>? payload) async {
    try {
      final db = await _databaseService.database;
      await db.insert('notification_history', {
        'id': id.toString(),
        'title': title,
        'body': body,
        'channelId': channelId,
        'payload': payload != null ? jsonEncode(payload) : null,
        'type': 'local',
        'createdAt': DateTime.now().toIso8601String(),
        'isShown': 1,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store local notification: $e');
      }
    }
  }

  Future<void> _storeScheduledNotification(int id, String title, String body, DateTime scheduledDate, String channelId, Map<String, dynamic>? payload, bool repeat) async {
    try {
      final db = await _databaseService.database;

      // Extract notification type from payload or use default
      String notificationType = 'general';
      if (payload != null && payload.containsKey('type')) {
        notificationType = payload['type'].toString();
      }

      await db.insert('scheduled_notifications', {
        'id': id.toString(),
        'type': notificationType, // Add the missing type field
        'title': title,
        'body': body,
        'channelId': channelId,
        'payload': payload != null ? jsonEncode(payload) : null,
        'scheduledDate': scheduledDate.toIso8601String(),
        'isRepeating': repeat ? 1 : 0,
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to store scheduled notification: $e');
      }
    }
  }

  Future<void> _markNotificationAsTapped(String id) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'notification_history',
        {'tappedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to mark notification as tapped: $e');
      }
    }
  }

  Future<void> _cancelScheduledNotification(int id) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'scheduled_notifications',
        {'isActive': 0, 'cancelledAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id.toString()],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel scheduled notification: $e');
      }
    }
  }

  Future<void> _cancelAllScheduledNotifications() async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'scheduled_notifications',
        {'isActive': 0, 'cancelledAt': DateTime.now().toIso8601String()},
        where: 'isActive = ?',
        whereArgs: [1],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel all scheduled notifications: $e');
      }
    }
  }

  // Notification tap handlers (implementation stubs)
  Future<void> _handleHealthAlertTap(Map<String, dynamic> data) async {
    // Navigate to health alert details
  }

  Future<void> _handleVaccinationReminderTap(Map<String, dynamic> data) async {
    // Navigate to vaccination screen
  }

  Future<void> _handleGrowthReminderTap(Map<String, dynamic> data) async {
    // Navigate to growth tracking screen
  }

  Future<void> _handleMilestoneReminderTap(Map<String, dynamic> data) async {
    // Navigate to milestone tracking screen
  }

  Future<void> _handleFeedingReminderTap(Map<String, dynamic> data) async {
    // Navigate to feeding log screen
  }

  Future<void> _handleMedicationReminderTap(Map<String, dynamic> data) async {
    // Navigate to medication tracking screen
  }

  Future<void> _handleGeneralNotificationTap(Map<String, dynamic> data) async {
    // Handle general notification tap
  }

  /// Show test notification for debugging and user testing
  Future<void> showTestNotification() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working correctly.',
      channelId: 'general',
      priority: NotificationPriority.medium,
    );
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Cleanup resources
  Future<void> dispose() async {
    _isInitialized = false;
  }
}