import 'package:flutter/material.dart';

/// Centralized navigation service to prevent duplicate pushes and back-stack issues.
///
/// This replaces scattered Navigator.pushNamed calls throughout the app with
/// a single source of truth for all navigation operations.
///
/// Usage:
/// ```dart
/// AppNavigation.to('/route-name');        // Navigate to route
/// AppNavigation.replace('/route-name');   // Replace current route
/// AppNavigation.back();                   // Go back safely
/// AppNavigation.backToRoot();             // Clear stack, go to root
/// ```
class AppNavigation {
  // Use existing NavigationService's key for compatibility
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize with navigator key (called from main.dart)
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static NavigatorState? get _navigator => _navigatorKey?.currentState;

  /// Navigate to a route by pushing it onto the stack
  ///
  /// This is the primary navigation method. Use this instead of Navigator.pushNamed().
  static Future<T?>? to<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available for route: $routeName');
      return null;
    }

    debugPrint('→ AppNavigation.to: $routeName');
    return _navigator!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace the current route with a new one
  ///
  /// Use this when you don't want the user to go back to the current screen.
  /// Example: After successful login, replace login screen with home.
  static Future<T?>? replace<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available for route: $routeName');
      return null;
    }

    debugPrint('→ AppNavigation.replace: $routeName');
    return _navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate back to the previous screen
  ///
  /// This safely pops the current route if possible. If the stack is empty,
  /// it does nothing (preventing app crash).
  ///
  /// Use this in all back buttons instead of Navigator.pop().
  static void back<T extends Object?>([T? result]) {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available for back navigation');
      return;
    }

    if (_navigator!.canPop()) {
      debugPrint('← AppNavigation.back');
      _navigator!.pop<T>(result);
    } else {
      debugPrint('⚠️ AppNavigation: Cannot pop, already at root');
    }
  }

  /// Pop until a specific route is reached
  ///
  /// Use this to go back multiple screens to a specific destination.
  /// Example: From deep navigation, go back to home screen.
  static void backToRoute(String routeName) {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available');
      return;
    }

    debugPrint('← AppNavigation.backToRoute: $routeName');
    _navigator!.popUntil(ModalRoute.withName(routeName));
  }

  /// Pop all routes and return to the root (first) screen
  ///
  /// Use this to reset navigation completely, like after logout.
  static void backToRoot() {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available');
      return;
    }

    debugPrint('← AppNavigation.backToRoot');
    _navigator!.popUntil((route) => route.isFirst);
  }

  /// Push a route and remove all previous routes
  ///
  /// Use this for authentication flows where you don't want users
  /// to go back to previous screens.
  static Future<T?>? toAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    if (_navigator == null) {
      debugPrint('⚠️ AppNavigation: Navigator not available for route: $routeName');
      return null;
    }

    debugPrint('→ AppNavigation.toAndClearStack: $routeName');
    return _navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Check if we can pop the current route
  ///
  /// Use this to determine whether to show a back button.
  static bool canPop() {
    return _navigator?.canPop() ?? false;
  }

  /// Get the current route name (if available)
  static String? get currentRouteName {
    final route = _navigator?.widget.pages.lastOrNull;
    return route?.name;
  }
}
