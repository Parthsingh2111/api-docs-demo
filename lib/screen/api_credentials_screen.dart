import 'package:flutter/material.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class ApiCredentialsScreen extends StatefulWidget {
  const ApiCredentialsScreen({super.key});

  @override
  _ApiCredentialsScreenState createState() => _ApiCredentialsScreenState();
}

class _ApiCredentialsScreenState extends State<ApiCredentialsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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
        title: 'API Credentials',
      ),
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
                    Colors.white,
                    AppTheme.primaryLight.withOpacity(0.03),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(context, isLargeScreen, isDark),

              // Required Credentials Section
              _buildRequiredCredentialsSection(context, isLargeScreen, isMediumScreen, isDark),

              // Steps Section
              _buildStepsSection(context, isLargeScreen, isMediumScreen, isDark),

              // Summary Section
              _buildSummarySection(context, isLargeScreen, isDark),

              SizedBox(height: AppTheme.spacing48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
          vertical: isLargeScreen ? 100 : 70,
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
                  // Icon Badge
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.vpn_key,
                      size: isLargeScreen ? 48 : 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Main Title
                  Text(
                    'Manage Your API Keys',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: isLargeScreen ? 48 : 36,
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
                      'Follow these simple steps to download and organize your API credentials. '
                      'You\'ll need these keys for authentication and secure integration.',
                      style: theme.textTheme.titleLarge?.copyWith(
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isLargeScreen ? 18 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredCredentialsSection(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    final credentials = [
      {
        'name': 'Merchant ID',
        'description': 'Unique identifier for your merchant account',
        'icon': Icons.badge,
        'color': AppTheme.success,
      },
      {
        'name': 'Public Key',
        'description': 'Used for client-side operations',
        'icon': Icons.public,
        'color': AppTheme.info,
      },
      {
        'name': 'Public Key ID',
        'description': 'Identifier for the public key',
        'icon': Icons.fingerprint,
        'color': AppTheme.accent,
      },
      {
        'name': 'Private Key',
        'description': 'Secure key for server-side operations',
        'icon': Icons.lock,
        'color': AppTheme.warning,
      },
      {
        'name': 'Private Key ID',
        'description': 'Identifier for the private key',
        'icon': Icons.vpn_key,
        'color': AppTheme.primaryLight,
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
                'Required Credentials',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 44 : 32,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'You will need 5 essential pieces of information to complete your integration',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),
              GridView.count(
                crossAxisCount: isLargeScreen ? 5 : (isMediumScreen ? 2 : 1),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.spacing24,
                crossAxisSpacing: AppTheme.spacing24,
                childAspectRatio: 0.95,
                children: credentials.map((cred) {
                  return _buildCredentialCard(
                    context,
                    cred['icon'] as IconData,
                    cred['name'] as String,
                    cred['description'] as String,
                    cred['color'] as Color,
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

  Widget _buildCredentialCard(
    BuildContext context,
    IconData icon,
    String name,
    String description,
    Color color,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    final steps = [
      {
        'number': '1',
        'title': 'Go to Key Management',
        'description': 'Log in to your PayGlocal dashboard and navigate to the Key Management section from the settings menu.',
        'icon': Icons.settings,
      },
      {
        'number': '2',
        'title': 'Download PayGlocal Public Key',
        'description': 'In the Key Management section, locate and download the PayGlocal public key file. This will be used for client-side operations.',
        'icon': Icons.download,
      },
      {
        'number': '3',
        'title': 'Select & Download Public Key',
        'description': 'Click on the key type dropdown menu and select your public key. Download it to a secure location on your system.',
        'icon': Icons.folder_open,
      },
      {
        'number': '4',
        'title': 'Save the Key IDs',
        'description': 'Extract the Key IDs (KIDs) from the downloaded file names. The KID is the text before the first underscore in the filename.',
        'icon': Icons.assignment,
      },
      {
        'number': '5',
        'title': 'Note Your Merchant ID',
        'description': 'Your Merchant ID is mentioned in your onboarding email and can also be found at the top center of the Transaction Tracking page in your dashboard.',
        'icon': Icons.business,
      },
    ];

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
                'Step-by-Step Guide',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isLargeScreen ? 44 : 32,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Follow these 5 simple steps to gather all your API credentials',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),
              Column(
                children: List.generate(steps.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < steps.length - 1 ? AppTheme.spacing32 : 0,
                    ),
                    child: _buildStepItem(
                      context,
                      steps[index]['number'] as String,
                      steps[index]['title'] as String,
                      steps[index]['description'] as String,
                      steps[index]['icon'] as IconData,
                      isLargeScreen,
                      isDark,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    String number,
    String title,
    String description,
    IconData icon,
    bool isLargeScreen,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colors = [AppTheme.accent, AppTheme.success, AppTheme.info, AppTheme.warning, AppTheme.primaryLight];
    final colorIndex = int.parse(number) - 1;
    final stepColor = colors[colorIndex];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: stepColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [stepColor, stepColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: stepColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing6,
                          ),
                          decoration: BoxDecoration(
                            color: stepColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: stepColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Step $number',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: stepColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Image Placeholder
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkSurface.withOpacity(0.5)
                  : AppTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    'Screenshot - Step $number',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing24,
        vertical: AppTheme.spacing48,
      ),
      padding: EdgeInsets.all(
        isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.1),
            AppTheme.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: AppTheme.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(
                  Icons.info_outlined,
                  size: 24,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Text(
                  'Key Extraction Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          _buildSummaryItem(
            context,
            'Public Key ID (KID) Extraction',
            'From the filename "kid-kjbvvkjsbkjdsb_kndk.pem", extract "kid-kjbvvkjsbkjdsb" (everything before the underscore)',
            isDark,
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildSummaryItem(
            context,
            'Private Key ID (KID) Extraction',
            'From the filename "hfjdfhjdfddfjk345_hfj.pem", extract "hfjdfhjdfddfjk345" (everything before the underscore)',
            isDark,
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildSummaryItem(
            context,
            'Merchant ID Location',
            'Find your Merchant ID in your onboarding email or at the top center of the Transaction Tracking page in your PayGlocal dashboard',
            isDark,
          ),
          const SizedBox(height: AppTheme.spacing20),
          PremiumButton(
            label: 'Back to Overview',
            icon: Icons.arrow_back,
            onPressed: () {
              Navigator.pop(context);
            },
            buttonStyle: PremiumButtonStyle.primary,
            isFullWidth: !isLargeScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String description,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withOpacity(0.5)
            : AppTheme.surfaceSecondary.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.success.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? AppTheme.darkTextSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
