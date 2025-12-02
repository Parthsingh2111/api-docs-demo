import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_navigation.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/themed_scaffold.dart';

class WebhooksDocumentationScreen extends StatefulWidget {
  const WebhooksDocumentationScreen({super.key});

  @override
  State<WebhooksDocumentationScreen> createState() => _WebhooksDocumentationScreenState();
}

class _WebhooksDocumentationScreenState extends State<WebhooksDocumentationScreen> {
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
        title: 'Webhooks Documentation',
        subtitle: 'Real-time event notifications for your application',
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
                // Hero Section with Overview
                _buildHeroSection(context),

                const SizedBox(height: 48),

                // Main Content Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Concepts
                    Expanded(
                      flex: isLargeScreen ? 1 : 0,
                      child: Column(
                        children: [
                          _buildConceptCard(
                            context,
                            'What is a Webhook?',
                            Icons.info_outline,
                            'A webhook is an automated HTTP POST request sent from one application to another when a specific event occurs. It enables real-time communication between systems without constant polling.',
                            AppTheme.blue600,
                          ),
                          const SizedBox(height: 24),
                          _buildConceptCard(
                            context,
                            'Why Use Webhooks?',
                            Icons.auto_awesome,
                            'Webhooks provide instant notifications, eliminate polling overhead, reduce server load, and enable event-driven architectures for faster, more efficient applications.',
                            AppTheme.blue600,
                          ),
                          const SizedBox(height: 24),
                          _buildConceptCard(
                            context,
                            'When to Use',
                            Icons.event_available,
                            'Use webhooks for payment status updates, order confirmations, transaction monitoring, system synchronization, and any scenario requiring immediate event-based actions.',
                            AppTheme.blue600,
                          ),
                        ],
                      ),
                    ),

                    if (isLargeScreen) const SizedBox(width: 32),

