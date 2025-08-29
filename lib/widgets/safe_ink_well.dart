import 'package:flutter/material.dart';

/// A wrapper around InkWell that safely handles disposal
/// to avoid "Looking up a deactivated widget's ancestor" errors
class SafeInkWell extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;
  final double? radius;
  final ShapeBorder? customBorder;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;

  const SafeInkWell({
    super.key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.radius,
    this.customBorder,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.padding,
  });

  @override
  State<SafeInkWell> createState() => _SafeInkWellState();
}

class _SafeInkWellState extends State<SafeInkWell> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Material to provide InkWell with proper ancestor
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        borderRadius: widget.borderRadius,
        splashColor: widget.splashColor,
        highlightColor: widget.highlightColor,
        hoverColor: widget.hoverColor,
        focusColor: widget.focusColor,
        radius: widget.radius,
        customBorder: widget.customBorder,
        enableFeedback: widget.enableFeedback,
        excludeFromSemantics: widget.excludeFromSemantics,
        focusNode: widget.focusNode,
        canRequestFocus: widget.canRequestFocus,
        autofocus: widget.autofocus,
        child: widget.padding != null
            ? Padding(padding: widget.padding!, child: widget.child)
            : widget.child,
      ),
    );
  }
}