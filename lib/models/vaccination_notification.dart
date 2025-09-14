import 'notification.dart';

/// Model for vaccination notification alerts
class VaccinationNotification {
  final String id;
  final String childId;
  final String vaccineId;
  final String vaccineName;
  final DateTime dueDate;
  final NotificationStatus status;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? dismissedAt;
  final String? dismissalReason;
  final DateTime? completedAt;

  VaccinationNotification({
    required this.id,
    required this.childId,
    required this.vaccineId,
    required this.vaccineName,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dismissedAt,
    this.dismissalReason,
    this.completedAt,
  });

  /// Check if notification is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate.add(const Duration(days: 30)));
  }

  /// Check if notification is due soon (within 30 days)
  bool get isDueSoon {
    final now = DateTime.now();
    return now.isAfter(dueDate.subtract(const Duration(days: 30))) &&
           now.isBefore(dueDate.add(const Duration(days: 30)));
  }

  /// Get age string when vaccine is due
  String get ageString {
    final now = DateTime.now();
    final dueDateLocal = dueDate;

    if (dueDateLocal.isBefore(now)) {
      final daysOverdue = now.difference(dueDateLocal).inDays;
      return '$daysOverdue days overdue';
    } else {
      final daysToDue = dueDateLocal.difference(now).inDays;
      return '$daysToDue days until due';
    }
  }

  /// Copy with updated fields
  VaccinationNotification copyWith({
    String? id,
    String? childId,
    String? vaccineId,
    String? vaccineName,
    DateTime? dueDate,
    NotificationStatus? status,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? dismissedAt,
    String? dismissalReason,
    DateTime? completedAt,
  }) {
    return VaccinationNotification(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      vaccineId: vaccineId ?? this.vaccineId,
      vaccineName: vaccineName ?? this.vaccineName,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      dismissalReason: dismissalReason ?? this.dismissalReason,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'vaccineId': vaccineId,
      'vaccineName': vaccineName,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'dismissedAt': dismissedAt?.toIso8601String(),
      'dismissalReason': dismissalReason,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from map
  factory VaccinationNotification.fromMap(Map<String, dynamic> map) {
    return VaccinationNotification(
      id: map['id'],
      childId: map['childId'],
      vaccineId: map['vaccineId'],
      vaccineName: map['vaccineName'],
      dueDate: DateTime.parse(map['dueDate']),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NotificationStatus.active,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      dismissedAt: map['dismissedAt'] != null ? DateTime.parse(map['dismissedAt']) : null,
      dismissalReason: map['dismissalReason'],
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}

/// Notification status enumeration
enum NotificationStatus {
  active,      // Currently shown to user
  dismissed,   // User dismissed with reason
  completed,   // User completed the vaccination
  expired,     // Too old, automatically hidden
}

// Use existing NotificationPriority from models/notification.dart