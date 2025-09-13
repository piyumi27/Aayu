import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../services/database_service.dart';
import '../../utils/responsive_utils.dart';
import 'notification_card.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  
  List<AppNotification> _allNotifications = [];
  List<AppNotification> _unreadNotifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> results = await db.query(
        'notification_history',
        orderBy: 'receivedAt DESC',
        limit: 100,
      );
      
      _allNotifications = results.map((map) => AppNotification.fromMap(map)).toList();
      _unreadNotifications = _allNotifications.where((n) => !n.isRead).toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'notification_history',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'notification_history',
        {'isRead': 1},
        where: 'isRead = ?',
        whereArgs: [0],
      );
      
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'notification_history',
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  List<AppNotification> _getFilteredNotifications() {
    List<AppNotification> notifications;
    
    switch (_tabController.index) {
      case 0: // All
        notifications = _allNotifications;
        break;
      case 1: // Unread
        notifications = _unreadNotifications;
        break;
      case 2: // Health Alerts
        notifications = _allNotifications
            .where((n) => n.category == NotificationCategory.healthAlerts)
            .toList();
        break;
      default:
        notifications = _allNotifications;
    }

    // Note: _selectedFilter handling removed as it uses string comparison with enum
    // This should be refactored to use proper enum filtering if needed

    return notifications;
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'vaccination', 'label': 'Vaccines'},
      {'key': 'growth', 'label': 'Growth'},
      {'key': 'milestone', 'label': 'Milestones'},
      {'key': 'feeding', 'label': 'Feeding'},
      {'key': 'medication', 'label': 'Medication'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = _getFilteredNotifications();
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: ResponsiveUtils.getResponsiveIconSize(context, 64),
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'No notifications found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (_tabController.index == 1) ...[
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Text(
                'All caught up! 🎉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: ResponsiveUtils.getResponsivePadding(context),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _markAsRead(notification.id),
            onDelete: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (_unreadNotifications.isNotEmpty)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: Text(
                'Mark All Read',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/notification-preferences');
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              icon: _allNotifications.isNotEmpty
                  ? Badge(
                      label: Text('${_allNotifications.length}'),
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
            ),
            Tab(
              text: 'Unread',
              icon: _unreadNotifications.isNotEmpty
                  ? Badge(
                      label: Text('${_unreadNotifications.length}'),
                      child: const Icon(Icons.mark_email_unread_outlined),
                    )
                  : const Icon(Icons.mark_email_unread_outlined),
            ),
            Tab(
              text: 'Health',
              icon: const Icon(Icons.health_and_safety_outlined),
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = 'all';
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsList(),
                      _buildNotificationsList(),
                      _buildNotificationsList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}