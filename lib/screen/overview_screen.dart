import 'package:flutter/material.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/grid_background_painter.dart';
import '../theme/app_theme.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final GlobalKey _productSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;
    final isMediumScreen = screenWidth > 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'PayGlocal',
      ),
      body: GridBackground(
        child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero Section
                  _buildHeroSection(context, isLargeScreen, isMediumScreen, isDark),

                  // Trust Section
                  _buildTrustSection(context, isLargeScreen, isDark),

                  // Main Features Grid
                  _buildFeaturesGrid(context, isLargeScreen, isMediumScreen, isDark),

                  // Testing and Go-Live Process Section
                  _buildTestingGoLiveSection(context, isLargeScreen, isMediumScreen, isDark),

                  // Product Selection Section
                  Container(
                    key: _productSectionKey,
                    child: _buildProductSection(context, isLargeScreen, isMediumScreen, isDark),
                  ),

                  SizedBox(height: AppTheme.spacing48),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isLargeScreen, bool isMediumScreen, bool isDark) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
          vertical: isLargeScreen ? 120 : 80,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.tertiary.withOpacity(0.08),
                  ]
                : [
                    theme.colorScheme.primary.withOpacity(0.08),
                    theme.colorScheme.tertiary.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
          border: Border(
            bottom: BorderSide(
                          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SlideTransition(
              position: _slideAnimation,
                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          'Start Accepting Payments Today',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Main Title
                          Text(
                    'Welcome to PayGlocal',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: isLargeScreen ? 56 : 40,
                      height: 1.2,
                      color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Subtitle
                  SizedBox(
                    width: isLargeScreen ? 800 : double.infinity,
                    child: Text(
                      'The most powerful payment gateway for global businesses. '
                      'Secure, scalable, and trusted by thousands of merchants worldwide.',
                      style: theme.textTheme.titleLarge?.copyWith(
                              height: 1.6,
                        fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isLargeScreen ? 20 : 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(height: AppTheme.spacing48),

                  // CTA Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PremiumButton(
                        label: 'Explore Products',
                        icon: Icons.arrow_forward,
                        onPressed: _scrollToProduct,
                        buttonStyle: PremiumButtonStyle.primary,
                        isFullWidth: !isLargeScreen,
                      ),
                      if (isMediumScreen) const SizedBox(width: AppTheme.spacing16),
                      if (isMediumScreen)
                        PremiumButton(
                          label: 'Manage Keys',
                          icon: Icons.vpn_key,
                          onPressed: () {
                            Navigator.pushNamed(context, '/api-credentials');
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
        ),
      ),
    );
  }

  Widget _buildTrustSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
        vertical: AppTheme.spacing32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
                            children: [
              Text(
                'Trusted by Industry Leaders',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
                              const SizedBox(height: AppTheme.spacing24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
                runSpacing: AppTheme.spacing24,
                children: [
                  _buildTrustBadge(context, '500M+', 'API requests per day', AppTheme.success),
                  _buildTrustBadge(context, '120+', 'Global currencies', AppTheme.info),
                  _buildTrustBadge(context, '30+', 'Payment methods', AppTheme.accent),
                  _buildTrustBadge(context, '100%', 'Uptime SLA', AppTheme.warning),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(BuildContext context, String number, String label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing32,
        vertical: AppTheme.spacing20,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
                          width: 1,
                        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
                      ),
                      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isLargeScreen, bool isMediumScreen, bool isDark) {
    final theme = Theme.of(context);

    final features = [
      {
        'icon': Icons.verified_user,
        'title': 'RBI Licensed',
        'description': 'Online payment aggregator license from Reserve Bank of India',
        'color': AppTheme.success,
      },
      {
        'icon': Icons.language,
        'title': 'Global Reach',
        'description': 'Support 100+ currencies and payment methods worldwide',
        'color': AppTheme.info,
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Flexible Compliance',
        'description': 'Support both PCI DSS-compliant and non-PCI DSS merchants',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.security,
        'title': 'Advanced Fraud Detection',
        'description': 'Dedicated risk engine to identify fraudulent transactions',
        'color': AppTheme.warning,
      },
      {
        'icon': Icons.integration_instructions,
        'title': 'Easy Integration',
        'description': 'SDKs for all major platforms and frameworks',
        'color': AppTheme.accent,
      },
      {
        'icon': Icons.headset_mic,
        'title': 'Expert Support',
        'description': 'Dedicated support team available 24/7/365',
        'color': AppTheme.accentLight,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
              Text(
                'Why PayGlocal?',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 44 : 32,
                ),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                'Everything you need to build a world-class payment experience',
                            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),
              GridView.count(
                crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.spacing20,
                crossAxisSpacing: AppTheme.spacing20,
                childAspectRatio: 2.6,
                children: features.map((feature) {
                  return _buildFeatureCard(
                    context,
                    feature['icon'] as IconData,
                    feature['title'] as String,
                    feature['description'] as String,
                    feature['color'] as Color,
                    isDark,
                  );
                }).toList(),
                          ),
                        ],
                      ),
                    ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.3,
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, bool isLargeScreen, bool isMediumScreen, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
        vertical: AppTheme.spacing64,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Integration Path',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 44 : 32,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Select the solution that best matches your business requirements',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isLargeScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProductCard(context, true, isLargeScreen, isDark)),
                        const SizedBox(width: AppTheme.spacing32),
                        Expanded(child: _buildProductCard(context, false, isLargeScreen, isDark)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProductCard(context, true, isLargeScreen, isDark),
                        const SizedBox(height: AppTheme.spacing24),
                        _buildProductCard(context, false, isLargeScreen, isDark),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, bool isPayCollect, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);
    final color = isPayCollect ? AppTheme.info : AppTheme.success;

    return Container(
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPayCollect ? Icons.shield_outlined : Icons.credit_card,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const Spacer(),
              PremiumBadge(
                label: isPayCollect ? 'PayGlocal Collect Card Details' : 'Merchant Collect Card Details',
                variant: isPayCollect
                    ? PremiumBadgeVariant.success
                    : PremiumBadgeVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            isPayCollect ? 'PayCollect' : 'PayDirect',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            isPayCollect
                ? 'Hosted payment solution with zero PCI compliance burden'
                : 'Custom-built payment integration with full UI control',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacing24),
          ...(isPayCollect
              ? [
                  _buildProductBenefit(context, 'Hosted secure payment page'),
                  _buildProductBenefit(context, 'Quick 5-minute integration'),
                  _buildProductBenefit(context, 'Built-in 3DS authentication'),
                  _buildProductBenefit(context, 'No PCI DSS compliance required'),
                ]
              : [
                  _buildProductBenefit(context, 'Custom UI integration'),
                  _buildProductBenefit(context, 'Full control over UX'),
                  _buildProductBenefit(context, 'Advanced payment flows'),
                  _buildProductBenefit(context, 'PCI DSS Level 1 required'),
                ]
          ),
          const SizedBox(height: AppTheme.spacing24),
          PremiumButton(
            label: 'Learn More',
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.pushNamed(
                context,
                isPayCollect ? '/paycollect-docs' : '/paydirect-docs',
              );
            },
            buttonStyle: PremiumButtonStyle.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductBenefit(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: AppTheme.success,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingGoLiveSection(BuildContext context, bool isLargeScreen, bool isMediumScreen, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
        vertical: AppTheme.spacing64,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Testing and Go-Live Process',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 44 : 32,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Seamless transition from testing to production environment',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isLargeScreen || isMediumScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProcessCard(context, true, isLargeScreen, isDark)),
                        const SizedBox(width: AppTheme.spacing32),
                        Expanded(child: _buildProcessCard(context, false, isLargeScreen, isDark)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProcessCard(context, true, isLargeScreen, isDark),
                        const SizedBox(height: AppTheme.spacing24),
                        _buildProcessCard(context, false, isLargeScreen, isDark),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessCard(BuildContext context, bool isUAT, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);
    final color = isUAT ? AppTheme.info : AppTheme.success;

    return Container(
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isUAT ? Icons.science : Icons.rocket_launch,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  isUAT ? 'Step 1' : 'Step 2',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            isUAT ? 'UAT Environment' : 'Production Environment',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            isUAT ? 'Testing Phase' : 'Go Live',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            isUAT
                ? 'Begin integration in the UAT (testing) environment. Set up your integration, run test transactions, and monitor results. The PayGlocal team reviews your test transactions to ensure everything is correctly configured.'
                : 'Once UAT testing is complete and verified by the PayGlocal team, transition to production is seamless. Simply update your API credentials to production environment credentials and start accepting real payments.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUAT ? Icons.info_outline : Icons.check_circle_outline,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    isUAT
                        ? 'Test with UAT credentials provided by PayGlocal'
                        : 'Switch to production credentials to go live instantly',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToProduct() {
    final context = _productSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }
}
