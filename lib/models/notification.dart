import 'package:flutter/material.dart';

/// Notification categories with Sri Lankan localization support
enum NotificationCategory {
  all,
  healthAlerts,
  reminders,
  tipsGuidance,
  systemUpdates,
}

/// Notification priority levels for intelligent sorting
enum NotificationPriority {
  critical, // Red - Immediate action required
  high,     // Orange - Action needed soon
  medium,   // Blue - Informational
  low,      // Gray - Background updates
}

/// Notification types with specific behaviors
enum NotificationType {
  // Health Alerts (Critical Priority)
  nutritionalConcern,
  growthStagnation,
  vaccinationOverdue,
  measurementGap,
  
  // Reminders (High Priority)
  measurementDue,
  vaccinationDue,
  vaccineDue,
  vaccineReminder,
  medicationDue,
  medicationReminder,
  medicationAdherence,
  phmVisit,
  milestoneCheck,
  
  // Educational Content (Medium Priority)
  nutritionTip,
  recipeSuggestion,
  developmentalGuidance,
  feedingChallenge,
  culturalNutrition,
  
  // System Updates (Low Priority)
  dataSync,
  appUpdate,
  offlineMode,
  phmIntegration,
}

/// Comprehensive notification model with Sri Lankan context
class AppNotification {
  final String id;
  final String titleKey;
  final String contentKey;
  final NotificationCategory category;
  final NotificationPriority priority;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isStarred;
  final String? childId;
  final Map<String, dynamic>? actionData;
  final String? imageUrl;
  final List<NotificationAction> actions;

  AppNotification({
    required this.id,
    required this.titleKey,
    required this.contentKey,
    required this.category,
    required this.priority,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isStarred = false,
    this.childId,
    this.actionData,
    this.imageUrl,
    this.actions = const [],
  });

  // Convenience constructor with title/body for backward compatibility
  AppNotification.withTitleBody({
    required this.id,
    required String title,
    required String body,
    required String category,
    required String priority,
    required this.timestamp,
    this.isRead = false,
    this.isStarred = false,
    this.childId,
    this.actionData,
    this.imageUrl,
    this.actions = const [],
  }) : titleKey = title,
       contentKey = body,
       category = _stringToCategory(category),
       priority = _stringToPriority(priority),
       type = _categoryToType(_stringToCategory(category));

  // Helper methods for string conversion
  static NotificationCategory _stringToCategory(String category) {
    switch (category) {
      case 'vaccination':
      case 'vaccination_reminders':
        return NotificationCategory.reminders;
      case 'growth':
      case 'growth_tracking':
        return NotificationCategory.reminders;
      case 'milestone':
      case 'milestone_tracking':
        return NotificationCategory.reminders;
      case 'health_alert':
      case 'critical_health_alert':
        return NotificationCategory.healthAlerts;
      case 'feeding':
      case 'feeding_reminders':
        return NotificationCategory.reminders;
      case 'medication':
      case 'medication_reminders':
        return NotificationCategory.reminders;
      default:
        return NotificationCategory.all;
    }
  }

  static NotificationPriority _stringToPriority(String priority) {
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

  static NotificationType _categoryToType(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.healthAlerts:
        return NotificationType.nutritionalConcern;
      case NotificationCategory.reminders:
        return NotificationType.measurementDue;
      case NotificationCategory.tipsGuidance:
        return NotificationType.nutritionTip;
      case NotificationCategory.systemUpdates:
        return NotificationType.dataSync;
      default:
        return NotificationType.measurementDue;
    }
  }

  // Getters for backward compatibility
  String get title => titleKey;
  String get body => contentKey;
  DateTime get createdAt => timestamp;

  // Factory constructor from Map (database)
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification.withTitleBody(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      category: map['category']?.toString() ?? 'general',
      priority: map['priority']?.toString() ?? 'medium',
      timestamp: DateTime.tryParse(map['receivedAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: (map['isRead'] as int?) == 1,
      childId: map['childId']?.toString(),
      actionData: map['data'] != null ? 
        (map['data'] is String ? 
          <String, dynamic>{} : 
          Map<String, dynamic>.from(map['data'])
        ) : <String, dynamic>{},
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': titleKey,
      'body': contentKey,
      'category': _categoryToString(category),
      'priority': _priorityToString(priority),
      'receivedAt': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'childId': childId,
      'data': actionData ?? <String, dynamic>{},
      'isProcessed': 1,
    };
  }

  String _categoryToString(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.healthAlerts:
        return 'health_alert';
      case NotificationCategory.reminders:
        return 'vaccination';
      case NotificationCategory.tipsGuidance:
        return 'nutrition_tip';
      case NotificationCategory.systemUpdates:
        return 'system_update';
      default:
        return 'general';
    }
  }

