import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';
import '../theme/app_theme.dart';

class WebhooksScreen extends StatefulWidget {
  const WebhooksScreen({super.key});

  @override
  _WebhooksScreenState createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends State<WebhooksScreen>
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
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('$label copied!',
                style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundPrimary,
      appBar: SharedAppBar(
        title: 'Webhooks',
        fadeAnimation: _fadeAnimation,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildOverviewSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildSetupSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildPayloadSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildSecuritySection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildEventsSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildHandlingExampleSection(isLargeScreen, isDark),
                    const SizedBox(height: 40),
                    _buildBestPracticesSection(isLargeScreen, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isLargeScreen, bool isDark) {
    final heroColor = isDark ? AppTheme.darkJwtBlue : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppTheme.darkJwtBlue.withOpacity(0.15), AppTheme.darkJwtBlueDim.withOpacity(0.1)]
            : [AppTheme.accent.withOpacity(0.1), AppTheme.accentLight.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? AppTheme.darkJwtBlue.withOpacity(0.3)
            : AppTheme.accent.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.darkJwtBlue : AppTheme.accent).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                    ? AppTheme.darkJwtBlue.withOpacity(0.15)
                    : AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.webhook, 
                  color: isDark ? AppTheme.darkJwtBlue : AppTheme.accent, 
                  size: 32
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Webhooks',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Receive real-time payment notifications to keep your system in sync',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are Webhooks?',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Webhooks are HTTP callbacks that notify your application when events occur in PayGlocal. Instead of repeatedly polling our API for status updates, webhooks push notifications to your server as soon as events happen.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why Use Webhooks?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitItem(
                Icons.speed,
                'Real-time Updates',
                'Get instant notifications when payment status changes',
                isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
                isDark,
              ),
              _buildBenefitItem(
                Icons.trending_down,
                'Reduced Load',
                'No need to continuously poll API for updates',
                isDark ? AppTheme.darkJwtBlue : AppTheme.info,
                isDark,
              ),
              _buildBenefitItem(
                Icons.verified,
                'Reliable',
                'Automatic retries ensure you receive critical updates',
                isDark ? AppTheme.darkSIPausePurple : AppTheme.accent,
                isDark,
              ),
              _buildBenefitItem(
                Icons.security,
                'Secure',
                'JWS signatures verify authenticity of notifications',
                isDark ? AppTheme.darkErrorCoral : AppTheme.error,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
      IconData icon, String title, String description, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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

  Widget _buildSetupSection(bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setting Up Webhooks',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          '1',
          'Create Webhook Endpoint',
          'Set up an HTTPS endpoint on your server to receive webhooks',
          _buildCodeBlock(
            '''// Node.js Express example
app.post('/webhook/payglocal', async (req, res) => {
  const payload = req.body;
  const signature = req.headers['x-gl-signature'];
  
  // Verify signature
  const isValid = await verifySignature(payload, signature);
  if (!isValid) {
    return res.status(401).send('Invalid signature');
  }
  
  // Process webhook
  await processPaymentWebhook(payload);
  
  // Respond quickly
  res.status(200).send('Webhook received');
});''',
            'javascript',
            isDark,
          ),
          isDark ? AppTheme.darkJwtBlue : AppTheme.info,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          '2',
          'Configure in Dashboard',
          'Add your webhook URL in the PayGlocal merchant dashboard',
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                ? AppTheme.darkWarningOrange.withOpacity(0.1)
                : AppTheme.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                  ? AppTheme.darkWarningOrange.withOpacity(0.3)
                  : AppTheme.warning.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Configuration Steps:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildConfigStep('1. Login to merchant dashboard', isDark),
                _buildConfigStep('2. Navigate to Settings > Webhooks', isDark),
                _buildConfigStep('3. Add your webhook URL (must be HTTPS)', isDark),
                _buildConfigStep('4. Select events you want to receive', isDark),
                _buildConfigStep('5. Save and activate', isDark),
              ],
            ),
          ),
          isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          '3',
          'Test Your Integration',
          'Use test mode to verify webhook handling',
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                ? AppTheme.darkSuccessEmerald.withOpacity(0.1)
                : AppTheme.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                  ? AppTheme.darkSuccessEmerald.withOpacity(0.3)
                  : AppTheme.success.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Testing Tips:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildConfigStep('Use webhook.site for quick testing', isDark),
                _buildConfigStep('Use ngrok for local development', isDark),
                _buildConfigStep('Test signature verification', isDark),
                _buildConfigStep('Simulate different payment scenarios', isDark),
              ],
            ),
          ),
          isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
          isDark,
        ),
      ],
    );
  }

  Widget _buildConfigStep(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description,
      Widget content, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.2 : 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 1.0),
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: color.withOpacity(0.4)) : null,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? color : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildPayloadSection(bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook Payload',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Webhooks are sent as POST requests with JWS-encrypted payload',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Headers:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '''Content-Type: application/jose
X-GL-Signature: <JWS_SIGNATURE>
X-Merchant-ID: <YOUR_MERCHANT_ID>''',
          'http',
          isDark,
        ),
        const SizedBox(height: 24),
        Text(
          'Decrypted Payload Structure:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '''{
  "event": "PAYMENT_SUCCESS",
  "timestamp": "2024-01-22T10:30:00Z",
  "data": {
    "gid": "PG_202401220001",
    "merchantTxnId": "TXN_20240122_001",
    "status": "SUCCESS",
    "amount": "1000.00",
    "currency": "INR",
    "paymentMethod": "CARD",
    "cardBrand": "VISA",
    "last4": "4242",
    "customerEmail": "customer@example.com",
    "customerId": "CUST_123",
    "createdAt": "2024-01-22T10:25:00Z",
    "completedAt": "2024-01-22T10:30:00Z"
  }
}''',
          'json',
          isDark,
        ),
      ],
    );
  }

  Widget _buildSecuritySection(bool isLargeScreen, bool isDark) {
    final errorColor = isDark ? AppTheme.darkErrorCoral : AppTheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security & Verification',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Always verify webhook authenticity using JWS signature',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark 
              ? errorColor.withOpacity(0.1)
              : AppTheme.errorLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorColor.withOpacity(isDark ? 0.3 : 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: errorColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Security Best Practices',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSecurityPoint('✓ Always verify JWS signature', isDark),
              _buildSecurityPoint('✓ Use HTTPS endpoint only', isDark),
              _buildSecurityPoint('✓ Validate merchant ID in headers', isDark),
              _buildSecurityPoint('✓ Check timestamp to prevent replay attacks', isDark),
              _buildSecurityPoint('✓ Don\'t expose webhook URL publicly', isDark),
              _buildSecurityPoint('✓ Implement rate limiting', isDark),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Signature Verification Example:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '''const crypto = require('crypto');
const { JWS } = require('node-jose');

async function verifyWebhookSignature(payload, signature) {
  try {
    // Load PayGlocal public key
    const publicKey = await JWS.createVerify(publicKeyStore);
    
    // Verify JWS signature
    const result = await publicKey.verify(signature);
    const verified = JSON.parse(result.payload.toString());
    
    // Verify timestamp (within 5 minutes)
    const timestamp = new Date(verified.timestamp);
    const now = new Date();
    const diff = Math.abs(now - timestamp) / 1000 / 60;
    
    if (diff > 5) {
      throw new Error('Webhook timestamp too old');
    }
    
    return verified;
  } catch (error) {
    console.error('Signature verification failed:', error);
    return null;
  }
}''',
          'javascript',
          isDark,
        ),
      ],
    );
  }

  Widget _buildSecurityPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEventsSection(bool isLargeScreen, bool isDark) {
    final events = [
      {
        'name': 'PAYMENT_SUCCESS',
        'description': 'Payment completed successfully',
        'color': isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
      },
      {
        'name': 'PAYMENT_FAILED',
        'description': 'Payment failed or was declined',
        'color': isDark ? AppTheme.darkErrorCoral : AppTheme.error,
      },
      {
        'name': 'PAYMENT_PENDING',
        'description': 'Payment is awaiting confirmation',
        'color': isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
      },
      {
        'name': 'REFUND_SUCCESS',
        'description': 'Refund processed successfully',
        'color': isDark ? AppTheme.darkJwtBlue : AppTheme.info,
      },
      {
        'name': 'REFUND_FAILED',
        'description': 'Refund processing failed',
        'color': isDark ? AppTheme.darkErrorCoral : AppTheme.error,
      },
      {
        'name': 'DISPUTE_OPENED',
        'description': 'Customer opened a dispute',
        'color': isDark ? AppTheme.darkSIPausePurple : AppTheme.accent,
      },
      {
        'name': 'DISPUTE_RESOLVED',
        'description': 'Dispute was resolved',
        'color': isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook Events',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PayGlocal sends webhooks for the following events',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            ),
          ),
          child: Column(
            children: events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final eventColor = event['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: index < events.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: eventColor.withOpacity(isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.circle,
                        color: eventColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name'] as String,
                            style: GoogleFonts.firaCode(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event['description'] as String,
                            style: GoogleFonts.poppins(
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHandlingExampleSection(bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook Handling Example',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Complete example showing how to handle webhook notifications and process the response',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample Webhook Response:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildCodeBlock(
                '''{
  "country": "UNITED KINGDOM",
  "amount": "48",
  "gid": "gl_o-pYA8MLrsnfVpKp1mw",
  "merchantId": "alwyntest1",
  "cardType": "PREPAID",
  "merchantTxnId": "17083906765",
  "paymentMethod": "CARD",
  "currency": "USD",
  "cardBrand": "VISA",
  "status": "SENT_FOR_CAPTURE"
}''',
                'json',
                isDark,
              ),
              const SizedBox(height: 24),
              Text(
                'Complete Handling Example (Node.js/Express):',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildCodeBlock(
                '''const express = require('express');
const crypto = require('crypto');
const { JWS } = require('node-jose');

const app = express();
app.use(express.text({ type: 'application/jose' })); // For JWS payload

// Store processed webhook IDs to prevent duplicates
const processedWebhooks = new Set();

app.post('/webhook/payglocal', async (req, res) => {
  try {
    // 1. Extract JWS signature from header
    const signature = req.headers['x-gl-signature'];
    const merchantId = req.headers['x-merchant-id'];
    
    if (!signature) {
      console.error('Missing x-gl-signature header');
      return res.status(401).json({ error: 'Missing signature' });
    }

    // 2. Verify JWS signature (if using JWS)
    // Note: If webhook uses plain JSON, skip signature verification
    // const isValid = await verifySignature(req.body, signature);
    // if (!isValid) {
    //   return res.status(401).json({ error: 'Invalid signature' });
    // }

    // 3. Parse the webhook payload
    // If using JWS, decrypt first, otherwise parse JSON directly
    let webhookData;
    try {
      // For plain JSON webhooks (as shown in the example)
      webhookData = typeof req.body === 'string' 
        ? JSON.parse(req.body) 
        : req.body;
    } catch (parseError) {
      console.error('Failed to parse webhook payload:', parseError);
      return res.status(400).json({ error: 'Invalid payload format' });
    }

    // 4. Extract key fields from webhook response
    const {
      gid,
      merchantTxnId,
      status,
      amount,
      currency,
      paymentMethod,
      cardBrand,
      cardType,
      country,
      merchantId: payloadMerchantId
    } = webhookData;

    // 5. Validate merchant ID
    if (merchantId && payloadMerchantId !== merchantId) {
      console.error('Merchant ID mismatch');
      return res.status(403).json({ error: 'Invalid merchant ID' });
    }

    // 6. Check for duplicate webhooks using merchantTxnId
    const webhookKey = \`\${merchantTxnId}_\${gid}\`;
    if (processedWebhooks.has(webhookKey)) {
      console.log('Duplicate webhook received, ignoring:', webhookKey);
      return res.status(200).json({ message: 'Webhook already processed' });
    }

    // 7. Process webhook based on status
    switch (status) {
      case 'SENT_FOR_CAPTURE':
      case 'SUCCESS':
        await handleSuccessfulPayment({
          gid,
          merchantTxnId,
          amount,
          currency,
          paymentMethod,
          cardBrand,
          cardType,
          country
        });
        break;
      
      case 'FAILED':
      case 'DECLINED':
        await handleFailedPayment({
          gid,
          merchantTxnId,
          amount,
          currency,
          status
        });
        break;
      
      case 'PENDING':
        await handlePendingPayment({
          gid,
          merchantTxnId,
          amount,
          currency
        });
        break;
      
      default:
        console.log('Unknown status received:', status);
    }

    // 8. Mark webhook as processed
    processedWebhooks.add(webhookKey);
    
    // 9. Clean up old entries (optional, prevent memory leak)
    if (processedWebhooks.size > 10000) {
      const entries = Array.from(processedWebhooks);
      processedWebhooks.clear();
      entries.slice(-5000).forEach(key => processedWebhooks.add(key));
    }

    // 10. Respond quickly (within 5 seconds)
    res.status(200).json({ 
      message: 'Webhook received successfully',
      gid,
      merchantTxnId 
    });

  } catch (error) {
    console.error('Webhook processing error:', error);
    // Still return 200 to prevent retries for processing errors
    // Log error for manual investigation
    res.status(200).json({ 
      error: 'Processing failed',
      message: error.message 
    });
  }
});

// Helper function to handle successful payments
async function handleSuccessfulPayment(data) {
  console.log('Processing successful payment:', data);
  
  // Update your database
  // await db.updateOrderStatus(data.merchantTxnId, 'PAID');
  
  // Send confirmation email
  // await sendEmail(data.customerEmail, 'Payment Successful');
  
  // Update inventory, etc.
  // await updateInventory(data.orderId);
}

// Helper function to handle failed payments
async function handleFailedPayment(data) {
  console.log('Processing failed payment:', data);
  
  // Update your database
  // await db.updateOrderStatus(data.merchantTxnId, 'FAILED');
  
  // Notify customer
  // await sendEmail(data.customerEmail, 'Payment Failed');
}

// Helper function to handle pending payments
async function handlePendingPayment(data) {
  console.log('Processing pending payment:', data);
  
  // Update your database
  // await db.updateOrderStatus(data.merchantTxnId, 'PENDING');
}

// Optional: Signature verification function (if using JWS)
async function verifySignature(payload, signature) {
  try {
    // Load PayGlocal public key
    // const publicKeyStore = await jose.JWK.asKeyStore(publicKeyJson);
    // const publicKey = await JWS.createVerify(publicKeyStore);
    
    // Verify JWS signature
    // const result = await publicKey.verify(signature);
    // const verified = JSON.parse(result.payload.toString());
    
    // For plain JSON webhooks (as in the example), signature verification
    // may not be required. Implement based on your webhook configuration.
    return true;
  } catch (error) {
    console.error('Signature verification failed:', error);
    return false;
  }
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(\`Webhook server listening on port \${PORT}\`);
});''',
                'javascript',
                isDark,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                    ? AppTheme.darkJwtBlue.withOpacity(0.1)
                    : AppTheme.infoLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                      ? AppTheme.darkJwtBlue.withOpacity(0.3)
                      : AppTheme.info.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark ? AppTheme.darkJwtBlue : AppTheme.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Key Points:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkJwtBlue : AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint('✓ Always respond with 200 OK within 5 seconds', isDark),
                    _buildInfoPoint('✓ Use merchantTxnId + gid to track and prevent duplicates', isDark),
                    _buildInfoPoint('✓ Process webhook data asynchronously after responding', isDark),
                    _buildInfoPoint('✓ Validate merchantId to ensure webhook is for your account', isDark),
                    _buildInfoPoint('✓ Handle different status values (SUCCESS, FAILED, PENDING, etc.)', isDark),
                    _buildInfoPoint('✓ Store webhook data in your database for audit trail', isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPracticesSection(bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Practices',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _buildPracticeCard(
          Icons.flash_on,
          'Respond Quickly',
          'Return 200 OK as soon as you receive the webhook. Process asynchronously.',
          isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildPracticeCard(
          Icons.replay,
          'Handle Duplicates',
          'Use merchantTxnId to track processed webhooks and ignore duplicates.',
          isDark ? AppTheme.darkJwtBlue : AppTheme.info,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildPracticeCard(
          Icons.error_outline,
          'Implement Fallback',
          'Don\'t rely solely on webhooks. Use status API as backup.',
          isDark ? AppTheme.darkErrorCoral : AppTheme.error,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildPracticeCard(
          Icons.storage,
          'Log Everything',
          'Keep detailed logs of all webhooks for debugging and auditing.',
          isDark ? AppTheme.darkSIPausePurple : AppTheme.accent,
          isDark,
        ),
      ],
    );
  }

  Widget _buildPracticeCard(
      IconData icon, String title, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.2 : 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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

  Widget _buildCodeBlock(String code, String language, bool isDark) {
    final codeBg = isDark ? AppTheme.darkSurfaceElevated : const Color(0xFF1E293B);
    final codeHeaderBg = isDark ? AppTheme.darkSurface : const Color(0xFF0F172A);
    final codeText = isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8);
    final codeLabel = isDark ? AppTheme.darkJwtBlue : const Color(0xFF60A5FA);
    
    return Container(
      decoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFF475569),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: codeHeaderBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: codeLabel.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    language,
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: codeLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: codeText, size: 18),
                  onPressed: () => _copyToClipboard(code, 'Code'),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: codeText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

