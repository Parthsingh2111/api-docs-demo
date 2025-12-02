import 'package:flutter/material.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_badge.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class PayDirectDocsScreen extends StatefulWidget {
  const PayDirectDocsScreen({super.key});

  @override
  _PayDirectDocsScreenState createState() => _PayDirectDocsScreenState();
}

class _PayDirectDocsScreenState extends State<PayDirectDocsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;

    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'PayDirect Documentation',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  _buildHeroSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // What is PayDirect
                  _buildWhatIsSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // For Which Merchants
                  _buildForWhomSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // Why Use PayDirect
                  _buildWhyUseSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // Advantages
                  _buildAdvantagesSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // Key Features
                  _buildKeyFeaturesSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),

                  // CTA Section
                  _buildCTASection(context, isLargeScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.success,
                      AppTheme.success.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.credit_card,
                  size: isLargeScreen ? 48 : 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PayDirect',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    PremiumBadge(
                      label: 'PCI DSS Level 1 Required',
                      variant: PremiumBadgeVariant.warning,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Direct API Payment Integration',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'PayDirect is a direct API integration solution that allows PCI DSS certified merchants to collect card details on their own interface with full control, enabling custom payment experiences and advanced payment flows.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is PayDirect?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PayDirect is a comprehensive direct API integration solution designed for PCI DSS certified merchants who prefer to collect card details directly on their own interface.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'With PayDirect, you have complete control over the payment UI and user experience. You collect card details on your own forms and pass them securely to PayGlocal via our APIs, giving you maximum flexibility to create custom payment flows.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForWhomSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final merchantTypes = [
      {
        'icon': Icons.business,
        'title': 'Enterprise Businesses',
        'description': 'Large organizations with complex payment requirements and dedicated security teams',
      },
      {
        'icon': Icons.palette,
        'title': 'Brand-Focused Merchants',
        'description': 'Businesses that require complete control over their payment UI and branding',
      },
      {
        'icon': Icons.integration_instructions,
        'title': 'Custom Integration Needs',
        'description': 'Merchants with unique payment flows and advanced integration requirements',
      },
      {
        'icon': Icons.code,
        'title': 'Technical Teams',
        'description': 'Organizations with in-house development capabilities and technical expertise',
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Advanced E-commerce',
        'description': 'Sophisticated online platforms with custom checkout experiences',
      },
      {
        'icon': Icons.account_balance,
        'title': 'Financial Services',
        'description': 'Financial institutions requiring direct payment processing capabilities',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For Which Merchants?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Text(
          'PayDirect is designed for PCI DSS certified merchants who want full control over their payment experience and have the technical capability to handle direct payment integration.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMediumScreen = constraints.maxWidth > 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                crossAxisSpacing: AppTheme.spacing16,
                mainAxisSpacing: AppTheme.spacing16,
                childAspectRatio: isLargeScreen ? 1.5 : 2,
              ),
              itemCount: merchantTypes.length,
              itemBuilder: (context, index) {
                final merchant = merchantTypes[index];
                return _buildMerchantTypeCard(
                  context,
                  merchant['icon'] as IconData,
                  merchant['title'] as String,
                  merchant['description'] as String,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMerchantTypeCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              icon,
              size: 28,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyUseSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final reasons = [
      {
        'icon': Icons.design_services,
        'title': 'Full UI Control',
        'description': 'Complete control over payment interface and user experience',
      },
      {
        'icon': Icons.tune,
        'title': 'Custom Flows',
        'description': 'Create advanced and customized payment workflows',
      },
      {
        'icon': Icons.branding_watermark,
        'title': 'Brand Consistency',
        'description': 'Maintain complete brand consistency throughout payment',
      },
      {
        'icon': Icons.extension,
        'title': 'Flexibility',
        'description': 'Maximum flexibility for complex integration requirements',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Use PayDirect?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 2 : 1,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: isLargeScreen ? 2.5 : 3,
          ),
          itemCount: reasons.length,
          itemBuilder: (context, index) {
            final reason = reasons[index];
            return _buildFeatureCard(
              context,
              reason['icon'] as IconData,
              reason['title'] as String,
              reason['description'] as String,
              AppTheme.success,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdvantagesSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final advantages = [
      'Custom UI integration - maintain complete control over look and feel',
      'Full control over user experience and payment flow',
      'Advanced payment flows with custom logic',
      'Direct API access for maximum flexibility',
      'Seamless integration with existing systems',
      'Support for complex payment scenarios',
      'Custom error handling and validation',
      'Enhanced analytics and tracking capabilities',
      'Support for tokenization and saved cards',
      'Real-time payment processing with instant feedback',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advantages of PayDirect',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: advantages
                .map((advantage) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 24,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              advantage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeaturesSection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem(
                context,
                'JWT PayDirect',
                'Direct payment initiation using JWT for seamless transactions with JWE/JWS encryption.',
              ),
              const Divider(height: AppTheme.spacing32),
              _buildFeatureItem(
                context,
                'SI PayDirect',
                'Automate recurring direct payments with Fixed or Variable schedules for subscriptions.',
              ),
              const Divider(height: AppTheme.spacing32),
              _buildFeatureItem(
                context,
                'Auth & Capture',
                'Separate authorization and capture phases for flexible payment processing with full control.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(
                Icons.star,
                size: 20,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.9),
            AppTheme.success,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.shadowLG,
      ),
      child: Column(
        children: [
          Icon(
            Icons.payments,
            size: isLargeScreen ? 56 : 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Ready to Explore PayDirect Payment Methods?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Discover all the payment methods available with PayDirect including JWT PayDirect, SI PayDirect, and Auth & Capture.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24),
          PremiumButton(
            label: 'Pay Direct Payment Methods',
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.pushNamed(context, '/paydirect');
            },
            buttonStyle: PremiumButtonStyle.primary,
            isFullWidth: !isLargeScreen,
          ),
        ],
      ),
    );
  }
}

