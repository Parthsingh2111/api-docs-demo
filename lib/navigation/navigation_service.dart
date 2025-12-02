import 'package:flutter/material.dart';
import 'app_router.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;
  static BuildContext get context => navigatorKey.currentContext!;

  // Navigation methods
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigator.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    navigator.pop<T>(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigator.popUntil(predicate);
  }

  static void popToRoot() {
    navigator.popUntil((route) => route.isFirst);
  }

  // Specific navigation methods for common flows
  static Future<void> goToHome() {
    return pushNamedAndRemoveUntil(AppRouter.home);
  }

  static Future<void> goToPayCollect() {
    return pushNamed(AppRouter.paycollect);
  }

  static Future<void> goToPayDirect() {
    return pushNamed(AppRouter.paydirect);
  }

  static Future<void> goToServices() {
    return pushNamed(AppRouter.services);
  }

  static Future<void> goToSDKs() {
    return pushNamed(AppRouter.sdks);
  }

  static Future<void> goToVisualization() {
    return pushNamed(AppRouter.visualization);
  }

  static Future<void> goToCheckout(Map<String, dynamic> checkoutData) {
    return pushNamed(AppRouter.checkout, arguments: checkoutData);
  }

  static Future<void> goToCodedrop(Map<String, dynamic> paymentData) {
    return pushNamed(AppRouter.codedrop, arguments: paymentData);
  }

  // PayCollect flows
  static Future<void> goToPayCollectJWT() {
    return pushNamed(AppRouter.paycollectJwt);
  }

  static Future<void> goToPayCollectOTT() {
    return pushNamed(AppRouter.paycollectOtt);
  }

  static Future<void> goToPayCollectAirline() {
    return pushNamed(AppRouter.paycollectAirline);
  }

  static Future<void> goToPayCollectBill() {
    return pushNamed(AppRouter.paycollectBill);
  }

  // PayDirect flows
  static Future<void> goToPayDirectJWT() {
    return pushNamed(AppRouter.paydirectJwt);
  }

  static Future<void> goToPayDirectOTT() {
    return pushNamed(AppRouter.paydirectOtt);
  }

  static Future<void> goToPayDirectAirline() {
    return pushNamed(AppRouter.paydirectAirline);
  }

  static Future<void> goToPayDirectBill() {
    return pushNamed(AppRouter.paydirectBill);
  }

  static Future<void> goToPayDirectSI() {
    return pushNamed(AppRouter.paydirectSi);
  }

  static Future<void> goToStandingInstruction() {
    return pushNamed(AppRouter.standingInstruction);
  }

  // Utility methods
  static bool canPop() {
    return navigator.canPop();
  }

  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  static void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red[600],
    );
  }

  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green[600],
    );
  }

  static void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue[600],
    );
  }

  static Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (context) => child,
    );
  }
}
