import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_router.dart';

class ComprehensiveNavigation extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final bool isCollapsed;
  final bool showToggleButton;
  final VoidCallback? onToggle;

  const ComprehensiveNavigation({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.isCollapsed = false,
    this.showToggleButton = true,
    this.onToggle,
  });

  @override
  State<ComprehensiveNavigation> createState() => _ComprehensiveNavigationState();
}

class _ComprehensiveNavigationState extends State<ComprehensiveNavigation>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _fadeController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  
  String? _hoveredItem;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Start collapsed by default
    _expandController.value = 0.0;
    _fadeController.value = 0.0;
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ComprehensiveNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Remove manual toggle behavior - now controlled by hover
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _expandController.forward();
        _fadeController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _expandController.reverse();
        _fadeController.reverse();
      },
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final width = 60 + (220 * _expandAnimation.value);
          return Container(
            width: width,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurface : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
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
                // Navigation Content
                Expanded(
                  child: _isHovered 
                      ? _buildExpandedNavigation(isDarkMode)
                      : _buildCollapsedNavigation(isDarkMode),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildCollapsedNavigation(bool isDarkMode) {
    final mainSections = _getMainSections();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      itemCount: mainSections.length,
      itemBuilder: (context, index) {
        final section = mainSections[index];
        final isActive = _isRouteActive(section.route);
        
        return _buildCollapsedNavItem(
          section,
          isActive,
          isDarkMode,
        );
      },
    );
  }

  Widget _buildExpandedNavigation(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizeTransition(
        sizeFactor: _expandAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Navigation Sections
              _buildMainSections(isDarkMode),
              // Extra breathing space to feel filled
              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSections(bool isDarkMode) {
    final mainSections = _getMainSections();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Text(
            'Main Sections',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...mainSections.map((section) => _buildNavItem(section, isDarkMode)),
        const SizedBox(height: AppTheme.spacing24),
      ],
    );
  }


  Widget _buildCollapsedNavItem(NavSection section, bool isActive, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing8,
      ),
      child: Tooltip(
        message: section.title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.spacing8),
            onTap: () => widget.onNavigate(section.route),
            onHover: (hovered) {
              setState(() {
                _hoveredItem = hovered ? section.route : null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : _hoveredItem == section.route
                        ? (isDarkMode ? AppTheme.darkSurfaceElevated : const Color(0xFFF8FAFC))
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.spacing8),
                border: isActive
                    ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))
                    : null,
              ),
              child: Icon(
                section.icon,
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavSection section, bool isDarkMode) {
    final isActive = _isRouteActive(section.route);
    final isHovered = _hoveredItem == section.route;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.spacing8),
          onTap: () => widget.onNavigate(section.route),
          onHover: (hovered) {
            setState(() {
              _hoveredItem = hovered ? section.route : null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : isHovered
                      ? (isDarkMode ? AppTheme.darkSurfaceElevated : const Color(0xFFF8FAFC))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.spacing8),
              border: isActive
                  ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  section.icon,
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    section.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (section.badge != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: section.badgeColor ?? const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(AppTheme.spacing4),
                      ),
                      child: Text(
                        section.badge!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool _isRouteActive(String route) {
    return widget.currentRoute == route;
  }



  List<NavSection> _getMainSections() {
    return [
      NavSection(
        title: 'Overview',
        route: AppRouter.home,
        icon: Icons.home,
      ),
      NavSection(
        title: 'PayCollect',
        route: AppRouter.paycollect,
        icon: Icons.shield,
        badge: 'Non-PCI',
        badgeColor: const Color(0xFF3B82F6),
      ),
      NavSection(
        title: 'PayDirect',
        route: AppRouter.paydirect,
        icon: Icons.credit_card,
        badge: 'PCI DSS',
        badgeColor: const Color(0xFF10B981),
      ),
      // CodeDrop quick navigation
      NavSection(
        title: 'CodeDrop',
        route: AppRouter.codedrop,
        icon: Icons.cloud_download,
      ),
      NavSection(
        title: 'Services',
        route: AppRouter.services,
        icon: Icons.api,
        badge: '3',
        badgeColor: const Color(0xFF8B5CF6),
      ),
      NavSection(
        title: 'Payload',
        route: AppRouter.payload,
        icon: Icons.data_object,
      ),
      NavSection(
        title: 'Payment Flow',
        route: AppRouter.visualization,
        icon: Icons.account_tree,
      ),
      NavSection(
        title: 'SDKs',
        route: AppRouter.sdks,
        icon: Icons.code,
        badge: '4',
        badgeColor: const Color(0xFF10B981),
      ),
      NavSection(
        title: 'Webhooks Docs',
        route: AppRouter.webhooksDocumentation,
        icon: Icons.webhook,
      ),
      NavSection(
        title: 'Payment Response',
        route: AppRouter.paymentResponseHandling,
        icon: Icons.receipt_long,
      ),
    ];
  }

}

class NavSection {
  final String title;
  final String route;
  final IconData icon;
  final String? badge;
  final Color? badgeColor;

  NavSection({
    required this.title,
    required this.route,
    required this.icon,
    this.badge,
    this.badgeColor,
  });
}

class PageNavItem {
  final String id;
  final String title;

  PageNavItem({
    required this.id,
    required this.title,
  });
}
