import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handler for the Aayu app
class AayuErrorHandler {
  static final AayuErrorHandler _instance = AayuErrorHandler._internal();
  factory AayuErrorHandler() => _instance;
  AayuErrorHandler._internal();

  /// Initialize error handling
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle errors not caught by Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorString = details.toString();

    // Known Flutter framework issues that can be safely ignored
    final isNavigatorError = errorString.contains('Navigator') &&
        errorString.contains('_debugLocked');
    final isScaffoldMessengerError = errorString.contains('ScaffoldMessengerState') &&
        errorString.contains('Looking up a deactivated widget');
    final isAnimationError = errorString.contains('AnimationController') &&
        errorString.contains('SnackBar');

    if (isNavigatorError || isScaffoldMessengerError || isAnimationError) {
      // These are known Flutter framework issues during disposal
      // Log them but don't present them to avoid noise
      if (kDebugMode) {
        debugPrint('🔧 Known framework disposal issue caught and suppressed');
        debugPrint('Type: ${isNavigatorError ? "Navigator" : isScaffoldMessengerError ? "ScaffoldMessenger" : "Animation"}');
        // Don't present these errors even in debug mode to reduce noise
      }
      return; // Exit early, don't log as error
    }

    // Handle other Flutter errors normally
    FlutterError.presentError(details);

    // Log error for analysis
    _logError('Flutter Error', details.exception, details.stack);
  }

  /// Handle platform errors
  static bool _handlePlatformError(Object error, StackTrace stack) {
    debugPrint('🚨 Platform error caught: $error');

    // Log error for analysis
    _logError('Platform Error', error, stack);

    return true;
  }

  /// Log errors for debugging and analysis
  static void _logError(String type, Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('═══ $type ═══');
      debugPrint('Error: $error');
      if (stack != null) {
        debugPrint('Stack trace:');
        debugPrint(stack.toString());
      }
      debugPrint('═══════════════════');
    }

    // TODO: In production, send to analytics/crash reporting
    // Analytics.recordError(error, stack, type);
  }

  /// Handle specific widget disposal errors
  static void handleWidgetDisposalError(String widgetName, Object error) {
    debugPrint('🔧 Widget disposal error in $widgetName: $error');

    // Log for analysis but don't crash the app
    _logError('Widget Disposal', error, StackTrace.current);
  }

  /// Handle navigation errors
  static void handleNavigationError(String route, Object error) {
    debugPrint('🧭 Navigation error to $route: $error');

    // Log for analysis
    _logError('Navigation Error', error, StackTrace.current);
  }

  /// Show user-friendly error dialog
  static void showUserError(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle async operation errors
  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error) {
      final name = operationName ?? 'Unknown Operation';
      debugPrint('🔧 Safe async operation failed ($name): $error');
      _logError('Async Operation', error, StackTrace.current);
      return fallbackValue;
    }
  }

  /// Wrap widget builds with error boundary
  static Widget buildSafely(
    Widget Function() builder, {
    Widget? fallbackWidget,
    String? widgetName,
  }) {
    try {
      return builder();
    } catch (error) {
      final name = widgetName ?? 'Unknown Widget';
      debugPrint('🔧 Widget build error ($name): $error');
      _logError('Widget Build', error, StackTrace.current);

      return fallbackWidget ??
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Error in $name',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
    }
  }
}

/// Widget that catches and handles build errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final String? name;

  const ErrorBoundary({
    required this.child,
    this.fallbackWidget,
    this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AayuErrorHandler.buildSafely(
      () => child,
      fallbackWidget: fallbackWidget,
      widgetName: name,
    );
  }
}