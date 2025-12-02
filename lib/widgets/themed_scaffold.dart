import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'grid_background_painter.dart';

/// Universal scaffold wrapper that provides consistent theming across all screens
///
/// Features:
/// - Automatic grid background in dark mode
/// - Consistent background colors from theme
/// - Simplified scaffold creation
///
/// Usage:
/// ```dart
/// ThemedScaffold(
///   appBar: MyAppBar(),
///   body: MyContent(),
/// )
/// ```
class ThemedScaffold extends StatelessWidget {
  /// App bar widget
  final PreferredSizeWidget? appBar;

  /// Main body content
  final Widget body;

  /// Floating action button (optional)
  final Widget? floatingActionButton;

  /// Bottom navigation bar (optional)
  final Widget? bottomNavigationBar;

  /// Drawer (optional)
  final Widget? drawer;

  /// End drawer (optional)
  final Widget? endDrawer;

  /// Whether to apply safe area insets (default: true)
  final bool useSafeArea;

  /// Whether to apply grid background in dark mode (default: true)
  final bool useGridBackground;

  /// Override background color (optional - uses theme by default)
  final Color? backgroundColor;

  /// Whether body should be scrollable (default: false)
  final bool isScrollable;

  /// Scroll physics (only used if isScrollable = true)
  final ScrollPhysics? scrollPhysics;

  const ThemedScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.useSafeArea = true,
    this.useGridBackground = true,
    this.backgroundColor,
    this.isScrollable = false,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme background color or override
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    Widget bodyWidget = body;

    // Wrap with SingleChildScrollView if requested
    if (isScrollable) {
      bodyWidget = SingleChildScrollView(
        physics: scrollPhysics ?? const BouncingScrollPhysics(),
        child: bodyWidget,
      );
    }

    // Apply grid background in dark mode (if enabled)
    if (useGridBackground && isDark) {
      bodyWidget = GridBackground(
        backgroundColor: bgColor,
        child: bodyWidget,
      );
    } else if (useGridBackground) {
      // In light mode, just wrap in container with background color
      bodyWidget = Container(
        color: bgColor,
        child: bodyWidget,
      );
    }

    // Apply safe area if requested
    if (useSafeArea) {
      bodyWidget = SafeArea(child: bodyWidget);
    }

    return Scaffold(
      // Don't set backgroundColor here - let GridBackground handle it
      appBar: appBar,
      body: bodyWidget,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}
