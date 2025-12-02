import 'package:flutter/material.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_badge.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen>
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
        title: 'Getting Started',
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
                  _buildHeroSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildQuickStartPath(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildIntegrationSteps(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildPrerequisites(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildNextSteps(context, isLargeScreen),
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
            AppTheme.accent.withOpacity(0.1),
            AppTheme.success.withOpacity(0.05),
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
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  size: 40,
                  color: AppTheme.success,
                ),
              ),
              const Spacer(),
              const PremiumBadge(
                label: '5 min setup',
                variant: PremiumBadgeVariant.success,
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Start Accepting Payments in Minutes',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Follow this quick guide to integrate PayGlocal and start processing payments. No complex setup required.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartPath(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Start Path',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Text(
          'Choose your integration approach based on your needs',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppTheme.spacing24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isLargeScreen) {
              return Row(
                children: [
                  Expanded(child: _buildPathCard(context, true)),
                  const SizedBox(width: AppTheme.spacing24),
                  Expanded(child: _buildPathCard(context, false)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildPathCard(context, true),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildPathCard(context, false),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPathCard(BuildContext context, bool isPayCollect) {
    final theme = Theme.of(context);
    final color = isPayCollect ? AppTheme.info : AppTheme.success;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Spacer(),
              PremiumBadge(
                label: isPayCollect ? 'Recommended' : 'Advanced',
                variant: isPayCollect
                    ? PremiumBadgeVariant.success
                    : PremiumBadgeVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            isPayCollect ? 'PayCollect' : 'PayDirect',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            isPayCollect
                ? 'Best for quick integration. No PCI compliance needed.'
                : 'Full control over UI. Requires PCI DSS certification.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacing16),
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

  Widget _buildIntegrationSteps(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final steps = [
      {
        'number': '1',
        'title': 'Get API Credentials',
        'description': 'Sign up and obtain your API keys from the PayGlocal dashboard',
        'icon': Icons.key,
        'color': AppTheme.accent,
      },
      {
        'number': '2',
        'title': 'Choose Integration Method',
        'description': 'Select SDK, API, or Plugin based on your platform',
        'icon': Icons.integration_instructions,
        'color': AppTheme.info,
      },
      {
        'number': '3',
        'title': 'Implement Payment Flow',
        'description': 'Follow our guides to add payment processing to your app',
        'icon': Icons.code,
        'color': AppTheme.warning,
      },
      {
        'number': '4',
        'title': 'Test & Go Live',
        'description': 'Test with sandbox, then switch to production',
        'icon': Icons.check_circle,
        'color': AppTheme.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integration Steps',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Column(
            children: [
              _buildStepCard(
                context,
                step['number'] as String,
                step['title'] as String,
                step['description'] as String,
                step['icon'] as IconData,
                step['color'] as Color,
              ),
              if (index < steps.length - 1) 
                const SizedBox(height: AppTheme.spacing16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisites(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);

    final prerequisites = [
      'Active PayGlocal merchant account',
      'API credentials (Merchant ID & API Key)',
      'Basic understanding of REST APIs',
      'HTTPS-enabled server for webhooks',
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Prerequisites',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacing16),
          ...prerequisites.map((prereq) => Padding(
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
                    prereq,
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

  Widget _buildNextSteps(BuildContext context, bool isLargeScreen) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to Integrate?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Choose your next step to continue with the integration',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
          Wrap(
            spacing: AppTheme.spacing12,
            runSpacing: AppTheme.spacing12,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/api-reference'),
                icon: const Icon(Icons.api),
                label: const Text('API Reference'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing16,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/sdks'),
                icon: const Icon(Icons.code),
                label: const Text('Download SDKs'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing16,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/testing-guide'),
                icon: const Icon(Icons.science),
                label: const Text('Testing Guide'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
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

