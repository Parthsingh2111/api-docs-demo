import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool collapseOnMobile;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.collapseOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile && collapseOnMobile && items.length > 2) {
      return _buildCollapsedBreadcrumb(isDark);
    }

    return _buildFullBreadcrumb(isDark);
  }

  Widget _buildFullBreadcrumb(bool isDark) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withOpacity(0.5) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildBreadcrumbItem(items[i], i == items.length - 1, isDark),
            if (i < items.length - 1) _buildSeparator(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsedBreadcrumb(bool isDark) {
    // Show first item ... last item on mobile
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withOpacity(0.5) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBreadcrumbItem(items.first, false, isDark),
          _buildSeparator(isDark),
          Icon(
            Icons.more_horiz,
            size: 16,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          _buildSeparator(isDark),
          _buildBreadcrumbItem(items.last, true, isDark),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, bool isLast, bool isDark) {
    final textColor = isLast
        ? AppTheme.accent
        : (isDark ? Colors.white70 : Colors.black54);

    if (isLast || item.route == null) {
      return Text(
        item.label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
          color: textColor,
        ),
      );
    }

    return InkWell(
      onTap: () => item.onTap?.call(),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '›',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.onTap,
  });
}

