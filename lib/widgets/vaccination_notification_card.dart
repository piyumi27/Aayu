import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification.dart';
import '../models/vaccination_notification.dart';
import '../providers/child_provider.dart';
import '../screens/add_health_record_screen.dart';
import '../services/vaccination_notification_service.dart';
import '../utils/responsive_utils.dart';

class VaccinationNotificationCard extends StatelessWidget {
  final VaccinationNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onComplete;

  const VaccinationNotificationCard({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = ResponsiveUtils.isSmallWidth(context);

    return Card(
      margin: ResponsiveUtils.getResponsivePadding(context),
      elevation: notification.priority == NotificationPriority.critical ? 8 : 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPriorityColor(notification.priority, theme),
            width: 2,
          ),
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getPriorityIcon(notification.priority),
                    color: _getPriorityColor(notification.priority, theme),
                    size: ResponsiveUtils.getResponsiveFontSize(context, 24),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.vaccineName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          ),
                        ),
                        Text(
                          _getPriorityText(notification.priority),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getPriorityColor(notification.priority, theme),
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDismissDialog(context),
                    icon: const Icon(Icons.close_outlined),
                    iconSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Text(
                notification.ageString,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              if (isSmall)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildAddRecordButton(context),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    SizedBox(
                      width: double.infinity,
                      child: _buildDismissButton(context),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildAddRecordButton(context)),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    Expanded(child: _buildDismissButton(context)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddRecordButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToAddRecord(context),
      icon: const Icon(Icons.add_outlined),
      label: const Text('Add Health Record'),
      style: ElevatedButton.styleFrom(
        padding: ResponsiveUtils.getResponsivePadding(context),
        textStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDismissDialog(context),
      icon: const Icon(Icons.schedule_outlined),
      label: const Text('Remind Later'),
      style: OutlinedButton.styleFrom(
        padding: ResponsiveUtils.getResponsivePadding(context),
        textStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
      ),
    );
  }

  void _navigateToAddRecord(BuildContext context) async {
    final childProvider = Provider.of<ChildProvider>(context, listen: false);

    if (childProvider.selectedChild == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHealthRecordScreen(
          initialRecordType: HealthRecordType.vaccine,
          preselectedVaccineName: notification.vaccineName,
          preselectedVaccineId: notification.vaccineId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      onComplete();
    }
  }

  void _showDismissDialog(BuildContext context) {
    final reasons = [
      'Vaccine already given at clinic',
      'Postponed due to illness',
      'Doctor advised to wait',
      'Child refused vaccination',
      'Vaccine not available',
      'Other reason',
    ];

    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dismiss Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why are you dismissing this vaccination reminder for ${notification.vaccineName}?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: reasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedReason = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await VaccinationNotificationService().dismissNotification(
                  notification.id,
                  selectedReason,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onDismiss();
                }
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(NotificationPriority priority, ThemeData theme) {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData _getPriorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Icons.error_outline;
      case NotificationPriority.high:
        return Icons.warning_outlined;
      case NotificationPriority.medium:
        return Icons.info_outline;
      case NotificationPriority.low:
        return Icons.schedule_outlined;
    }
  }

  String _getPriorityText(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'Seriously Overdue';
      case NotificationPriority.high:
        return 'Overdue';
      case NotificationPriority.medium:
        return 'Due Soon';
      case NotificationPriority.low:
        return 'Upcoming';
    }
  }
}