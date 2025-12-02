import 'package:flutter/material.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_badge.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class ProductComparisonScreen extends StatefulWidget {
  const ProductComparisonScreen({super.key});

  @override
  _ProductComparisonScreenState createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen>
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
        title: 'Product Comparison',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildQuickComparison(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildDetailedComparison(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildUseCases(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildCTASection(context, isLargeScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.tertiary.withOpacity(0.05),
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
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            child: Icon(
              Icons.compare_arrows,
              size: isLargeScreen ? 40 : 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Choose the Right Product',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Compare PayCollect and PayDirect to find the best fit for your business needs',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickComparison(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Comparison',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isLargeScreen) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildProductOverviewCard(context, true)),
                  const SizedBox(width: AppTheme.spacing24),
                  Expanded(child: _buildProductOverviewCard(context, false)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildProductOverviewCard(context, true),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildProductOverviewCard(context, false),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProductOverviewCard(BuildContext context, bool isPayCollect) {
    final theme = Theme.of(context);
    final color = isPayCollect ? AppTheme.info : AppTheme.success;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: Icon(
                  isPayCollect ? Icons.shield_outlined : Icons.credit_card,
                  color: color,
                  size: 32,
                ),
              ),
              const Spacer(),
              PremiumBadge(
                label: isPayCollect ? 'Easiest' : 'Most Flexible',
                variant: isPayCollect
                    ? PremiumBadgeVariant.success
                    : PremiumBadgeVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            isPayCollect ? 'PayCollect' : 'PayDirect',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            isPayCollect
                ? 'Hosted payment solution'
                : 'Direct API integration',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacing20),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacing20),
          
          _buildInfoRow(
            context,
            Icons.security,
            'PCI Compliance',
            isPayCollect ? 'Not required' : 'Level 1 required',
            isPayCollect,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            context,
            Icons.timer,
            'Setup Time',
            isPayCollect ? '5 minutes' : '1-2 hours',
            isPayCollect,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            context,
            Icons.design_services,
            'UI Control',
            isPayCollect ? 'Limited' : 'Full control',
            !isPayCollect,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildInfoRow(
            context,
            Icons.build,
            'Complexity',
            isPayCollect ? 'Simple' : 'Advanced',
            isPayCollect,
          ),
          
          const SizedBox(height: AppTheme.spacing24),
          PremiumButton(
            label: 'Learn More',
            icon: Icons.arrow_forward,
            onPressed: () => Navigator.pushNamed(
              context,
              isPayCollect ? '/paycollect' : '/paydirect',
            ),
            buttonStyle: PremiumButtonStyle.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isPositive,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isPositive ? AppTheme.success : theme.colorScheme.onSurface,
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedComparison(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final comparisonData = [
      {
        'category': 'Integration',
        'items': [
          {'feature': 'Setup Time', 'paycollect': '5 minutes', 'paydirect': '1-2 hours'},
          {'feature': 'Technical Skill', 'paycollect': 'Basic', 'paydirect': 'Advanced'},
          {'feature': 'Code Complexity', 'paycollect': 'Low', 'paydirect': 'High'},
        ],
      },
      {
        'category': 'Compliance',
        'items': [
          {'feature': 'PCI DSS Required', 'paycollect': 'No', 'paydirect': 'Yes (Level 1)'},
          {'feature': 'Audit Overhead', 'paycollect': 'Minimal', 'paydirect': 'Significant'},
          {'feature': 'Liability', 'paycollect': 'PayGlocal', 'paydirect': 'Merchant'},
        ],
      },
      {
        'category': 'Customization',
        'items': [
          {'feature': 'UI Customization', 'paycollect': 'Limited', 'paydirect': 'Full'},
          {'feature': 'Payment Flow', 'paycollect': 'Standard', 'paydirect': 'Custom'},
          {'feature': 'Branding', 'paycollect': 'Basic', 'paydirect': 'Complete'},
        ],
      },
      {
        'category': 'Features',
        'items': [
          {'feature': '3DS Support', 'paycollect': 'Built-in', 'paydirect': 'Manual'},
          {'feature': 'Tokenization', 'paycollect': 'Automatic', 'paydirect': 'Custom'},
          {'feature': 'Webhooks', 'paycollect': 'Yes', 'paydirect': 'Yes'},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Comparison',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        
        ...comparisonData.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    const Divider(height: 1),
                    const SizedBox(height: AppTheme.spacing16),
                    
                    ...(category['items'] as List).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['feature'],
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppTheme.spacing12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.info.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                                      border: Border.all(
                                        color: AppTheme.info.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item['paycollect'],
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.info,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppTheme.spacing12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                                      border: Border.all(
                                        color: AppTheme.success.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item['paydirect'],
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildUseCases(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best For',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        
        LayoutBuilder(
          builder: (context, constraints) {
            if (isLargeScreen) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildUseCaseCard(context, true)),
                  const SizedBox(width: AppTheme.spacing24),
                  Expanded(child: _buildUseCaseCard(context, false)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildUseCaseCard(context, true),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildUseCaseCard(context, false),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildUseCaseCard(BuildContext context, bool isPayCollect) {
    final theme = Theme.of(context);
    final color = isPayCollect ? AppTheme.info : AppTheme.success;

    final useCases = isPayCollect
        ? [
            'E-commerce startups',
            'Small to medium businesses',
            'Quick market launches',
            'Non-technical teams',
            'Standard payment flows',
          ]
        : [
            'Enterprise businesses',
            'Custom payment experiences',
            'Complex payment flows',
            'Technical teams',
            'Brand-focused merchants',
          ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              isPayCollect ? Icons.shield_outlined : Icons.credit_card,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            isPayCollect ? 'PayCollect' : 'PayDirect',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacing16),
          
          ...useCases.map((useCase) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    useCase,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
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
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.shadowLG,
      ),
      child: Column(
        children: [
          Text(
            'Still Not Sure?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Explore each product in detail or contact our team for guidance',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24),
          Wrap(
            spacing: AppTheme.spacing12,
            runSpacing: AppTheme.spacing12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/paycollect'),
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Explore PayCollect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.info,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing16,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/paydirect'),
                icon: const Icon(Icons.credit_card),
                label: const Text('Explore PayDirect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
