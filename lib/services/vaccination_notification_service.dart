import 'package:uuid/uuid.dart';
import '../models/vaccination_notification.dart';
import '../models/vaccine.dart';
import '../models/child.dart';
import '../models/notification.dart';
import '../services/database_service.dart';
import '../services/notifications/local_notification_service.dart';

/// Service to manage vaccination notifications and alerts
class VaccinationNotificationService {
  static final VaccinationNotificationService _instance = VaccinationNotificationService._internal();
  factory VaccinationNotificationService() => _instance;
  VaccinationNotificationService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final Uuid _uuid = const Uuid();

  /// Initialize the service and create notification table if needed
  Future<void> initialize() async {
    await _createNotificationTable();
    // Initialize local notification service for system notifications
    if (!_localNotificationService.isInitialized) {
      await _localNotificationService.initialize();
    }
  }

  /// Create vaccination notifications table
  Future<void> _createNotificationTable() async {
    final db = await _databaseService.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccination_notifications (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        vaccineId TEXT NOT NULL,
        vaccineName TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dismissedAt TEXT,
        dismissalReason TEXT,
        completedAt TEXT,
        FOREIGN KEY (childId) REFERENCES children (id),
        FOREIGN KEY (vaccineId) REFERENCES vaccines (id)
      )
    ''');
  }

  /// Generate notifications for a child based on their vaccination schedule
  Future<void> generateNotificationsForChild(Child child) async {
    final vaccines = await _databaseService.getVaccines();
    final childAge = _calculateAgeInMonths(child.birthDate);
    final existingRecords = await _databaseService.getVaccineRecords(child.id);
    final givenVaccineIds = existingRecords.map((r) => r.vaccineId).toSet();

    // Clear existing notifications for this child
    await _clearNotificationsForChild(child.id);

    final notifications = <VaccinationNotification>[];

    for (final vaccine in vaccines) {
      // Skip if already given
      if (givenVaccineIds.contains(vaccine.id)) continue;

      // Skip if not mandatory or too far in future
      if (!vaccine.isMandatory || vaccine.recommendedAgeMonths > childAge + 12) continue;

      final dueDate = _calculateVaccineDueDate(child.birthDate, vaccine.recommendedAgeMonths);
      final priority = _calculatePriority(dueDate, childAge, vaccine.recommendedAgeMonths);

      // Only create notifications for due soon or overdue vaccines
      if (priority != NotificationPriority.low) {
        final notification = VaccinationNotification(
          id: _uuid.v4(),
          childId: child.id,
          vaccineId: vaccine.id,
          vaccineName: vaccine.name,
          dueDate: dueDate,
          status: NotificationStatus.active,
          priority: priority,
          createdAt: DateTime.now(),
        );

        notifications.add(notification);
      }
    }

    // Save notifications to database
    for (final notification in notifications) {
      await _insertNotification(notification);
    }
  }

  /// Get active notifications for a child
  Future<List<VaccinationNotification>> getActiveNotifications(String childId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'vaccination_notifications',
      where: 'childId = ? AND status = ?',
      whereArgs: [childId, 'active'],
      orderBy: 'priority DESC, dueDate ASC',
    );

    return maps.map((map) => VaccinationNotification.fromMap(map)).toList();
  }

  /// Get all notifications for a child (for history)
  Future<List<VaccinationNotification>> getAllNotifications(String childId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'vaccination_notifications',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => VaccinationNotification.fromMap(map)).toList();
  }

  /// Dismiss a notification with reason
  Future<void> dismissNotification(String notificationId, String reason) async {
    final db = await _databaseService.database;
    await db.update(
      'vaccination_notifications',
      {
        'status': 'dismissed',
        'dismissedAt': DateTime.now().toIso8601String(),
        'dismissalReason': reason,
      },
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Mark notification as completed when vaccine is given
  Future<void> completeNotification(String vaccineId, String childId) async {
    final db = await _databaseService.database;
    await db.update(
      'vaccination_notifications',
      {
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      },
      where: 'vaccineId = ? AND childId = ? AND status = ?',
      whereArgs: [vaccineId, childId, 'active'],
    );
  }

  /// Clear old notifications for a child
  Future<void> _clearNotificationsForChild(String childId) async {
    final db = await _databaseService.database;
    await db.delete(
      'vaccination_notifications',
      where: 'childId = ? AND status = ?',
      whereArgs: [childId, 'active'],
    );
  }

  /// Insert notification into database
  Future<void> _insertNotification(VaccinationNotification notification) async {
    final db = await _databaseService.database;
    await db.insert('vaccination_notifications', notification.toMap());
  }

  /// Calculate age in months
  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  /// Calculate due date for vaccine
  DateTime _calculateVaccineDueDate(DateTime birthDate, int ageInMonths) {
    if (ageInMonths == 0) {
      return birthDate;
    }

    return DateTime(
      birthDate.year,
      birthDate.month + ageInMonths,
      birthDate.day,
    );
  }

  /// Calculate notification priority based on due date and child age
  NotificationPriority _calculatePriority(DateTime dueDate, int childAge, int recommendedAge) {
    final now = DateTime.now();
    final daysDifference = now.difference(dueDate).inDays;

    if (daysDifference > 60) {
      return NotificationPriority.critical; // Seriously overdue
    } else if (daysDifference > 0) {
      return NotificationPriority.high; // Overdue
    } else if (daysDifference > -30) {
      return NotificationPriority.medium; // Due soon
    } else {
      return NotificationPriority.low; // Future
    }
  }

  /// Update all notifications for all children (call periodically)
  Future<void> updateAllNotifications() async {
    final children = await _databaseService.getChildren();
    for (final child in children) {
      await generateNotificationsForChild(child);
    }
  }

  /// Get count of active notifications for a child
  Future<int> getActiveNotificationCount(String childId) async {
    final notifications = await getActiveNotifications(childId);
    return notifications.length;
  }

  /// Get count of high/critical priority notifications
  Future<int> getUrgentNotificationCount(String childId) async {
    final notifications = await getActiveNotifications(childId);
    return notifications.where((n) =>
      n.priority == NotificationPriority.high ||
      n.priority == NotificationPriority.critical
    ).length;
  }
}