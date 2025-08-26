import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';
import '../providers/child_provider.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';

/// Comprehensive notifications screen with intelligent prioritization
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> 
    with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  NotificationCategory _selectedCategory = NotificationCategory.all;
  List<AppNotification> _filteredNotifications = [];
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  final Map<String, bool> _expandedNotifications = {};
  final Set<String> _selectedForDeletion = {};

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeNotifications();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _notificationService.addListener(_onNotificationUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationService.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  /// Load user language preference
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      });
    }
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    await _notificationService.loadNotifications();
    
    // Generate health notifications for current child
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    if (childProvider.selectedChild != null) {
      await _notificationService.generateHealthNotifications(
        childProvider.selectedChild!,
        childProvider.growthRecords,
      );
    }
    
    // Set default tab based on priorities
    final defaultCategory = _notificationService.getDefaultTab();
    setState(() {
      _selectedCategory = defaultCategory;
      _tabController.index = defaultCategory.index;
    });
    
    _filterNotifications();
  }

  /// Handle notification updates
  void _onNotificationUpdate(List<AppNotification> notifications) {
    if (mounted) {
      setState(() {
        _filterNotifications();
      });
    }
  }

  /// Handle tab change
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    setState(() {
      _selectedCategory = NotificationCategory.values[_tabController.index];
      _filterNotifications();
    });
  }

  /// Filter notifications based on selected category
  void _filterNotifications() {
    setState(() {
      _filteredNotifications = _notificationService.getNotificationsByCategory(_selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(texts),
      body: Column(
        children: [
          _buildSegmentedControl(texts),
          Expanded(
            child: _buildNotificationList(texts),
          ),
        ],
      ),
    );
  }

  /// Build app bar with smart features
  PreferredSizeWidget _buildAppBar(Map<String, String> texts) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF1A1A1A),
          ),
          Text(
            texts['notifications']!,
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(width: 8),
          if (_getUnreadCount() > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_getUnreadCount()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
          color: const Color(0xFF1A1A1A),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
          color: const Color(0xFF1A1A1A),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
          onSelected: (value) => _handleMenuAction(value, texts),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  const Icon(Icons.done_all, size: 20),
                  const SizedBox(width: 12),
                  Text(texts['markAllRead']!),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_category',
              child: Row(
                children: [
                  const Icon(Icons.clear_all, size: 20),
                  const SizedBox(width: 12),
                  Text(texts['clearCategory']!),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 12),
                  Text(texts['notificationSettings']!),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build segmented control with smart badges
  Widget _buildSegmentedControl(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0086FF),
            unselectedLabelColor: const Color(0xFF718096),
            indicatorColor: const Color(0xFF0086FF),
            indicatorWeight: 3,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: NotificationCategory.values.map((category) {
              final badge = _notificationService.getBadgeForCategory(category);
              final label = _getCategoryLabel(category, texts);
              
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    if (badge.count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badge.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${badge.count}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  /// Build notification list with intelligent sorting
  Widget _buildNotificationList(Map<String, String> texts) {
    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState(texts);
    }

    return RefreshIndicator(
      onRefresh: _initializeNotifications,
      color: const Color(0xFF0086FF),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          return _buildNotificationCard(notification, texts);
        },
      ),
    );
  }

  /// Build notification card with swipe actions
  Widget _buildNotificationCard(AppNotification notification, Map<String, String> texts) {
    final isExpanded = _expandedNotifications[notification.id] ?? false;
    final isSelected = _selectedForDeletion.contains(notification.id);

    return Dismissible(
      key: Key(notification.id),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      confirmDismiss: (direction) => _handleSwipe(direction, notification, texts),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () => _toggleSelection(notification),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: notification.color,
                width: 4,
              ),
              top: BorderSide(
                color: isSelected ? const Color(0xFF0086FF) : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
              right: BorderSide(
                color: isSelected ? const Color(0xFF0086FF) : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF0086FF) : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationContent(notification, texts, isExpanded),
              if (isExpanded) _buildExpandedContent(notification, texts),
              if (notification.actions.isNotEmpty) _buildQuickActions(notification, texts),
            ],
          ),
        ),
      ),
    );
  }

  /// Build notification content
  Widget _buildNotificationContent(
    AppNotification notification, 
    Map<String, String> texts,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              color: notification.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.getLocalizedTitle(texts),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ),
                    if (notification.isStarred) ...[
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      notification.formatTimestamp(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.getLocalizedContent(texts),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF4B5563),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (!isExpanded && _hasExpandableContent(notification)) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build expanded content for detailed notifications
  Widget _buildExpandedContent(AppNotification notification, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(68, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.actionData != null && notification.actionData!['details'] != null) ...[
            Text(
              notification.actionData!['details'].toString(),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: const Color(0xFF4B5563),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
          if (notification.imageUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                notification.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build quick actions
  Widget _buildQuickActions(AppNotification notification, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(68, 0, 16, 12),
      child: Row(
        children: notification.actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                action.onTap();
                _notificationService.markAsRead(notification.id);
              },
              icon: Icon(action.icon, size: 16),
              label: Text(
                texts[action.labelKey] ?? action.labelKey,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: action.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build swipe background
  Widget _buildSwipeBackground(bool isLeftSwipe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLeftSwipe ? const Color(0xFF10B981) : const Color(0xFFFF8C00),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isLeftSwipe ? Icons.done : Icons.snooze,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Build empty state for categories
  Widget _buildEmptyState(Map<String, String> texts) {
    final emptyState = NotificationEmptyState.forCategory(_selectedCategory);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getEmptyStateIcon(),
                size: 60,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              texts[emptyState.titleKey] ?? 'No notifications',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              texts[emptyState.messageKey] ?? 'You\'re all caught up!',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: const Color(0xFF4B5563),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (emptyState.ctaTextKey != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _handleEmptyStateCTA(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0086FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  texts[emptyState.ctaTextKey!] ?? 'Get Started',
                  style: TextStyle(
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get empty state icon
  IconData _getEmptyStateIcon() {
    switch (_selectedCategory) {
      case NotificationCategory.healthAlerts:
        return Icons.check_circle;
      case NotificationCategory.reminders:
        return Icons.event_available;
      case NotificationCategory.tipsGuidance:
        return Icons.lightbulb;
      case NotificationCategory.systemUpdates:
        return Icons.cloud_done;
      case NotificationCategory.all:
        return Icons.notifications_none;
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }
    
    setState(() {
      final isExpanded = _expandedNotifications[notification.id] ?? false;
      _expandedNotifications[notification.id] = !isExpanded;
    });
  }

  /// Handle swipe actions
  Future<bool> _handleSwipe(
    DismissDirection direction, 
    AppNotification notification,
    Map<String, String> texts,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      // Mark as done
      _notificationService.markAsRead(notification.id);
      _showSnackbar(texts['markedAsDone'] ?? 'Marked as done');
      return false; // Don't remove from list
    } else {
      // Snooze
      await _showSnoozeDialog(notification, texts);
      return false; // Don't remove from list
    }
  }

  /// Show snooze dialog
  Future<void> _showSnoozeDialog(AppNotification notification, Map<String, String> texts) async {
    final snoozeOptions = [
      {'label': texts['snooze1Hour'] ?? '1 hour', 'duration': const Duration(hours: 1)},
      {'label': texts['snooze3Hours'] ?? '3 hours', 'duration': const Duration(hours: 3)},
      {'label': texts['snoozeTomorrow'] ?? 'Tomorrow', 'duration': const Duration(days: 1)},
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          texts['snoozeNotification'] ?? 'Snooze notification',
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: snoozeOptions.map((option) {
            return ListTile(
              title: Text(
                option['label'] as String,
                style: TextStyle(
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _snoozeNotification(notification, option['duration'] as Duration);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Snooze notification
  void _snoozeNotification(AppNotification notification, Duration duration) {
    // Implementation for snoozing
    _showSnackbar('Snoozed for ${duration.inHours} hours');
  }

  /// Toggle selection mode
  void _toggleSelection(AppNotification notification) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedForDeletion.contains(notification.id)) {
        _selectedForDeletion.remove(notification.id);
      } else {
        _selectedForDeletion.add(notification.id);
      }
    });
  }

  /// Handle menu actions
  void _handleMenuAction(String action, Map<String, String> texts) {
    switch (action) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_category':
        _clearCategory(texts);
        break;
      case 'settings':
        _showNotificationSettings();
        break;
    }
  }

  /// Mark all as read
  void _markAllAsRead() {
    for (final notification in _filteredNotifications) {
      _notificationService.markAsRead(notification.id);
    }
    _showSnackbar('All notifications marked as read');
  }

  /// Clear category
  void _clearCategory(Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['clearCategory'] ?? 'Clear category'),
        content: Text(texts['clearCategoryConfirm'] ?? 'Are you sure you want to clear all notifications in this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(texts['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.clearCategory(_selectedCategory);
              _showSnackbar(texts['categoryCleared'] ?? 'Category cleared');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(texts['clear'] ?? 'Clear'),
          ),
        ],
      ),
    );
  }

  /// Show notification settings
  void _showNotificationSettings() {
    context.push('/settings/notifications');
  }

  /// Show search dialog
  void _showSearchDialog() {
    // Implementation for search
  }

  /// Show filter dialog
  void _showFilterDialog() {
    // Implementation for filters
  }

  /// Handle empty state CTA
  void _handleEmptyStateCTA() {
    switch (_selectedCategory) {
      case NotificationCategory.healthAlerts:
      case NotificationCategory.reminders:
        context.push('/add-measurement');
        break;
      case NotificationCategory.tipsGuidance:
        context.push('/nutrition-guide');
        break;
      default:
        break;
    }
  }

  /// Get unread count
  int _getUnreadCount() {
    return _filteredNotifications.where((n) => !n.isRead).length;
  }

  /// Check if notification has expandable content
  bool _hasExpandableContent(AppNotification notification) {
    return notification.imageUrl != null || 
           (notification.actionData != null && notification.actionData!['details'] != null);
  }

  /// Get category label
  String _getCategoryLabel(NotificationCategory category, Map<String, String> texts) {
    switch (category) {
      case NotificationCategory.all:
        return texts['categoryAll'] ?? 'All';
      case NotificationCategory.healthAlerts:
        return texts['categoryHealthAlerts'] ?? 'Health Alerts';
      case NotificationCategory.reminders:
        return texts['categoryReminders'] ?? 'Reminders';
      case NotificationCategory.tipsGuidance:
        return texts['categoryTips'] ?? 'Tips & Guidance';
      case NotificationCategory.systemUpdates:
        return texts['categorySystem'] ?? 'System Updates';
    }
  }

  /// Show snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'notifications': 'Notifications',
        'categoryAll': 'All',
        'categoryHealthAlerts': 'Health Alerts',
        'categoryReminders': 'Reminders',
        'categoryTips': 'Tips & Guidance',
        'categorySystem': 'System',
        
        // Actions
        'markAllRead': 'Mark all as read',
        'clearCategory': 'Clear category',
        'notificationSettings': 'Notification settings',
        'markedAsDone': 'Marked as done',
        'snoozeNotification': 'Snooze notification',
        'snooze1Hour': '1 hour',
        'snooze3Hours': '3 hours',
        'snoozeTomorrow': 'Tomorrow',
        'cancel': 'Cancel',
        'clear': 'Clear',
        'clearCategoryConfirm': 'Clear all notifications in this category?',
        'categoryCleared': 'Category cleared',
        
        // Empty states
        'healthAlertsEmptyTitle': 'All Good!',
        'healthAlertsEmptyMessage': 'No health concerns detected. Keep up the good work!',
        'remindersEmptyTitle': 'You\'re Up to Date',
        'remindersEmptyMessage': 'All reminders have been completed.',
        'tipsEmptyTitle': 'You\'re All Caught Up',
        'tipsEmptyMessage': 'Check back later for new tips and guidance.',
        'systemEmptyTitle': 'System is Synced',
        'systemEmptyMessage': 'All systems are running smoothly.',
        'allNotificationsEmptyTitle': 'No Notifications',
        'allNotificationsEmptyMessage': 'You\'re all caught up! Check back later.',
        
        // CTAs
        'scheduleNextMeasurement': 'Schedule Measurement',
        'viewMeasurementHistory': 'View History',
        'exploreNutritionArticles': 'Explore Articles',
        
        // Notification content
        'bmiConcernTitle': 'BMI Below Normal Range',
        'bmiConcernContent': 'Consider scheduling a consultation with your PHM for nutritional guidance.',
        'measurementReminderTitle': 'Time for Monthly Measurement',
        'measurementReminderContent': 'Regular tracking helps monitor healthy growth.',
        'weeklyNutritionTipTitle': 'This Week\'s Nutrition Tip',
        'weeklyNutritionTipContent': 'Include iron-rich foods like red rice and green leafy vegetables.',
        
        // Quick actions
        'scheduleMeasurement': 'Schedule',
        'addMeasurement': 'Add Now',
        'consultPHM': 'Consult PHM',
        'viewNutritionGuide': 'View Guide',
        'schedulePHMVisit': 'Schedule Visit',
      },
      'si': {
        'notifications': 'දැනුම්දීම්',
        'categoryAll': 'සියල්ල',
        'categoryHealthAlerts': 'සෞඛ්‍ය අනතුරු ඇඟවීම්',
        'categoryReminders': 'මතක් කිරීම්',
        'categoryTips': 'උපදෙස්',
        'categorySystem': 'පද්ධතිය',
        
        // Actions
        'markAllRead': 'සියල්ල කියවූ බව සලකුණු කරන්න',
        'clearCategory': 'කාණ්ඩය හිස් කරන්න',
        'notificationSettings': 'දැනුම්දීම් සැකසුම්',
        'markedAsDone': 'සම්පූර්ණ කළ බව සලකුණු කරන ලදී',
        'snoozeNotification': 'දැනුම්දීම කල් දමන්න',
        'snooze1Hour': 'පැයක්',
        'snooze3Hours': 'පැය 3ක්',
        'snoozeTomorrow': 'හෙට',
        'cancel': 'අවලංගු කරන්න',
        'clear': 'හිස් කරන්න',
        'clearCategoryConfirm': 'මෙම කාණ්ඩයේ සියලු දැනුම්දීම් හිස් කරන්නද?',
        'categoryCleared': 'කාණ්ඩය හිස් කරන ලදී',
        
        // Empty states
        'healthAlertsEmptyTitle': 'සියල්ල හොඳයි!',
        'healthAlertsEmptyMessage': 'සෞඛ්‍ය ගැටලු කිසිවක් හඳුනාගෙන නැත. හොඳ වැඩක්!',
        'remindersEmptyTitle': 'ඔබ යාවත්කාලීනයි',
        'remindersEmptyMessage': 'සියලු මතක් කිරීම් සම්පූර්ණ කර ඇත.',
        'tipsEmptyTitle': 'ඔබ සියල්ල දැක ඇත',
        'tipsEmptyMessage': 'නව උපදෙස් සඳහා පසුව නැවත පරීක්ෂා කරන්න.',
        'systemEmptyTitle': 'පද්ධතිය සමමුහුර්ත කර ඇත',
        'systemEmptyMessage': 'සියලු පද්ධති සුමටව ක්‍රියාත්මක වේ.',
        'allNotificationsEmptyTitle': 'දැනුම්දීම් නැත',
        'allNotificationsEmptyMessage': 'ඔබ සියල්ල දැක ඇත! පසුව නැවත පරීක්ෂා කරන්න.',
        
        // CTAs
        'scheduleNextMeasurement': 'මිනුම් කාලසටහන',
        'viewMeasurementHistory': 'ඉතිහාසය බලන්න',
        'exploreNutritionArticles': 'ලිපි කියවන්න',
        
        // Notification content
        'bmiConcernTitle': 'BMI සාමාන්‍ය පරාසයට වඩා අඩුයි',
        'bmiConcernContent': 'පෝෂණ මඟ පෙන්වීම සඳහා ඔබේ PHM සමඟ උපදේශනයක් කාලසටහන් කරන්න.',
        'measurementReminderTitle': 'මාසික මිනුම් සඳහා කාලයයි',
        'measurementReminderContent': 'නිතිපතා සටහන් තැබීම සෞඛ්‍ය සම්පන්න වර්ධනය නිරීක්ෂණයට උපකාරී වේ.',
        'weeklyNutritionTipTitle': 'මෙම සතියේ පෝෂණ උපදෙස',
        'weeklyNutritionTipContent': 'රතු සහල් සහ කොළ පැහැති එළවළු වැනි යකඩ බහුල ආහාර ඇතුළත් කරන්න.',
        
        // Quick actions
        'scheduleMeasurement': 'කාලසටහන',
        'addMeasurement': 'දැන් එක් කරන්න',
        'consultPHM': 'PHM උපදෙස',
        'viewNutritionGuide': 'මාර්ගෝපදේශ බලන්න',
        'schedulePHMVisit': 'පත්වීම සටහන',
      },
      'ta': {
        'notifications': 'அறிவிப்புகள்',
        'categoryAll': 'அனைத்தும்',
        'categoryHealthAlerts': 'உடல்நல எச்சரிக்கைகள்',
        'categoryReminders': 'நினைவூட்டல்கள்',
        'categoryTips': 'குறிப்புகள் & வழிகாட்டி',
        'categorySystem': 'அமைப்பு',
        
        // Empty states and other Tamil translations...
      },
    };
    
    return texts[_selectedLanguage] ?? texts['en']!;
  }
}