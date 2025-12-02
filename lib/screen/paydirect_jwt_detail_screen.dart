import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_button.dart';
import '../theme/app_theme.dart';

class PayDirectJwtDetailScreen extends StatefulWidget {
  const PayDirectJwtDetailScreen({super.key});

  @override
  _PayDirectJwtDetailScreenState createState() => _PayDirectJwtDetailScreenState();
}

class _PayDirectJwtDetailScreenState extends State<PayDirectJwtDetailScreen>
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
        title: 'JWT Authentication - PayDirect',
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
                  // Hero Section
                  _buildHeroSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // What is JWT Authentication
                  _buildWhatIsSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // Why Use JWT Authentication
                  _buildWhyUseSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // When to Use
                  _buildWhenToUseSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // Key Features
                  _buildKeyFeaturesSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // API Reference
                  _buildApiReferenceSection(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // Try Demo CTA
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
            AppTheme.info.withOpacity(0.1),
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
                      AppTheme.info,
                      AppTheme.info.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.info.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_outline,
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
                      'JWT Authentication',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.info,
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
            'Secure Payment Initiation with JWE/JWS Encryption',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'JWT (JSON Web Token) Authentication for PayDirect enables PCI DSS certified merchants to securely process direct payments with card data collection on their own interface. Perfect for enterprises requiring maximum control and security.',
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
          'What is JWT Authentication?',
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
                'JWT Authentication is a secure method of payment initiation that uses JSON Web Encryption (JWE) and JSON Web Signature (JWS) to protect sensitive payment data during transmission.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'When you initiate a payment using JWT Authentication:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              _buildBulletPoint('Your payment data is encrypted using PayGlocal\'s public key (JWE)', isDark),
              _buildBulletPoint('The encrypted data is then signed with your private key (JWS)', isDark),
              _buildBulletPoint('PayGlocal validates the signature and decrypts the data', isDark),
              _buildBulletPoint('This ensures data confidentiality, integrity, and non-repudiation', isDark),
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
        'icon': Icons.security,
        'title': 'Maximum Security',
        'description': 'Dual-layer encryption with JWE and JWS provides military-grade security for your payment data.',
      },
      {
        'icon': Icons.verified_user,
        'title': 'Data Integrity',
        'description': 'Digital signatures ensure that payment data cannot be tampered with during transmission.',
      },
      {
        'icon': Icons.shield,
        'title': 'Non-Repudiation',
        'description': 'Cryptographic signatures prove the authenticity and origin of each payment request.',
      },
      {
        'icon': Icons.privacy_tip,
        'title': 'Confidentiality',
        'description': 'End-to-end encryption ensures that sensitive payment data remains private and secure.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Use JWT Authentication?',
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
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Icon(
                      reason['icon'] as IconData,
                      size: 28,
                      color: AppTheme.info,
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
        'title': 'High-Security Payment Integrations',
        'description': 'When your business handles sensitive financial data and requires the highest level of security compliance.',
        'icon': Icons.account_balance,
      },
      {
        'title': 'Enterprise Payment Processing',
        'description': 'Large-scale merchants who need robust authentication and security for high-value transactions.',
        'icon': Icons.business,
      },
      {
        'title': 'Regulated Industries',
        'description': 'Financial services, healthcare, and other industries with strict data protection requirements.',
        'icon': Icons.policy,
      },
      {
        'title': 'API-First Integration',
        'description': 'Merchants who want advanced API access with cryptographic authentication across all PayGlocal services.',
        'icon': Icons.api,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When to Use JWT Authentication?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        ...useCases.map((useCase) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
          child: PremiumCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: Icon(
                    useCase['icon'] as IconData,
                    size: 24,
                    color: AppTheme.info,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildKeyFeaturesSection(BuildContext context, bool isLargeScreen, bool isDark) {
    final theme = Theme.of(context);

    final features = [
      'JWE (JSON Web Encryption) using RSA-OAEP-256 algorithm',
      'JWS (JSON Web Signature) using RS256 algorithm',
      'Asymmetric key cryptography for maximum security',
      'Compatible with all PayGlocal APIs and endpoints',
      'x-gl-token-external header for secure token transmission',
      'Automatic key rotation and management support',
      'RFC 7519 compliant JWT implementation',
      'SDK support for Node.js, Java, PHP, and C#',
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

        // Endpoint Section
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: AppTheme.info, size: 24),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Payment Initiation Endpoint',
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
                        '/gl/v1/payments/initiate',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(
                        '/gl/v1/payments/initiate',
                        'Endpoint',
                      ),
                      tooltip: 'Copy endpoint',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
                Text(
                'This endpoint initiates a direct payment using JWT authentication for PayDirect. The request includes card data and must be encrypted using JWE and signed using JWS.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Headers Section
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.http, color: AppTheme.warning, size: 24),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Request Headers',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildHeaderItem('Content-Type', 'text/plain', 'The payload is sent as plain text (JWE token)', isDark),
              const SizedBox(height: AppTheme.spacing12),
              _buildHeaderItem('x-gl-token-external', '<JWS_TOKEN>', 'JWT signature token for authentication', isDark),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Request Body Section
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: AppTheme.info, size: 24),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Request Body (Before Encryption)',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'The following JSON payload is encrypted using JWE before sending:',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JSON',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF9CA3AF)),
                          onPressed: () => _copyToClipboard(
                            '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR",\n    "cardData": {\n      "number": "5132552222223470",\n      "expiryMonth": "12",\n      "expiryYear": "2030",\n      "securityCode": "123"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
                            'Request payload',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    SelectableText(
                      '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR",\n    "cardData": {\n      "number": "5132552222223470",\n      "expiryMonth": "12",\n      "expiryYear": "2030",\n      "securityCode": "123"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildParameterItem('merchantTxnId', 'string', 'Unique transaction ID from your system', true),
              _buildParameterItem('paymentData.totalAmount', 'string', 'Payment amount in smallest currency unit', true),
              _buildParameterItem('paymentData.txnCurrency', 'string', 'ISO 4217 currency code (e.g., INR, USD)', true),
              _buildParameterItem('paymentData.cardData.number', 'string', 'Card number', true),
              _buildParameterItem('paymentData.cardData.expiryMonth', 'string', 'Card expiry month (MM)', true),
              _buildParameterItem('paymentData.cardData.expiryYear', 'string', 'Card expiry year (YYYY)', true),
              _buildParameterItem('paymentData.cardData.securityCode', 'string', 'Card CVV/CVC', true),
              _buildParameterItem('merchantCallbackURL', 'string', 'URL to receive payment status callbacks', true),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Response Section
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Response (Success)',
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
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JSON',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF9CA3AF)),
                          onPressed: () => _copyToClipboard(
                            '{\n  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",\n  "status": "INPROGRESS",\n  "message": "Transaction Created Successfully",\n  "data": {\n    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=...",\n    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-962989f8777c7ff29lo0Yd5X2/status",\n    "merchantTxnId": "23AEE8CB6B62EE2AF07"\n  }\n}',
                            'Response payload',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    SelectableText(
                      '{\n  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",\n  "status": "INPROGRESS",\n  "message": "Transaction Created Successfully",\n  "data": {\n    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=...",\n    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-962989f8777c7ff29lo0Yd5X2/status",\n    "merchantTxnId": "23AEE8CB6B62EE2AF07"\n  }\n}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildParameterItem('gid', 'string', 'PayGlocal transaction ID', false),
              _buildParameterItem('status', 'string', 'Transaction status (INPROGRESS, SUCCESS, FAILED)', false),
              _buildParameterItem('data.redirectUrl', 'string', 'URL to redirect customer for payment', false),
              _buildParameterItem('data.statusUrl', 'string', 'URL to check payment status', false),
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
            AppTheme.info.withOpacity(0.9),
            AppTheme.info,
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
            'Ready to Try JWT Authentication?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Experience the power of secure JWT-based payment initiation in our interactive demo. Test real API calls and see how easy integration can be.',
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
              Navigator.pushNamed(context, '/paydirect/jwt');
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
            color: AppTheme.info,
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

  Widget _buildHeaderItem(String name, String value, String description, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.info,
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterItem(String name, String type, String description, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          if (isRequired)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.error,
                ),
              ),
            ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

