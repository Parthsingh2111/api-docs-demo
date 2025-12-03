import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/breadcrumb_navigation.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/scroll_to_top_button.dart';
import 'ott_subscription_checkout.dart';

class PayCollectSiUnifiedDocsScreen extends StatefulWidget {
  const PayCollectSiUnifiedDocsScreen({super.key});

  @override
  State<PayCollectSiUnifiedDocsScreen> createState() => _PayCollectSiUnifiedDocsScreenState();
}

class _PayCollectSiUnifiedDocsScreenState extends State<PayCollectSiUnifiedDocsScreen>
    with TickerProviderStateMixin {
  // State management
  String _activeSection = 'overview';
  bool _leftPanelCollapsed = false;
  final Map<String, bool> _parametersExpanded = {}; // Track which parameter sections are expanded
  final Map<String, bool> _navSectionsExpanded = {
    'ondemand-detection': true,
    'pause': true,
    'refund': true,
  }; // Track which navigation sections are expanded
  
  // Controllers
  final ScrollController _contentScrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  
  // Debouncing for smooth scroll detection
  DateTime? _lastScrollUpdate;
  Timer? _scrollDebounceTimer;
  
  // Animation controllers
  late AnimationController _leftPanelAnimController;
  late Animation<double> _leftPanelAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSectionKeys();
    _initializeAnimations();
    _contentScrollController.addListener(_onContentScrollDebounced);
  }
  
  void _onContentScrollDebounced() {
    // Cancel previous timer
    _scrollDebounceTimer?.cancel();
    
    // Set new timer to debounce scroll events
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _contentScrollController.hasClients) {
      _onContentScroll();
      }
    });
  }

  void _initializeSectionKeys() {
    final sections = [
      'overview',
      // Payment Initiation
      'api-si-initiate',
      // Payment Deduction
      'deduction-fixed-autodebit',
      'api-ondemand-deduction',
      // Mandate Management
      'api-si-status',
      'api-pause',
      'api-instant-pause',
      'api-pause-by-date',
      'api-activate',
      // Transaction Management
      'api-status-check',
      'api-full-refund',
      'api-partial-refund',
      'product-demo',
    ];
    for (var section in sections) {
      _sectionKeys[section] = GlobalKey();
    }
  }

  void _initializeAnimations() {
    _leftPanelAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _leftPanelAnimation = CurvedAnimation(
      parent: _leftPanelAnimController,
      curve: Curves.easeInOutCubic,
    );
    
    _leftPanelAnimController.value = 1.0; // Left panel starts expanded
  }

  void _onContentScroll() {
    // Check if widget is still mounted and controller is attached
    if (!mounted || !_contentScrollController.hasClients) {
      return;
    }

    // Prevent rapid updates - throttle to max once per 150ms
    final now = DateTime.now();
    if (_lastScrollUpdate != null && 
        now.difference(_lastScrollUpdate!).inMilliseconds < 150) {
      return; // Skip this update to prevent flickering
    }
    _lastScrollUpdate = now;
    
    // Detect which section is currently visible with improved accuracy
    String? newActiveSection;
    double closestDistance = double.infinity;
    
    // Find the section closest to the top of the viewport
    for (var entry in _sectionKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;

      if (context == null || !mounted) continue;

        try {
        final renderObject = context.findRenderObject();

        // More strict type checking to prevent casting errors
        if (renderObject == null) continue;
        if (renderObject is! RenderBox) continue;
        if (!renderObject.hasSize) continue;
        if (!renderObject.attached) continue; // Check if attached to render tree

        final position = renderObject.localToGlobal(Offset.zero);
            // Check if section is in viewport (with some tolerance)
            final distanceFromTop = (position.dy - 100).abs();
            
            // Prefer sections near the top of the viewport
            if (position.dy <= 300 && position.dy >= -100) {
              if (distanceFromTop < closestDistance) {
                closestDistance = distanceFromTop;
                newActiveSection = entry.key;
            }
          }
        } catch (e) {
        // Skip sections that can't be measured - ignore errors during scroll
          continue;
      }
    }
    
    // Update active section and trigger UI update (only if changed and mounted)
    // Defer setState to avoid layout glitches during scroll
    if (mounted && newActiveSection != null && newActiveSection != _activeSection) {
      final sectionToSet = newActiveSection; // Capture value for closure
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && sectionToSet != null && sectionToSet != _activeSection) {
          setState(() {
            _activeSection = sectionToSet;
          });
        }
      });
    }
  }

  void _scrollToSection(String sectionId) {
    final key = _sectionKeys[sectionId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
      setState(() {
        _activeSection = sectionId;
        // Auto-expand parent sections when child is selected
        if (sectionId == 'api-ondemand-deduction' || sectionId == 'deduction-variable-ondemand') {
          _navSectionsExpanded['ondemand-detection'] = true;
        } else if (sectionId == 'api-instant-pause' || sectionId == 'api-pause-by-date') {
          _navSectionsExpanded['pause'] = true;
        } else if (sectionId == 'api-full-refund' || sectionId == 'api-partial-refund') {
          _navSectionsExpanded['refund'] = true;
        }
      });
    }
  }

  void _toggleLeftPanel() {
    setState(() {
      _leftPanelCollapsed = !_leftPanelCollapsed;
      if (_leftPanelCollapsed) {
        _leftPanelAnimController.reverse();
      } else {
        _leftPanelAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _contentScrollController.removeListener(_onContentScrollDebounced);
    _contentScrollController.dispose();
    _leftPanelAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFFAFAFA),
      appBar: _buildAppBar(isDark, isDesktop),
      drawer: !isDesktop ? _buildDrawer(isDark) : null,
      body: isDesktop
          ? _buildDesktopLayout(isDark)
          : _buildMobileLayout(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isDesktop) {
    return AppBar(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: 0,
      leading: isDesktop 
          ? null
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (isDesktop) ...[
            SmartBackButton(
              parentPageName: 'PayCollect',
              parentRoute: '/paycollect',
              showLabel: false,
            ),
            const SizedBox(width: 12),
            Icon(Icons.account_balance_wallet, color: AppTheme.accent, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              'Standing Instructions API',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (isDesktop) ...[
          // API Reference Button
          Tooltip(
            message: 'View API Reference',
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/paycollect-api-reference-si');
              },
              icon: const Icon(Icons.code, size: 18),
              label: Text(
                'API Reference',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildPanelToggleButton(
            isDark,
            icon: Icons.menu_open,
            label: 'Navigation',
            onPressed: _toggleLeftPanel,
            isCollapsed: _leftPanelCollapsed,
            ),
          const SizedBox(width: 16),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildPanelToggleButton(
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isCollapsed,
  }) {
    return Tooltip(
      message: '${isCollapsed ? 'Show' : 'Hide'} $label',
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: isCollapsed
              ? (isDark ? Colors.white54 : Colors.black54)
              : AppTheme.accent,
        ),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isCollapsed
                ? (isDark ? Colors.white54 : Colors.black54)
                : AppTheme.accent,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: isCollapsed
              ? Colors.transparent
              : AppTheme.accent.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Navigation
            AnimatedBuilder(
              animation: _leftPanelAnimation,
              builder: (context, child) {
                final width = 280.0 * _leftPanelAnimation.value;
                return width > 0
                    ? Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          border: Border(
                            right: BorderSide(
                              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Opacity(
                          opacity: _leftPanelAnimation.value,
                          child: child,
                        ),
                      )
                    : const SizedBox.shrink();
              },
              child: _buildLeftPanel(isDark),
            ),

            // Content Panel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb Navigation
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: BreadcrumbNavigation(
                          items: [
                            BreadcrumbItem(
                              label: 'Home',
                              route: '/',
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => route.isFirst,
                              ),
                            ),
                            BreadcrumbItem(
                              label: 'PayCollect',
                              route: '/paycollect',
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/paycollect',
                                (route) => route.settings.name == '/paycollect' || route.isFirst,
                              ),
                            ),
                        const BreadcrumbItem(
                          label: 'Standing Instructions API',
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildContentPanel(isDark)),
                ],
              ),
            ),
          ],
        ),
        // Scroll to Top Button
        ScrollToTopButton(scrollController: _contentScrollController),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Stack(
      children: [
        _buildContentPanel(isDark),
        ScrollToTopButton(scrollController: _contentScrollController),
      ],
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        // Overview
        _buildNavItem(isDark, 'Overview', 'overview', Icons.info_outline),
        const SizedBox(height: 8),
        
        // Payment Initiation Category
        _buildCategoryHeader(isDark, 'PAYMENT INITIATION', Icons.rocket_launch),
        _buildNavItem(isDark, 'SI Initiate', 'api-si-initiate', Icons.play_arrow),
        const SizedBox(height: 8),
        
        // Payment Deduction Category
        _buildCategoryHeader(isDark, 'PAYMENT DEDUCTION', Icons.payment),
        _buildNavItem(isDark, 'Fixed + Auto Debit', 'deduction-fixed-autodebit', Icons.autorenew),
        _buildCollapsibleNavSection(
          isDark,
          'OnDemand Detection',
          'api-ondemand-deduction',
          Icons.payments,
          'ondemand-detection',
          [
            <String, dynamic>{
              'label': 'Variable + On-Demand',
              'sectionId': 'api-ondemand-deduction',
              'icon': Icons.touch_app,
            },
          ],
        ),
        const SizedBox(height: 8),
        
        // Mandate Management Category
        _buildCategoryHeader(isDark, 'MANDATE MANAGEMENT', Icons.settings),
        _buildNavItem(isDark, 'SI Status', 'api-si-status', Icons.assignment),
        _buildCollapsibleNavSection(
          isDark,
          'Pause',
          'api-pause',
          Icons.pause_circle_outline,
          'pause',
          [
            <String, dynamic>{
              'label': 'Instant Pause',
              'sectionId': 'api-instant-pause',
              'icon': Icons.pause,
            },
            <String, dynamic>{
              'label': 'Pause by Date',
              'sectionId': 'api-pause-by-date',
              'icon': Icons.schedule,
            },
          ],
        ),
        _buildNavItem(isDark, 'Activate Mandate', 'api-activate', Icons.play_circle_outline),
        const SizedBox(height: 8),
        
        // Transaction Management Category
        _buildCategoryHeader(isDark, 'TRANSACTION MANAGEMENT', Icons.receipt_long),
        _buildNavItem(isDark, 'Status Check', 'api-status-check', Icons.info),
        _buildCollapsibleNavSection(
          isDark,
          'Refund',
          'api-full-refund',
          Icons.refresh,
          'refund',
          [
            <String, dynamic>{
              'label': 'Full Refund',
              'sectionId': 'api-full-refund',
              'icon': Icons.check_circle,
            },
            <String, dynamic>{
              'label': 'Partial Refund',
              'sectionId': 'api-partial-refund',
              'icon': Icons.pie_chart,
            },
          ],
        ),
        const SizedBox(height: 16),
        
        // Product Demo
        _buildCategoryHeader(isDark, 'PRODUCT DEMO', Icons.play_circle_outline),
        _buildNavItem(isDark, 'Try Demo', 'product-demo', Icons.subscriptions),
      ],
    );
  }

  Widget _buildCategoryHeader(bool isDark, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.accent,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    bool isDark,
    String label,
    String sectionId,
    IconData icon, {
    bool isParent = false,
    bool isChild = false,
  }) {
    final isActive = _activeSection == sectionId;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scrollToSection(sectionId),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withOpacity(isDark ? 0.2 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: isActive ? AppTheme.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? AppTheme.accent
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleNavSection(
    bool isDark,
    String parentLabel,
    String parentSectionId,
    IconData parentIcon,
    String sectionKey,
    List<Map<String, dynamic>> children,
  ) {
    // Ensure the section key exists in the map
    if (!_navSectionsExpanded.containsKey(sectionKey)) {
      _navSectionsExpanded[sectionKey] = true;
    }
    final isExpanded = _navSectionsExpanded[sectionKey] ?? true;
    
    // Only highlight parent if parent itself is active, not when child is active
    final isParentActive = _activeSection == parentSectionId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _navSectionsExpanded[sectionKey] = !isExpanded;
              });
              if (!isExpanded) {
                _scrollToSection(parentSectionId);
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isParentActive
                    ? AppTheme.accent.withOpacity(isDark ? 0.15 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border(
                  left: BorderSide(
                    color: isParentActive ? AppTheme.accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: isParentActive
                        ? AppTheme.accent
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    parentIcon,
                    size: 16,
                    color: isParentActive
                        ? AppTheme.accent
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      parentLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isParentActive ? FontWeight.w600 : FontWeight.w500,
                        color: isParentActive
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: children.asMap().entries.map((entry) {
                    final index = entry.key;
                    final child = entry.value;
                    
                    // Safely extract values with null checks
                    String label = '';
                    String sectionId = '';
                    IconData icon = Icons.info;
                    
                    try {
                      if (child != null && child is Map) {
                        label = (child['label'] ?? '').toString();
                        sectionId = (child['sectionId'] ?? '').toString();
                        final iconData = child['icon'];
                        if (iconData != null && iconData is IconData) {
                          icon = iconData;
                        }
                      }
                    } catch (e) {
                      // Use defaults if extraction fails
                    }
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < children.length - 1 ? 2 : 0,
                      ),
                      child: _buildNavItem(
                        isDark,
                        label,
                        sectionId,
                        icon,
                        isChild: false, // Not a child visually - same alignment
                      ),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }


  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBackground : const Color(0xFFFAFAFA),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: AppTheme.accent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Standing Instructions',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'API Documentation',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildLeftPanel(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPanel(bool isDark) {
    return SingleChildScrollView(
      controller: _contentScrollController,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentSections(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSections(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Section
        Container(key: _sectionKeys['overview']),
        _buildOverviewSection(isDark),
        const SizedBox(height: 48),
        
        Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        const SizedBox(height: 40),

        // PAYMENT INITIATION
        _buildSectionCategoryHeader(isDark, 'PAYMENT INITIATION', Icons.rocket_launch, AppTheme.accent),
        const SizedBox(height: 24),
        
        Container(key: _sectionKeys['api-si-initiate']),
        _buildApiSiInitiateInfo(isDark),
        const SizedBox(height: 48),
        
        Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        const SizedBox(height: 40),

        // PAYMENT DEDUCTION
        _buildSectionCategoryHeader(isDark, 'PAYMENT DEDUCTION', Icons.payment, const Color(0xFF10B981)),
        const SizedBox(height: 24),
        
        Container(key: _sectionKeys['deduction-fixed-autodebit']),
        _buildFixedAutoDebitSection(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-ondemand-deduction']),
        _buildApiOnDemandInfo(isDark),
        const SizedBox(height: 48),
        
        Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        const SizedBox(height: 40),

        // MANDATE MANAGEMENT
        _buildSectionCategoryHeader(isDark, 'MANDATE MANAGEMENT', Icons.settings, const Color(0xFF7C3AED)),
        const SizedBox(height: 24),
        
        Container(key: _sectionKeys['api-si-status']),
        _buildApiSiStatusInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-pause']),
        _buildApiPauseInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-instant-pause']),
        _buildApiInstantPauseInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-pause-by-date']),
        _buildApiPauseByDateInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-activate']),
        _buildApiActivateInfo(isDark),
        const SizedBox(height: 48),
        
        Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        const SizedBox(height: 40),

        // TRANSACTION MANAGEMENT
        _buildSectionCategoryHeader(isDark, 'TRANSACTION MANAGEMENT', Icons.receipt_long, const Color(0xFFF59E0B)),
        const SizedBox(height: 24),
        
        Container(key: _sectionKeys['api-status-check']),
        _buildApiStatusCheckInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-full-refund']),
        _buildApiFullRefundInfo(isDark),
        const SizedBox(height: 32),

        Container(key: _sectionKeys['api-partial-refund']),
        _buildApiPartialRefundInfo(isDark),
        const SizedBox(height: 48),

        Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        const SizedBox(height: 40),

        // PRODUCT DEMO
        Container(key: _sectionKeys['product-demo']),
        _buildProductDemoSection(isDark),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSectionCategoryHeader(bool isDark, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.15 : 0.1),
            color.withOpacity(isDark ? 0.05 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Section builders will be continued...
  Widget _buildOverviewSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          isDark,
          'Standing Instructions API',
          'Understanding Recurring Payments with Pre-Authorized Mandates',
        ),
        const SizedBox(height: 20),
        Text(
          'Standing Instructions (SI) enable merchants to charge customers on a recurring basis with pre-authorized mandates. This powerful payment solution is perfect for subscriptions, EMI payments, utility bills, and any scenario requiring automatic recurring charges.',
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          isDark,
          '💡 Key Concept',
          'Customers authorize once during the initial payment, and the returned Mandate ID allows subsequent charges without re-authentication.',
          AppTheme.info,
        ),
        const SizedBox(height: 24),
        _buildFeatureGrid(isDark),
      ],
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark, String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isDark) {
    final features = [
      {
        'icon': Icons.repeat,
        'title': 'Mandate-Based',
        'desc': 'One-time authorization for multiple payments',
      },
      {
        'icon': Icons.sync_alt,
        'title': 'Flexible Types',
        'desc': 'Fixed amount or Variable within ceiling',
      },
      {
        'icon': Icons.schedule,
        'title': 'Auto or Manual',
        'desc': 'Autodebit or ONDEMAND merchant control',
      },
      {
        'icon': Icons.verified_user,
        'title': 'Secure & Compliant',
        'desc': 'PCI DSS compliant automated billing',
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features.map((feature) {
        return Container(
          width: 250,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppTheme.accent,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feature['desc'] as String,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Widget _buildFixedAutoDebitSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.autorenew, color: AppTheme.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fixed + Auto Debit',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'frequency: DAILY/WEEKLY/MONTHLY',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PayGlocal automatically debits the fixed amount based on your schedule. Zero merchant intervention required after initial mandate setup.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariableOnDemandSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.touch_app, color: const Color(0xFF7C3AED), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variable + On-Demand',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'frequency: ONDEMAND',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum flexibility—YOU control both timing AND amount. Call the OnDemand Deduction API whenever you want to charge, specifying any amount up to maxAmount.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  // API Section implementations
  // ===== BUSINESS-FOCUSED API INFORMATION SECTIONS =====

  Widget _buildApiSiInitiateInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBusinessInfoSection(
      isDark: isDark,
      title: 'SI Initiate - Creating Payment Mandates',
      icon: Icons.rocket_launch,
      iconColor: const Color(0xFF3B82F6),
      description: 'SI Initiate is the foundation of recurring payments. It creates a mandate that authorizes you to charge customers automatically on scheduled dates or on-demand.',
      sections: [
        {'title': 'What It Does', 'content': 'Creates a standing instruction mandate linked to a customer\'s payment method. The customer approves this mandate during the first payment, giving you permission for future charges.'},
        {'title': 'When to Use', 'content': 'Use SI Initiate when onboarding customers for subscriptions, EMIs, utility bill payments, or any recurring payment scenario. This is always the first step.'},
        {'title': 'Mandate ID is Critical', 'content': 'The response includes a Mandate ID - store this securely! You\'ll need it for all future operations: charging, checking status, pausing, or reactivating the mandate.'},
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.autorenew, color: AppTheme.accent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fixed SI',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Use for subscriptions, EMIs, or any scenario where the same amount needs to be charged every time. Perfect for predictable, recurring billing.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.touch_app, color: const Color(0xFF7C3AED), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Variable SI',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Use for utility bills, usage-based services, or scenarios where amounts vary. Set a maximum ceiling, then charge any amount up to that limit.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApiOnDemandInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variable + On-Demand header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.touch_app, color: const Color(0xFF7C3AED), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variable + On-Demand',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'frequency: ONDEMAND',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum flexibility—YOU control both timing AND amount. Call the OnDemand Deduction API whenever you want to charge, specifying any amount up to maxAmount.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 24),
          // On-Demand Deduction API section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: const Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'On-Demand Deduction - Executing Charges',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Execute a payment against an existing mandate whenever you need to charge the customer. This applies to Variable SI mandates with ONDEMAND frequency.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 20),
          ...[
            {'title': 'What It Does', 'content': 'Charges the customer\'s linked payment method using a previously created VARIABLE mandate. You specify the amount each time, up to the maximum ceiling set during mandate creation.'},
            {'title': 'When to Use', 'content': 'Use this API when you need to trigger a payment: billing cycle arrived, service usage accumulated, or customer requested a top-up. Only works with VARIABLE SI mandates.'},
        {'title': 'Business Scenarios', 'content': 'Perfect for variable utility bills, usage-based charging, one-time top-ups within subscription plans, or scheduled billing dates where you control timing.'},
        {'title': 'Payment Confirmation', 'content': 'The API returns immediately with status. Final payment confirmation comes via webhook - always implement webhook handlers for production systems.'},
          ].map((section) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder.withOpacity(0.5) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title']!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['content']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildApiStatusCheckInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info, color: AppTheme.info, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Status Check',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Check the current status of any payment transaction using its Global ID (gid). This API provides real-time transaction status, payment method used, amount details, and complete transaction history.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder.withOpacity(0.5) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Points',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...['Real-time transaction status updates',
                    'Returns payment method and amount details',
                    'Includes authorization codes and timestamps',
                    'Shows complete transaction lifecycle',
                    'Essential for reconciliation and reporting',
                    'Can be called multiple times without side effects',
                ].map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.info,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ),
      ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiPauseInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Pause Mandate - Temporary Suspension',
      icon: Icons.pause_circle_outline,
      iconColor: const Color(0xFFF59E0B),
      description: 'Temporarily stop charges without canceling the mandate permanently. You can pause instantly or schedule a pause from a specific future date (pause-by-date).',
      sections: [
        {'title': 'Business Scenarios', 'content': 'Customer requests payment holiday, account under dispute investigation, seasonal service pause (e.g., gym membership freeze), insufficient funds - give customer time to add funds, or payment method update in progress.'},
        {'title': 'Pause Types', 'content': 'Instant pause stops charges immediately from now. Pause-by-date lets you choose a future date from which charges should stop (for example, pause from next billing cycle).'},
        {'title': 'Impact on Billing', 'content': 'No charges will occur while paused. Billing cycle doesn\'t advance during the pause window. All mandate details are preserved so it\'s easy to resume when ready.'},
        {'title': 'When to Use', 'content': 'Use pause when the issue is temporary and customer intends to continue. Don\'t use for permanent cancellations - those require different handling.'},
        {'title': 'Customer Communication', 'content': 'Always inform customers when pausing their mandate. Explain the reason and expected resume date. This builds trust and reduces support tickets.'},
      ],
    );
  }

  Widget _buildApiActivateInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Activate Mandate - Resuming Charges',
      icon: Icons.play_circle_outline,
      iconColor: const Color(0xFF10B981),
      description: 'Resume a paused mandate to restart recurring charges.',
      sections: [
        {'title': 'Business Use Cases', 'content': 'Customer resolves payment issue, dispute settled in your favor, seasonal service resumes, customer updates payment method successfully, or free trial/payment holiday ends.'},
        {'title': 'What Happens After Activation', 'content': 'Mandate becomes active immediately. Next scheduled charge proceeds as normal. All original mandate details preserved. Billing cycle continues from where it left off.'},
        {'title': 'When to Activate', 'content': 'Only activate after confirming the reason for pause is resolved. Verify with customer when appropriate. Ensure payment method is still valid and has sufficient funds.'},
        {'title': 'Operational Best Practice', 'content': 'Send customer confirmation when reactivating. Schedule first charge thoughtfully - don\'t surprise customers. Update your billing system to reflect active status immediately.'},
      ],
    );
  }

  Widget _buildBusinessInfoSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required List<Map<String, String>> sections,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ...sections.map((section) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder.withOpacity(0.5) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title']!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['content']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  // New API Info Methods
  Widget _buildApiSiStatusInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'SI Status Check',
      icon: Icons.assignment,
      iconColor: AppTheme.info,
      description: 'Check the current status and details of a standing instruction mandate.',
      sections: [
        {'title': 'What It Does', 'content': 'Retrieves comprehensive information about an SI mandate including its current state, payment history, and next scheduled payment.'},
        {'title': 'When to Use', 'content': 'Check before making deductions, customer service inquiries, reporting and reconciliation, or monitoring mandate health.'},
        {'title': 'Key Information', 'content': 'Returns mandate status (ACTIVE/PAUSED/CANCELLED), total debits processed, remaining payments, and next billing date.'},
      ],
    );
  }

  Widget _buildApiInstantPauseInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Instant Pause',
      icon: Icons.pause,
      iconColor: AppTheme.warning,
      description: 'Immediately pause a mandate effective from the current moment.',
      sections: [
        {'title': 'Immediate Effect', 'content': 'The mandate is paused instantly. Any scheduled payments from this moment onwards will not be processed.'},
        {'title': 'Use Cases', 'content': 'Customer requests immediate suspension, payment disputes, insufficient funds detected, or compliance requirements.'},
        {'title': 'Reactivation', 'content': 'Use the Activate API to resume the mandate when the issue is resolved.'},
      ],
    );
  }

  Widget _buildApiPauseByDateInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Pause by Date',
      icon: Icons.schedule,
      iconColor: AppTheme.warning,
      description: 'Schedule a mandate pause to begin from a specific future date.',
      sections: [
        {'title': 'Scheduled Pause', 'content': 'Specify a future date from which the mandate should be paused. Payments before this date will continue normally.'},
        {'title': 'Business Scenarios', 'content': 'Planned service interruptions, seasonal business closures, customer-requested future holds, or billing cycle adjustments.'},
        {'title': 'Flexibility', 'content': 'Allows you to plan ahead and communicate changes to customers in advance while maintaining current billing.'},
      ],
    );
  }

  Widget _buildApiFullRefundInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Full Refund',
      icon: Icons.check_circle,
      iconColor: AppTheme.success,
      description: 'Refund the complete transaction amount in one operation.',
      sections: [
        {'title': 'Complete Refund', 'content': 'Refunds the entire deducted amount back to the customer. Simplest refund method for complete cancellations.'},
        {'title': 'When to Use', 'content': 'Complete order cancellations, service not delivered as promised, customer satisfaction gestures, or dispute resolutions.'},
        {'title': 'Processing Time', 'content': 'Typically processes within 5-7 business days. Webhook notification sent upon completion.'},
      ],
    );
  }

  Widget _buildApiPartialRefundInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      title: 'Partial Refund',
      icon: Icons.pie_chart,
      iconColor: AppTheme.warning,
      description: 'Refund a specific amount from a completed transaction.',
      sections: [
        {'title': 'Flexible Refunds', 'content': 'Refund any amount up to the total transaction amount. Multiple partial refunds allowed until full amount is refunded.'},
        {'title': 'Business Use Cases', 'content': 'Partial service cancellations, price adjustments, promotional credits, or goodwill gestures.'},
        {'title': 'Processing', 'content': 'Each partial refund requires a unique transaction ID. Refunds typically process within 5-7 business days.'},
      ],
    );
  }

  Widget _buildProductDemoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  size: 28,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Demo',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Experience Standing Instructions in action',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Try our interactive demo to see how Standing Instructions work in a real subscription scenario. Experience the complete flow from subscription setup to recurring payments.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OttSubscriptionCheckoutScreen(isPayDirect: false),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Launch Product Demo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

