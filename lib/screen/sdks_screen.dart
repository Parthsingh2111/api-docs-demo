import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_badge.dart';
import '../theme/app_theme.dart';

class SDKsScreen extends StatefulWidget {
  const SDKsScreen({super.key});

  @override
  State<SDKsScreen> createState() => _SDKsScreenState();
}

class _SDKsScreenState extends State<SDKsScreen> with TickerProviderStateMixin {
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

  final List<_SDK> _sdks = const [
    _SDK(
      name: 'Node.js',
      language: 'JavaScript/TypeScript',
      icon: Icons.code,
      color: AppTheme.success,
      description: 'Express.js ready with comprehensive features and minimal dependencies',
      githubUrl: 'https://github.com/Parthsingh2111/pg-client-sdk',
      status: 'Production Ready',
      statusColor: AppTheme.success,
      version: 'v2.0.0',
      features: [
        'JWT & API Key Authentication',
        'Complete Payment Suite',
        'Minimal Dependencies',
        'Enterprise Security',
        'TypeScript Support',
      ],
      installation: 'npm install @payglocal/node-sdk',
    ),
    _SDK(
      name: 'Java',
      language: 'Java/Spring Boot',
      icon: Icons.coffee,
      color: AppTheme.info,
      description: 'Spring Boot ready with thread-safe operations and async support',
      githubUrl: 'https://github.com/Parthsingh2111/pg-client-sdk-java',
      status: 'Production Ready',
      statusColor: AppTheme.success,
      version: 'v2.0.0',
      features: [
        'Thread-Safe Operations',
        'CompletableFuture Async',
        'Maven Central Ready',
        'Builder Pattern',
        'Spring Boot Compatible',
      ],
      installation: 'Maven/Gradle integration available',
    ),
    _SDK(
      name: 'PHP',
      language: 'PHP/Laravel',
      icon: Icons.web,
      color: Color(0xFF8B5CF6),
      description: 'Laravel compatible with zero dependencies and native OpenSSL support',
      githubUrl: 'https://github.com/Parthsingh2111/pg-client-sdk-php',
      status: 'Beta',
      statusColor: AppTheme.warning,
      version: 'v2.0.0',
      features: [
        'Zero Dependencies',
        'Native OpenSSL Support',
        'PSR-4 Compliant',
        'Modern PHP 8+',
        'Laravel Integration',
      ],
      installation: 'composer require payglocal/php-sdk',
    ),
    _SDK(
      name: 'C#',
      language: 'C#/.NET Core',
      icon: Icons.apps,
      color: AppTheme.error,
      description: '.NET Core ready with async/await patterns and NuGet package support',
      githubUrl: 'https://github.com/Parthsingh2111/pg-client-sdk-csharp',
      status: 'Beta',
      statusColor: AppTheme.warning,
      version: 'v2.0.0',
      features: [
        'Async/Await Pattern',
        'NuGet Package Available',
        '.NET Standard Support',
        'Modern C# Features',
        'Full IntelliSense',
      ],
      installation: 'dotnet add package PayGlocal.SDK',
    ),
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Text('$label copied!'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;
    final isMediumScreen = screenWidth > 768 && screenWidth <= 1024;

    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'SDKs & Libraries',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context, isLargeScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildSDKsGrid(context, isLargeScreen, isMediumScreen),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildQuickStart(context, isLargeScreen),
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
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: Icon(
                  Icons.code,
                  size: isLargeScreen ? 40 : 32,
                  color: AppTheme.accent,
                ),
              ),
              const Spacer(),
              const PremiumBadge(
                label: '4 Languages',
                variant: PremiumBadgeVariant.primary,
                icon: Icons.language,
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing24 : AppTheme.spacing16),
          Text(
            'SDKs & Libraries',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Production-ready SDKs for your favorite programming languages. Start integrating in minutes with comprehensive features and excellent documentation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing24 : AppTheme.spacing16),
          
          // Quick info
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.infoLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: AppTheme.info.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.info,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    'All SDKs provide identical functionality with language-specific optimizations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.info,
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

  Widget _buildSDKsGrid(BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available SDKs',
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
            crossAxisSpacing: AppTheme.spacing24,
            mainAxisSpacing: AppTheme.spacing24,
            childAspectRatio: isLargeScreen ? 1.4 : 1.1,
          ),
          itemCount: _sdks.length,
          itemBuilder: (context, index) {
            return _buildSDKCard(_sdks[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSDKCard(_SDK sdk) {
    return _SDKCard(
      sdk: sdk,
      onOpenUrl: (url) => _launchURL(url),
      onCopy: (text, label) => _copyToClipboard(text, label),
    );
  }

  Widget _buildQuickStart(BuildContext context, bool isLargeScreen) {
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
          Icon(
            Icons.rocket_launch,
            size: isLargeScreen ? 48 : 40,
            color: Colors.white,
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing24 : AppTheme.spacing16),
          Text(
            'Ready to Get Started?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Choose your SDK and start integrating PayGlocal in minutes',
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
                onPressed: () => Navigator.pushNamed(context, '/getting-started'),
                icon: const Icon(Icons.menu_book),
                label: const Text('View Documentation'),
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
                onPressed: () => Navigator.pushNamed(context, '/api-reference'),
                icon: const Icon(Icons.api),
                label: const Text('API Reference'),
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

class _SDK {
  final String name;
  final String language;
  final IconData icon;
  final Color color;
  final String description;
  final String githubUrl;
  final String status;
  final Color statusColor;
  final String version;
  final List<String> features;
  final String installation;

  const _SDK({
    required this.name,
    required this.language,
    required this.icon,
    required this.color,
    required this.description,
    required this.githubUrl,
    required this.status,
    required this.statusColor,
    required this.version,
    required this.features,
    required this.installation,
  });
}

class _SDKCard extends StatefulWidget {
  final _SDK sdk;
  final void Function(String url) onOpenUrl;
  final void Function(String text, String label) onCopy;

  const _SDKCard({
    required this.sdk,
    required this.onOpenUrl,
    required this.onCopy,
  });

  @override
  State<_SDKCard> createState() => _SDKCardState();
}

class _SDKCardState extends State<_SDKCard> {
  bool _isHovered = false;
  bool _showFeatures = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sdk = widget.sdk;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surfacePrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: _isHovered
                ? sdk.color.withOpacity(0.5)
                : (isDark ? AppTheme.darkBorder : AppTheme.borderLight),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? AppTheme.shadowLG : AppTheme.shadowMD,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: sdk.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Icon(
                      sdk.icon,
                      size: 28,
                      color: sdk.color,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sdk.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: sdk.color,
                          ),
                        ),
                        Text(
                          sdk.language,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PremiumBadge(
                    label: sdk.status,
                    variant: sdk.statusColor == AppTheme.success
                        ? PremiumBadgeVariant.success
                        : PremiumBadgeVariant.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              // Description
              Text(
                sdk.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              // Installation command
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.darkSurfaceElevated 
                      : AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sdk.installation,
                        style: AppTheme.codeStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    InkWell(
                      onTap: () => widget.onCopy(sdk.installation, 'Installation command'),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: sdk.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              // Features toggle
              InkWell(
                onTap: () => setState(() => _showFeatures = !_showFeatures),
                child: Row(
                  children: [
                    Text(
                      'Features',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: sdk.color,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Icon(
                      _showFeatures ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: sdk.color,
                    ),
                  ],
                ),
              ),
              
              // Features list
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showFeatures
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacing12),
                    ...sdk.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: sdk.color,
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              
              const Spacer(),
              const SizedBox(height: AppTheme.spacing16),
              
              // Actions
              Row(
                children: [
                  Text(
                    sdk.version,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => widget.onOpenUrl(sdk.githubUrl),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('GitHub'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: sdk.color,
                      side: BorderSide(color: sdk.color, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing8,
                      ),
                    ),
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
