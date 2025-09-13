import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../utils/responsive_utils.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showZeroCount;
  final Color? badgeColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final String? customCount;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showZeroCount = false,
    this.badgeColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.customCount,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getUnreadNotificationCountStream(context),
      builder: (context, snapshot) {
        final count = customCount != null 
            ? int.tryParse(customCount!) ?? 0
            : snapshot.data ?? 0;
        
        if (count == 0 && !showZeroCount) {
          return child;
        }

        return Badge(
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: TextStyle(
              color: textColor ?? Theme.of(context).colorScheme.onError,
              fontSize: fontSize ?? ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: badgeColor ?? Theme.of(context).colorScheme.error,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: child,
        );
      },
    );
  }

  Stream<int> _getUnreadNotificationCountStream(BuildContext context) async* {
    final databaseService = DatabaseService();
    
    while (true) {
      try {
        final db = await databaseService.database;
        final result = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ?',
          whereArgs: [0],
        );
        
        final count = result.first['count'] as int? ?? 0;
        yield count;
        
        // Wait before next update
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Error getting notification count: $e');
        yield 0;
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }
}

class CriticalNotificationBadge extends StatelessWidget {
  final Widget child;
  final bool animated;

  const CriticalNotificationBadge({
    super.key,
    required this.child,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getCriticalNotificationCountStream(context),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        if (count == 0) {
          return child;
        }

        Widget badge = Badge(
          label: Text(
            count > 9 ? '9+' : count.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: child,
        );

        if (!animated) return badge;

        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(0),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.8, end: 1.2),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: badge,
                );
              },
            );
          },
        );
      },
    );
  }

  Stream<int> _getCriticalNotificationCountStream(BuildContext context) async* {
    final databaseService = DatabaseService();
    
    while (true) {
      try {
        final db = await databaseService.database;
        final result = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ? AND (category = ? OR category = ?)',
          whereArgs: [0, 'critical_health_alert', 'health_alert'],
        );
        
        final count = result.first['count'] as int? ?? 0;
        yield count;
        
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Error getting critical notification count: $e');
        yield 0;
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }
}

class CategoryNotificationBadge extends StatelessWidget {
  final Widget child;
  final String category;
  final bool showZeroCount;

  const CategoryNotificationBadge({
    super.key,
    required this.child,
    required this.category,
    this.showZeroCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getCategoryNotificationCountStream(context),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        if (count == 0 && !showZeroCount) {
          return child;
        }

        Color badgeColor;
        switch (category) {
          case 'vaccination':
            badgeColor = Theme.of(context).colorScheme.primary;
            break;
          case 'growth':
            badgeColor = Theme.of(context).colorScheme.secondary;
            break;
          case 'health_alert':
          case 'critical_health_alert':
            badgeColor = Theme.of(context).colorScheme.error;
            break;
          case 'milestone':
            badgeColor = Colors.amber;
            break;
          case 'feeding':
            badgeColor = Colors.green;
            break;
          case 'medication':
            badgeColor = Colors.purple;
            break;
          default:
            badgeColor = Theme.of(context).colorScheme.tertiary;
        }

        return Badge(
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: TextStyle(
              color: _getContrastColor(badgeColor),
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: badgeColor,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: child,
        );
      },
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Stream<int> _getCategoryNotificationCountStream(BuildContext context) async* {
    final databaseService = DatabaseService();
    
    while (true) {
      try {
        final db = await databaseService.database;
        final result = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ? AND category = ?',
          whereArgs: [0, category],
        );
        
        final count = result.first['count'] as int? ?? 0;
        yield count;
        
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Error getting category notification count: $e');
        yield 0;
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }
}

class SmartNotificationBadge extends StatefulWidget {
  final Widget child;
  final Duration updateInterval;
  final bool showAnimation;

  const SmartNotificationBadge({
    super.key,
    required this.child,
    this.updateInterval = const Duration(seconds: 5),
    this.showAnimation = true,
  });

  @override
  State<SmartNotificationBadge> createState() => _SmartNotificationBadgeState();
}

class _SmartNotificationBadgeState extends State<SmartNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleCountChange(int newCount) {
    if (widget.showAnimation && newCount > _lastCount && newCount > 0) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    _lastCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: _getSmartNotificationData(context),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'total': 0, 'critical': 0, 'recent': 0};
        final totalCount = data['total'] ?? 0;
        final criticalCount = data['critical'] ?? 0;
        final recentCount = data['recent'] ?? 0;

        _handleCountChange(totalCount);

        if (totalCount == 0) {
          return widget.child;
        }

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                children: [
                  widget.child,
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: criticalCount > 0 
                            ? Theme.of(context).colorScheme.error
                            : recentCount > 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        totalCount > 99 ? '99+' : totalCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Stream<Map<String, int>> _getSmartNotificationData(BuildContext context) async* {
    final databaseService = DatabaseService();
    
    while (true) {
      try {
        final db = await databaseService.database;
        
        // Get total unread count
        final totalResult = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ?',
          whereArgs: [0],
        );
        
        // Get critical unread count
        final criticalResult = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ? AND (category = ? OR category = ?)',
          whereArgs: [0, 'critical_health_alert', 'health_alert'],
        );
        
        // Get recent (last 24 hours) unread count
        final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
        final recentResult = await db.query(
          'notification_history',
          columns: ['COUNT(*) as count'],
          where: 'isRead = ? AND receivedAt > ?',
          whereArgs: [0, twentyFourHoursAgo.toIso8601String()],
        );
        
        yield {
          'total': totalResult.first['count'] as int? ?? 0,
          'critical': criticalResult.first['count'] as int? ?? 0,
          'recent': recentResult.first['count'] as int? ?? 0,
        };
        
        await Future.delayed(widget.updateInterval);
      } catch (e) {
        debugPrint('Error getting smart notification data: $e');
        yield {'total': 0, 'critical': 0, 'recent': 0};
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }
}