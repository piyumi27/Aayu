import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/date_utils.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showActions;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.showActions = true,
  });

  IconData _getCategoryIcon() {
    switch (notification.category) {
      case NotificationCategory.healthAlerts:
        return Icons.warning_amber_outlined;
      case NotificationCategory.reminders:
        return Icons.alarm_on_outlined;
      case NotificationCategory.tipsGuidance:
        return Icons.lightbulb_outlined;
      case NotificationCategory.systemUpdates:
        return Icons.system_update_outlined;
      case NotificationCategory.all:
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (notification.category) {
      case NotificationCategory.healthAlerts:
        return colorScheme.error;
      case NotificationCategory.reminders:
        return colorScheme.primary;
      case NotificationCategory.tipsGuidance:
        return Colors.green;
      case NotificationCategory.systemUpdates:
        return colorScheme.secondary;
      case NotificationCategory.all:
      default:
        return colorScheme.primary;
    }
  }

  String _getCategoryDisplayName() {
    switch (notification.category) {
      case NotificationCategory.healthAlerts:
        return 'Health Alert';
      case NotificationCategory.reminders:
        return 'Reminder';
      case NotificationCategory.tipsGuidance:
        return 'Tips & Guidance';
      case NotificationCategory.systemUpdates:
        return 'System Update';
      case NotificationCategory.all:
      default:
        return 'Notification';
    }
  }

  Widget _buildPriorityIndicator(BuildContext context) {
    Color priorityColor;
    String priorityText;
    
    switch (notification.priority) {
      case NotificationPriority.critical:
        priorityColor = Theme.of(context).colorScheme.error;
        priorityText = 'URGENT';
        break;
      case NotificationPriority.high:
        priorityColor = Colors.orange;
        priorityText = 'HIGH';
        break;
      case NotificationPriority.medium:
        priorityColor = Colors.blue;
        priorityText = 'MEDIUM';
        break;
      case NotificationPriority.low:
      default:
        priorityColor = Theme.of(context).colorScheme.outline;
        priorityText = 'LOW';
        break;
    }

    if (notification.priority == NotificationPriority.low) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        border: Border.all(color: priorityColor, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priorityText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: priorityColor,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
        ),
      ),
    );
  }

  Widget _buildChildInfo(BuildContext context) {
    if (notification.childId == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(
          Icons.child_care_outlined,
          size: ResponsiveUtils.getResponsiveIconSize(context, 14),
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          'Child ID: ${notification.childId}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context);
    final isUnread = !notification.isRead;
    
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 8),
      ),
      elevation: isUnread ? 2 : 1,
      color: isUnread 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isUnread 
                ? Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: categoryColor,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getCategoryDisplayName(),
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityIndicator(context),
                              if (isUnread) ...[
                                const Spacer(),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.getTimeAgo(notification.createdAt),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showActions && onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        iconSize: ResponsiveUtils.getResponsiveIconSize(context, 20),
                        color: Theme.of(context).colorScheme.outline,
                        tooltip: 'Delete notification',
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Body
                Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    height: 1.3,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (notification.childId != null) ...[
                  const SizedBox(height: 8),
                  _buildChildInfo(context),
                ],
                
                // Action Buttons (if notification has action data)
                if (notification.actionData != null && notification.actionData!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Handle action based on notification data
                          final route = notification.actionData?['route'];
                          if (route != null) {
                            Navigator.of(context).pushNamed(route);
                          }
                        },
                        icon: Icon(
                          Icons.open_in_new,
                          size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                        ),
                        label: Text(
                          notification.actionData?['action_label'] ?? 'View Details',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: categoryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}