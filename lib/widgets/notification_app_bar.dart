import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/notifications/notification_badge.dart';
import '../utils/responsive_utils.dart';

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotificationButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const NotificationAppBar({
    super.key,
    required this.title,
    this.showNotificationButton = true,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> appBarActions = [];
    
    // Add notification button if enabled
    if (showNotificationButton) {
      appBarActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SmartNotificationBadge(
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              tooltip: 'Notifications',
            ),
          ),
        ),
      );
    }
    
    // Add any additional actions
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading: leading,
      actions: appBarActions.isNotEmpty ? appBarActions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SimpleNotificationButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;

  const SimpleNotificationButton({
    super.key,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SmartNotificationBadge(
      child: IconButton(
        onPressed: () => context.push('/notifications'),
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor,
          size: iconSize ?? ResponsiveUtils.getResponsiveIconSize(context, 24),
        ),
        tooltip: 'Notifications',
      ),
    );
  }
}