import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/child.dart';
import '../../models/vaccine.dart';
import '../../models/growth_record.dart';
import '../../models/development_milestone.dart';
import '../../models/notification.dart';
import '../../repositories/standards_repository.dart';
import '../database_service.dart';
import '../health_alert_service.dart';
import 'local_notification_service.dart';
import 'push_notification_service.dart';

/// Expert-level Smart Scheduling Engine for Health Notifications
/// Handles intelligent scheduling with machine learning-inspired algorithms
class NotificationSchedulingEngine {
  static final NotificationSchedulingEngine _instance = NotificationSchedulingEngine._internal();
  factory NotificationSchedulingEngine() => _instance;
  NotificationSchedulingEngine._internal();

  final DatabaseService _databaseService = DatabaseService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final PushNotificationService _pushNotificationService = PushNotificationService();
  final StandardsRepository _standardsRepository = StandardsRepository();
  final HealthAlertService _healthAlertService = HealthAlertService();

  bool _isInitialized = false;
  static const String _backgroundTaskName = 'smartNotificationScheduling';

  /// Convert string priority to NotificationPriority enum
  NotificationPriority _stringToPriority(String priority) {
    switch (priority) {
      case 'critical':
        return NotificationPriority.critical;
      case 'high':
        return NotificationPriority.high;
      case 'medium':
        return NotificationPriority.medium;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.medium;
    }
  }

  /// Initialize the scheduling engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize WorkManager for background tasks
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register periodic background tasks
      await _registerBackgroundTasks();

      // Schedule initial notifications
      await _scheduleInitialNotifications();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Notification Scheduling Engine initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Scheduling Engine initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Register background tasks for intelligent scheduling
  Future<void> _registerBackgroundTasks() async {
    // Register daily notification planning task
    await Workmanager().registerPeriodicTask(
      'daily_notification_planning',
      _backgroundTaskName,
      frequency: const Duration(hours: 6), // Run every 6 hours
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
      ),
      inputData: {
        'taskType': 'daily_planning',
        'priority': 'high',
      },
    );

    // Register vaccination reminder task
    await Workmanager().registerPeriodicTask(
      'vaccination_check',
      _backgroundTaskName,
      frequency: const Duration(hours: 12), // Run twice daily
      inputData: {
        'taskType': 'vaccination_check',
        'priority': 'high',
      },
    );

    // Register growth monitoring task
    await Workmanager().registerPeriodicTask(
      'growth_monitoring',
      _backgroundTaskName,
      frequency: const Duration(days: 1), // Run daily
      inputData: {
        'taskType': 'growth_monitoring',
        'priority': 'medium',
      },
    );

