import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';

class TroubleshootingScreen extends StatefulWidget {
  const TroubleshootingScreen({super.key});

  @override
  _TroubleshootingScreenState createState() => _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends State<TroubleshootingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';

  final Map<String, List<Map<String, dynamic>>> _issues = {
    'Authentication': [
      {
        'error': '401 Unauthorized',
        'cause': 'Invalid or missing authentication credentials',
        'solutions': [
          'Verify your Merchant ID is correct',
          'Check that private/public keys are properly loaded',
          'Ensure JWE encryption is working correctly',
          'Verify X-MERCHANT-ID and X-GL-TOKEN-ID headers are sent',
        ],
      },
      {
        'error': 'JWE/JWS Encryption Failed',
        'cause': 'Problem with encryption or signature',
        'solutions': [
          'Verify you\'re using the correct PayGlocal public key',
          'Check key format (PEM format required)',
          'Ensure payload is valid JSON before encryption',
          'Test with SDK examples first',
        ],
      },
    ],
    'Payment': [
      {
        'error': 'Payment Declined',
        'cause': 'Card issuer declined the transaction',
        'solutions': [
          'Ask customer to use a different card',
          'Verify card details are entered correctly',
          'Check if card has sufficient funds',
          'Contact customer\'s bank for specific decline reason',
        ],
      },
      {
        'error': 'Transaction Timeout',
        'cause': 'Payment processing took too long',
        'solutions': [
          'Increase API timeout to at least 60 seconds',
          'Implement status check via webhook',
          'Use status API to query transaction result',
          'Don\'t retry immediately - check status first',
        ],
      },
      {
        'error': '3DS Authentication Failed',
        'cause': 'Customer failed 3D Secure verification',
        'solutions': [
          'Ensure customer completes 3DS challenge',
          'Check browser compatibility',
          'Verify callback URL is accessible',
          'Test in different browsers',
        ],
      },
    ],
    'Integration': [
      {
        'error': '400 Bad Request - Invalid Parameters',
        'cause': 'Request payload has missing or invalid fields',
        'solutions': [
          'Validate all required fields are present',
          'Check data types match API specification',
          'Verify amount format (string with 2 decimals)',
          'Ensure currency code is valid (e.g., INR, USD)',
        ],
      },
      {
        'error': 'Webhook Not Received',
        'cause': 'Callback URL not accessible or webhook failed',
        'solutions': [
          'Verify webhook URL is publicly accessible (HTTPS)',
          'Check firewall/security settings',
          'Test URL with tools like webhook.site',
          'Implement retry logic with exponential backoff',
          'Use status API as backup',
        ],
      },
      {
        'error': 'Signature Verification Failed',
        'cause': 'JWS signature doesn\'t match expected value',
        'solutions': [
          'Use PayGlocal public key for verification',
          'Don\'t modify response before verification',
          'Check for character encoding issues',
          'Use SDK methods for verification',
        ],
      },
    ],
    'Network': [
      {
        'error': '500 Internal Server Error',
        'cause': 'PayGlocal service encountered an error',
        'solutions': [
          'Retry request with exponential backoff',
          'Check PayGlocal status page',
          'Use idempotency key to prevent duplicates',
          'Contact support if persists',
        ],
      },
      {
        'error': 'Connection Timeout',
        'cause': 'Unable to reach PayGlocal API',
        'solutions': [
          'Check internet connectivity',
          'Verify firewall allows outbound HTTPS',
          'Test with curl/postman first',
          'Check DNS resolution',
        ],
      },
    ],
  };

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SharedAppBar(
        title: 'Troubleshooting Guide',
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
                    _buildCategoryFilter(isLargeScreen),
                    const SizedBox(height: 32),
                    _buildIssuesList(),
                    const SizedBox(height: 40),
                    _buildErrorCodes(isLargeScreen),
                    const SizedBox(height: 40),
                    _buildSupportSection(isLargeScreen),
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
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
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
                child: const Icon(Icons.build, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Guide',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Common issues and their solutions to help you resolve integration problems quickly',
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

  Widget _buildCategoryFilter(bool isLargeScreen) {
    final categories = ['All', ..._issues.keys];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIssuesList() {
    final filteredIssues = _selectedCategory == 'All'
        ? _issues
        : {_selectedCategory: _issues[_selectedCategory]!};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredIssues.entries.expand((category) {
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.key),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.key,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          ...category.value
              .map((issue) => _buildIssueCard(issue, category.key))
              ,
          const SizedBox(height: 32),
        ];
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Authentication':
        return const Color(0xFFEF4444);
      case 'Payment':
        return const Color(0xFFF59E0B);
      case 'Integration':
        return const Color(0xFF3B82F6);
      case 'Network':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildIssueCard(Map<String, dynamic> issue, String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: _getCategoryColor(category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue['error'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(category),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Common Cause',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue['cause'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Solutions:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...(issue['solutions'] as List<String>).asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
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

  Widget _buildErrorCodes(bool isLargeScreen) {
    final errorCodes = [
      {
        'code': '200',
        'status': 'Success',
        'description': 'Request processed successfully',
        'color': const Color(0xFF10B981),
      },
      {
        'code': '400',
        'status': 'Bad Request',
        'description': 'Invalid parameters or malformed request',
        'color': const Color(0xFFF59E0B),
      },
      {
        'code': '401',
        'status': 'Unauthorized',
        'description': 'Authentication failed or missing credentials',
        'color': const Color(0xFFEF4444),
      },
      {
        'code': '403',
        'status': 'Forbidden',
        'description': 'Valid credentials but insufficient permissions',
        'color': const Color(0xFFEF4444),
      },
      {
        'code': '404',
        'status': 'Not Found',
        'description': 'Resource or endpoint not found',
        'color': const Color(0xFF64748B),
      },
      {
        'code': '429',
        'status': 'Too Many Requests',
        'description': 'Rate limit exceeded, retry with backoff',
        'color': const Color(0xFFF59E0B),
      },
      {
        'code': '500',
        'status': 'Internal Server Error',
        'description': 'Server error, retry with exponential backoff',
        'color': const Color(0xFFEF4444),
      },
      {
        'code': '503',
        'status': 'Service Unavailable',
        'description': 'Service temporarily unavailable',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HTTP Status Codes',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Understanding PayGlocal API response codes',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: errorCodes.asMap().entries.map((entry) {
              final index = entry.key;
              final code = entry.value;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: index < errorCodes.length - 1
                      ? const Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: (code['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code['code'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.firaCode(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: code['color'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            code['status'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            code['description'] as String,
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'Need More Help?',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If you\'re still experiencing issues after trying these solutions, our support team is here to help.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSupportOption(
                Icons.email,
                'Email Support',
                'support@payglocal.in',
              ),
              _buildSupportOption(
                Icons.description,
                'Documentation',
                'docs.payglocal.in',
              ),
              _buildSupportOption(
                Icons.chat,
                'Live Chat',
                'Available 24/7',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

