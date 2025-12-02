import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'comprehensive_navigation.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget content;
  final String currentRoute;
  final Function(String) onNavigate;
  final Widget? bottomNavigation;

  const ResponsiveLayout({
    super.key,
    required this.content,
    required this.currentRoute,
    required this.onNavigate,
    this.bottomNavigation,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool _isNavigationCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1400;
    final isLargeScreen = screenWidth >= 1200 && screenWidth < 1400;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    // Adaptive layout based on screen size and content density
    if (isWideScreen) {
      return _buildWideScreenLayout();
    } else if (isLargeScreen) {
      return _buildLargeScreenLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWideScreenLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          // Full-width app bar area
          Expanded(
            child: Row(
              children: [
                // Comprehensive Navigation System
                ComprehensiveNavigation(
                  currentRoute: widget.currentRoute,
                  onNavigate: widget.onNavigate,
                  isCollapsed: _isNavigationCollapsed,
                  showToggleButton: false, // Remove toggle button
                  onToggle: null,
                ),
                
                // Main content area with improved spacing
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacing32),
                          child: widget.content,
                        ),
                      ),
                      
                      // Enhanced bottom navigation for wide screens
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
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          // Full-width app bar area
          Expanded(
            child: Row(
              children: [
                // Comprehensive Navigation System
                ComprehensiveNavigation(
                  currentRoute: widget.currentRoute,
                  onNavigate: widget.onNavigate,
                  isCollapsed: _isNavigationCollapsed,
                  showToggleButton: false, // Remove toggle button
                  onToggle: null,
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
                          ),
                          child: widget.bottomNavigation!,
                        ),
                    ],
                  ),
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
                    color: Colors.black.withValues(alpha: 0.1),
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

