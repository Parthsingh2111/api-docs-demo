import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium button with loading state and icon support
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final PremiumButtonStyle buttonStyle;
  final PremiumButtonSize size;
  
  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.buttonStyle = PremiumButtonStyle.primary,
    this.size = PremiumButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button;
    
    switch (buttonStyle) {
      case PremiumButtonStyle.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildContent(theme),
        );
        break;
      case PremiumButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildContent(theme),
        );
        break;
      case PremiumButtonStyle.tertiary:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildContent(theme),
        );
        break;
      case PremiumButtonStyle.success:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
          ),
          child: _buildContent(theme),
        );
        break;
      case PremiumButtonStyle.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
          ),
          child: _buildContent(theme),
        );
        break;
    }
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
  
  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getHeight(),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                buttonStyle == PremiumButtonStyle.primary ||
                buttonStyle == PremiumButtonStyle.success ||
                buttonStyle == PremiumButtonStyle.danger
                    ? Colors.white
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: _getSpacing()),
          Text(label),
        ],
      );
    }
    
    return Text(label);
  }
  
  double _getHeight() {
    switch (size) {
      case PremiumButtonSize.small:
        return 36;
      case PremiumButtonSize.medium:
        return 44;
      case PremiumButtonSize.large:
        return 52;
    }
  }
  
  double _getIconSize() {
    switch (size) {
      case PremiumButtonSize.small:
        return 16;
      case PremiumButtonSize.medium:
        return 20;
      case PremiumButtonSize.large:
        return 24;
    }
  }
  
  double _getSpacing() {
    switch (size) {
      case PremiumButtonSize.small:
        return AppTheme.spacing6;
      case PremiumButtonSize.medium:
        return AppTheme.spacing8;
      case PremiumButtonSize.large:
        return AppTheme.spacing12;
    }
  }
}

enum PremiumButtonStyle {
  primary,
  secondary,
  tertiary,
  success,
  danger,
}

enum PremiumButtonSize {
  small,
  medium,
  large,
}

/// Icon-only button
class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurface,
      ),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? 
            (isDark ? AppTheme.darkSurfaceElevated : AppTheme.surfaceSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
      ),
    );
  }
}

