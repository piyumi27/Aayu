import 'package:flutter/material.dart';

/// A wrapper around GestureDetector that safely handles disposal
/// to avoid "Looking up a deactivated widget's ancestor" errors
class SafeGestureDetector extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressUpCallback? onLongPressUp;
  final GestureLongPressEndCallback? onLongPressEnd;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;

  const SafeGestureDetector({
    super.key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.behavior,
    this.excludeFromSemantics = false,
  });

  @override
  State<SafeGestureDetector> createState() => _SafeGestureDetectorState();
}

class _SafeGestureDetectorState extends State<SafeGestureDetector> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  VoidCallback? _safeCallback(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      if (!_isDisposed && mounted) {
        callback();
      }
    };
  }

  GestureTapDownCallback? _safeTapDownCallback(GestureTapDownCallback? callback) {
    if (callback == null) return null;
    return (details) {
      if (!_isDisposed && mounted) {
        callback(details);
      }
    };
  }

  GestureTapUpCallback? _safeTapUpCallback(GestureTapUpCallback? callback) {
    if (callback == null) return null;
    return (details) {
      if (!_isDisposed && mounted) {
        callback(details);
      }
    };
  }

  GestureTapCancelCallback? _safeTapCancelCallback(GestureTapCancelCallback? callback) {
    if (callback == null) return null;
    return () {
      if (!_isDisposed && mounted) {
        callback();
      }
    };
  }

  GestureLongPressStartCallback? _safeLongPressStartCallback(GestureLongPressStartCallback? callback) {
    if (callback == null) return null;
    return (details) {
      if (!_isDisposed && mounted) {
        callback(details);
      }
    };
  }

  GestureLongPressMoveUpdateCallback? _safeLongPressMoveUpdateCallback(GestureLongPressMoveUpdateCallback? callback) {
    if (callback == null) return null;
    return (details) {
      if (!_isDisposed && mounted) {
        callback(details);
      }
    };
  }

  GestureLongPressUpCallback? _safeLongPressUpCallback(GestureLongPressUpCallback? callback) {
    if (callback == null) return null;
    return () {
      if (!_isDisposed && mounted) {
        callback();
      }
    };
  }

  GestureLongPressEndCallback? _safeLongPressEndCallback(GestureLongPressEndCallback? callback) {
    if (callback == null) return null;
    return (details) {
      if (!_isDisposed && mounted) {
        callback(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _safeCallback(widget.onTap),
      onDoubleTap: _safeCallback(widget.onDoubleTap),
      onLongPress: _safeCallback(widget.onLongPress),
      onTapDown: _safeTapDownCallback(widget.onTapDown),
      onTapUp: _safeTapUpCallback(widget.onTapUp),
      onTapCancel: _safeTapCancelCallback(widget.onTapCancel),
      onLongPressStart: _safeLongPressStartCallback(widget.onLongPressStart),
      onLongPressMoveUpdate: _safeLongPressMoveUpdateCallback(widget.onLongPressMoveUpdate),
      onLongPressUp: _safeLongPressUpCallback(widget.onLongPressUp),
      onLongPressEnd: _safeLongPressEndCallback(widget.onLongPressEnd),
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      child: widget.child,
    );
  }
}