import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'comprehensive_navigation.dart';

class UniversalLayout extends StatefulWidget {
  final Widget content;
  final String currentRoute;
  final Function(String) onNavigate;
  final bool showNavigation;
  final Widget? bottomNavigation;

  const UniversalLayout({
    super.key,
    required this.content,
    required this.currentRoute,
    required this.onNavigate,
    this.showNavigation = true,
    this.bottomNavigation,
  });

  @override
  State<UniversalLayout> createState() => _UniversalLayoutState();
}

class _UniversalLayoutState extends State<UniversalLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNavigationCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1400;
    final isLargeScreen = screenWidth >= 1200 && screenWidth < 1400;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Don't show navigation for website interfaces
    if (!widget.showNavigation) {
      return Scaffold(
        key: _scaffoldKey,
        body: widget.content,
      );
    }

    if (isWideScreen || isLargeScreen) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // Comprehensive Navigation System
          ComprehensiveNavigation(
            currentRoute: widget.currentRoute,
            onNavigate: widget.onNavigate,
            isCollapsed: _isNavigationCollapsed,
            showToggleButton: true,
            onToggle: () {
              setState(() {
                _isNavigationCollapsed = !_isNavigationCollapsed;
              });
            },
          ),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: widget.content,
                  ),
                ),
                
                // Bottom navigation
                if (widget.bottomNavigation != null)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: widget.bottomNavigation!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: 280,
        child: ComprehensiveNavigation(
          currentRoute: widget.currentRoute,
          onNavigate: (route) {
            Navigator.pop(context); // Close drawer
            widget.onNavigate(route);
          },
          isCollapsed: false,
          showToggleButton: false, // No toggle button in drawer
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: widget.content,
            ),
          ),
          
          // Bottom navigation
          if (widget.bottomNavigation != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: widget.bottomNavigation!,
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: 280,
        child: ComprehensiveNavigation(
          currentRoute: widget.currentRoute,
          onNavigate: (route) {
            Navigator.pop(context); // Close drawer
            widget.onNavigate(route);
          },
          isCollapsed: false,
          showToggleButton: false, // No toggle button in drawer
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: widget.content,
            ),
          ),
          
          // Bottom navigation
          if (widget.bottomNavigation != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: widget.bottomNavigation!,
            ),
        ],
      ),
    );
  }
}
