import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_router.dart';
import '../widgets/breadcrumb_navigation.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/scroll_to_top_button.dart';
import 'merchant_product_interface.dart';

class PayCollectJwtDetailScreen extends StatefulWidget {
  const PayCollectJwtDetailScreen({super.key});

  @override
  State<PayCollectJwtDetailScreen> createState() => _PayCollectJwtDetailScreenState();
}

class _PayCollectJwtDetailScreenState extends State<PayCollectJwtDetailScreen>
    with TickerProviderStateMixin {
  // State management
  String _activeSection = 'overview';
  bool _leftPanelCollapsed = false;
  
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
    _scrollDebounceTimer?.cancel();
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
      'api-payment-initiate',
      // Transaction Management
      'api-status-check',
      'api-refund-partial',
      'api-refund-full',
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
    
    _leftPanelAnimController.value = 1.0;
  }

  void _onContentScroll() {
    // Check if widget is still mounted and controller is attached
    if (!mounted || !_contentScrollController.hasClients) {
      return;
    }

    final now = DateTime.now();
    if (_lastScrollUpdate != null && 
        now.difference(_lastScrollUpdate!).inMilliseconds < 150) {
      return;
    }
    _lastScrollUpdate = now;
    
    String? newActiveSection;
    double closestDistance = double.infinity;
    
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
            final distance = (position.dy - 100).abs();
            
            if (distance < closestDistance) {
              closestDistance = distance;
              newActiveSection = entry.key;
          }
        } catch (e) {
        // Silently skip sections that can't be measured during layout
        continue;
      }
    }
    
    // Update active section only if mounted and changed
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

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _contentScrollController.removeListener(_onContentScrollDebounced);
    _contentScrollController.dispose();
    _leftPanelAnimController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionId) {
    final key = _sectionKeys[sectionId];
    if (key?.currentContext != null) {
    setState(() {
        _activeSection = sectionId;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        } catch (e) {
          // Fallback to manual scroll
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFFAFBFC),
      appBar: _buildAppBar(isDark, isDesktop),
      drawer: !isDesktop ? _buildDrawer(isDark) : null,
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (Desktop only)
              if (isDesktop) _buildLeftPanel(isDark),
              
              // Main Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb Navigation
                    if (isDesktop)
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
                              label: 'JWT Authentication',
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildContentPanel(isDark, isDesktop, isTablet)),
                  ],
                ),
              ),
            ],
          ),
          // Scroll to Top Button
          ScrollToTopButton(scrollController: _contentScrollController),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isDesktop) {
    return AppBar(
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
              parentRoute: AppRouter.paycollect,
              showLabel: false,
            ),
            const SizedBox(width: 12),
          ],
          Icon(Icons.security, color: AppTheme.info, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'JWT Authentication',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: 0,
      actions: [
        // API Reference Button
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to API Reference, but allow back to return here
            Navigator.pushNamed(context, AppRouter.paycollectApiReferenceJwt);
          },
          icon: const Icon(Icons.code, size: 18),
          label: Text(
            'API Reference',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
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

  Widget _buildLeftPanel(bool isDark) {
    return AnimatedBuilder(
      animation: _leftPanelAnimation,
      builder: (context, child) {
        return Container(
          width: 280 * _leftPanelAnimation.value,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          child: _leftPanelAnimation.value > 0.5
              ? ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  children: [
                    // Overview
                    _buildNavItem(isDark, 'Overview', 'overview', Icons.info_outline),
                    const SizedBox(height: 8),
                    
                    // Payment Initiation Category
                    _buildCategoryHeader(isDark, 'PAYMENT INITIATION', Icons.rocket_launch),
                    _buildNavItem(isDark, 'Payment Initiate', 'api-payment-initiate', Icons.payment),
                    const SizedBox(height: 8),
                    
                    // Transaction Management Category
                    _buildCategoryHeader(isDark, 'TRANSACTION MANAGEMENT', Icons.receipt_long),
                    _buildNavItem(isDark, 'Status Check', 'api-status-check', Icons.info),
                    _buildNavItem(isDark, 'Partial Refund', 'api-refund-partial', Icons.pie_chart),
                    _buildNavItem(isDark, 'Full Refund', 'api-refund-full', Icons.check_circle),
                    const SizedBox(height: 16),
                    
                    // Product Demo
                    _buildCategoryHeader(isDark, 'PRODUCT DEMO', Icons.play_circle_outline),
                    _buildNavItem(isDark, 'Try Demo', 'product-demo', Icons.shopping_cart),
                  ],
                )
              : null,
        );
      },
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
                      Icon(Icons.security, color: AppTheme.info, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JWT Authentication',
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildNavItem(isDark, 'Overview', 'overview', Icons.info_outline, closeDrawerOnTap: true),
                const SizedBox(height: 8),
                
                _buildCategoryHeader(isDark, 'PAYMENT INITIATION', Icons.rocket_launch),
                _buildNavItem(isDark, 'Payment Initiate', 'api-payment-initiate', Icons.payment, closeDrawerOnTap: true),
                const SizedBox(height: 8),
                
                _buildCategoryHeader(isDark, 'TRANSACTION MANAGEMENT', Icons.receipt_long),
                _buildNavItem(isDark, 'Status Check', 'api-status-check', Icons.info, closeDrawerOnTap: true),
                _buildNavItem(isDark, 'Partial Refund', 'api-refund-partial', Icons.pie_chart, closeDrawerOnTap: true),
                _buildNavItem(isDark, 'Full Refund', 'api-refund-full', Icons.check_circle, closeDrawerOnTap: true),
                const SizedBox(height: 16),
                
                // Product Demo
                _buildCategoryHeader(isDark, 'PRODUCT DEMO', Icons.play_circle_outline),
                _buildNavItem(isDark, 'Try Demo', 'product-demo', Icons.shopping_cart, closeDrawerOnTap: true),
              ],
            ),
          ),
        ],
      ),
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
    bool closeDrawerOnTap = false,
  }) {
    final isActive = _activeSection == sectionId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _scrollToSection(sectionId);
          if (closeDrawerOnTap && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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


  Widget _buildContentPanel(bool isDark, bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      controller: _contentScrollController,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24, vertical: 24),
        child: Column(
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

            Container(key: _sectionKeys['api-payment-initiate']),
            _buildApiPaymentInitiateInfo(isDark),
            const SizedBox(height: 48),

            Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
            const SizedBox(height: 40),

            // TRANSACTION MANAGEMENT
            _buildSectionCategoryHeader(isDark, 'TRANSACTION MANAGEMENT', Icons.receipt_long, const Color(0xFFF59E0B)),
            const SizedBox(height: 24),

            Container(key: _sectionKeys['api-status-check']),
            _buildApiStatusCheckInfo(isDark),
            const SizedBox(height: 32),

            Container(key: _sectionKeys['api-refund-partial']),
            _buildApiPartialRefundInfo(isDark),
            const SizedBox(height: 32),

            Container(key: _sectionKeys['api-refund-full']),
            _buildApiFullRefundInfo(isDark),
            const SizedBox(height: 48),

            Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
            const SizedBox(height: 40),

            // PRODUCT DEMO
            Container(key: _sectionKeys['product-demo']),
            _buildProductDemoSection(isDark),
            const SizedBox(height: 48),
          ],
        ),
      ),
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

  Widget _buildOverviewSection(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      icon: Icons.info_outline,
      iconColor: AppTheme.info,
      title: 'JWT Authentication - Overview',
      description: 'JWT (JSON Web Token) authentication provides a secure, stateless way to handle payment transactions. PayGlocal uses JWT with JWE (encryption) and JWS (signature) to ensure your payment data remains secure throughout the transaction lifecycle.',
      keyPoints: [
        'Immediate payment capture upon successful authorization',
        'Secure token-based authentication for all API calls',
        'Real-time transaction status tracking',
        'Support for full and partial refunds',
        'Suitable for one-time payment scenarios',
      ],
    );
  }

  Widget _buildApiPaymentInitiateInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      icon: Icons.payment,
      iconColor: AppTheme.success,
      title: 'Payment Initiate',
      description: 'Initiate a payment transaction with immediate capture. This API creates a payment session and redirects the customer to PayGlocal\'s secure payment interface. Upon successful payment, the amount is immediately captured and settled.',
      keyPoints: [
        'Creates a payment transaction with specified amount',
        'Generates a redirect URL for customer payment',
        'Immediate capture upon successful authorization',
        'Returns Global ID (gid) for transaction tracking',
        'Supports multiple payment methods (Cards, UPI, Net Banking)',
        'Webhook notification sent to your callback URL',
      ],
    );
  }

  Widget _buildApiStatusCheckInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      icon: Icons.info,
      iconColor: AppTheme.info,
      title: 'Status Check',
      description: 'Check the current status of any payment transaction using its Global ID (gid). This API provides real-time transaction status, payment method used, amount details, and complete transaction history.',
      keyPoints: [
        'Real-time transaction status updates',
        'Returns payment method and amount details',
        'Includes authorization codes and timestamps',
        'Shows complete transaction lifecycle',
        'Essential for reconciliation and reporting',
        'Can be called multiple times without side effects',
      ],
    );
  }


  Widget _buildApiPartialRefundInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      icon: Icons.pie_chart,
      iconColor: AppTheme.warning,
      title: 'Partial Refund',
      description: 'Refund a specific amount from a completed transaction. This is useful when you need to return only a portion of the payment, such as for partial order cancellations or discounts applied after payment.',
      keyPoints: [
        'Refund any amount up to the original transaction amount',
        'Multiple partial refunds allowed until full amount is refunded',
        'Requires refundType "P" and paymentData.totalAmount',
        'Each refund requires a unique merchantTxnId',
        'Refund typically processes within 5-7 business days',
        'Webhook notification sent upon refund completion',
      ],
    );
  }

  Widget _buildApiFullRefundInfo(bool isDark) {
    return _buildBusinessInfoSection(
      isDark: isDark,
      icon: Icons.check_circle,
      iconColor: AppTheme.success,
      title: 'Full Refund',
      description: 'Refund the entire transaction amount in one operation. This is the quickest way to process a complete refund for order cancellations or returns.',
      keyPoints: [
        'Refunds the complete original transaction amount',
        'Requires refundType "F" only, no amount needed',
        'Simpler payload than partial refund',
        'Only one full refund allowed per transaction',
        'Refund typically processes within 5-7 business days',
        'Webhook notification sent upon refund completion',
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
                      'Experience JWT Authentication in action',
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
            'Try our interactive demo to see how JWT Authentication works in a real e-commerce scenario. Experience the complete payment flow from product selection to successful payment.',
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
                    builder: (context) => const clothingMerchantInterface(isPayDirect: false),
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

  Widget _buildBusinessInfoSection({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> keyPoints,
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
            description,
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
                ...keyPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: iconColor,
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
}

