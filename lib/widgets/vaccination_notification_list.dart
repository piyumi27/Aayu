import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vaccination_notification.dart';
import '../providers/child_provider.dart';
import '../services/vaccination_notification_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/vaccination_notification_card.dart';

class VaccinationNotificationList extends StatefulWidget {
  const VaccinationNotificationList({super.key});

  @override
  State<VaccinationNotificationList> createState() => _VaccinationNotificationListState();
}

class _VaccinationNotificationListState extends State<VaccinationNotificationList> {
  final VaccinationNotificationService _notificationService = VaccinationNotificationService();
  List<VaccinationNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (!_hasInitialized) {
      await _notificationService.initialize();
      _hasInitialized = true;
    }
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final childProvider = Provider.of<ChildProvider>(context, listen: false);

    if (childProvider.selectedChild == null) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
      return;
    }

    try {
      // Generate fresh notifications for the selected child
      await _notificationService.generateNotificationsForChild(childProvider.selectedChild!);

      // Load active notifications
      final notifications = await _notificationService.getActiveNotifications(childProvider.selectedChild!.id);

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildProvider>(
      builder: (context, childProvider, child) {
        // Reload notifications when selected child changes
        if (childProvider.selectedChild != null) {
          _loadNotifications();
        }

        if (_isLoading) {
          return _buildLoadingState();
        }

        if (_notifications.isEmpty) {
          return _buildEmptyState();
        }

        return _buildNotificationsList();
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      margin: ResponsiveUtils.getResponsivePadding(context),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 24),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: ResponsiveUtils.getResponsivePadding(context),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 24),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: ResponsiveUtils.getResponsiveFontSize(context, 48),
              color: Colors.green,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'All Caught Up!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              'No upcoming vaccination reminders at this time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Sort notifications by priority and due date
    final sortedNotifications = List<VaccinationNotification>.from(_notifications);
    sortedNotifications.sort((a, b) {
      // First sort by priority (critical first)
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Then by due date (earliest first)
      return a.dueDate.compareTo(b.dueDate);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: ResponsiveUtils.getResponsiveFontSize(context, 24),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Text(
                'Vaccination Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_notifications.isNotEmpty) ...[
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8),
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _notifications.length.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ...sortedNotifications.map((notification) => VaccinationNotificationCard(
              notification: notification,
              onDismiss: () => _handleNotificationDismiss(notification),
              onComplete: () => _handleNotificationComplete(notification),
            ),),
      ],
    );
  }

  void _handleNotificationDismiss(VaccinationNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
  }

  void _handleNotificationComplete(VaccinationNotification notification) async {
    // Mark notification as completed
    await _notificationService.completeNotification(
      notification.vaccineId,
      notification.childId,
    );

    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.vaccineName} health record added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}