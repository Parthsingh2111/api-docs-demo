import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';

class SidebarNavigation extends StatelessWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
    this.isCollapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: isCollapsed ? 60 : 280,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 70,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(AppTheme.spacing12),
              ),
            ),
            child: Row(
              children: [
                if (!isCollapsed) ...[
                  const Icon(
                    Icons.account_tree,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      'PayGlocal Docs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else
                  const Icon(
                    Icons.account_tree,
                    color: Colors.white,
                    size: 24,
                  ),
                if (onToggle != null)
                  IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      isCollapsed ? Icons.menu : Icons.close,
                      color: Colors.white,
                    ),
                    tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                  ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              children: [
                _buildNavItem(
                  context,
                  'Overview',
                  Icons.home,
                  AppRouter.home,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'Payment Flow',
                  Icons.visibility,
                  AppRouter.visualization,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'SDKs',
                  Icons.code,
                  AppRouter.sdks,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'Services',
                  Icons.api,
                  AppRouter.services,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'PayCollect',
                  Icons.shield,
                  AppRouter.paycollect,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'PayDirect',
                  Icons.credit_card,
                  AppRouter.paydirect,
                  isCollapsed,
                ),
                const Divider(height: AppTheme.spacing24),
                _buildNavItem(
                  context,
                  'JWT Services',
                  Icons.security,
                  AppRouter.jwtServices,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'Auth Services',
                  Icons.verified_user,
                  AppRouter.authServices,
                  isCollapsed,
                ),
                _buildNavItem(
                  context,
                  'SI Services',
                  Icons.repeat,
                  AppRouter.siServices,
                  isCollapsed,
                ),
              ],
            ),
          ),
          
          // Theme Toggle
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: themeProvider.toggleTheme,
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                  tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isCollapsed,
  ) {
    final isActive = currentRoute == route;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            NavigationService.pushNamed(route);
            if (onToggle != null) onToggle!();
          },
          borderRadius: BorderRadius.circular(AppTheme.spacing8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.1))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.spacing8),
              border: isActive
                  ? Border.all(
                      color: isDark ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
