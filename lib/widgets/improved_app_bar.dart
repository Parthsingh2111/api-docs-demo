import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/navigation_service.dart';
import '../theme/app_theme.dart';
import 'global_search_widget.dart';

class ImprovedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Animation<double>? fadeAnimation;
  final VoidCallback? onBackPressed;

  const ImprovedAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.fadeAnimation,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = NavigationService.canPop();
    final shouldShowBackButton = showBackButton && canPop;

    return AppBar(
      backgroundColor: backgroundColor ?? AppTheme.primaryDark,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 4,
      centerTitle: centerTitle,
      automaticallyImplyLeading: shouldShowBackButton,
      leading: _buildLeading(context, shouldShowBackButton),
      title: _buildTitle(context),
      actions: _buildActions(context),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, bool shouldShowBackButton) {
    if (leading != null) return leading;
    
    if (!shouldShowBackButton) return null;

    return IconButton(
      onPressed: onBackPressed ?? () => NavigationService.pop(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.white,
        ),
      ),
      tooltip: 'Back',
    );
  }

  Widget _buildTitle(BuildContext context) {
    final titleWidget = Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? Colors.white,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (fadeAnimation != null) {
      return FadeTransition(
        opacity: fadeAnimation!,
        child: titleWidget,
      );
    }

    return titleWidget;
  }

  List<Widget>? _buildActions(BuildContext context) {
    return [
      const GlobalSearchWidget(),
      const SizedBox(width: 16),
      if (actions != null) ...actions!,
      const SizedBox(width: 8),
    ];
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Animation<double>? fadeAnimation;
  final VoidCallback? onBackPressed;
  final bool showGradient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.fadeAnimation,
    this.onBackPressed,
    this.showGradient = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = NavigationService.canPop();
    final shouldShowBackButton = showBackButton && canPop;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: showGradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              )
            : BoxDecoration(
                color: backgroundColor ?? AppTheme.primaryDark,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          centerTitle: centerTitle,
          automaticallyImplyLeading: shouldShowBackButton,
          leading: _buildLeading(context, shouldShowBackButton),
          title: _buildTitle(context),
          actions: _buildActions(context),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, bool shouldShowBackButton) {
    if (leading != null) return leading;
    
    if (!shouldShowBackButton) return null;

    return IconButton(
      onPressed: onBackPressed ?? () => NavigationService.pop(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.white,
        ),
      ),
      tooltip: 'Back',
    );
  }

  Widget _buildTitle(BuildContext context) {
    final titleWidget = Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (fadeAnimation != null) {
      return FadeTransition(
        opacity: fadeAnimation!,
        child: titleWidget,
      );
    }

    return titleWidget;
  }

  List<Widget>? _buildActions(BuildContext context) {
    return [
      const GlobalSearchWidget(),
      const SizedBox(width: 16),
      if (actions != null) ...actions!,
      const SizedBox(width: 8),
    ];
  }
}

class MinimalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const MinimalAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = NavigationService.canPop();
    final shouldShowBackButton = showBackButton && canPop;

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: shouldShowBackButton,
      leading: _buildLeading(context, shouldShowBackButton),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: actions,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, bool shouldShowBackButton) {
    if (leading != null) return leading;
    
    if (!shouldShowBackButton) return null;

    return IconButton(
      onPressed: onBackPressed ?? () => NavigationService.pop(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.borderLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
      tooltip: 'Back',
    );
  }
}
