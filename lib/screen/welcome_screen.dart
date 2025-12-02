import 'package:flutter/material.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppTheme.darkBackground,
                    AppTheme.darkSurface,
                  ]
                : [
                    AppTheme.primaryLight.withOpacity(0.1),
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo/Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(
                            isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowXL,
                          ),
                          child: Icon(
                            Icons.celebration,
                            size: isLargeScreen ? 80 : 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32),

                      // Welcome Title
                      Text(
                        'Welcome to PayGlocal!',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppTheme.spacing24),

                      // Congratulations Message
                      Container(
                        padding: EdgeInsets.all(
                          isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurface
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.borderLight,
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.shadowLG,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: isLargeScreen ? 64 : 48,
                              color: AppTheme.success,
                            ),
                            const SizedBox(height: AppTheme.spacing20),
                            Text(
                              'Congratulations!',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              'Thank you for onboarding with PayGlocal. We\'re excited to have you on board!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            Text(
                              'You now have access to our comprehensive payment gateway solutions designed to help your business grow seamlessly.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32),

                      // Features Preview
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppTheme.spacing16,
                        runSpacing: AppTheme.spacing16,
                        children: [
                          _buildFeatureChip(
                            context,
                            Icons.security,
                            'Bank-Grade Security',
                            isDark,
                          ),
                          _buildFeatureChip(
                            context,
                            Icons.language,
                            'Global Coverage',
                            isDark,
                          ),
                          _buildFeatureChip(
                            context,
                            Icons.flash_on,
                            'Fast Integration',
                            isDark,
                          ),
                          _buildFeatureChip(
                            context,
                            Icons.support_agent,
                            '24/7 Support',
                            isDark,
                          ),
                        ],
                      ),

                      SizedBox(height: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32),

                      // Getting Started Button
                      PremiumButton(
                        label: 'Getting Started',
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/overview');
                        },
                        buttonStyle: PremiumButtonStyle.primary,
                        isFullWidth: !isLargeScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

