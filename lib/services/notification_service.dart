import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/notification.dart';
import '../models/vaccine.dart';
import '../models/medication.dart';

/// Intelligent notification service for health monitoring
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<Function(List<AppNotification>)> _listeners = [];

  /// Add listener for notification updates
  void addListener(Function(List<AppNotification>) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(List<AppNotification>) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_notifications);
    }
  }

  /// Get all notifications with intelligent sorting
  List<AppNotification> getAllNotifications() {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort(_compareNotifications);
    return sorted;
  }

  /// Get notifications by category
  List<AppNotification> getNotificationsByCategory(NotificationCategory category) {
    if (category == NotificationCategory.all) {
      return getAllNotifications();
    }
    
    final filtered = _notifications
        .where((n) => n.category == category)
        .toList();
    filtered.sort(_compareNotifications);
    return filtered;
  }

  /// Get notification badge for category
  NotificationBadge getBadgeForCategory(NotificationCategory category) {
    final notifications = getNotificationsByCategory(category);
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final hasUrgent = notifications.any((n) => n.isUrgent);
    
    NotificationPriority highestPriority = NotificationPriority.low;
    for (final notification in notifications) {
      if (notification.priority.index < highestPriority.index) {
        highestPriority = notification.priority;
      }
    }

    return NotificationBadge(
      count: unreadCount,
      priority: highestPriority,
      hasUrgent: hasUrgent,
    );
  }

  /// Get default tab based on urgent notifications
  NotificationCategory getDefaultTab() {
    final urgentAlerts = _notifications
        .where((n) => n.category == NotificationCategory.healthAlerts && n.isUrgent)
        .length;
    final overdueReminders = _notifications
        .where((n) => n.category == NotificationCategory.reminders && 
                      n.priority == NotificationPriority.critical,)
        .length;

    if (urgentAlerts > 0) {
      return NotificationCategory.healthAlerts;
    } else if (overdueReminders > 0) {
      return NotificationCategory.reminders;
    }
    return NotificationCategory.all;
  }

  /// Intelligent notification comparison for sorting
  int _compareNotifications(AppNotification a, AppNotification b) {
    // First: Unread notifications come first
    if (a.isRead != b.isRead) {
      return a.isRead ? 1 : -1;
    }

    // Second: Starred notifications
    if (a.isStarred != b.isStarred) {
      return a.isStarred ? -1 : 1;
    }

    // Third: Priority (critical first)
    if (a.priority != b.priority) {
      return a.priority.index.compareTo(b.priority.index);
    }

    // Fourth: Urgency
    if (a.isUrgent != b.isUrgent) {
      return a.isUrgent ? -1 : 1;
    }

    // Finally: Most recent first
    return b.timestamp.compareTo(a.timestamp);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
      _saveNotifications();
    }
  }

  /// Toggle notification starred status
  void toggleStarred(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isStarred: !_notifications[index].isStarred,
      );
      _notifyListeners();
      _saveNotifications();
    }
  }

  /// Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
    _saveNotifications();
  }

  /// Clear all notifications in category
  void clearCategory(NotificationCategory category) {
    if (category == NotificationCategory.all) {
      _notifications.clear();
    } else {
      _notifications.removeWhere((n) => n.category == category);
    }
    _notifyListeners();
    _saveNotifications();
  }

  /// Generate intelligent health notifications based on child data
  Future<void> generateHealthNotifications(
    Child child, 
    List<GrowthRecord> records, {
    List<Vaccine>? vaccines,
    List<VaccineRecord>? vaccineRecords,
    List<Medication>? medications,
    List<MedicationDoseRecord>? doseRecords,
  }) async {
    final notifications = <AppNotification>[];

    // Check for measurement gaps
    if (records.isNotEmpty) {
      final latestRecord = records.first;
      final daysSinceLastMeasurement = DateTime.now().difference(latestRecord.date).inDays;
      
      if (daysSinceLastMeasurement > 42) { // 6 weeks
        notifications.add(_createMeasurementGapNotification(child, daysSinceLastMeasurement));
      }
    }

    // Check for nutritional concerns
    if (records.length >= 2) {
      final bmiTrend = _analyzeBMITrend(records);
      if (bmiTrend == BMITrend.declining) {
        notifications.add(_createNutritionalConcernNotification(child));
      }
    }

    // Check for growth stagnation
    final growthStagnation = _checkGrowthStagnation(records);
    if (growthStagnation) {
      notifications.add(_createGrowthStagnationNotification(child));
    }

    // Generate measurement reminders
    final measurementReminder = _generateMeasurementReminder(child, records);
    if (measurementReminder != null) {
      notifications.add(measurementReminder);
    }

    // Generate vaccination reminders
    if (vaccines != null && vaccineRecords != null) {
      final vaccinationReminders = _generateVaccinationReminders(child, vaccines, vaccineRecords);
      notifications.addAll(vaccinationReminders);
    }

    // Generate medication reminders
    if (medications != null && doseRecords != null) {
      final medicationReminders = _generateMedicationReminders(child, medications, doseRecords);
      notifications.addAll(medicationReminders);
    }

    // Add age-appropriate tips
    final tips = _generateAgeTips(child);
    notifications.addAll(tips);

    // Add notifications to list
    for (final notification in notifications) {
      _addNotificationIfNotExists(notification);
    }

    _notifyListeners();
    await _saveNotifications();
  }

  /// Create measurement gap notification
  AppNotification _createMeasurementGapNotification(Child child, int days) {
    return AppNotification(
      id: 'measurement_gap_${child.id}',
      titleKey: 'measurementGapTitle',
      contentKey: 'measurementGapContent',
      category: NotificationCategory.healthAlerts,
      priority: NotificationPriority.critical,
      type: NotificationType.measurementGap,
      timestamp: DateTime.now(),
      childId: child.id,
      actionData: {'days': days, 'childName': child.name},
      actions: [
        NotificationAction(
          id: 'schedule_measurement',
          labelKey: 'scheduleMeasurement',
          icon: Icons.add_circle,
          color: const Color(0xFF10B981),
          onTap: () {
            // Navigate to add measurement
          },
        ),
      ],
    );
  }

  /// Create nutritional concern notification
  AppNotification _createNutritionalConcernNotification(Child child) {
    return AppNotification(
      id: 'nutrition_concern_${child.id}',
      titleKey: 'nutritionConcernTitle',
      contentKey: 'nutritionConcernContent',
      category: NotificationCategory.healthAlerts,
      priority: NotificationPriority.critical,
      type: NotificationType.nutritionalConcern,
      timestamp: DateTime.now(),
      childId: child.id,
      actionData: {'childName': child.name},
      actions: [
        NotificationAction(
          id: 'consult_phm',
          labelKey: 'consultPHM',
          icon: Icons.local_hospital,
          color: const Color(0xFF0086FF),
          onTap: () {
            // Navigate to PHM consultation
          },
        ),
        NotificationAction(
          id: 'view_nutrition_guide',
          labelKey: 'viewNutritionGuide',
          icon: Icons.book,
          color: const Color(0xFF10B981),
          onTap: () {
            // Navigate to nutrition guide
          },
        ),
      ],
    );
  }

  /// Create growth stagnation notification
  AppNotification _createGrowthStagnationNotification(Child child) {
    return AppNotification(
      id: 'growth_stagnation_${child.id}',
      titleKey: 'growthStagnationTitle',
      contentKey: 'growthStagnationContent',
      category: NotificationCategory.healthAlerts,
      priority: NotificationPriority.critical,
      type: NotificationType.growthStagnation,
      timestamp: DateTime.now(),
      childId: child.id,
      actionData: {'childName': child.name},
      actions: [
        NotificationAction(
          id: 'schedule_phm_visit',
          labelKey: 'schedulePHMVisit',
          icon: Icons.calendar_today,
          color: const Color(0xFF0086FF),
          onTap: () {
            // Schedule PHM visit
          },
        ),
      ],
    );
  }

  /// Generate measurement reminder based on child age
  AppNotification? _generateMeasurementReminder(Child child, List<GrowthRecord> records) {
    final ageInMonths = child.ageInMonths;
    final lastMeasurement = records.isNotEmpty ? records.first.date : child.birthDate;
    final daysSinceLastMeasurement = DateTime.now().difference(lastMeasurement).inDays;

    int recommendedInterval;
    if (ageInMonths <= 12) {
      recommendedInterval = 30; // Monthly for 0-12 months
    } else if (ageInMonths <= 24) {
      recommendedInterval = 60; // Bi-monthly for 12-24 months
    } else {
      recommendedInterval = 90; // Quarterly for 24+ months
    }

    if (daysSinceLastMeasurement >= recommendedInterval - 7) { // 7 days before due
      return AppNotification(
        id: 'measurement_reminder_${child.id}',
        titleKey: 'measurementReminderTitle',
        contentKey: 'measurementReminderContent',
        category: NotificationCategory.reminders,
        priority: daysSinceLastMeasurement >= recommendedInterval 
            ? NotificationPriority.high 
            : NotificationPriority.medium,
        type: NotificationType.measurementDue,
        timestamp: DateTime.now(),
        childId: child.id,
        actionData: {'childName': child.name, 'daysOverdue': math.max(0, daysSinceLastMeasurement - recommendedInterval)},
        actions: [
          NotificationAction(
            id: 'add_measurement',
            labelKey: 'addMeasurement',
            icon: Icons.add,
            color: const Color(0xFF10B981),
            onTap: () {
              // Navigate to add measurement
            },
          ),
        ],
      );
    }
    return null;
  }

  /// Generate age-appropriate tips
  List<AppNotification> _generateAgeTips(Child child) {
    final tips = <AppNotification>[];
    final ageInMonths = child.ageInMonths;

    // Generate weekly nutrition tips based on age
    if (ageInMonths >= 6 && ageInMonths <= 11) {
      tips.add(_createNutritionTip(
        'nutrition_tip_6_11m',
        'nutritionTip6To11Title',
        'nutritionTip6To11Content',
        child,
      ),);
    } else if (ageInMonths >= 12 && ageInMonths <= 23) {
      tips.add(_createNutritionTip(
        'nutrition_tip_12_23m',
        'nutritionTip12To23Title',
        'nutritionTip12To23Content',
        child,
      ),);
    }

    return tips;
  }

  /// Create nutrition tip notification
  AppNotification _createNutritionTip(String id, String titleKey, String contentKey, Child child) {
    return AppNotification(
      id: id,
      titleKey: titleKey,
      contentKey: contentKey,
      category: NotificationCategory.tipsGuidance,
      priority: NotificationPriority.medium,
      type: NotificationType.nutritionTip,
      timestamp: DateTime.now(),
      childId: child.id,
      actionData: {'childName': child.name, 'ageInMonths': child.ageInMonths},
    );
  }

  /// Analyze BMI trend
  BMITrend _analyzeBMITrend(List<GrowthRecord> records) {
    if (records.length < 2) return BMITrend.stable;

    final recent = records.take(3).toList();
    if (recent.length < 2) return BMITrend.stable;

    double bmiChange = 0;
    for (int i = 0; i < recent.length - 1; i++) {
      final current = _calculateBMI(recent[i]);
      final previous = _calculateBMI(recent[i + 1]);
      bmiChange += current - previous;
    }

    if (bmiChange < -0.5) return BMITrend.declining;
    if (bmiChange > 0.5) return BMITrend.improving;
    return BMITrend.stable;
  }

  /// Calculate BMI
  double _calculateBMI(GrowthRecord record) {
    final heightInM = record.height / 100;
    return record.weight / (heightInM * heightInM);
  }

  /// Check for growth stagnation
  bool _checkGrowthStagnation(List<GrowthRecord> records) {
    if (records.length < 3) return false;

    final recent = records.take(3).toList();
    bool weightStagnant = true;
    bool heightStagnant = true;

    for (int i = 0; i < recent.length - 1; i++) {
      final current = recent[i];
      final previous = recent[i + 1];

      if (current.weight - previous.weight > 0.2) { // 200g gain
        weightStagnant = false;
      }

      if (current.height - previous.height > 1.0) { // 1cm gain
        heightStagnant = false;
      }
    }

    return weightStagnant && heightStagnant;
  }

  /// Add notification if it doesn't already exist
  void _addNotificationIfNotExists(AppNotification notification) {
    final exists = _notifications.any((n) => n.id == notification.id);
    if (!exists) {
      _notifications.add(notification);
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationData = _notifications.map((n) => {
      'id': n.id,
      'titleKey': n.titleKey,
      'contentKey': n.contentKey,
      'category': n.category.index,
      'priority': n.priority.index,
      'type': n.type.index,
      'timestamp': n.timestamp.millisecondsSinceEpoch,
      'isRead': n.isRead,
      'isStarred': n.isStarred,
      'childId': n.childId,
    },).toList();
    
    await prefs.setString('notifications_data', notificationData.toString());
  }

  /// Load notifications from local storage
  Future<void> loadNotifications() async {
    // Implementation for loading saved notifications
    // For now, we'll generate some sample notifications
    await _generateSampleNotifications();
  }

  /// Generate sample notifications for testing
  Future<void> _generateSampleNotifications() async {
    final now = DateTime.now();
    
    final samples = [
      AppNotification(
        id: 'sample_1',
        titleKey: 'bmiConcernTitle',
        contentKey: 'bmiConcernContent',
        category: NotificationCategory.healthAlerts,
        priority: NotificationPriority.critical,
        type: NotificationType.nutritionalConcern,
        timestamp: now.subtract(const Duration(minutes: 30)),
        actionData: {'childName': 'සම්මානේ'},
      ),
      AppNotification(
        id: 'sample_2',
        titleKey: 'measurementReminderTitle',
        contentKey: 'measurementReminderContent',
        category: NotificationCategory.reminders,
        priority: NotificationPriority.high,
        type: NotificationType.measurementDue,
        timestamp: now.subtract(const Duration(hours: 2)),
        actionData: {'childName': 'සම්මානේ'},
      ),
      AppNotification(
        id: 'sample_3',
        titleKey: 'weeklyNutritionTipTitle',
        contentKey: 'weeklyNutritionTipContent',
        category: NotificationCategory.tipsGuidance,
        priority: NotificationPriority.medium,
        type: NotificationType.nutritionTip,
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
    ];

    _notifications.addAll(samples);
    _notifyListeners();
  }

  /// Generate vaccination reminders
  List<AppNotification> _generateVaccinationReminders(Child child, List<Vaccine> vaccines, List<VaccineRecord> records) {
    final notifications = <AppNotification>[];
    final ageInMonths = child.ageInMonths;
    final givenVaccineIds = records.map((r) => r.vaccineId).toSet();
    final now = DateTime.now();

    // Check for overdue vaccines
    final overdueVaccines = vaccines.where((vaccine) {
      return !givenVaccineIds.contains(vaccine.id) && 
             vaccine.recommendedAgeMonths <= ageInMonths &&
             vaccine.recommendedAgeMonths < (ageInMonths - 2); // 2 months overdue
    }).toList();

    for (final vaccine in overdueVaccines) {
      notifications.add(AppNotification(
        id: 'vaccine_overdue_${child.id}_${vaccine.id}',
        titleKey: 'vaccineOverdueTitle',
        contentKey: 'vaccineOverdueContent',
        category: NotificationCategory.healthAlerts,
        priority: vaccine.isMandatory ? NotificationPriority.critical : NotificationPriority.high,
        type: NotificationType.vaccineDue,
        timestamp: now,
        childId: child.id,
        actionData: {
          'childName': child.name,
          'vaccineName': vaccine.name,
          'vaccineLocal': vaccine.nameLocal,
          'monthsOverdue': ageInMonths - vaccine.recommendedAgeMonths,
        },
        actions: [
          NotificationAction(
            id: 'schedule_vaccine',
            labelKey: 'scheduleVaccine',
            icon: Icons.vaccines,
            color: const Color(0xFF0086FF),
            onTap: () {},
          ),
        ],
      ));
    }

    return notifications;
  }

  /// Generate medication reminders
  List<AppNotification> _generateMedicationReminders(Child child, List<Medication> medications, List<MedicationDoseRecord> doseRecords) {
    final notifications = <AppNotification>[];
    final now = DateTime.now();

    // Check for overdue medications
    final activeMeds = medications.where((med) => med.isActive).toList();
    
    for (final medication in activeMeds) {
      if (medication.frequency == MedicationFrequency.asNeeded) continue;

      // Get last dose record for this medication
      final lastDose = doseRecords
          .where((record) => record.medicationId == medication.id && record.isTaken)
          .fold<MedicationDoseRecord?>(null, (prev, current) {
        if (prev == null) return current;
        return current.actualTime!.isAfter(prev.actualTime!) ? current : prev;
      });

      final lastDoseTime = lastDose?.actualTime ?? medication.startDate;
      final hoursSinceLastDose = now.difference(lastDoseTime).inHours;
      final expectedFrequencyHours = medication.frequencyInHours;

      if (hoursSinceLastDose >= expectedFrequencyHours + 1) { // 1 hour grace period
        final priority = medication.isImportant 
            ? NotificationPriority.critical
            : NotificationPriority.high;

        notifications.add(AppNotification(
          id: 'medication_overdue_${child.id}_${medication.id}',
          titleKey: 'medicationOverdueTitle',
          contentKey: 'medicationOverdueContent',
          category: NotificationCategory.reminders,
          priority: priority,
          type: NotificationType.medicationDue,
          timestamp: now,
          childId: child.id,
          actionData: {
            'childName': child.name,
            'medicationName': medication.name,
            'medicationLocal': medication.nameLocal,
            'dosage': medication.dosageText,
            'hoursOverdue': hoursSinceLastDose - expectedFrequencyHours,
          },
          actions: [
            NotificationAction(
              id: 'take_medication',
              labelKey: 'takeMedication',
              icon: Icons.medication,
              color: const Color(0xFF0086FF),
              onTap: () {},
            ),
          ],
        ));
      }
    }

    return notifications;
  }
}

/// BMI trend analysis
enum BMITrend {
  declining,
  stable,
  improving,
}