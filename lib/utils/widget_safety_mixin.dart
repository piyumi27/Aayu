import 'package:flutter/material.dart';

/// Mixin to provide safe widget operations that prevent common errors
/// like calling setState on disposed widgets
mixin WidgetSafetyMixin<T extends StatefulWidget> on State<T> {
  /// Safe setState that checks if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Safe build context access
  bool get isSafeContext => mounted && context.mounted;

  /// Safe future completion handler
  void safeFutureHandler<R>(
    Future<R> future,
    void Function(R result) onSuccess, {
    void Function(Object error)? onError,
  }) {
    future.then((result) {
      if (mounted) {
        onSuccess(result);
      }
    }).catchError((error) {
      if (mounted && onError != null) {
        onError(error);
      } else if (mounted) {
        debugPrint('Future error in ${T.toString()}: $error');
      }
    });
  }

  /// Safe async operation with loading state
  Future<void> safeAsyncOperation(
    Future<void> Function() operation, {
    void Function()? onStart,
    void Function()? onComplete,
    void Function(Object error)? onError,
  }) async {
    if (!mounted) return;

    try {
      if (onStart != null) onStart();
      await operation();
    } catch (error) {
      if (mounted) {
        if (onError != null) {
          onError(error);
        } else {
          debugPrint('Async operation error in ${T.toString()}: $error');
        }
      }
    } finally {
      if (mounted && onComplete != null) {
        onComplete();
      }
    }
  }

  /// Safe timer creation that automatically cancels on dispose
  void safeTimer(Duration duration, VoidCallback callback) {
    if (!mounted) return;

    Future.delayed(duration, () {
      if (mounted) {
        callback();
      }
    });
  }

  /// Safe stream subscription
  void safeStreamListen<R>(
    Stream<R> stream,
    void Function(R data) onData, {
    void Function(Object error)? onError,
  }) {
    if (!mounted) return;

    stream.listen(
      (data) {
        if (mounted) onData(data);
      },
      onError: (error) {
        if (mounted) {
          if (onError != null) {
            onError(error);
          } else {
            debugPrint('Stream error in ${T.toString()}: $error');
          }
        }
      },
    );
  }
}

/// Extension to make BuildContext operations safer
extension SafeBuildContext on BuildContext {
  /// Check if context is still valid for operations
  bool get isSafe {
    try {
      // Try to access the widget to see if context is still valid
      widget;
      return mounted;
    } catch (e) {
      return false;
    }
  }

  /// Safe context operation
  T? safeOperation<T>(T Function() operation) {
    try {
      if (isSafe) {
        return operation();
      }
    } catch (e) {
      debugPrint('Safe context operation failed: $e');
    }
    return null;
  }
}
