import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';

class TestingGuideScreen extends StatefulWidget {
  const TestingGuideScreen({super.key});

  @override
  _TestingGuideScreenState createState() => _TestingGuideScreenState();
}

class _TestingGuideScreenState extends State<TestingGuideScreen>
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SharedAppBar(
        title: 'Testing Guide',
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
                    _buildHeroSection(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildEnvironmentSection(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildTestCardsSection(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildTestScenariosSection(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildWebhookTestingSection(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildBestPracticesSection(isLargeScreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Your Integration',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use our sandbox environment and test cards to simulate all payment scenarios',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: Colors.white.withOpacity(0.9),
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

  Widget _buildEnvironmentSection(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Testing Environment',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PayGlocal provides a UAT (User Acceptance Testing) environment for safe testing',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dns,
                        color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'UAT Base URL',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        'https://api.uat.payglocal.in',
                        style: GoogleFonts.firaCode(
                          fontSize: 14,
                          color: const Color(0xFF60A5FA),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy,
                          color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => _copyToClipboard(
                          'https://api.uat.payglocal.in', 'UAT URL'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoPoint(
                '🔒 Secure sandbox environment - no real transactions',
              ),
              _buildInfoPoint(
                '💳 Use test cards to simulate success, failure, and 3DS scenarios',
              ),
              _buildInfoPoint(
                '🔄 All features available just like production',
              ),
              _buildInfoPoint(
                '📊 View test transactions in merchant dashboard',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTestCardsSection(bool isLargeScreen) {
    final testCards = [
      {
        'number': '5123456789012346',
        'cvv': '123',
        'expiry': '12/28',
        'name': 'Success Card',
        'description': 'Transaction will complete successfully',
        'color': const Color(0xFF10B981),
        'icon': Icons.check_circle,
      },
      {
        'number': '4000000000000002',
        'cvv': '123',
        'expiry': '12/28',
        'name': 'Declined Card',
        'description': 'Transaction will be declined by bank',
        'color': const Color(0xFFEF4444),
        'icon': Icons.cancel,
      },
      {
        'number': '4000000000003220',
        'cvv': '123',
        'expiry': '12/28',
        'name': '3DS Authentication',
        'description': 'Requires 3D Secure authentication',
        'color': const Color(0xFF3B82F6),
        'icon': Icons.security,
      },
      {
        'number': '4000000000000069',
        'cvv': '123',
        'expiry': '12/28',
        'name': 'Expired Card',
        'description': 'Simulates expired card error',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.warning,
      },
      {
        'number': '4000000000000127',
        'cvv': '123',
        'expiry': '12/28',
        'name': 'Insufficient Funds',
        'description': 'Simulates insufficient balance',
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.account_balance_wallet,
      },
      {
        'number': '4000000000000259',
        'cvv': '123',
        'expiry': '12/28',
        'name': 'Processing Error',
        'description': 'Simulates processing error',
        'color': const Color(0xFF64748B),
        'icon': Icons.error,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Card Numbers',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Use these test cards to simulate different payment scenarios in the UAT environment',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 2 : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isLargeScreen ? 2.2 : 1.8,
          ),
          itemCount: testCards.length,
          itemBuilder: (context, index) {
            return _buildTestCard(testCards[index]);
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'For all test cards, you can use any name, any valid future expiry date, and any 3-digit CVV',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF78350F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (card['color'] as Color).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (card['color'] as Color).withOpacity(0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (card['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      card['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildCardDetail('Card Number', card['number'] as String),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCardDetail('CVV', card['cvv'] as String)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildCardDetail('Expiry', card['expiry'] as String)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(value, label),
              color: const Color(0xFF64748B),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestScenariosSection(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Scenarios',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 24),
        _buildScenarioCard(
          '1. Successful Payment Flow',
          'Test the happy path from payment initiation to completion',
          [
            'Use success test card (5123456789012346)',
            'Initiate payment with valid amount and customer details',
            'Complete payment on hosted page',
            'Verify success callback received',
            'Check payment status via API',
          ],
          const Color(0xFF10B981),
          Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),
        _buildScenarioCard(
          '2. Failed Payment Handling',
          'Ensure your app handles failed payments gracefully',
          [
            'Use declined test card (4000000000000002)',
            'Initiate payment',
            'Handle failure callback',
            'Display appropriate error message to user',
            'Verify transaction shows as failed in status check',
          ],
          const Color(0xFFEF4444),
          Icons.error_outline,
        ),
        const SizedBox(height: 16),
        _buildScenarioCard(
          '3. 3D Secure Authentication',
          'Test the additional authentication flow',
          [
            'Use 3DS test card (4000000000003220)',
            'Initiate payment',
            'Complete 3DS challenge on authentication page',
            'Handle post-authentication callback',
            'Verify successful completion',
          ],
          const Color(0xFF3B82F6),
          Icons.security,
        ),
        const SizedBox(height: 16),
        _buildScenarioCard(
          '4. Status Check & Reconciliation',
          'Test transaction status queries and reconciliation',
          [
            'Complete multiple test transactions',
            'Query status for each transaction',
            'Test with both successful and failed transactions',
            'Verify all transaction details match',
            'Test webhook delivery and status query consistency',
          ],
          const Color(0xFF8B5CF6),
          Icons.fact_check,
        ),
      ],
    );
  }

  Widget _buildScenarioCard(String title, String description,
      List<String> steps, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWebhookTestingSection(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook Testing',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Test webhook delivery and signature verification',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWebhookStep(
                '1',
                'Use a public webhook URL',
                'Tools like ngrok or webhook.site for local testing',
                const Color(0xFF3B82F6),
              ),
              _buildWebhookStep(
                '2',
                'Configure in merchant dashboard',
                'Add your webhook URL in UAT settings',
                const Color(0xFF10B981),
              ),
              _buildWebhookStep(
                '3',
                'Complete test transaction',
                'PayGlocal will send webhook notification',
                const Color(0xFF8B5CF6),
              ),
              _buildWebhookStep(
                '4',
                'Verify signature',
                'Validate JWS signature using PayGlocal public key',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebhookStep(
      String number, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPracticesSection(bool isLargeScreen) {
    final practices = [
      {
        'icon': Icons.rotate_right,
        'title': 'Test All Scenarios',
        'description':
            'Cover success, failure, timeout, and edge cases before going live'
      },
      {
        'icon': Icons.verified_user,
        'title': 'Verify Webhooks',
        'description':
            'Always validate JWS signatures on webhook callbacks for security'
      },
      {
        'icon': Icons.storage,
        'title': 'Store Transaction IDs',
        'description':
            'Keep both your merchantTxnId and PayGlocal gid for reconciliation'
      },
      {
        'icon': Icons.error_outline,
        'title': 'Handle Errors Gracefully',
        'description':
            'Display user-friendly messages and provide retry options'
      },
      {
        'icon': Icons.sync,
        'title': 'Implement Idempotency',
        'description':
            'Use unique transaction IDs to prevent duplicate payments'
      },
      {
        'icon': Icons.schedule,
        'title': 'Set Appropriate Timeouts',
        'description':
            'Handle network delays and set reasonable timeout values'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Testing Best Practices',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 3 : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isLargeScreen ? 1.2 : 2.5,
          ),
          itemCount: practices.length,
          itemBuilder: (context, index) {
            final practice = practices[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    practice['icon'] as IconData,
                    color: const Color(0xFF3B82F6),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    practice['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    practice['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.5,
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
}

