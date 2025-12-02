import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/themed_scaffold.dart';

class PaymentResponseHandlingScreen extends StatefulWidget {
  const PaymentResponseHandlingScreen({super.key});

  @override
  State<PaymentResponseHandlingScreen> createState() => _PaymentResponseHandlingScreenState();
}

class _PaymentResponseHandlingScreenState extends State<PaymentResponseHandlingScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _hoveredSection;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return ThemedScaffold(
      appBar: SharedAppBar(
        title: 'Payment Response Handling',
        subtitle: 'Understanding PayGlocal payment callbacks',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getTextPrimary(context)),
          onPressed: () => AppNavigation.back(),
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(context),

                const SizedBox(height: 48),

                // Overview Cards
                _buildSectionHeader(context, 'Overview', Icons.dashboard),
                const SizedBox(height: 24),
                _buildOverviewCards(context),

                const SizedBox(height: 48),

                // Step 1: Payment Creation
                _buildSectionHeader(context, 'Step 1: Payment Creation', Icons.create),
                const SizedBox(height: 24),
                _buildPaymentCreationSection(context),

                const SizedBox(height: 48),

                // Step 2: Callback Response
                _buildSectionHeader(context, 'Step 2: Callback Response', Icons.phone_callback),
                const SizedBox(height: 24),
                _buildCallbackResponseSection(context),

                const SizedBox(height: 48),

                // Step 3: Decoding Process
                _buildSectionHeader(context, 'Step 3: Decoding Process', Icons.lock_open),
                const SizedBox(height: 24),
                _buildDecodingSection(context),

                const SizedBox(height: 48),

                // Step 4: Implementation
                _buildSectionHeader(context, 'Step 4: Implementation', Icons.code),
                const SizedBox(height: 24),
                _buildImplementationSection(context),

                const SizedBox(height: 48),

                // Payment Status Reference
                _buildSectionHeader(context, 'Payment Status Reference', Icons.info_outline),
                const SizedBox(height: 24),
                _buildStatusReference(context),

                const SizedBox(height: 48),

                // Error Handling
                _buildSectionHeader(context, 'Error Handling & Best Practices', Icons.warning_amber),
                const SizedBox(height: 24),
                _buildErrorHandling(context),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [AppTheme.blue600.withOpacity(0.1), AppTheme.blue600.withOpacity(0.15)]
            : [AppTheme.blue50, AppTheme.blue50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.blue600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, size: 48, color: AppTheme.blue600),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Callback Flow',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'After a user completes payment, PayGlocal sends an HTTP POST request to your callback URL with encoded payment details. Learn how to receive, decode, and process this response.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getTextSecondary(context),
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.blue600.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.blue600, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    final cards = [
      {
        'title': 'HTTP POST Request',
        'description': 'PayGlocal sends payment results via HTTP POST to your configured callback URL',
        'icon': Icons.send,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Encoded Token',
        'description': 'Payment data is sent as x-gl-token in base64url encoded JWT format',
        'icon': Icons.vpn_key,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Decode & Process',
        'description': 'Extract, decode, and parse the token to access payment details',
        'icon': Icons.code,
        'color': AppTheme.blue600,
      },
    ];

    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (card['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    card['icon'] as IconData,
                    color: card['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  card['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card['description'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.getTextSecondary(context),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentCreationSection(BuildContext context) {
    const paymentPayload = '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "15",
    "txnCurrency": "USD"
  },
  "merchantCallbackURL": "https://your-website-domain.com/payments/merchantCallback"
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.blue600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create Payment with Callback URL',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'When creating a payment, include merchantCallbackURL in your request. This is where PayGlocal will send the payment result after completion.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.getTextSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildCodeBlock(
                context,
                'Payment Creation Payload',
                paymentPayload,
                'application/json',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallbackResponseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.blue600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Receive Callback Response',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'After payment completion, PayGlocal sends an HTTP POST request to your callback URL with payment data encoded in x-gl-token format.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.getTextSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.blue50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.blue600.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.blue600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Token Format',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The x-gl-token follows JWT structure: HEADER.PAYLOAD.SIGNATURE',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment data is in the middle PAYLOAD section, encoded in base64url format.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.getTextSecondary(context),
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

  Widget _buildDecodingSection(BuildContext context) {
    final steps = [
      {
        'title': 'Extract Token',
        'explanation': 'First, retrieve the x-gl-token from the HTTP request. This token contains the encoded payment information sent by PayGlocal.',
        'code': 'const glToken = req.body[\'x-gl-token\'];',
      },
      {
        'title': 'Split by Dot',
        'explanation': 'JWT tokens have three parts separated by dots: header, payload, and signature. Split the token to access each section.',
        'code': 'const tokenParts = glToken.split(\'.\');',
      },
      {
        'title': 'Get Payload',
        'explanation': 'The middle section (index 1) contains the actual payment data. This is what we need to decode.',
        'code': 'const base64UrlPayload = tokenParts[1];',
      },
      {
        'title': 'Convert Base64URL',
        'explanation': 'Base64URL uses different characters than standard Base64. Replace dashes with plus signs and underscores with slashes to convert it.',
        'code': 'const base64Payload = base64UrlPayload\n  .replace(/-/g, \'+\')\n  .replace(/_/g, \'/\');',
      },
      {
        'title': 'Decode Base64',
        'explanation': 'Decode the Base64 string into a readable UTF-8 text format. This will give us the JSON string containing payment details.',
        'code': 'const decodedString = Buffer\n  .from(base64Payload, \'base64\')\n  .toString(\'utf-8\');',
      },
      {
        'title': 'Parse JSON',
        'explanation': 'Finally, parse the decoded string into a JavaScript object so you can access individual payment fields like status, amount, and transaction ID.',
        'code': 'const paymentData = JSON.parse(decodedString);',
      },
    ];

    return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Column(
                children: [
                  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                    width: 28,
                    height: 28,
                        decoration: BoxDecoration(
                      color: AppTheme.blue600,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                          fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: GoogleFonts.inter(
                            fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                        const SizedBox(height: 6),
                            Text(
                          step['explanation'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.getTextSecondary(context),
                            height: 1.4,
                        ),
                  ),
                        const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                            padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkSurfaceElevated
                                : AppTheme.gray100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.getBorderColor(context).withOpacity(0.5),
                              ),
                    ),
                    child: SelectableText(
                      step['code'] as String,
                      style: GoogleFonts.robotoMono(
                              fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textPrimary,
                              height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
                  ),
                ],
            ),
            if (index < steps.length - 1)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                      const SizedBox(width: 14),
                    Container(
                      width: 2,
                        height: 20,
                        color: AppTheme.blue600.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
          ],
        );
      }).toList(),
      ),
    );
  }

  Widget _buildImplementationSection(BuildContext context) {
    const callbackHandler = '''app.post('/payments/merchantCallback', async (req, res) => {
  try {
    // Step 1: Extract token
    const glToken = req.body['x-gl-token'];
    if (!glToken) {
      return res.status(400).send('Token missing');
    }

    // Step 2: Split token by dot
    const tokenParts = glToken.split('.');
    const base64UrlPayload = tokenParts[1];

    // Step 3: Convert base64url to base64
    const base64Payload = base64UrlPayload
      .replace(/-/g, '+')
      .replace(/_/g, '/');

    // Step 4: Decode base64 to string
    const decodedString = Buffer
      .from(base64Payload, 'base64')
      .toString('utf-8');

    // Step 5: Parse JSON
    const paymentData = JSON.parse(decodedString);

    // Step 6: Extract payment details
    const { status, merchantTxnId, amount, gid } = paymentData;

    // Step 7: Handle success/failure
    if (status === 'SENT_FOR_CAPTURE') {
      // Payment successful
      await updateOrderStatus(merchantTxnId, 'paid');
      await sendConfirmationEmail(merchantTxnId);

      // Redirect to success page
      return res.redirect(
        `https://your-domain.com/payment/success?txnId=\${merchantTxnId}`
      );
    } else {
      // Payment failed
      await updateOrderStatus(merchantTxnId, 'failed');

      // Redirect to failure page
      return res.redirect(
        `https://your-domain.com/payment/failure?txnId=\${merchantTxnId}`
      );
    }
  } catch (error) {
    console.error('Error processing payment callback:', error);
    res.status(500).send('Internal server error');
  }
});''';

    return _buildCodeBlock(
      context,
      'Complete Callback Handler (Node.js)',
      callbackHandler,
      'javascript',
    );
  }

  Widget _buildCodeBlock(BuildContext context, String title, String code, String language) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, color: AppTheme.blue600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.blue600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    language,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blue600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray100,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(
                color: AppTheme.getBorderColor(context).withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    code,
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard'),
                        backgroundColor: AppTheme.blue600,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text('Copy Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusReference(BuildContext context) {
    final statuses = [
      {
        'status': 'SENT_FOR_CAPTURE',
        'meaning': 'Payment Successful',
        'description': 'Payment has been successfully processed and authorized. You can proceed with order fulfillment.',
        'action': 'Update order status to "paid", send confirmation, fulfill order',
        'color': AppTheme.blue600,
        'icon': Icons.check_circle,
      },
      {
        'status': 'FAILED',
        'meaning': 'Payment Failed',
        'description': 'Payment attempt was unsuccessful. This could be due to insufficient funds, declined card, or other payment issues.',
        'action': 'Update order status to "failed", notify user, allow retry',
        'color': AppTheme.blue600,
        'icon': Icons.cancel,
      },
      {
        'status': 'PENDING',
        'meaning': 'Payment Pending',
        'description': 'Payment is still being processed. Wait for final status before taking action.',
        'action': 'Keep order in pending state, wait for final webhook',
        'color': AppTheme.blue600,
        'icon': Icons.pending,
      },
      {
        'status': 'CANCELLED',
        'meaning': 'Payment Cancelled',
        'description': 'Payment was cancelled by the user before completion.',
        'action': 'Update order status to "cancelled", allow new payment attempt',
        'color': AppTheme.gray600,
        'icon': Icons.cancel_outlined,
      },
    ];

    return Column(
      children: statuses.map((status) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (status['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: status['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status['status'] as String,
                          style: GoogleFonts.robotoMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: status['color'] as Color,
                          ),
                        ),
                        Text(
                          status['meaning'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                status['description'] as String,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.getTextSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (status['color'] as Color).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (status['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: status['color'] as Color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Action: ${status['action']}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorHandling(BuildContext context) {
    final practices = [
      {
        'title': 'Always Validate Token',
        'description': 'Check if x-gl-token exists before processing',
        'icon': Icons.verified_user,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Handle Decode Errors',
        'description': 'Wrap decoding logic in try-catch blocks',
        'icon': Icons.error_outline,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Log All Callbacks',
        'description': 'Keep detailed logs for debugging and audit trails',
        'icon': Icons.article,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Validate Status Values',
        'description': 'Check status against known values before processing',
        'icon': Icons.fact_check,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Implement Idempotency',
        'description': 'Use merchantTxnId to prevent duplicate processing',
        'icon': Icons.filter_1,
        'color': AppTheme.blue600,
      },
      {
        'title': 'Secure Your Endpoint',
        'description': 'Use HTTPS, validate signatures, implement rate limiting',
        'icon': Icons.security,
        'color': AppTheme.blue600,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: practices.length,
      itemBuilder: (context, index) {
        final practice = practices[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (practice['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  practice['icon'] as IconData,
                  color: practice['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      practice['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      practice['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