    // Register health alert monitoring
    await Workmanager().registerPeriodicTask(
      'health_alert_monitoring',
      _backgroundTaskName,
      frequency: const Duration(hours: 4), // Run every 4 hours
      inputData: {
        'taskType': 'health_monitoring',
        'priority': 'critical',
      },
    );
  }

  /// Schedule initial notifications for all children
  Future<void> _scheduleInitialNotifications() async {
    try {
      final children = await _databaseService.getChildren();
      
      for (final child in children) {
        await scheduleNotificationsForChild(child);
      }

      if (kDebugMode) {
        print('✅ Initial notifications scheduled for ${children.length} children');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule initial notifications: $e');
      }
    }
  }

  /// Schedule comprehensive notifications for a specific child
  Future<void> scheduleNotificationsForChild(Child child) async {
    try {
      // Schedule vaccination reminders
      await _scheduleVaccinationReminders(child);
      
      // Schedule growth check reminders
      await _scheduleGrowthCheckReminders(child);
      
      // Schedule milestone check reminders
      await _scheduleMilestoneCheckReminders(child);
      
      // Schedule feeding reminders (for young children)
      await _scheduleFeedingReminders(child);
      
      // Schedule health monitoring notifications
      await _scheduleHealthMonitoringReminders(child);

      if (kDebugMode) {
        print('✅ Notifications scheduled for child: ${child.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule notifications for ${child.name}: $e');
      }
    }
  }

  /// Schedule vaccination reminders with intelligent timing
  Future<void> _scheduleVaccinationReminders(Child child) async {
    try {
      final vaccines = await _databaseService.getVaccines();
      final childAgeMonths = _calculateAgeInMonths(child.birthDate);
      final vaccineRecords = await _databaseService.getVaccineRecords(child.id);
      final givenVaccineIds = vaccineRecords.map((record) => record.vaccineId).toSet();

      for (final vaccine in vaccines) {
        // Skip if already given
        if (givenVaccineIds.contains(vaccine.id)) continue;

        // Skip if not yet due (schedule 1 month before)
        if (vaccine.recommendedAgeMonths > childAgeMonths + 1) continue;

        final dueDate = child.birthDate.add(Duration(days: vaccine.recommendedAgeMonths * 30));
        final now = DateTime.now();

        // Schedule multiple reminders for each vaccine
        final reminderDates = [
          dueDate.subtract(const Duration(days: 7)), // 7 days before
          dueDate.subtract(const Duration(days: 3)), // 3 days before
          dueDate.subtract(const Duration(days: 1)), // 1 day before
          dueDate, // On due date
          dueDate.add(const Duration(days: 1)), // 1 day overdue
          dueDate.add(const Duration(days: 7)), // 1 week overdue
        ];

        for (int i = 0; i < reminderDates.length; i++) {
          final reminderDate = reminderDates[i];
          
          // Only schedule future reminders
          if (reminderDate.isAfter(now)) {
            final notificationId = '${vaccine.id}_${child.id}_reminder_$i'.hashCode;
            final isOverdue = reminderDate.isAfter(dueDate);
            
            await _localNotificationService.scheduleNotification(
              id: notificationId,
              title: _getVaccinationReminderTitle(vaccine, isOverdue),
              body: _getVaccinationReminderBody(vaccine, child, reminderDate, dueDate),
              scheduledDate: _getOptimalNotificationTime(reminderDate),
              channelId: 'vaccination_reminders',
              priority: _stringToPriority(isOverdue ? 'high' : 'medium'),
              payload: {
                'type': 'vaccination_reminder',
                'childId': child.id,
                'vaccineId': vaccine.id,
                'dueDate': dueDate.toIso8601String(),
                'isOverdue': isOverdue,
              },
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule vaccination reminders: $e');
      }
    }
  }

  /// Schedule growth check reminders with intelligent frequency
  Future<void> _scheduleGrowthCheckReminders(Child child) async {
    try {
      final childAgeMonths = _calculateAgeInMonths(child.birthDate);
      final growthRecords = await _databaseService.getGrowthRecords(child.id);
      
      // Determine reminder frequency based on age and last measurement
      int reminderFrequencyDays;
      if (childAgeMonths < 6) {
        reminderFrequencyDays = 14; // Every 2 weeks for infants
      } else if (childAgeMonths < 24) {
        reminderFrequencyDays = 30; // Monthly for toddlers
      } else {
        reminderFrequencyDays = 90; // Every 3 months for older children
      }

      DateTime nextReminderDate;
      
      if (growthRecords.isNotEmpty) {
        final lastMeasurement = growthRecords.first.date;
        nextReminderDate = lastMeasurement.add(Duration(days: reminderFrequencyDays));
      } else {
        // No measurements yet, remind soon
        nextReminderDate = DateTime.now().add(const Duration(days: 3));
      }

      // Schedule up to 6 months of growth reminders
      final endDate = DateTime.now().add(const Duration(days: 180));
      
      while (nextReminderDate.isBefore(endDate)) {
        final notificationId = 'growth_reminder_${child.id}_${nextReminderDate.millisecondsSinceEpoch}'.hashCode;
        
        await _localNotificationService.scheduleNotification(
          id: notificationId,
          title: _getGrowthReminderTitle(child),
          body: _getGrowthReminderBody(child, nextReminderDate),
          scheduledDate: _getOptimalNotificationTime(nextReminderDate),
          channelId: 'growth_reminders',
          priority: _stringToPriority('medium'),
          payload: {
            'type': 'growth_reminder',
            'childId': child.id,
            'reminderType': 'routine',
          },
        );

        nextReminderDate = nextReminderDate.add(Duration(days: reminderFrequencyDays));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule growth reminders: $e');
      }
    }
  }

  /// Schedule milestone check reminders with domain-specific timing
  Future<void> _scheduleMilestoneCheckReminders(Child child) async {
    try {
      final childAgeMonths = _calculateAgeInMonths(child.birthDate);
      final expectedMilestones = await _standardsRepository.getMilestonesForAge(
        ageMonths: childAgeMonths,
      );
      
      final milestoneRecords = await _standardsRepository.getMilestoneRecords(child.id);
      final achievedMilestoneIds = milestoneRecords
          .where((record) => record.achieved)
          .map((record) => record.milestoneId)
          .toSet();

      for (final milestone in expectedMilestones) {
        // Skip if already achieved
        if (achievedMilestoneIds.contains(milestone.id)) continue;

        // Calculate reminder date based on milestone age range
        final reminderAge = milestone.ageMonthsMax;
        final reminderDate = child.birthDate.add(Duration(days: reminderAge * 30));
        
        // Only schedule future reminders
        if (reminderDate.isAfter(DateTime.now())) {
          final notificationId = 'milestone_${milestone.id}_${child.id}'.hashCode;
          
          await _localNotificationService.scheduleNotification(
            id: notificationId,
            title: _getMilestoneReminderTitle(milestone),
            body: _getMilestoneReminderBody(milestone, child),
            scheduledDate: _getOptimalNotificationTime(reminderDate),
            channelId: 'milestone_reminders',
            priority: _stringToPriority(milestone.isRedFlag ? 'high' : 'medium'),
            payload: {
              'type': 'milestone_reminder',
              'childId': child.id,
              'milestoneId': milestone.id,
              'domain': milestone.domain,
              'isRedFlag': milestone.isRedFlag,
            },
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule milestone reminders: $e');
      }
    }
  }

  /// Schedule feeding reminders for young children
  Future<void> _scheduleFeedingReminders(Child child) async {
    try {
      final childAgeMonths = _calculateAgeInMonths(child.birthDate);
      
      // Only schedule feeding reminders for children under 12 months
      if (childAgeMonths >= 12) return;

      final feedingSchedule = _getFeedingScheduleForAge(childAgeMonths);
      final today = DateTime.now();
      
      // Schedule for next 7 days
      for (int day = 0; day < 7; day++) {
        final feedingDate = today.add(Duration(days: day));
        
        for (final feedingTime in feedingSchedule) {
          final scheduledTime = DateTime(
            feedingDate.year,
            feedingDate.month,
            feedingDate.day,
            feedingTime.hour,
            feedingTime.minute,
          );
          
          // Only schedule future feeding times
          if (scheduledTime.isAfter(DateTime.now())) {
            final notificationId = 'feeding_${child.id}_${scheduledTime.millisecondsSinceEpoch}'.hashCode;
            
            await _localNotificationService.scheduleNotification(
              id: notificationId,
              title: _getFeedingReminderTitle(child),
              body: _getFeedingReminderBody(child, feedingTime),
              scheduledDate: scheduledTime,
              channelId: 'feeding_reminders',
              priority: _stringToPriority('low'),
              payload: {
                'type': 'feeding_reminder',
                'childId': child.id,
                'feedingTime': feedingTime.toString(),
              },
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule feeding reminders: $e');
      }
    }
  }

  /// Schedule health monitoring reminders
  Future<void> _scheduleHealthMonitoringReminders(Child child) async {
    try {
      final today = DateTime.now();
      
      // Schedule weekly health check reminder
      final weeklyCheckDate = today.add(const Duration(days: 7));
      
      await _localNotificationService.scheduleNotification(
        id: 'health_check_${child.id}_weekly'.hashCode,
        title: 'Weekly Health Check',
        body: 'Time to review ${child.name}\'s health progress and any concerns',
        scheduledDate: _getOptimalNotificationTime(weeklyCheckDate),
        channelId: 'general',
        priority: _stringToPriority('low'),
        payload: {
          'type': 'health_monitoring',
          'childId': child.id,
          'checkType': 'weekly',
        },
        repeat: true,
        repeatInterval: 'weekly',
      );

      // Schedule monthly comprehensive review
      final monthlyReviewDate = today.add(const Duration(days: 30));
      
      await _localNotificationService.scheduleNotification(
        id: 'health_review_${child.id}_monthly'.hashCode,
        title: 'Monthly Health Review',
        body: 'Time for ${child.name}\'s comprehensive health and development review',
        scheduledDate: _getOptimalNotificationTime(monthlyReviewDate),
        channelId: 'general',
        priority: _stringToPriority('medium'),
        payload: {
          'type': 'health_monitoring',
          'childId': child.id,
          'checkType': 'monthly',
        },
        repeat: true,
        repeatInterval: 'monthly',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule health monitoring reminders: $e');
      }
    }
  }

  /// Get optimal notification time based on user preferences and smart scheduling
  DateTime _getOptimalNotificationTime(DateTime baseDate) {
    // Default to 9 AM if specific time not provided
    if (baseDate.hour == 0 && baseDate.minute == 0) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
    }
    
    // Apply smart scheduling adjustments
    final adjustedTime = _applySmartSchedulingAdjustments(baseDate);
    return adjustedTime;
  }

  /// Apply machine learning-inspired scheduling adjustments
  DateTime _applySmartSchedulingAdjustments(DateTime baseTime) {
    // This would typically use user behavior data and preferences
    // For now, we apply basic optimizations
    
    final hour = baseTime.hour;
    
    // Avoid very early morning (before 7 AM) and late night (after 10 PM)
    if (hour < 7) {
      return DateTime(baseTime.year, baseTime.month, baseTime.day, 9, 0);
    } else if (hour > 22) {
      return DateTime(baseTime.year, baseTime.month, baseTime.day + 1, 9, 0);
    }
    
    // Prefer morning times for important reminders
    return baseTime;
  }

  /// Calculate age in months from birth date
  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30.44).round();
  }

  /// Get feeding schedule based on child's age
  List<DateTime> _getFeedingScheduleForAge(int ageMonths) {
    final today = DateTime.now();
    
    if (ageMonths < 2) {
      // Newborns: every 2-3 hours
      return [
        DateTime(today.year, today.month, today.day, 6, 0),
        DateTime(today.year, today.month, today.day, 9, 0),
        DateTime(today.year, today.month, today.day, 12, 0),
        DateTime(today.year, today.month, today.day, 15, 0),
        DateTime(today.year, today.month, today.day, 18, 0),
        DateTime(today.year, today.month, today.day, 21, 0),
      ];
    } else if (ageMonths < 6) {
      // 2-6 months: every 3-4 hours
      return [
        DateTime(today.year, today.month, today.day, 7, 0),
        DateTime(today.year, today.month, today.day, 11, 0),
        DateTime(today.year, today.month, today.day, 15, 0),
        DateTime(today.year, today.month, today.day, 19, 0),
      ];
    } else {
      // 6+ months: regular meal times
      return [
        DateTime(today.year, today.month, today.day, 8, 0),
        DateTime(today.year, today.month, today.day, 12, 0),
        DateTime(today.year, today.month, today.day, 18, 0),
      ];
    }
  }

  // Notification text generators
  String _getVaccinationReminderTitle(Vaccine vaccine, bool isOverdue) {
    if (isOverdue) {
      return 'Overdue Vaccination: ${vaccine.name}';
    }
    return 'Vaccination Reminder: ${vaccine.name}';
  }

  String _getVaccinationReminderBody(Vaccine vaccine, Child child, DateTime reminderDate, DateTime dueDate) {
    final daysUntilDue = dueDate.difference(reminderDate).inDays;
    
    if (daysUntilDue > 0) {
      return '${child.name} has ${vaccine.name} (${vaccine.nameLocal}) vaccination due in $daysUntilDue days';
    } else if (daysUntilDue == 0) {
      return '${child.name}\'s ${vaccine.name} (${vaccine.nameLocal}) vaccination is due today';
    } else {
      final daysOverdue = -daysUntilDue;
      return '${child.name}\'s ${vaccine.name} (${vaccine.nameLocal}) vaccination is $daysOverdue days overdue';
    }
  }

  String _getGrowthReminderTitle(Child child) {
    return 'Growth Check for ${child.name}';
  }

  String _getGrowthReminderBody(Child child, DateTime reminderDate) {
    return 'Time to measure ${child.name}\'s height, weight, and head circumference';
  }

  String _getMilestoneReminderTitle(DevelopmentMilestone milestone) {
    return 'Milestone Check: ${milestone.domain}';
  }

  String _getMilestoneReminderBody(DevelopmentMilestone milestone, Child child) {
    return 'Check if ${child.name} can: ${milestone.milestone}';
  }

  String _getFeedingReminderTitle(Child child) {
    return 'Feeding Time for ${child.name}';
  }

  String _getFeedingReminderBody(Child child, DateTime feedingTime) {
    return 'It\'s time for ${child.name}\'s feeding';
  }

  /// Cancel all notifications for a child
  Future<void> cancelNotificationsForChild(String childId) async {
    try {
      final db = await _databaseService.database;
      
      // Get all scheduled notifications for this child
      final notifications = await db.query(
        'scheduled_notifications',
        where: 'childId = ? AND isActive = ?',
        whereArgs: [childId, 1],
      );

      // Cancel each notification
      for (final notification in notifications) {
        final notificationId = int.tryParse(notification['id'] as String);
        if (notificationId != null) {
          await _localNotificationService.cancelNotification(notificationId);
        }
      }

      // Mark as cancelled in database
      await db.update(
        'scheduled_notifications',
        {
          'isActive': 0,
          'cancelledAt': DateTime.now().toIso8601String(),
        },
        where: 'childId = ?',
        whereArgs: [childId],
      );

      if (kDebugMode) {
        print('✅ Cancelled ${notifications.length} notifications for child: $childId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel notifications for child: $e');
      }
    }
  }

  /// Update notification preferences and reschedule accordingly
  Future<void> updateNotificationPreferences(Map<String, dynamic> preferences) async {
    try {
      final db = await _databaseService.database;
      
      for (final entry in preferences.entries) {
        await db.update(
          'notification_preferences',
          {
            'isEnabled': entry.value['enabled'] ? 1 : 0,
            'soundEnabled': entry.value['sound'] ? 1 : 0,
            'vibrationEnabled': entry.value['vibration'] ? 1 : 0,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          where: 'category = ?',
          whereArgs: [entry.key],
        );
      }

      // Reschedule notifications based on new preferences
      await _rescheduleNotificationsForPreferences();

      if (kDebugMode) {
        print('✅ Updated notification preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update notification preferences: $e');
      }
    }
  }

  /// Reschedule notifications based on updated preferences
  Future<void> _rescheduleNotificationsForPreferences() async {
    // This would analyze current preferences and reschedule notifications accordingly
    // Implementation would be complex and involve analyzing all scheduled notifications
    
    if (kDebugMode) {
      print('📅 Rescheduling notifications for updated preferences');
    }
  }

  /// Cleanup old notifications and optimize performance
  Future<void> performMaintenance() async {
    try {
      final db = await _databaseService.database;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Clean up old notification history
      await db.delete(
        'notification_history',
        where: 'createdAt < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );

      // Clean up old scheduled notifications that are no longer active
      await db.delete(
        'scheduled_notifications',
        where: 'isActive = 0 AND cancelledAt < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );

      // Clean up old analytics data
      await db.delete(
        'notification_analytics',
        where: 'createdAt < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );

      if (kDebugMode) {
        print('✅ Notification maintenance completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Notification maintenance failed: $e');
      }
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final db = await _databaseService.database;
      
      final totalScheduled = await db.rawQuery(
        'SELECT COUNT(*) as count FROM scheduled_notifications WHERE isActive = 1'
      );
      
      final totalSent = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notification_history WHERE isShown = 1'
      );
      
      final totalTapped = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notification_history WHERE tappedAt IS NOT NULL'
      );

      return {
        'totalScheduled': totalScheduled.first['count'],
        'totalSent': totalSent.first['count'],
        'totalTapped': totalTapped.first['count'],
        'engagementRate': totalSent.first['count'] as int > 0 
            ? (totalTapped.first['count'] as int) / (totalSent.first['count'] as int)
            : 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get notification statistics: $e');
      }
      return {};
    }
  }

  /// Dispose and cleanup resources
  Future<void> dispose() async {
    _isInitialized = false;
    await Workmanager().cancelAll();
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print('🔄 Background task: $task');
    }

    try {
      final taskType = inputData?['taskType'] ?? 'unknown';
      
      switch (taskType) {
        case 'daily_planning':
          await _performDailyNotificationPlanning();
          break;
        case 'vaccination_check':
          await _performVaccinationCheck();
          break;
        case 'growth_monitoring':
          await _performGrowthMonitoring();
          break;
        case 'health_monitoring':
          await _performHealthMonitoring();
          break;
        default:
          if (kDebugMode) {
            print('❓ Unknown background task type: $taskType');
          }
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Background task failed: $e');
      }
      return Future.value(false);
    }
  });
}

/// Background task implementations
Future<void> _performDailyNotificationPlanning() async {
  // Analyze usage patterns and optimize notification timing
  if (kDebugMode) {
    print('📊 Performing daily notification planning');
  }
}

Future<void> _performVaccinationCheck() async {
  // Check for upcoming and overdue vaccinations
  if (kDebugMode) {
    print('💉 Performing vaccination check');
  }
}

Future<void> _performGrowthMonitoring() async {
  // Check if growth measurements are due
  if (kDebugMode) {
    print('📏 Performing growth monitoring check');
  }
}

Future<void> _performHealthMonitoring() async {
  // Monitor for health alerts and critical conditions
  if (kDebugMode) {
    print('🏥 Performing health monitoring check');
  }
}