                    // Right Column - Visual Flow
                    if (isLargeScreen)
                      Expanded(
                        flex: 1,
                        child: _buildFlowDiagram(context),
                      ),
                  ],
                ),

                const SizedBox(height: 48),

                // Webhook Handling Example
                _buildSectionHeader(context, 'Webhook Handling Example', Icons.code),
                const SizedBox(height: 24),
                _buildHandlingExampleSection(context),

                const SizedBox(height: 48),

                // Webhooks vs Polling
                _buildSectionHeader(context, 'Webhooks vs Polling', Icons.compare_arrows),
                const SizedBox(height: 24),
                _buildComparisonSection(context),

                const SizedBox(height: 48),

                // PayGlocal Implementation
                _buildSectionHeader(context, 'PayGlocal Webhook Implementation', Icons.integration_instructions),
                const SizedBox(height: 24),
                _buildImplementationSection(context),

                const SizedBox(height: 48),

                // Sample Webhook Response
                _buildSectionHeader(context, 'Sample Webhook Response', Icons.code),
                const SizedBox(height: 24),
                _buildWebhookResponse(context),

                const SizedBox(height: 48),

                // Best Practices
                _buildSectionHeader(context, 'Best Practices', Icons.verified_user),
                const SizedBox(height: 24),
                _buildBestPractices(context),

                const SizedBox(height: 48),

                // FAQ
                _buildSectionHeader(context, 'Frequently Asked Questions', Icons.help_outline),
                const SizedBox(height: 24),
                _buildFAQ(context),

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
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.blue600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.webhook, size: 48, color: AppTheme.blue600),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Real-Time Event Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Webhooks enable your application to receive instant notifications when events occur in PayGlocal, eliminating the need for constant polling and enabling real-time, event-driven workflows.',
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

  Widget _buildConceptCard(BuildContext context, String title, IconData icon, String description, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHovered = _hoveredSection == title;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSection = title),
      onExit: (_) => setState(() => _hoveredSection = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered ? accentColor.withOpacity(0.5) : AppTheme.getBorderColor(context),
            width: isHovered ? 2 : 1,
          ),
          boxShadow: isHovered
            ? [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]
            : isDark ? AppTheme.shadowSM : AppTheme.shadowXS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.getTextSecondary(context),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowDiagram(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Text(
            'Webhook Flow',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 24),
          _buildFlowStep(context, '1', 'Event Occurs', 'Payment processed', AppTheme.blue600),
          _buildFlowArrow(context),
          _buildFlowStep(context, '2', 'Webhook Triggered', 'PayGlocal sends POST', AppTheme.blue600),
          _buildFlowArrow(context),
          _buildFlowStep(context, '3', 'Server Receives', 'Your endpoint gets data', AppTheme.blue600),
          _buildFlowArrow(context),
          _buildFlowStep(context, '4', 'Process & Respond', 'Handle event, return 200', AppTheme.blue600),
          _buildFlowArrow(context),
          _buildFlowStep(context, '5', 'Action Taken', 'Update database, notify user', AppTheme.blue600),
        ],
      ),
    );
  }

  Widget _buildFlowStep(BuildContext context, String number, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14,
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Icon(
          Icons.arrow_downward,
          color: AppTheme.getTextSecondary(context),
          size: 20,
        ),
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

  Widget _buildHandlingExampleSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(
          'Complete example showing how to handle webhook notifications and process the response',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 24),
            Container(
          padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                'Sample Webhook Response:',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildCodeBlock(
                context,
                'Webhook Payload',
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
              ),
              const SizedBox(height: 24),
              Text(
                'Complete Handling Example (Node.js/Express):',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
                    ),
              const SizedBox(height: 12),
              _buildCodeBlock(
                context,
                'Webhook Handler',
                '''app.post('/webhook/payglocal', async (req, res) => {
  try {
    // Parse webhook payload
    const webhookData = typeof req.body === 'string' 
      ? JSON.parse(req.body) 
      : req.body;

    // Extract payment details
    const { gid, merchantTxnId, status, amount, currency } = webhookData;

    // Process based on status
    if (status === 'SENT_FOR_CAPTURE' || status === 'SUCCESS') {
      // Payment successful - update order, send confirmation
      await updateOrderStatus(merchantTxnId, 'PAID');
    } else if (status === 'FAILED' || status === 'DECLINED') {
      // Payment failed - update order, notify user
      await updateOrderStatus(merchantTxnId, 'FAILED');
    }

    // Respond quickly (within 5 seconds)
    res.status(200).json({ 
      message: 'Webhook received',
      gid,
      merchantTxnId 
    });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(200).json({ error: 'Processing failed' });
  }
});''',
                'javascript',
                  ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                    ? AppTheme.blue600.withOpacity(0.1)
                    : AppTheme.blue50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.blue600.withOpacity(0.3),
                  ),
                ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.blue600,
                          size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                          'Key Points:',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                            color: AppTheme.blue600,
                              ),
                            ),
                          ],
                        ),
                    const SizedBox(height: 12),
                    _buildInfoPoint('✓ Always respond with 200 OK within 5 seconds', context),
                    _buildInfoPoint('✓ Use merchantTxnId + gid to track and prevent duplicates', context),
                    _buildInfoPoint('✓ Process webhook data asynchronously after responding', context),
                    _buildInfoPoint('✓ Validate merchantId to ensure webhook is for your account', context),
                    _buildInfoPoint('✓ Handle different status values (SUCCESS, FAILED, PENDING, etc.)', context),
                    _buildInfoPoint('✓ Store webhook data in your database for audit trail', context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildInfoPoint(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
                child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.getTextSecondary(context),
              height: 1.5,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildComparisonSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.gray50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Feature',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.webhook, color: AppTheme.blue600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Webhooks',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: AppTheme.blue600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Polling',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...[
            {'feature': 'Response Time', 'webhooks': 'Instant', 'polling': 'Delayed'},
            {'feature': 'Server Load', 'webhooks': 'Minimal', 'polling': 'High'},
            {'feature': 'Bandwidth Usage', 'webhooks': 'Low', 'polling': 'High'},
            {'feature': 'Scalability', 'webhooks': 'Excellent', 'polling': 'Limited'},
            {'feature': 'Efficiency', 'webhooks': 'Event-driven', 'polling': 'Wasteful'},
          ].asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: index % 2 == 0
                  ? Colors.transparent
                  : (isDark ? AppTheme.darkBackground : AppTheme.gray50.withOpacity(0.3)),
                border: Border(
                  top: BorderSide(color: AppTheme.getBorderColor(context)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row['feature']!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.blue600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          row['webhooks']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.blue600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: AppTheme.blue600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          row['polling']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.blue600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildImplementationSection(BuildContext context) {
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.blue600.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.settings, color: AppTheme.blue600, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Configuration',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Configure your webhook URL in the PayGlocal dashboard to start receiving real-time notifications.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.getTextSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoBox(
                context,
                'Your webhook endpoint must:',
                [
                  'Accept HTTP POST requests',
                  'Return HTTP 200 status for successful receipt',
                  'Respond within 5 seconds',
                  'Handle duplicate events (idempotency)',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context, String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blue50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.blue600.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, color: AppTheme.blue600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.getTextSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWebhookResponse(BuildContext context) {
    const webhookJson = '''{
  "country": "UNITED KINGDOM",
  "amount": "48",
  "gid": "PGL_7F8A9B3C2D1E4F5A",
  "merchantId": "MERCH_9X8Y7Z6W5V4U3T",
  "cardType": "PREPAID",
  "merchantTxnId": "TXN_4K5L6M7N8O9P0Q",
  "paymentMethod": "CARD",
  "currency": "USD",
  "cardBrand": "VISA",
  "status": "SENT_FOR_CAPTURE"
}''';

    return _buildCodeBlock(
      context,
      'Webhook Payload Structure',
      webhookJson,
      'application/json',
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
                SelectableText(
                  code,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    height: 1.6,
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

  Widget _buildBestPractices(BuildContext context) {
    final practices = [
      {
        'title': 'Respond Quickly',
        'description': 'Return HTTP 200 within 5 seconds to acknowledge receipt',
        'icon': Icons.speed,
      },
      {
        'title': 'Implement Idempotency',
        'description': 'Handle duplicate webhooks gracefully using transaction IDs',
        'icon': Icons.filter_1,
      },
      {
        'title': 'Validate Signatures',
        'description': 'Verify webhook authenticity using PayGlocal signatures',
        'icon': Icons.verified_user,
      },
      {
        'title': 'Use Queue Systems',
        'description': 'Process webhooks asynchronously for better reliability',
        'icon': Icons.queue,
      },
      {
        'title': 'Log Everything',
        'description': 'Keep detailed logs for debugging and auditing',
        'icon': Icons.article,
      },
      {
        'title': 'Monitor Failures',
        'description': 'Set up alerts for failed webhook deliveries',
        'icon': Icons.notifications_active,
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
                  color: AppTheme.blue600.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  practice['icon'] as IconData,
                  color: AppTheme.blue600,
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

  Widget _buildFAQ(BuildContext context) {
    final faqs = [
      {
        'q': 'What happens if my webhook endpoint is down?',
        'a': 'PayGlocal will retry sending the webhook with exponential backoff. Ensure you have monitoring in place to detect failures quickly.',
      },
      {
        'q': 'Can I receive the same webhook multiple times?',
        'a': 'Yes, webhooks may be delivered multiple times. Implement idempotency using the transaction ID to handle duplicates.',
      },
      {
        'q': 'How do I secure my webhook endpoint?',
        'a': 'Verify webhook signatures provided by PayGlocal, use HTTPS, and validate the payload structure before processing.',
      },
      {
        'q': 'What should I return in the webhook response?',
        'a': 'Return HTTP 200 status code with an empty body or simple acknowledgment message within 5 seconds.',
      },
      {
        'q': 'Can I test webhooks before going live?',
        'a': 'Yes, use PayGlocal\'s test environment to simulate webhook events and validate your implementation.',
      },
    ];

    return Column(
      children: faqs.map((faq) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: ExpansionTile(
            leading: Icon(Icons.help_outline, color: AppTheme.blue600),
            title: Text(
              faq['q']!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  faq['a']!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.getTextSecondary(context),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
