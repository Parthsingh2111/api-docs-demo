import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium badge component for status indicators
class PremiumBadge extends StatelessWidget {
  final String label;
  final PremiumBadgeVariant variant;
  final PremiumBadgeSize size;
  final IconData? icon;
  
  const PremiumBadge({
    super.key,
    required this.label,
    this.variant = PremiumBadgeVariant.neutral,
    this.size = PremiumBadgeSize.medium,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: colors.foreground,
            ),
            SizedBox(width: _getSpacing()),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
              fontSize: _getFontSize(),
            ),
          ),
        ],
      ),
    );
  }
  
  _BadgeColors _getColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    switch (variant) {
      case PremiumBadgeVariant.success:
        return _BadgeColors(
          background: AppTheme.successLight,
          foreground: AppTheme.success,
          border: AppTheme.success.withOpacity(0.2),
        );
      case PremiumBadgeVariant.warning:
        return _BadgeColors(
          background: AppTheme.warningLight,
          foreground: const Color(0xFF92400E),
          border: AppTheme.warning.withOpacity(0.2),
        );
      case PremiumBadgeVariant.error:
        return _BadgeColors(
          background: AppTheme.errorLight,
          foreground: AppTheme.error,
          border: AppTheme.error.withOpacity(0.2),
        );
      case PremiumBadgeVariant.info:
        return _BadgeColors(
          background: AppTheme.infoLight,
          foreground: AppTheme.info,
          border: AppTheme.info.withOpacity(0.2),
        );
      case PremiumBadgeVariant.primary:
        return _BadgeColors(
          background: AppTheme.accentLight.withOpacity(0.15),
          foreground: AppTheme.accent,
          border: AppTheme.accent.withOpacity(0.2),
        );
      case PremiumBadgeVariant.neutral:
        return _BadgeColors(
          background: isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray100,
          foreground: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          border: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
        );
    }
  }
  
  EdgeInsets _getPadding() {
    switch (size) {
      case PremiumBadgeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing6,
          vertical: AppTheme.spacing4,
        );
      case PremiumBadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing8,
          vertical: AppTheme.spacing4,
        );
      case PremiumBadgeSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing6,
        );
    }
  }
  
  double _getIconSize() {
    switch (size) {
      case PremiumBadgeSize.small:
        return 12;
      case PremiumBadgeSize.medium:
        return 14;
      case PremiumBadgeSize.large:
        return 16;
    }
  }
  
  double _getFontSize() {
    switch (size) {
      case PremiumBadgeSize.small:
        return 10;
      case PremiumBadgeSize.medium:
        return 11;
      case PremiumBadgeSize.large:
        return 12;
    }
  }
  
  double _getSpacing() {
    switch (size) {
      case PremiumBadgeSize.small:
        return AppTheme.spacing4;
      case PremiumBadgeSize.medium:
        return AppTheme.spacing4;
      case PremiumBadgeSize.large:
        return AppTheme.spacing6;
    }
  }
}

class _BadgeColors {
  final Color background;
  final Color foreground;
  final Color border;
  
  _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

enum PremiumBadgeVariant {
  neutral,
  primary,
  success,
  warning,
  error,
  info,
}

enum PremiumBadgeSize {
  small,
  medium,
  large,
}

/// Product showcase card for PayDirect/PayCollect
class ProductShowcaseCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final VoidCallback onExplore;
  final VoidCallback? onCompare;
  
  const ProductShowcaseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.onExplore,
    this.onCompare,
  });

  @override
  State<ProductShowcaseCard> createState() => _ProductShowcaseCardState();
}

class _ProductShowcaseCardState extends State<ProductShowcaseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surfacePrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: _isHovered 
                ? widget.accentColor.withOpacity(0.3)
                : (isDark ? AppTheme.darkBorder : AppTheme.borderLight),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? AppTheme.shadowLG : AppTheme.shadowMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.accentColor.withOpacity(0.1),
                    widget.accentColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLG),
                  topRight: Radius.circular(AppTheme.radiusLG),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing12),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: widget.accentColor,
                        ),
                      ),
                      const Spacer(),
                      PremiumBadge(
                        label: widget.badge,
                        variant: PremiumBadgeVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  const Divider(height: 1),
                  const SizedBox(height: AppTheme.spacing20),
                  
                  // Features
                  ...widget.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: widget.accentColor,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onExplore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Explore'),
                        ),
                      ),
                      if (widget.onCompare != null) ...[
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCompare,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: widget.accentColor,
                              side: BorderSide(
                                color: widget.accentColor,
                                width: 1.5,
                              ),
                            ),
                            child: const Text('Compare'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

