import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class PayDirectAuthDetailScreen extends StatefulWidget {
  const PayDirectAuthDetailScreen({super.key});

  @override
  _PayDirectAuthDetailScreenState createState() => _PayDirectAuthDetailScreenState();
}

class _PayDirectAuthDetailScreenState extends State<PayDirectAuthDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1024;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
      appBar: const PremiumAppBar(
        title: 'Auth & Capture - PayDirect',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(
            isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildWhatIsSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildWhyUseSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildWhenToUseSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildWorkflowSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildKeyFeaturesSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildApiReferenceSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                  _buildTryDemoCTA(context, isLargeScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

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
                  Icons.swap_horiz,
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
                      'Auth & Capture',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'PayDirect',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Flexible Payment Authorization and Capture',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Auth & Capture separates payment authorization from fund capture, giving you complete control over when to charge customers. Perfect for businesses that need to verify inventory, confirm bookings, or validate services before capturing payment.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is Auth & Capture?',
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
                'Auth & Capture is a two-phase payment process that separates fund reservation (authorization) from fund collection (capture).',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'The three phases:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              _buildBulletPoint('Authorization: Reserve funds on customer\'s card without charging', isDark),
              _buildBulletPoint('Capture: Charge the reserved funds after confirmation', isDark),
              _buildBulletPoint('Reversal: Release reserved funds if transaction is canceled', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhyUseSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    final reasons = [
      {
        'icon': Icons.inventory,
        'title': 'Inventory Verification',
        'description': 'Reserve funds while you check stock availability before charging customers.',
      },
      {
        'icon': Icons.shield_moon,
        'title': 'Fraud Prevention',
        'description': 'Validate orders and prevent fraudulent transactions before capturing payment.',
      },
      {
        'icon': Icons.schedule,
        'title': 'Delayed Fulfillment',
        'description': 'Charge customers only when you\'re ready to ship or deliver the service.',
      },
      {
        'icon': Icons.undo,
        'title': 'Clean Reversals',
        'description': 'Release funds without going through refund processes if order is canceled.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Use Auth & Capture?',
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
            return PremiumCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Icon(
                      reason['icon'] as IconData,
                      size: 28,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reason['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          reason['description'] as String,
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
          },
        ),
      ],
    );
  }

  Widget _buildWhenToUseSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    final useCases = [
      {
        'title': 'E-commerce with Inventory',
        'description': 'Authorize payment, verify stock, then capture only after confirming availability.',
        'icon': Icons.shopping_cart,
        'example': 'Online retailers, fashion stores',
      },
      {
        'title': 'Travel & Hospitality',
        'description': 'Reserve funds for bookings, charge after seat/room confirmation.',
        'icon': Icons.flight,
        'example': 'Airlines, hotels, car rentals',
      },
      {
        'title': 'Event Ticketing',
        'description': 'Hold tickets during purchase flow, charge upon final confirmation.',
        'icon': Icons.confirmation_number,
        'example': 'Concerts, sports events, theaters',
      },
      {
        'title': 'Custom Orders',
        'description': 'Authorize for custom products, capture after production completion.',
        'icon': Icons.design_services,
        'example': 'Made-to-order products, custom printing',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When to Use Auth & Capture?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        ...useCases.map((useCase) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Icon(
                        useCase['icon'] as IconData,
                        size: 24,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            useCase['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            useCase['description'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing12,
                              vertical: AppTheme.spacing8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: Text(
                              'Examples: ${useCase['example']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWorkflowSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auth & Capture Workflow',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildWorkflowStep('1', 'Authorization', 'Reserve funds on customer card', AppTheme.info, isDark),
                  if (isLargeScreen) const SizedBox(height: AppTheme.spacing16),
                  if (!isLargeScreen) _buildWorkflowArrow(isDark),
                ],
              ),
            ),
            if (isLargeScreen) _buildWorkflowArrow(isDark),
            Expanded(
              child: Column(
                children: [
                  _buildWorkflowStep('2', 'Verification', 'Check stock/booking', AppTheme.warning, isDark),
                  if (isLargeScreen) const SizedBox(height: AppTheme.spacing16),
                  if (!isLargeScreen) _buildWorkflowArrow(isDark),
                ],
              ),
            ),
            if (isLargeScreen) _buildWorkflowArrow(isDark),
            Expanded(
              child: _buildWorkflowStep('3', 'Capture/Reversal', 'Charge or release funds', AppTheme.success, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkflowStep(String number, String title, String description, Color color, bool isDark) {
    return PremiumCard(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.arrow_forward,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        size: 24,
      ),
    );
  }

  Widget _buildKeyFeaturesSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    final features = [
      'Separate authorization and capture workflow',
      'Full or partial capture support',
      'Authorization reversal for canceled orders',
      'Automatic authorization expiry (typically 7 days)',
      'Multiple captures from single authorization',
      'Real-time status updates for each phase',
      'Clean fund release without refund processes',
      'Reduced chargeback risk',
    ];

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
            children: features
                .map((feature) => Padding(
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
                              feature,
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

  Widget _buildApiReferenceSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Reference',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Authorization Endpoint
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_open, color: AppTheme.info, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Authorization Endpoint',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Text(
                        'POST',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        '/gl/v1/payments/auth',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(
                        '/gl/v1/payments/auth',
                        'Authorization endpoint',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Capture Endpoint
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Capture Endpoint',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Text(
                        'POST',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        '/gl/v1/payments/{gid}/capture',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(
                        '/gl/v1/payments/{gid}/capture',
                        'Capture endpoint',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Reversal Endpoint
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.undo, color: AppTheme.warning, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Reversal Endpoint',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Text(
                        'POST',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        '/gl/v1/payments/{gid}/auth-reversal',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(
                        '/gl/v1/payments/{gid}/auth-reversal',
                        'Reversal endpoint',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTryDemoCTA(BuildContext context, bool isLargeScreen) {
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
            Icons.rocket_launch,
            size: isLargeScreen ? 56 : 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Ready to Try Auth & Capture?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Test the complete auth, capture, and reversal workflow in our interactive demo.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24),
          PremiumButton(
            label: 'Try Demo Now',
            icon: Icons.play_arrow,
            onPressed: () {
              Navigator.pushNamed(context, '/paydirect/airline');
            },
            buttonStyle: PremiumButtonStyle.primary,
            isFullWidth: !isLargeScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right,
            size: 20,
            color: AppTheme.success,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

