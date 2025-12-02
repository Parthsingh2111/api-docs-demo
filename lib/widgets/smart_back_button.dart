import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_router.dart';

class SmartBackButton extends StatefulWidget {
  final String? parentPageName;
  final String? parentRoute;
  final VoidCallback? onPressed;
  final bool showLabel;

  const SmartBackButton({
    super.key,
    this.parentPageName,
    this.parentRoute,
    this.onPressed,
    this.showLabel = true,
  });

  @override
  State<SmartBackButton> createState() => _SmartBackButtonState();
}

class _SmartBackButtonState extends State<SmartBackButton> {
  bool _isHovered = false;

  void _handleNavigation() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    final navigator = Navigator.of(context);
    
    // If parent route is specified, navigate directly to it (clearing stack)
    if (widget.parentRoute != null) {
      navigator.pushNamedAndRemoveUntil(
        widget.parentRoute!,
        (route) => route.settings.name == widget.parentRoute || route.isFirst,
      );
    } else if (navigator.canPop()) {
      // Otherwise, just pop if possible
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();
    final hasParentRoute = widget.parentRoute != null;

    // Hide if can't navigate back and no custom handler
    if (!canPop && widget.onPressed == null && !hasParentRoute) {
      return const SizedBox.shrink();
    }

    final label = widget.parentPageName != null
        ? 'Back to ${_truncateLabel(widget.parentPageName!)}'
        : 'Back';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleNavigation,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF3F4F6))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.accent.withOpacity(0.3)
                    : (isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: _isHovered
                      ? AppTheme.accent
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                if (widget.showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _isHovered
                          ? AppTheme.accent
                          : (isDark ? Colors.white70 : Colors.black54),
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

  String _truncateLabel(String label) {
    if (label.length <= 20) return label;
    return '${label.substring(0, 17)}...';
  }
}

