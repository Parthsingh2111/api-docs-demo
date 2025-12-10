import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class PayDirectScreen extends StatefulWidget {
  const PayDirectScreen({super.key});

  @override
  State<PayDirectScreen> createState() => _PayDirectScreenState();
}

class _PayDirectScreenState extends State<PayDirectScreen>
    with TickerProviderStateMixin {
  late AnimationController _statsController;
  late AnimationController _fadeController;
  String _selectedTab = 'overview';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Set default tab to overview (no other tabs now)
    _selectedTab = 'overview';
  }

  @override
  void dispose() {
    _statsController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.gray50,
      appBar: const PremiumAppBar(
        title: 'PayDirect Documentation',
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section with Stats
            _buildHeroSection(theme, isDark, screenWidth),

            // Overview Content (only content now)
            _buildOverviewContent(theme, isDark, screenWidth),

            // CTA Section (full width)
            _buildCTASection(theme, isDark, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isDark, double screenWidth) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryDark,
                  AppTheme.primaryMid,
                  AppTheme.success.withOpacity(0.3),
                ]
              : [
                  const Color(0xFF0A5C36),
                  const Color(0xFF047857),
                  AppTheme.success.withOpacity(0.8),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : (isTablet ? 24 : 48),
              vertical: isMobile ? 40 : 64,
            ),
            child: Column(
              children: [
                // Title and description
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 16,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Direct Payment Solution',
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main title
                      Text(
                        'PayDirect',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 36 : (isTablet ? 48 : 56),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Process payments directly with full control. For PCI DSS certified merchants who collect card data on their own interface.',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Trust badges
                      _buildTrustBadges(isMobile, isTablet),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Animated statistics
                _buildAnimatedStats(isMobile, isTablet, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadges(bool isMobile, bool isTablet) {
    final badges = [
      {'icon': Icons.verified_user, 'label': 'PCI DSS\nRequired'},
      {'icon': Icons.payment, 'label': 'Direct\nPayment'},
      {'icon': Icons.security, 'label': 'Full\nControl'},
      {'icon': Icons.speed, 'label': 'High\nPerformance'},
    ];

    return Wrap(
      spacing: isMobile ? 12 : 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: badges.map((badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                badge['icon'] as IconData,
                size: isMobile ? 24 : 28,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                badge['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimatedStats(bool isMobile, bool isTablet, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.3 : 1.5,
          children: [
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 25,
              label: 'Payment Methods',
              suffix: '+',
              icon: Icons.credit_card,
              color: AppTheme.success,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 100,
              label: 'Avg Response Time',
              suffix: 'ms',
              icon: Icons.speed,
              color: AppTheme.info,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 300,
              label: 'Daily API Requests',
              suffix: 'M+',
              icon: Icons.business,
              color: AppTheme.accent,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 99,
              label: 'Success Rate',
              suffix: '.9%',
              icon: Icons.check_circle,
              color: AppTheme.warning,
            ),
          ],
        );
      },
    );
  }


  Widget _buildOverviewContent(ThemeData theme, bool isDark, double screenWidth) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 24 : 32)),
        child: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // What is PayDirect
              _buildSectionTitle('What is PayDirect?', isDark, isMobile),
              const SizedBox(height: 16),
              _buildContentCard(
                    isDark,
                child: Text(
                    'PayDirect is a direct payment integration solution for PCI DSS compliant merchants who collect card data on their own interface. You maintain full control over the payment flow and customer experience, while PayGlocal handles secure processing through our robust payment gateway. This approach is ideal for enterprises requiring maximum customization and direct card data handling.',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 15 : 16,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Payment Flow Diagram
              _buildSectionTitle('Payment Flow', isDark, isMobile),
              const SizedBox(height: 16),
              _PaymentFlowDiagram(isDark: isDark, isMobile: isMobile),
              const SizedBox(height: 48),

              // Business Benefits
              _buildSectionTitle('Key Benefits', isDark, isMobile),
              const SizedBox(height: 16),
              _buildBusinessBenefits(isDark, isMobile, isTablet),
              const SizedBox(height: 48),

              // Payment Methods
              _buildSectionTitle('Payment Methods', isDark, isMobile),
              const SizedBox(height: 16),
              _buildPaymentMethods(isDark, isMobile, isTablet),
              const SizedBox(height: 48),

                  // For Which Merchants
              _buildSectionTitle('Ideal For', isDark, isMobile),
              const SizedBox(height: 16),
              _buildMerchantTypes(isDark, isMobile, isTablet),
                ],
              ),
            ),
          ),
    );
  }


  Widget _buildSectionTitle(String title, bool isDark, bool isMobile) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: isMobile ? 24 : 32,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildContentCard(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }


  Widget _buildMerchantTypes(bool isDark, bool isMobile, bool isTablet) {
    final types = [
      {
        'icon': Icons.business_center,
        'title': 'Enterprise Businesses',
        'description': 'Large corporations requiring customized payment experiences and direct control',
      },
      {
        'icon': Icons.account_balance,
        'title': 'Financial Institutions',
        'description': 'Banks and fintech requiring specialized integrations and compliance',
      },
      {
        'icon': Icons.store_mall_directory,
        'title': 'Retail Chains',
        'description': 'Multi-location businesses needing unified payment processing',
      },
      {
        'icon': Icons.code,
        'title': 'Tech-First Companies',
        'description': 'Development teams wanting full API control and custom implementations',
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Aggregators',
        'description': 'Platforms providing payment services to multiple merchants',
      },
      {
        'icon': Icons.local_hospital,
        'title': 'Healthcare Providers',
        'description': 'Medical institutions requiring HIPAA-compliant payment processing',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 2 : 1.3,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return _buildContentCard(
          isDark,
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
                padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type['icon'] as IconData,
                  size: 28,
                  color: AppTheme.success,
            ),
          ),
              const SizedBox(height: 16),
              Text(
                type['title'] as String,
            style: GoogleFonts.inter(
                  fontSize: 16,
              fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type['description'] as String,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessBenefits(bool isDark, bool isMobile, bool isTablet) {
    final benefits = [
      {
        'icon': Icons.brush,
        'title': 'Full UI Customization',
        'description': 'Complete control over payment interface and user experience',
        'color': AppTheme.success,
      },
      {
        'icon': Icons.speed,
        'title': 'Direct Processing',
        'description': 'No redirects - payments processed on your domain',
        'color': AppTheme.info,
      },
      {
        'icon': Icons.code,
        'title': 'Advanced API Access',
        'description': 'Comprehensive APIs with full customization capability',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.analytics,
        'title': 'Real-time Analytics',
        'description': 'Instant access to transaction data and insights',
        'color': AppTheme.warning,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.8 : (isTablet ? 1.5 : 1.1),
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return _buildContentCard(
          isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (benefit['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  size: 24,
                  color: benefit['color'] as Color,
                ),
              ),
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit['title'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
                    const SizedBox(height: 8),
        Text(
                    benefit['description'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        height: 1.4,
                    ),
                  ),
                ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethods(bool isDark, bool isMobile, bool isTablet) {
    final methods = [
      {
        'icon': Icons.lock,
        'title': 'JWT Authentication',
        'description': 'Secure payment processing with JWT token encryption for enhanced security',
        'route': '/paydirect-jwt-detail',
        'color': AppTheme.info,
        'benefits': [
          'Enhanced security with JWT',
          'Full control over payment flow',
          'Direct card data handling',
        ],
      },
      {
        'icon': Icons.credit_card,
        'title': 'Auth & Capture',
        'description': 'Two-step payment process - authorize first, capture later for flexible payment control',
        'route': '/paydirect-auth-detail',
        'color': AppTheme.success,
        'benefits': [
          'Hold funds before capture',
          'Flexible payment timing',
          'Reduce chargebacks',
        ],
      },
      {
        'icon': Icons.repeat,
        'title': 'Standing Instructions',
        'description': 'Automated recurring payments with customer consent for subscriptions and recurring billing',
        'route': '/paydirect-si-detail',
        'color': AppTheme.warning,
        'benefits': [
          'Automated recurring payments',
          'Reduced manual processing',
          'Improved cash flow',
        ],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.1 : (isTablet ? 0.95 : 0.85),
      ),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        return _PaymentMethodCard(
          icon: method['icon'] as IconData,
          title: method['title'] as String,
          description: method['description'] as String,
          route: method['route'] as String,
          color: method['color'] as Color,
          benefits: method['benefits'] as List<String>,
          isDark: isDark,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildCTASection(ThemeData theme, bool isDark, double screenWidth) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
        vertical: isMobile ? 40 : 64,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.success.withOpacity(0.2), AppTheme.info.withOpacity(0.2)]
              : [AppTheme.success.withOpacity(0.1), AppTheme.info.withOpacity(0.1)],
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          ),
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ready to Get Started?',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Explore PayDirect payment methods including JWT Authentication, Standing Instructions, and Auth & Capture.',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 15 : 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  PremiumButton(
                    label: 'View Payment Methods',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.pushNamed(context, '/paydirect-docs');
                    },
                    buttonStyle: PremiumButtonStyle.primary,
                    isFullWidth: false,
                  ),
                  PremiumButton(
                    label: 'API Documentation',
                    icon: Icons.code,
                    onPressed: () {
                      Navigator.pushNamed(context, '/api-reference');
                    },
                    buttonStyle: PremiumButtonStyle.secondary,
                    isFullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM WIDGETS
// ============================================================================

class _AnimatedStatCard extends StatelessWidget {
  final Animation<double> animation;
  final double endValue;
  final String label;
  final String suffix;
  final IconData icon;
  final Color color;

  const _AnimatedStatCard({
    required this.animation,
    required this.endValue,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final value = endValue * animation.value;
              return Text(
                '${value.toStringAsFixed(endValue < 10 ? 1 : 0)}$suffix',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PaymentFlowDiagram extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const _PaymentFlowDiagram({
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.store, 'label': 'Merchant\nInterface', 'color': AppTheme.success},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.credit_card, 'label': 'Card Data\nCollection', 'color': AppTheme.info},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.lock, 'label': 'JWT\nEncryption', 'color': AppTheme.warning},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.cloud, 'label': 'PayGlocal\nGateway', 'color': AppTheme.accent},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.check_circle, 'label': 'Payment\nProcessed', 'color': AppTheme.success},
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildSteps(steps, isDark, false),
      ),
    );
  }

  List<Widget> _buildSteps(List<Map<String, dynamic>> steps, bool isDark, bool isVertical) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isArrow = step['icon'] == Icons.arrow_forward;

      if (isArrow) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              isVertical ? Icons.arrow_downward : Icons.arrow_forward,
              size: 32,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        );
      }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (step['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: step['color'] as Color,
                width: 2,
              ),
            ),
            child: Icon(
              step['icon'] as IconData,
              size: 32,
              color: step['color'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              step['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    }).toList();
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentMethodCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;
  final List<String> benefits;
  final bool isDark;
  final bool isMobile;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.color,
    required this.benefits,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<_PaymentMethodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.5)
                  : (widget.isDark ? AppTheme.darkBorder : AppTheme.borderLight),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.2)
                    : Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: widget.isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                widget.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: widget.isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Benefits
              ...widget.benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: widget.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: widget.isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, widget.route);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: _isHovered ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Learn More',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
