import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';
import '../theme/app_theme.dart';

class ApiReferenceScreen extends StatefulWidget {
  const ApiReferenceScreen({super.key});

  @override
  _ApiReferenceScreenState createState() => _ApiReferenceScreenState();
}

class _ApiReferenceScreenState extends State<ApiReferenceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'Payment';
  String _selectedEndpoint = 'initiate-payment';

  final Map<String, List<Map<String, dynamic>>> _apiCategories = {
    'Payment': [
      {
        'id': 'initiate-payment',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/initiate/paycollect',
        'title': 'Initiate Payment',
        'description':
            'Initiate a payment transaction (supports JWT, API Key, Standing Instruction, and Auth payment)',
        'requiresAuth': true,
      },
      {
        'id': 'status',
        'method': 'GET',
        'endpoint': '/gl/v1/payments/{gid}/status',
        'title': 'Check Payment Status',
        'description': 'Query the status of a payment transaction using the global transaction ID (gid)',
        'requiresAuth': true,
      },
      {
        'id': 'refund',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/{gid}/refund',
        'title': 'Initiate Refund',
        'description': 'Refund a completed payment transaction (supports full or partial refund)',
        'requiresAuth': true,
      },
      {
        'id': 'capture',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/{gid}/capture',
        'title': 'Capture Payment',
        'description': 'Capture a previously authorized payment (supports full or partial capture)',
        'requiresAuth': true,
      },
      {
        'id': 'auth-reversal',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/{gid}/auth-reversal',
        'title': 'Auth Reversal',
        'description': 'Reverse a previously authorized payment',
        'requiresAuth': true,
      },
    ],
    'Standing Instruction': [
      {
        'id': 'si-modify',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/si/modify',
        'title': 'Pause Standing Instruction',
        'description': 'Pause an active standing instruction using mandate ID',
        'requiresAuth': true,
      },
      {
        'id': 'si-activate',
        'method': 'PUT',
        'endpoint': '/gl/v1/payments/si/status',
        'title': 'Activate Standing Instruction',
        'description': 'Activate a paused standing instruction using mandate ID',
        'requiresAuth': true,
      },
      {
        'id': 'si-sale',
        'method': 'POST',
        'endpoint': '/gl/v1/payments/si/sale',
        'title': 'SI On-Demand Sale',
        'description': 'Trigger a sale transaction using an existing standing instruction mandate',
        'requiresAuth': true,
      },
      {
        'id': 'si-status-check',
        'method': 'GET',
        'endpoint': '/gl/v1/payments/si/status',
        'title': 'Check SI Status',
        'description': 'Check the status of a standing instruction using mandate ID',
        'requiresAuth': true,
      },
    ],
    'Webhooks': [
      {
        'id': 'callback',
        'method': 'POST',
        'endpoint': '[Your Callback URL]',
        'title': 'Payment Callback',
        'description':
            'Webhook notification sent when payment status changes',
        'requiresAuth': false,
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
    final isLargeScreen = screenWidth > 1000;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
      appBar: SharedAppBar(
        title: 'API Reference',
        fadeAnimation: _fadeAnimation,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: isLargeScreen ? _buildDesktopLayout(isDark) : _buildMobileLayout(isDark),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              right: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
            ),
          ),
          child: _buildSidebar(),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildEndpointDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              bottom: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _apiCategories.keys
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category,
                              style: GoogleFonts.poppins(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _selectedEndpoint =
                        _apiCategories[value]![0]['id'] as String;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Endpoint',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedEndpoint,
                isExpanded: true,
                items: _apiCategories[_selectedCategory]!
                    .map((endpoint) => DropdownMenuItem(
                          value: endpoint['id'] as String,
                          child: Text(endpoint['title'] as String,
                              style: GoogleFonts.poppins(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEndpoint = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildEndpointDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'API ENDPOINTS',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ..._apiCategories.entries.map((category) {
          return _buildCategorySection(category.key, category.value);
        }),
      ],
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, dynamic>> endpoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        ...endpoints.map((endpoint) {
          final isSelected = _selectedCategory == category &&
              _selectedEndpoint == endpoint['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _selectedEndpoint = endpoint['id'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMethodColor(endpoint['method'] as String)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      endpoint['method'] as String,
                      style: GoogleFonts.firaCode(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getMethodColor(endpoint['method'] as String),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      endpoint['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF475569),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return const Color(0xFF10B981);
      case 'POST':
        return const Color(0xFF3B82F6);
      case 'PUT':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildEndpointDetails() {
    final endpoint = _apiCategories[_selectedCategory]!
        .firstWhere((e) => e['id'] == _selectedEndpoint);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMethodColor(endpoint['method'] as String)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  endpoint['method'] as String,
                  style: GoogleFonts.firaCode(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getMethodColor(endpoint['method'] as String),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  endpoint['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            endpoint['description'] as String,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Endpoint URL
          _buildEndpointUrl(endpoint),
          const SizedBox(height: 32),

          // Authentication
          if (endpoint['requiresAuth'] as bool) ...[
            _buildSection('Authentication', [
              _buildInfoCard(
                'This endpoint requires authentication via JWE/JWS encryption',
                Icons.security,
                const Color(0xFFFEF3C7),
                const Color(0xFFD97706),
              ),
              const SizedBox(height: 12),
              _buildAuthDetails(),
            ]),
            const SizedBox(height: 32),
          ],

          // Request Details
          _buildSection('Request', [
            _buildRequestDetails(endpoint),
          ]),
          const SizedBox(height: 32),

          // Response Details
          _buildSection('Response', [
            _buildResponseDetails(endpoint),
          ]),
          const SizedBox(height: 32),

          // Code Examples
          _buildSection('Code Examples', [
            _buildCodeExamples(endpoint),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEndpointUrl(Map<String, dynamic> endpoint) {
    final baseUrl = 'https://api.uat.payglocal.in';
    final fullUrl = baseUrl + (endpoint['endpoint'] as String);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENDPOINT',
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  fullUrl,
                  style: GoogleFonts.firaCode(
                    fontSize: 15,
                    color: const Color(0xFF60A5FA),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF94A3B8)),
            onPressed: () => _copyToClipboard(fullUrl, 'Endpoint URL'),
            tooltip: 'Copy URL',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String message, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: iconColor.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Headers Required:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildHeaderItem('X-GL-TOKEN-EXTERNAL', 'JWS token for request authentication'),
          _buildHeaderItem('X-MERCHANT-ID', 'Your unique merchant identifier'),
          _buildHeaderItem('Content-Type', 'application/jose'),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String header, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              header,
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(Map<String, dynamic> endpoint) {
    final payloadExample = _getRequestPayload(endpoint['id'] as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request Body (Before JWE Encryption):',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(payloadExample, 'json'),
      ],
    );
  }

  Widget _buildResponseDetails(Map<String, dynamic> endpoint) {
    final responseExample = _getResponsePayload(endpoint['id'] as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response (After JWS Decryption):',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(responseExample, 'json'),
        const SizedBox(height: 16),
        _buildResponseCodes(),
      ],
    );
  }

  Widget _buildResponseCodes() {
    final codes = [
      {'code': '200', 'description': 'Success - Payment processed'},
      {'code': '400', 'description': 'Bad Request - Invalid parameters'},
      {'code': '401', 'description': 'Unauthorized - Auth failed'},
      {'code': '500', 'description': 'Server Error - Retry later'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HTTP Status Codes:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...codes.map((code) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(code['code']!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      code['code']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(code['code']!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      code['description']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
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

  Color _getStatusColor(String code) {
    if (code.startsWith('2')) return const Color(0xFF10B981);
    if (code.startsWith('4')) return const Color(0xFFF59E0B);
    if (code.startsWith('5')) return const Color(0xFFEF4444);
    return const Color(0xFF64748B);
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
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
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    language,
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: const Color(0xFF60A5FA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.copy, color: Color(0xFF94A3B8), size: 18),
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
                color: const Color(0xFF94A3B8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExamples(Map<String, dynamic> endpoint) {
    final examples = {
      'Node.js': _getNodeExample(endpoint['id'] as String),
      'Java': _getJavaExample(endpoint['id'] as String),
      'PHP': _getPhpExample(endpoint['id'] as String),
      'C#': _getCsharpExample(endpoint['id'] as String),
    };

    return DefaultTabController(
      length: examples.length,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF64748B),
              indicator: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: examples.keys
                  .map((lang) => Tab(
                        child: Text(
                          lang,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: examples.entries.map((entry) {
                return SingleChildScrollView(
                  child: _buildCodeBlock(entry.value, entry.key.toLowerCase()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getRequestPayload(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
      return '''{
  "merchantTxnId": "TXN_20250122_001",
  "paymentData": {
    "totalAmount": "1000",
    "txnCurrency": "INR"
  },
  "customerData": {
    "emailId": "customer@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "9876543210",
    "countryCode": "+91"
  },
  "merchantCallbackURL": "https://yourwebsite.com/callback"
}''';
      
      case 'status':
        return '''Request: GET /gl/v1/payments/{gid}/status

Headers:
  X-GL-TOKEN-EXTERNAL: <JWS_TOKEN>
  X-MERCHANT-ID: <MERCHANT_ID>
  Content-Type: application/jose

No request body required for status check''';
      
      case 'refund':
      return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "merchantTxnId": "REFUND_TXN_001",
  "refundType": "F",
  "paymentData": {
    "totalAmount": "1000"
  }
}

Note:
- refundType: "F" for Full refund, "P" for Partial refund
- For partial refund, include paymentData.totalAmount with refund amount''';
      
      case 'capture':
        return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "merchantTxnId": "CAPTURE_TXN_001",
  "captureType": "F",
  "paymentData": {
    "totalAmount": "1000"
  }
}

Note:
- captureType: "F" for Full capture, "P" for Partial capture
- For partial capture, include paymentData.totalAmount with capture amount''';
      
      case 'auth-reversal':
        return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "merchantTxnId": "REVERSAL_TXN_001"
}''';
      
      case 'si-modify':
        return '''{
  "merchantTxnId": "SI_PAUSE_001",
  "standingInstruction": {
    "action": "PAUSE",
    "mandateId": "MANDATE_123456",
    "data": {
      "startDate": "2025-02-01"
    }
  }
}

Note: data.startDate is optional for PAUSE action''';
      
      case 'si-activate':
        return '''{
  "merchantTxnId": "SI_ACTIVATE_001",
  "standingInstruction": {
    "action": "ACTIVATE",
    "mandateId": "MANDATE_123456"
  }
}''';
      
      case 'si-sale':
        return '''{
  "merchantTxnId": "SI_SALE_001",
  "paymentData": {
    "totalAmount": "500"
  },
  "standingInstruction": {
    "mandateId": "MANDATE_123456"
  }
}''';
      
      case 'si-status-check':
        return '''Request: GET /gl/v1/payments/si/status?mandateId={MANDATE_ID}

Headers:
  X-GL-TOKEN-EXTERNAL: <JWS_TOKEN>
  X-MERCHANT-ID: <MERCHANT_ID>
  Content-Type: application/jose

No request body required for SI status check''';
      
      default:
    return '{}';
    }
  }

  String _getResponsePayload(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
      return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "merchantTxnId": "TXN_20250122_001",
  "redirectUrl": "https://api.uat.payglocal.in/gateway/..."
}''';
      
      case 'status':
        return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "merchantTxnId": "TXN_20250122_001",
  "status": "CHARGED",
  "message": "Transaction successful",
  "paymentData": {
    "totalAmount": "1000",
    "txnCurrency": "INR"
  },
  "timestamp": "2025-01-22T10:30:00Z"
}''';
      
      case 'refund':
        return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "status": "SUCCESS",
  "message": "Refund initiated successfully",
  "merchantTxnId": "REFUND_TXN_001",
  "refundAmount": "1000"
}''';
      
      case 'capture':
      return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "status": "SUCCESS",
  "message": "Capture successful",
  "merchantTxnId": "CAPTURE_TXN_001",
  "capturedAmount": "1000"
}''';
      
      case 'auth-reversal':
        return '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "status": "SUCCESS",
  "message": "Authorization reversed successfully",
  "merchantTxnId": "REVERSAL_TXN_001"
}''';
      
      case 'si-modify':
        return '''{
  "status": "SUCCESS",
  "message": "Standing instruction paused successfully",
  "merchantTxnId": "SI_PAUSE_001",
  "mandateId": "MANDATE_123456",
  "mandateStatus": "PAUSED"
}''';
      
      case 'si-activate':
        return '''{
  "status": "SUCCESS",
  "message": "Standing instruction activated successfully",
  "merchantTxnId": "SI_ACTIVATE_001",
  "mandateId": "MANDATE_123456",
  "mandateStatus": "ACTIVE"
}''';
      
      case 'si-sale':
        return '''{
  "gid": "gl_o-123456789abcdef",
  "status": "INPROGRESS",
  "message": "SI sale transaction initiated",
  "merchantTxnId": "SI_SALE_001",
  "mandateId": "MANDATE_123456",
  "amount": "500"
}''';
      
      case 'si-status-check':
        return '''{
  "mandateId": "MANDATE_123456",
  "status": "ACTIVE",
  "type": "FIXED",
  "frequency": "MONTHLY",
  "numberOfPayments": 12,
  "amount": "500",
  "startDate": "2025-01-01",
  "paymentsCompleted": 3
}''';
      
      default:
    return '{}';
    }
  }

  String _getNodeExample(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');
const fs = require('fs');

// Initialize SDK
const client = new PayGlocalClient({
  apiKey: process.env.PAYGLOCAL_API_KEY,
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID,
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
  payglocalPublicKey: fs.readFileSync('path/to/payglocal_public_key', 'utf8'),
  merchantPrivateKey: fs.readFileSync('path/to/merchant_private_key', 'utf8'),
  payglocalEnv: 'UAT', // or 'PROD'
  logLevel: 'info'
});

// Initiate Payment
async function initiatePayment() {
  try {
    const response = await client.initiateJwtPayment({
      merchantTxnId: 'TXN_' + Date.now(),
      paymentData: {
        totalAmount: '1000',
        txnCurrency: 'INR'
      },
      customerData: {
        emailId: 'customer@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '9876543210',
        countryCode: '+91'
      },
      merchantCallbackURL: 'https://yoursite.com/callback'
    });
    
    console.log('Payment Response:', response);
    console.log('Redirect URL:', response.redirectUrl);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

initiatePayment();''';
      
      case 'status':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function checkStatus(gid) {
  try {
    const response = await client.initiateCheckStatus({ gid });
    console.log('Status:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkStatus('gl_o-962989f8777c7ff29lo0Yd5X2');''';
      
      case 'refund':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function initiateRefund() {
  try {
    const response = await client.initiateRefund({
      gid: 'gl_o-962989f8777c7ff29lo0Yd5X2',
      merchantTxnId: 'REFUND_TXN_' + Date.now(),
      refundType: 'F', // 'F' for Full, 'P' for Partial
      paymentData: {
        totalAmount: '1000' // Required for partial refund
      }
    });
    console.log('Refund Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

initiateRefund();''';
      
      case 'capture':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function capturePayment() {
  try {
    const response = await client.initiateCapture({
      gid: 'gl_o-962989f8777c7ff29lo0Yd5X2',
      merchantTxnId: 'CAPTURE_TXN_' + Date.now(),
      captureType: 'F', // 'F' for Full, 'P' for Partial
      paymentData: {
        totalAmount: '1000' // Required for partial capture
      }
    });
    console.log('Capture Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

capturePayment();''';
      
      case 'auth-reversal':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function reverseAuth() {
  try {
    const response = await client.initiateAuthReversal({
      gid: 'gl_o-962989f8777c7ff29lo0Yd5X2',
      merchantTxnId: 'REVERSAL_TXN_' + Date.now()
    });
    console.log('Reversal Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

reverseAuth();''';
      
      case 'si-modify':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function pauseSI() {
  try {
    const response = await client.initiatePauseSI({
      merchantTxnId: 'SI_PAUSE_' + Date.now(),
      standingInstruction: {
        action: 'PAUSE',
        mandateId: 'MANDATE_123456',
        data: {
          startDate: '2025-02-01' // Optional
        }
      }
    });
    console.log('SI Pause Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

pauseSI();''';
      
      case 'si-activate':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function activateSI() {
  try {
    const response = await client.initiateActivateSI({
      merchantTxnId: 'SI_ACTIVATE_' + Date.now(),
      standingInstruction: {
        action: 'ACTIVATE',
        mandateId: 'MANDATE_123456'
      }
    });
    console.log('SI Activate Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

activateSI();''';
      
      case 'si-sale':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function siOnDemand() {
  try {
    const response = await client.initiateSiOnDemandVariable({
      merchantTxnId: 'SI_SALE_' + Date.now(),
      paymentData: {
        totalAmount: '500'
      },
      standingInstruction: {
        mandateId: 'MANDATE_123456'
      }
    });
    console.log('SI Sale Response:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

siOnDemand();''';
      
      case 'si-status-check':
        return '''const PayGlocalClient = require('./pg-client-sdk/lib/index.js');

const client = new PayGlocalClient({ /* config */ });

async function checkSIStatus() {
  try {
    const response = await client.initiateSiStatusCheck({
      mandateId: 'MANDATE_123456'
    });
    console.log('SI Status:', response);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkSIStatus();''';
      
      default:
        return '// Node.js example coming soon';
    }
  }

  String _getJavaExample(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
        return '''import com.payglocal.sdk.PayGlocalClient;
import java.util.HashMap;
import java.util.Map;

public class PaymentExample {
    public static void main(String[] args) {
        // Initialize SDK
        PayGlocalClient client = new PayGlocalClient(
            merchantId: "YOUR_MERCHANT_ID",
            apiKey: "YOUR_API_KEY",
            environment: "UAT",
            publicKeyId: "YOUR_PUBLIC_KEY_ID",
            privateKeyId: "YOUR_PRIVATE_KEY_ID",
            payglocalPublicKey: readKeyFromFile("payglocal_public_key.pem"),
            merchantPrivateKey: readKeyFromFile("merchant_private_key.pem")
        );
        
        // Prepare payment data
        Map<String, Object> payload = new HashMap<>();
        payload.put("merchantTxnId", "TXN_" + System.currentTimeMillis());
        
        Map<String, Object> paymentData = new HashMap<>();
        paymentData.put("totalAmount", "1000");
        paymentData.put("txnCurrency", "INR");
        payload.put("paymentData", paymentData);
        
        Map<String, Object> customerData = new HashMap<>();
        customerData.put("emailId", "customer@example.com");
        customerData.put("firstName", "John");
        customerData.put("lastName", "Doe");
        payload.put("customerData", customerData);
        
        payload.put("merchantCallbackURL", "https://yoursite.com/callback");
        
        // Initiate payment
        try {
            Map<String, Object> response = client.initiateJwtPayment(payload);
            System.out.println("Payment Response: " + response);
            System.out.println("GID: " + response.get("gid"));
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}''';
      
      case 'status':
        return '''import com.payglocal.sdk.PayGlocalClient;

// Initialize client (see initiate-payment example)
PayGlocalClient client = new PayGlocalClient(/* config */);

try {
    Map<String, Object> response = client.checkStatus("gl_o-962989f8777c7ff29lo0Yd5X2");
    System.out.println("Status: " + response);
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}''';
      
      case 'refund':
        return '''import com.payglocal.sdk.PayGlocalClient;
import java.util.HashMap;
import java.util.Map;

PayGlocalClient client = new PayGlocalClient(/* config */);

Map<String, Object> payload = new HashMap<>();
payload.put("gid", "gl_o-962989f8777c7ff29lo0Yd5X2");
payload.put("merchantTxnId", "REFUND_TXN_" + System.currentTimeMillis());
payload.put("refundType", "F"); // F for Full, P for Partial

Map<String, Object> paymentData = new HashMap<>();
paymentData.put("totalAmount", "1000");
payload.put("paymentData", paymentData);

try {
    Map<String, Object> response = client.initiateRefund(payload);
    System.out.println("Refund Response: " + response);
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}''';
      
      case 'capture':
        return '''import com.payglocal.sdk.PayGlocalClient;
import java.util.HashMap;
import java.util.Map;

PayGlocalClient client = new PayGlocalClient(/* config */);

String gid = "gl_o-962989f8777c7ff29lo0Yd5X2";
Map<String, Object> payload = new HashMap<>();
payload.put("merchantTxnId", "CAPTURE_TXN_" + System.currentTimeMillis());
payload.put("captureType", "F"); // F for Full, P for Partial

Map<String, Object> paymentData = new HashMap<>();
paymentData.put("totalAmount", "1000");
payload.put("paymentData", paymentData);

try {
    Map<String, Object> response = client.initiateCapture(gid, payload);
    System.out.println("Capture Response: " + response);
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}''';
      
      default:
        return '// Java example for $endpointId';
    }
  }

  String _getPhpExample(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
    return '''<?php
require_once __DIR__ . '/pg-client-sdk-php/vendor/autoload.php';

use PayGlocal\\PgClientSdk\\PayGlocalClient;

// Initialize SDK
\$client = new PayGlocalClient([
    'apiKey' => getenv('PAYGLOCAL_API_KEY'),
    'merchantId' => getenv('PAYGLOCAL_MERCHANT_ID'),
    'publicKeyId' => getenv('PAYGLOCAL_PUBLIC_KEY_ID'),
    'privateKeyId' => getenv('PAYGLOCAL_PRIVATE_KEY_ID'),
    'payglocalPublicKey' => file_get_contents('path/to/payglocal_public_key.pem'),
    'merchantPrivateKey' => file_get_contents('path/to/merchant_private_key.pem'),
    'payglocalEnv' => 'UAT',
    'logLevel' => 'info',
]);

// Initiate Payment
\$payload = [
    'merchantTxnId' => 'TXN_' . time(),
    'paymentData' => [
        'totalAmount' => '1000',
        'txnCurrency' => 'INR'
    ],
    'customerData' => [
        'emailId' => 'customer@example.com',
        'firstName' => 'John',
        'lastName' => 'Doe',
        'phoneNumber' => '9876543210',
        'countryCode' => '+91'
    ],
    'merchantCallbackURL' => 'https://yoursite.com/callback'
];

try {
    \$response = \$client->initiateJwtPayment(\$payload);
    echo "Payment Response: " . json_encode(\$response, JSON_PRETTY_PRINT);
    echo "\\nRedirect URL: " . \$response['redirectUrl'];
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}''';
      
      case 'status':
        return '''<?php
use PayGlocal\\PgClientSdk\\PayGlocalClient;

\$client = new PayGlocalClient([/* config */]);

try {
    \$response = \$client->initiateCheckStatus(['gid' => 'gl_o-962989f8777c7ff29lo0Yd5X2']);
    echo "Status: " . json_encode(\$response, JSON_PRETTY_PRINT);
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}''';
      
      case 'refund':
        return '''<?php
use PayGlocal\\PgClientSdk\\PayGlocalClient;

\$client = new PayGlocalClient([/* config */]);

\$payload = [
    'gid' => 'gl_o-962989f8777c7ff29lo0Yd5X2',
    'merchantTxnId' => 'REFUND_TXN_' . time(),
    'refundType' => 'F', // F for Full, P for Partial
    'paymentData' => [
        'totalAmount' => '1000'
    ]
];

try {
    \$response = \$client->initiateRefund(\$payload);
    echo "Refund Response: " . json_encode(\$response, JSON_PRETTY_PRINT);
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}''';
      
      case 'capture':
        return '''<?php
use PayGlocal\\PgClientSdk\\PayGlocalClient;

\$client = new PayGlocalClient([/* config */]);

\$payload = [
    'gid' => 'gl_o-962989f8777c7ff29lo0Yd5X2',
    'merchantTxnId' => 'CAPTURE_TXN_' . time(),
    'captureType' => 'F', // F for Full, P for Partial
    'paymentData' => [
        'totalAmount' => '1000'
    ]
];

try {
    \$response = \$client->initiateCapture(\$payload);
    echo "Capture Response: " . json_encode(\$response, JSON_PRETTY_PRINT);
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage();
}''';
      
      default:
        return '<?php // PHP example for $endpointId';
    }
  }

  String _getCsharpExample(String endpointId) {
    switch (endpointId) {
      case 'initiate-payment':
        return '''using PayGlocal;
using Newtonsoft.Json.Linq;

// Initialize SDK
        var client = new PayGlocalClient(
    merchantId: Environment.GetEnvironmentVariable("PAYGLOCAL_MERCHANT_ID"),
    apiKey: Environment.GetEnvironmentVariable("PAYGLOCAL_API_KEY"),
    environment: "UAT",
    publicKeyId: Environment.GetEnvironmentVariable("PAYGLOCAL_PUBLIC_KEY_ID"),
    privateKeyId: Environment.GetEnvironmentVariable("PAYGLOCAL_PRIVATE_KEY_ID"),
    payglocalPublicKey: File.ReadAllText("path/to/payglocal_public_key.pem"),
    merchantPrivateKey: File.ReadAllText("path/to/merchant_private_key.pem"),
    logLevel: "info"
);

// Prepare payment payload
var payload = new JObject
{
    ["merchantTxnId"] = "TXN_" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
    ["paymentData"] = new JObject
    {
        ["totalAmount"] = "1000",
        ["txnCurrency"] = "INR"
    },
    ["customerData"] = new JObject
    {
        ["emailId"] = "customer@example.com",
        ["firstName"] = "John",
        ["lastName"] = "Doe",
        ["phoneNumber"] = "9876543210",
        ["countryCode"] = "+91"
    },
    ["merchantCallbackURL"] = "https://yoursite.com/callback"
};

// Initiate payment
try
{
    var response = await client.InitiateJwtPayment(payload);
    Console.WriteLine("Payment Response: " + response);
    Console.WriteLine("GID: " + response["gid"]);
}
catch (Exception ex)
{
    Console.WriteLine("Error: " + ex.Message);
}''';
      
      case 'status':
        return '''using PayGlocal;
using Newtonsoft.Json.Linq;

var client = new PayGlocalClient(/* config */);

try
{
    var payload = new JObject { ["gid"] = "gl_o-962989f8777c7ff29lo0Yd5X2" };
    var response = await client.InitiateCheckStatus(payload);
    Console.WriteLine("Status: " + response);
}
catch (Exception ex)
{
    Console.WriteLine("Error: " + ex.Message);
}''';
      
      case 'refund':
        return '''using PayGlocal;
using Newtonsoft.Json.Linq;

var client = new PayGlocalClient(/* config */);

var payload = new JObject
{
    ["gid"] = "gl_o-962989f8777c7ff29lo0Yd5X2",
    ["merchantTxnId"] = "REFUND_TXN_" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
    ["refundType"] = "F", // F for Full, P for Partial
    ["paymentData"] = new JObject
    {
        ["totalAmount"] = "1000"
    }
};

try
{
    var response = await client.InitiateRefund(payload);
    Console.WriteLine("Refund Response: " + response);
}
catch (Exception ex)
{
    Console.WriteLine("Error: " + ex.Message);
}''';
      
      case 'capture':
        return '''using PayGlocal;
using Newtonsoft.Json.Linq;

var client = new PayGlocalClient(/* config */);

var payload = new JObject
{
    ["gid"] = "gl_o-962989f8777c7ff29lo0Yd5X2",
    ["merchantTxnId"] = "CAPTURE_TXN_" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
    ["captureType"] = "F", // F for Full, P for Partial
    ["paymentData"] = new JObject
    {
        ["totalAmount"] = "1000"
    }
};

try
{
    var response = await client.InitiateCapture(payload);
    Console.WriteLine("Capture Response: " + response);
}
catch (Exception ex)
{
    Console.WriteLine("Error: " + ex.Message);
}''';
      
      default:
        return '// C# example for $endpointId';
    }
  }
}