  String _priorityToString(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'critical';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.medium:
        return 'medium';
      case NotificationPriority.low:
        return 'low';
    }
  }

  /// Get localized title
  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  /// Get localized content
  String getLocalizedContent(Map<String, String> texts) {
    return texts[contentKey] ?? contentKey;
  }

  /// Get notification icon based on type
  IconData get icon {
    switch (type) {
      case NotificationType.nutritionalConcern:
      case NotificationType.growthStagnation:
        return Icons.warning_amber;
      case NotificationType.vaccinationOverdue:
      case NotificationType.vaccinationDue:
      case NotificationType.vaccineDue:
      case NotificationType.vaccineReminder:
        return Icons.vaccines;
      case NotificationType.measurementGap:
      case NotificationType.measurementDue:
        return Icons.monitor_weight;
      case NotificationType.medicationReminder:
      case NotificationType.medicationDue:
      case NotificationType.medicationAdherence:
        return Icons.medication;
      case NotificationType.phmVisit:
        return Icons.local_hospital;
      case NotificationType.milestoneCheck:
        return Icons.child_care;
      case NotificationType.nutritionTip:
      case NotificationType.culturalNutrition:
        return Icons.restaurant_menu;
      case NotificationType.recipeSuggestion:
        return Icons.book;
      case NotificationType.developmentalGuidance:
        return Icons.psychology;
      case NotificationType.feedingChallenge:
        return Icons.help_center;
      case NotificationType.dataSync:
        return Icons.sync;
      case NotificationType.appUpdate:
        return Icons.system_update;
      case NotificationType.offlineMode:
        return Icons.offline_bolt;
      case NotificationType.phmIntegration:
        return Icons.integration_instructions;
    }
  }

  /// Get notification color based on priority
  Color get color {
    switch (priority) {
      case NotificationPriority.critical:
        return const Color(0xFFE53E3E); // Red
      case NotificationPriority.high:
        return const Color(0xFFFF8C00); // Orange
      case NotificationPriority.medium:
        return const Color(0xFF0086FF); // Blue
      case NotificationPriority.low:
        return const Color(0xFF718096); // Gray
    }
  }

  /// Check if notification requires immediate action
  bool get isUrgent {
    return priority == NotificationPriority.critical || 
           (priority == NotificationPriority.high && 
            DateTime.now().difference(timestamp).inHours > 24);
  }

  /// Format timestamp intelligently
  String formatTimestamp() {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',][timestamp.month - 1];
      return '$month ${timestamp.day}';
    }
  }

  /// Create copy with updated fields
  AppNotification copyWith({
    bool? isRead,
    bool? isStarred,
  }) {
    return AppNotification(
      id: id,
      titleKey: titleKey,
      contentKey: contentKey,
      category: category,
      priority: priority,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      childId: childId,
      actionData: actionData,
      imageUrl: imageUrl,
      actions: actions,
    );
  }
}

/// Notification action for quick interactions
class NotificationAction {
  final String id;
  final String labelKey;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  NotificationAction({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Smart notification badge for categories
class NotificationBadge {
  final int count;
  final NotificationPriority priority;
  final bool hasUrgent;

  NotificationBadge({
    required this.count,
    required this.priority,
    required this.hasUrgent,
  });

  Color get color {
    if (hasUrgent) return const Color(0xFFE53E3E); // Red for urgent
    switch (priority) {
      case NotificationPriority.critical:
        return const Color(0xFFE53E3E); // Red
      case NotificationPriority.high:
        return const Color(0xFFFF8C00); // Orange
      case NotificationPriority.medium:
        return const Color(0xFF0086FF); // Blue
      case NotificationPriority.low:
        return const Color(0xFF718096); // Gray
    }
  }
}

/// Notification filter options
class NotificationFilter {
  final List<NotificationCategory> categories;
  final List<NotificationPriority> priorities;
  final bool showOnlyUnread;
  final bool showOnlyStarred;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  NotificationFilter({
    this.categories = const [],
    this.priorities = const [],
    this.showOnlyUnread = false,
    this.showOnlyStarred = false,
    this.dateFrom,
    this.dateTo,
  });
}

/// Empty state configuration for different categories
class NotificationEmptyState {
  final String illustrationAsset;
  final String titleKey;
  final String messageKey;
  final String? ctaTextKey;
  final VoidCallback? ctaAction;

  NotificationEmptyState({
    required this.illustrationAsset,
    required this.titleKey,
    required this.messageKey,
    this.ctaTextKey,
    this.ctaAction,
  });

  static NotificationEmptyState forCategory(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.healthAlerts:
        return NotificationEmptyState(
          illustrationAsset: 'assets/images/health_all_good.png',
          titleKey: 'healthAlertsEmptyTitle',
          messageKey: 'healthAlertsEmptyMessage',
          ctaTextKey: 'scheduleNextMeasurement',
        );
      case NotificationCategory.reminders:
        return NotificationEmptyState(
          illustrationAsset: 'assets/images/reminders_uptodate.png',
          titleKey: 'remindersEmptyTitle',
          messageKey: 'remindersEmptyMessage',
          ctaTextKey: 'viewMeasurementHistory',
        );
      case NotificationCategory.tipsGuidance:
        return NotificationEmptyState(
          illustrationAsset: 'assets/images/tips_caught_up.png',
          titleKey: 'tipsEmptyTitle',
          messageKey: 'tipsEmptyMessage',
          ctaTextKey: 'exploreNutritionArticles',
        );
      case NotificationCategory.systemUpdates:
        return NotificationEmptyState(
          illustrationAsset: 'assets/images/system_synced.png',
          titleKey: 'systemEmptyTitle',
          messageKey: 'systemEmptyMessage',
        );
      case NotificationCategory.all:
        return NotificationEmptyState(
          illustrationAsset: 'assets/images/notifications_empty.png',
          titleKey: 'allNotificationsEmptyTitle',
          messageKey: 'allNotificationsEmptyMessage',
        );
    }
  }
}