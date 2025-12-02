import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardNavigationWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool enableKeyboardNavigation;

  const KeyboardNavigationWrapper({
    super.key,
    required this.child,
    this.onPrevious,
    this.onNext,
    this.enableKeyboardNavigation = true,
  });

  @override
  State<KeyboardNavigationWrapper> createState() => _KeyboardNavigationWrapperState();
}

class _KeyboardNavigationWrapperState extends State<KeyboardNavigationWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.enableKeyboardNavigation) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enableKeyboardNavigation) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyJ:
          if (widget.onPrevious != null) {
            widget.onPrevious!();
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyK:
          if (widget.onNext != null) {
            widget.onNext!();
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.escape:
          // Close any open dialogs or return to previous screen
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            return KeyEventResult.handled;
          }
          break;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}

class FocusRingWidget extends StatelessWidget {
  final Widget child;
  final bool showFocusRing;
  final Color? focusColor;

  const FocusRingWidget({
    super.key,
    required this.child,
    this.showFocusRing = true,
    this.focusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFocusRing) {
      return child;
    }

    return Focus(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.transparent,
            width: 2,
          ),
        ),
        child: child,
      ),
      onFocusChange: (hasFocus) {
        // This will be handled by the Focus widget's built-in focus ring
      },
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final String? semanticsLabel;
  final bool showFocusRing;
  final EdgeInsetsGeometry? padding;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.semanticsLabel,
    this.showFocusRing = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );

    if (semanticsLabel != null) {
      button = Semantics(
        label: semanticsLabel,
        button: true,
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (showFocusRing) {
      button = FocusRingWidget(
        focusColor: Theme.of(context).colorScheme.primary,
        child: button,
      );
    }

    return button;
  }
}
