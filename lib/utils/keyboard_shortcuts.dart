import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';

class KeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const KeyboardShortcuts({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Alt + Left Arrow: Go back
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft): const NavigateBackIntent(),
        
        // Ctrl/Cmd + Home: Go to home
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.home): const NavigateHomeIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.home): const NavigateHomeIntent(),
        
        // Escape: Close drawer/modal
        LogicalKeySet(LogicalKeyboardKey.escape): const CloseDrawerIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NavigateBackIntent: NavigateBackAction(context),
          NavigateHomeIntent: NavigateHomeAction(),
          CloseDrawerIntent: CloseDrawerAction(context),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

// Intents
class NavigateBackIntent extends Intent {
  const NavigateBackIntent();
}

class NavigateHomeIntent extends Intent {
  const NavigateHomeIntent();
}

class CloseDrawerIntent extends Intent {
  const CloseDrawerIntent();
}

// Actions
class NavigateBackAction extends Action<NavigateBackIntent> {
  final BuildContext context;

  NavigateBackAction(this.context);

  @override
  Object? invoke(NavigateBackIntent intent) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    return null;
  }
}

class NavigateHomeAction extends Action<NavigateHomeIntent> {
  @override
  Object? invoke(NavigateHomeIntent intent) {
    NavigationService.pushNamedAndRemoveUntil(AppRouter.home);
    return null;
  }
}

class CloseDrawerAction extends Action<CloseDrawerIntent> {
  final BuildContext context;

  CloseDrawerAction(this.context);

  @override
  Object? invoke(CloseDrawerIntent intent) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
    return null;
  }
}

