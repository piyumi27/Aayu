import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation manager to handle safe navigation operations
/// and prevent Navigator disposal errors
class NavigationManager {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  /// Safe navigation method that checks if context is still mounted
  static void safeNavigate(
    BuildContext context,
    String route, {
    Object? extra,
    bool replace = false,
  }) {
    if (!_isContextValid(context)) {
      debugPrint('⚠️ NavigationManager: Context is not valid, skipping navigation to $route');
      return;
    }

    try {
      if (replace) {
        context.go(route, extra: extra);
      } else {
        context.push(route, extra: extra);
      }
    } catch (e) {
      debugPrint('❌ NavigationManager: Error navigating to $route - $e');
    }
  }

  /// Safe pop operation
  static void safePop(BuildContext context, [Object? result]) {
    if (!_isContextValid(context)) {
      debugPrint('⚠️ NavigationManager: Context is not valid, skipping pop');
      return;
    }

    try {
      if (context.canPop()) {
        context.pop(result);
      } else {
        // If can't pop, navigate to home
        context.go('/');
      }
    } catch (e) {
      debugPrint('❌ NavigationManager: Error popping - $e');
      // Fallback to home
      try {
        context.go('/');
      } catch (fallbackError) {
        debugPrint('❌ NavigationManager: Fallback navigation failed - $fallbackError');
      }
    }
  }

  /// Check if context is still valid for navigation
  static bool _isContextValid(BuildContext context) {
    try {
      // Check if widget is still mounted
      if (context is StatefulElement) {
        return (context as StatefulElement).state.mounted;
      }

      // Check if context has access to GoRouter
      GoRouter.of(context);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safe navigation with confirmation dialog
  static Future<void> safeNavigateWithConfirmation(
    BuildContext context,
    String route, {
    String? confirmationTitle,
    String? confirmationMessage,
    Object? extra,
    bool replace = false,
  }) async {
    if (!_isContextValid(context)) return;

    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(confirmationTitle ?? 'Confirm Navigation'),
        content: Text(confirmationMessage ?? 'Are you sure you want to navigate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldNavigate == true) {
      safeNavigate(context, route, extra: extra, replace: replace);
    }
  }

  /// Get current route safely
  static String? getCurrentRoute(BuildContext context) {
    try {
      if (!_isContextValid(context)) return null;
      return GoRouterState.of(context).uri.path;
    } catch (e) {
      debugPrint('❌ NavigationManager: Error getting current route - $e');
      return null;
    }
  }

  /// Check if we can pop from current route
  static bool canPop(BuildContext context) {
    try {
      if (!_isContextValid(context)) return false;
      return context.canPop();
    } catch (e) {
      debugPrint('❌ NavigationManager: Error checking canPop - $e');
      return false;
    }
  }

  /// Navigate to home safely (fallback navigation)
  static void navigateToHome(BuildContext context) {
    safeNavigate(context, '/', replace: true);
  }

  /// Handle back button press safely
  static Future<bool> handleBackButton(BuildContext context) async {
    if (!_isContextValid(context)) return true;

    try {
      if (context.canPop()) {
        context.pop();
        return false; // Don't exit app
      } else {
        // Show exit confirmation if at root
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      }
    } catch (e) {
      debugPrint('❌ NavigationManager: Error handling back button - $e');
      return true; // Allow exit on error
    }
  }
}

/// Mixin to provide safe navigation methods to widgets
mixin SafeNavigationMixin<T extends StatefulWidget> on State<T> {
  void navigateSafely(String route, {Object? extra, bool replace = false}) {
    if (mounted) {
      NavigationManager.safeNavigate(context, route, extra: extra, replace: replace);
    }
  }

  void popSafely([Object? result]) {
    if (mounted) {
      NavigationManager.safePop(context, result);
    }
  }

  Future<void> navigateWithConfirmation(
    String route, {
    String? title,
    String? message,
    Object? extra,
    bool replace = false,
  }) async {
    if (mounted) {
      await NavigationManager.safeNavigateWithConfirmation(
        context,
        route,
        confirmationTitle: title,
        confirmationMessage: message,
        extra: extra,
        replace: replace,
      );
    }
  }
}

/// Widget wrapper for safe navigation handling
class SafeNavigationWrapper extends StatefulWidget {
  final Widget child;

  const SafeNavigationWrapper({
    required this.child,
    super.key,
  });

  @override
  State<SafeNavigationWrapper> createState() => _SafeNavigationWrapperState();
}

class _SafeNavigationWrapperState extends State<SafeNavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await NavigationManager.handleBackButton(context);
          if (shouldPop && context.mounted) {
            NavigationManager.safePop(context, result);
          }
        }
      },
      child: widget.child,
    );
  }
}