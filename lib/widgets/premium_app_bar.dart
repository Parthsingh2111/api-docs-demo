import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../navigation/navigation_service.dart';
import 'global_search_widget.dart';

/// Premium unified app bar for all screens
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showSearch;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  
  const PremiumAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.showSearch = true,
    this.showThemeToggle = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = NavigationService.canPop();
    final shouldShowBackButton = showBackButton && canPop;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            children: [
              // Back button
              if (shouldShowBackButton) ...[
                IconButton(
                  onPressed: onBackPressed ?? () => NavigationService.pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                  ),
                  tooltip: 'Back',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark 
                        ? AppTheme.darkSurfaceElevated 
                        : AppTheme.surfaceSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
              ],
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Actions
              if (showSearch) ...[
                const GlobalSearchWidget(),
                const SizedBox(width: AppTheme.spacing8),
              ],
              
              if (showThemeToggle) ...[
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return IconButton(
                      onPressed: themeProvider.toggleTheme,
                      icon: Icon(
                        themeProvider.isDarkMode 
                            ? Icons.light_mode_outlined 
                            : Icons.dark_mode_outlined,
                      ),
                      tooltip: themeProvider.isDarkMode 
                          ? 'Switch to light mode' 
                          : 'Switch to dark mode',
                      style: IconButton.styleFrom(
                        backgroundColor: isDark 
                            ? AppTheme.darkSurfaceElevated 
                            : AppTheme.surfaceSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppTheme.spacing8),
              ],
              
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal app bar for clean layouts
class MinimalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  
  const MinimalAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final canPop = NavigationService.canPop();
    final shouldShowBackButton = showBackButton && canPop;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: shouldShowBackButton
          ? IconButton(
              onPressed: () => NavigationService.pop(),
              icon: const Icon(Icons.close),
            )
          : null,
      title: title != null ? Text(title!) : null,
      actions: actions,
    );
  }
}

