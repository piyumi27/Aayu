import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Safe navigation utilities to prevent Navigator disposal crashes
/// Handles common navigation edge cases and provides lifecycle safety
class SafeNavigation {
  /// Safely pop the current route if the context is still mounted
  static bool safePop(BuildContext context) {
    if (!context.mounted) return false;

    try {
      context.pop();
      return true;
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: Failed to pop - $e');
      return false;
    }
  }

  /// Safely navigate to a route if the context is still mounted
  static bool safeGo(BuildContext context, String location, {Object? extra}) {
    if (!context.mounted) return false;

    try {
      context.go(location, extra: extra);
      return true;
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: Failed to go to $location - $e');
      return false;
    }
  }

  /// Safely push a route if the context is still mounted
  static Future<T?> safePush<T extends Object?>(
      BuildContext context, String location,
      {Object? extra}) async {
    if (!context.mounted) return null;

    try {
      return await context.push<T>(location, extra: extra);
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: Failed to push $location - $e');
      return null;
    }
  }

  /// Safely replace the current route if the context is still mounted
  static bool safeReplace(BuildContext context, String location,
      {Object? extra}) {
    if (!context.mounted) return false;

    try {
      context.replace(location, extra: extra);
      return true;
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: Failed to replace with $location - $e');
      return false;
    }
  }

  /// Check if navigation is safe (context is mounted and Navigator exists)
  static bool canNavigate(BuildContext context) {
    if (!context.mounted) return false;

    try {
      // Try to access the Navigator to ensure it exists and isn't disposed
      return Navigator.maybeOf(context) != null;
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: Navigator access failed - $e');
      return false;
    }
  }

  /// Safely execute a navigation operation with additional safety checks
  static Future<T?> safeNavigationOperation<T>(
    BuildContext context,
    Future<T?> Function() operation, {
    String operationName = 'navigation',
  }) async {
    if (!canNavigate(context)) {
      debugPrint(
          '⚠️ SafeNavigation: Cannot perform $operationName - context not safe');
      return null;
    }

    try {
      return await operation();
    } catch (e) {
      debugPrint('⚠️ SafeNavigation: $operationName failed - $e');
      return null;
    }
  }
}
