import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class PayCollectDocsScreen extends StatefulWidget {
  const PayCollectDocsScreen({super.key});

  @override
  State<PayCollectDocsScreen> createState() => _PayCollectDocsScreenState();
}

class _PayCollectDocsScreenState extends State<PayCollectDocsScreen>
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
        title: 'PayCollect Documentation',
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
                  AppTheme.accent.withOpacity(0.3),
                ]
              : [
                  const Color(0xFF0F2847),
                  const Color(0xFF1E3A5F),
                  AppTheme.info.withOpacity(0.8),
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
                              Icons.verified_user,
                              size: 16,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hosted Payment Solution',
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
                        'PayCollect',
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
                        'Accept payments securely without PCI DSS compliance. PayGlocal manages all card data collection on your behalf.',
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
      {'icon': Icons.security, 'label': 'PCI DSS\nCompliant'},
      {'icon': Icons.account_balance, 'label': 'RBI\nLicensed'},
      {'icon': Icons.verified, 'label': 'ISO\nCertified'},
      {'icon': Icons.lock, 'label': 'Bank Grade\nSecurity'},
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
              endValue: 99.8,
              label: 'Success Rate',
              suffix: '%',
              icon: Icons.trending_up,
              color: AppTheme.success,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 150,
              label: 'Avg Response Time',
              suffix: 'ms',
              icon: Icons.speed,
              color: AppTheme.info,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 5000,
              label: 'Active Merchants',
              suffix: '+',
              icon: Icons.business,
              color: AppTheme.accent,
            ),
            _AnimatedStatCard(
              animation: _statsController,
              endValue: 200,
              label: 'Countries Supported',
              suffix: '+',
              icon: Icons.public,
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
                  // What is PayCollect
              _buildSectionTitle('What is PayCollect?', isDark, isMobile),
              const SizedBox(height: 16),
              _buildContentCard(
                    isDark,
                child: Text(
                    'PayCollect is a hosted payment page solution where PayGlocal manages the entire payment collection process. When a customer makes a payment, they are redirected to a secure PayGlocal-hosted page to enter their card details. This means sensitive payment information never touches your servers, significantly reducing your security obligations and compliance requirements.',
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
        'icon': Icons.shopping_cart,
        'title': 'E-commerce Platforms',
        'description': 'Online stores wanting quick payment integration without compliance overhead',
      },
      {
        'icon': Icons.subscriptions,
        'title': 'Subscription Services',
        'description': 'SaaS and recurring billing businesses needing automated payment collection',
      },
      {
        'icon': Icons.flight,
        'title': 'Travel & Hospitality',
        'description': 'Booking platforms requiring secure payment processing with Auth & Capture',
      },
      {
        'icon': Icons.school,
        'title': 'Education Institutions',
        'description': 'Schools and universities collecting fees with Standing Instructions',
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Logistics Companies',
        'description': 'Delivery services needing flexible payment capture options',
      },
      {
        'icon': Icons.store,
        'title': 'SMEs & Startups',
        'description': 'Small businesses prioritizing speed-to-market over custom UI',
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
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type['icon'] as IconData,
                  size: 28,
                  color: AppTheme.accent,
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

  Widget _buildKeyFeatures(bool isDark, bool isMobile, bool isTablet) {
    return Column(
      children: [
        _ExpandableFeatureCard(
          title: 'JWT Authentication',
          icon: Icons.lock,
              color: AppTheme.info,
          description: 'Secure payment initiation using JWT tokens with JWE (encryption) and JWS (signature) for maximum security.',
          isDark: isDark,
          technicalDetails: [
            'JWE encryption for data confidentiality',
            'JWS signature for data integrity',
            'Asymmetric and symmetric key support',
            'Non-repudiation through digital signatures',
            'Token expiration and refresh mechanisms',
          ],
        ),
        const SizedBox(height: 16),
        _ExpandableFeatureCard(
          title: 'Standing Instructions (SI)',
          icon: Icons.repeat,
          color: AppTheme.warning,
          description: 'Enable recurring payments with automatic mandate registration for both Fixed and Variable payment frequencies.',
          isDark: isDark,
          technicalDetails: [
            'FIXED SI: Scheduled payments with predetermined amounts',
            'VARIABLE SI: On-demand payments up to maximum limit',
            'Configurable frequency (DAILY, WEEKLY, MONTHLY, ONDEMAND)',
            'Automated retry mechanism for failed payments',
            'Mandate management APIs (pause, activate, cancel)',
          ],
        ),
        const SizedBox(height: 16),
        _ExpandableFeatureCard(
          title: 'Auth & Capture',
          icon: Icons.swap_horiz,
          color: AppTheme.success,
          description: 'Two-phase payment processing that separates authorization from fund capture, ideal for order fulfillment workflows.',
          isDark: isDark,
          technicalDetails: [
            'Reserve funds without immediate charge',
            'Capture full or partial amounts',
            'Auth reversal for canceled orders',
            'Configurable authorization hold period',
            'Perfect for inventory-based businesses',
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalSpecs(bool isDark, bool isMobile, bool isTablet) {
    final specs = [
      {'label': 'API Version', 'value': 'v1'},
      {'label': 'Authentication', 'value': 'JWT (JWE + JWS)'},
      {'label': 'Request Format', 'value': 'JSON'},
      {'label': 'Response Format', 'value': 'JSON'},
      {'label': 'Timeout', 'value': '30 seconds'},
      {'label': 'Rate Limit', 'value': '1000 req/min'},
      {'label': 'Encryption', 'value': 'TLS 1.2+'},
      {'label': 'Supported Currencies', 'value': '150+'},
    ];

    return _buildContentCard(
      isDark,
      child: Column(
        children: specs.map((spec) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        Text(
                  spec['label']!,
          style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  spec['value']!,
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusinessBenefits(bool isDark, bool isMobile, bool isTablet) {
    final benefits = [
      {
        'icon': Icons.security,
        'title': 'No PCI DSS Compliance Required',
        'value': '80%',
        'metric': 'Cost Savings',
        'description': 'Eliminate expensive PCI DSS certification and annual audits',
        'color': AppTheme.success,
      },
      {
        'icon': Icons.speed,
        'title': 'Faster Time-to-Market',
        'value': '75%',
        'metric': 'Faster Launch',
        'description': 'Go live in days instead of months with hosted solution',
        'color': AppTheme.info,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Higher Success Rates',
        'value': '99.8%',
        'metric': 'Transaction Success',
        'description': 'Bank-grade infrastructure ensures maximum uptime',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Technical Support',
        'value': '<15min',
        'metric': 'Response Time',
        'description': 'Dedicated integration team and round-the-clock support',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit['value'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 20,
            fontWeight: FontWeight.w700,
                      color: benefit['color'] as Color,
                    ),
                  ),
                  Text(
                    benefit['metric'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit['title'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
                  const SizedBox(height: 4),
        Text(
                    benefit['description'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUseCaseGallery(bool isDark, bool isMobile, bool isTablet) {
    final useCases = [
      {
        'industry': 'E-commerce',
        'icon': Icons.shopping_bag,
        'color': AppTheme.info,
        'scenario': 'Online Fashion Store',
        'challenge': 'High cart abandonment due to complex payment flows',
        'solution': 'PayCollect with Auth & Capture',
        'result': '35% increase in conversion rate',
        'metrics': {'Conversion': '+35%', 'Cart Abandonment': '-42%'},
      },
      {
        'industry': 'SaaS',
        'icon': Icons.cloud,
        'color': AppTheme.accent,
        'scenario': 'Project Management Tool',
        'challenge': 'Managing variable subscription billing',
        'solution': 'PayCollect with Variable SI',
        'result': '90% reduction in billing errors',
        'metrics': {'Billing Accuracy': '99.9%', 'Churn': '-25%'},
      },
      {
        'industry': 'Travel',
        'icon': Icons.flight_takeoff,
        'color': AppTheme.warning,
        'scenario': 'Flight Booking Platform',
        'challenge': 'Need to hold funds before ticket confirmation',
        'solution': 'PayCollect Auth & Capture flow',
        'result': 'Zero chargebacks for canceled bookings',
        'metrics': {'Chargebacks': '-100%', 'Customer Satisfaction': '4.8/5'},
      },
      {
        'industry': 'Education',
        'icon': Icons.school,
        'color': AppTheme.success,
        'scenario': 'Online Learning Platform',
        'challenge': 'Collecting monthly course fees automatically',
        'solution': 'PayCollect with Fixed SI',
        'result': '95% automated fee collection',
        'metrics': {'Collection Rate': '95%', 'Manual Work': '-80%'},
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 1 : 2),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 0.9 : 1.1,
      ),
      itemCount: useCases.length,
      itemBuilder: (context, index) {
        final useCase = useCases[index];
        return _buildContentCard(
          isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (useCase['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      useCase['icon'] as IconData,
                      size: 24,
                      color: useCase['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    useCase['industry'] as String,
          style: GoogleFonts.inter(
            fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
              ),
              const SizedBox(height: 16),
              _buildUseCaseRow('Scenario', useCase['scenario'] as String, isDark),
              _buildUseCaseRow('Challenge', useCase['challenge'] as String, isDark),
              _buildUseCaseRow('Solution', useCase['solution'] as String, isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        useCase['result'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (useCase['metrics'] as Map<String, String>).entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUseCaseRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROISection(bool isDark, bool isMobile, bool isTablet) {
    return _buildContentCard(
      isDark,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'PayCollect vs In-House Development',
          style: GoogleFonts.inter(
              fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _CostComparisonBar(
            label: 'Implementation Time',
            payCollectValue: 2,
            inHouseValue: 90,
            unit: 'days',
            color: AppTheme.info,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _CostComparisonBar(
            label: 'Development Cost',
            payCollectValue: 0,
            inHouseValue: 50000,
            unit: '\$',
            color: AppTheme.warning,
            isDark: isDark,
            isReversed: true,
          ),
          const SizedBox(height: 16),
          _CostComparisonBar(
            label: 'Annual Compliance Cost',
            payCollectValue: 0,
            inHouseValue: 30000,
            unit: '\$',
            color: AppTheme.error,
            isDark: isDark,
            isReversed: true,
        ),
          const SizedBox(height: 16),
          _CostComparisonBar(
            label: 'Technical Team Required',
            payCollectValue: 1,
            inHouseValue: 5,
            unit: 'developers',
            color: AppTheme.accent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSection(bool isDark, bool isMobile, bool isTablet) {
    final compliance = [
      {
        'title': 'PCI DSS Level 1',
        'icon': Icons.verified_user,
        'description': 'Highest level of payment card industry security certification',
        'color': AppTheme.success,
      },
      {
        'title': 'RBI Licensed',
        'icon': Icons.account_balance,
        'description': 'Reserve Bank of India licensed online payment aggregator',
        'color': AppTheme.info,
      },
      {
        'title': 'ISO 27001',
        'icon': Icons.shield,
        'description': 'International standard for information security management',
        'color': AppTheme.accent,
      },
      {
        'title': 'SOC 2 Type II',
        'icon': Icons.security,
        'description': 'Rigorous security, availability, and confidentiality audit',
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
        childAspectRatio: isMobile ? 2 : 1,
      ),
      itemCount: compliance.length,
      itemBuilder: (context, index) {
        final item = compliance[index];
        return _buildContentCard(
          isDark,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 40,
                color: item['color'] as Color,
              ),
              const SizedBox(height: 12),
        Text(
                item['title'] as String,
          style: GoogleFonts.inter(
            fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                item['description'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.4,
          ),
                textAlign: TextAlign.center,
        ),
      ],
          ),
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
              ? [AppTheme.accent.withOpacity(0.2), AppTheme.info.withOpacity(0.2)]
              : [AppTheme.info.withOpacity(0.1), AppTheme.accent.withOpacity(0.1)],
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
                'Explore PayCollect payment methods including JWT Authentication, Standing Instructions, and Auth & Capture.',
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
                      Navigator.pushNamed(context, '/paycollect');
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String description;
  final bool isDark;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const Spacer(),
        Text(
            value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
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
      {'icon': Icons.store, 'label': 'Merchant\nInitiates', 'color': AppTheme.accent},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.web, 'label': 'PayGlocal\nHosted Page', 'color': AppTheme.info},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.credit_card, 'label': 'Customer\nEnters Details', 'color': AppTheme.warning},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.check_circle, 'label': 'Payment\nProcessed', 'color': AppTheme.success},
      {'icon': Icons.arrow_forward, 'label': '', 'color': Colors.transparent},
      {'icon': Icons.webhook, 'label': 'Merchant\nCallback', 'color': AppTheme.accent},
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

class _ComparisonChart extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const _ComparisonChart({
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      {'feature': 'PCI DSS Compliance', 'payCollect': 'Not Required', 'traditional': 'Required', 'payCollectBetter': true},
      {'feature': 'Setup Time', 'payCollect': '2-3 Days', 'traditional': '3-6 Months', 'payCollectBetter': true},
      {'feature': 'Development Cost', 'payCollect': 'Low', 'traditional': 'High (\$50k+)', 'payCollectBetter': true},
      {'feature': 'Security Responsibility', 'payCollect': 'PayGlocal', 'traditional': 'Merchant', 'payCollectBetter': true},
      {'feature': 'Card Data Storage', 'payCollect': 'PayGlocal', 'traditional': 'Merchant', 'payCollectBetter': true},
      {'feature': 'UI Customization', 'payCollect': 'Limited', 'traditional': 'Full Control', 'payCollectBetter': false},
      {'feature': 'Maintenance', 'payCollect': 'Zero', 'traditional': 'Ongoing', 'payCollectBetter': true},
      {'feature': 'Annual Audits', 'payCollect': 'Not Required', 'traditional': 'Required', 'payCollectBetter': true},
    ];

    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray100,
          ),
          columns: [
            DataColumn(
              label: Text(
                'Feature',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Row(
                children: [
                  Icon(Icons.payment, size: 16, color: AppTheme.success),
                  const SizedBox(width: 8),
        Text(
                    'PayCollect',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),
            DataColumn(
              label: Text(
                'Traditional',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
          rows: features.map((feature) {
            final payCollectBetter = feature['payCollectBetter'] as bool;
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    feature['feature'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      if (payCollectBetter)
                        Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                      if (!payCollectBetter)
                        Icon(Icons.info, size: 16, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Text(
                        feature['payCollect'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    feature['traditional'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TechnicalArchitectureDiagram extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const _TechnicalArchitectureDiagram({
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          _buildArchitectureLayer(
            'Merchant Application',
            'Your Backend Server',
            Icons.computer,
            AppTheme.accent,
          isDark,
          ),
          _buildArrowDown(isDark),
          _buildArchitectureLayer(
            'API Request',
            'JWT Token (JWE + JWS)',
            Icons.vpn_key,
            AppTheme.info,
          isDark,
          ),
          _buildArrowDown(isDark),
          _buildArchitectureLayer(
            'PayGlocal Gateway',
            'Hosted Payment Page',
            Icons.web,
            AppTheme.warning,
          isDark,
          ),
          _buildArrowDown(isDark),
          _buildArchitectureLayer(
            'Payment Networks',
            'Visa, Mastercard, etc.',
            Icons.credit_card,
            AppTheme.success,
            isDark,
          ),
          _buildArrowDown(isDark),
          _buildArchitectureLayer(
            'Merchant Callback',
            'Webhook Notification',
            Icons.webhook,
            AppTheme.accent,
            isDark,
        ),
      ],
      ),
    );
  }

  Widget _buildArchitectureLayer(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
          child: Row(
            children: [
              Container(
            padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
              color: color,
                  shape: BoxShape.circle,
                ),
            child: Icon(icon, size: 24, color: Colors.white),
              ),
          const SizedBox(width: 16),
              Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildArrowDown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Icon(
        Icons.arrow_downward,
        size: 28,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
      ),
    );
  }
}

class _IntegrationTimeline extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const _IntegrationTimeline({
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'phase': 'Setup',
        'duration': '2-4 hours',
        'tasks': ['Register merchant account', 'Receive API credentials', 'Download SDK/Documentation'],
        'color': AppTheme.info,
      },
      {
        'phase': 'Development',
        'duration': '1-2 days',
        'tasks': ['Implement JWT authentication', 'Integrate payment initiation API', 'Setup callback handlers'],
        'color': AppTheme.warning,
      },
      {
        'phase': 'Testing',
        'duration': '2-3 days',
        'tasks': ['Test sandbox environment', 'Verify payment flows', 'Error handling validation'],
        'color': AppTheme.accent,
      },
      {
        'phase': 'Go Live',
        'duration': '1 day',
        'tasks': ['Production credentials', 'Deploy to production', 'Monitor transactions'],
        'color': AppTheme.success,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _buildTimelineStep(
          step['phase'] as String,
          step['duration'] as String,
          step['tasks'] as List<String>,
          step['color'] as Color,
          isDark,
          isLast,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineStep(
    String phase,
    String duration,
    List<String> tasks,
    Color color,
    bool isDark,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                    Text(
                      phase,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
              Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                        duration,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                    fontWeight: FontWeight.w600,
                          color: color,
                  ),
                ),
              ),
            ],
          ),
                const SizedBox(height: 12),
                ...tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
            child: Text(
                            task,
              style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableFeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> technicalDetails;
  final bool isDark;

  const _ExpandableFeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.technicalDetails,
    required this.isDark,
  });

  @override
  State<_ExpandableFeatureCard> createState() => _ExpandableFeatureCardState();
}

class _ExpandableFeatureCardState extends State<_ExpandableFeatureCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded
              ? widget.color
              : (widget.isDark ? AppTheme.darkBorder : AppTheme.borderLight),
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
            blurRadius: _isExpanded ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 28,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                          widget.title,
            style: GoogleFonts.inter(
              fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
                        const SizedBox(height: 4),
          Text(
                          widget.description,
            style: GoogleFonts.inter(
                            fontSize: 14,
                            color: widget.isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            height: 1.5,
            ),
          ),
        ],
      ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  Divider(color: widget.isDark ? AppTheme.darkBorder : AppTheme.borderLight),
                  const SizedBox(height: 12),
          Text(
                    'Technical Details:',
            style: GoogleFonts.inter(
                      fontSize: 14,
              fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.technicalDetails.map((detail) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: widget.color,
          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: widget.isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CostComparisonBar extends StatelessWidget {
  final String label;
  final double payCollectValue;
  final double inHouseValue;
  final String unit;
  final Color color;
  final bool isDark;
  final bool isReversed;

  const _CostComparisonBar({
    required this.label,
    required this.payCollectValue,
    required this.inHouseValue,
    required this.unit,
    required this.color,
    required this.isDark,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(payCollectValue, inHouseValue);
    final payCollectPercent = maxValue > 0 ? (payCollectValue / maxValue).toDouble() : 0.0;
    final inHousePercent = maxValue > 0 ? (inHouseValue / maxValue).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
          label,
            style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                'PayCollect',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: payCollectPercent > 0.05 ? payCollectPercent : 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        unit == '\$' ? '$unit${payCollectValue.toInt()}' : '${payCollectValue.toInt()}$unit',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ),
        ],
      ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                'In-House',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: inHousePercent > 0.05 ? inHousePercent : 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        unit == '\$' ? '$unit${inHouseValue.toInt()}' : '${inHouseValue.toInt()}$unit',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
