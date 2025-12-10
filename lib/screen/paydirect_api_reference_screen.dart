import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../theme/app_theme.dart';

class PayDirectAPIReferenceScreen extends StatefulWidget {
  const PayDirectAPIReferenceScreen({super.key});

  @override
  _PayDirectAPIReferenceScreenState createState() => _PayDirectAPIReferenceScreenState();
}

class _PayDirectAPIReferenceScreenState extends State<PayDirectAPIReferenceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  int _selectedAPI = 0;

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
        title: 'PayDirect SI - API Reference',
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
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),

                  // API Navigation
                  _buildAPINavigation(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing32),

                  // API Details based on selection
                  _buildAPIDetails(context, isLargeScreen, isDark),
                  const SizedBox(height: AppTheme.spacing48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLargeScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PayDirect Standing Instruction API Reference',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 40 : 28,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Text(
          'Complete API documentation with detailed request/response examples, parameters, and error handling',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildAPINavigation(BuildContext context, bool isLargeScreen, bool isDark) {
    final apis = [
      {'name': 'SI On-Demand FIXED', 'icon': '📝'},
      {'name': 'SI On-Demand VARIABLE', 'icon': '💳'},
      {'name': 'SI Status Check', 'icon': '✓'},
      {'name': 'SI Pause', 'icon': '⏸'},
      {'name': 'SI Activate', 'icon': '▶'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          apis.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAPI = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                decoration: BoxDecoration(
                  gradient: _selectedAPI == index
                      ? LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                        )
                      : null,
                  color: _selectedAPI == index ? null : (isDark ? AppTheme.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: _selectedAPI == index ? Colors.transparent : AppTheme.borderMedium,
                  ),
                ),
                child: Row(
                  children: [
                    Text(apis[index]['icon'] as String),
                    const SizedBox(width: 8),
                    Text(
                      apis[index]['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedAPI == index ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAPIDetails(BuildContext context, bool isLargeScreen, bool isDark) {
    switch (_selectedAPI) {
      case 0:
        return _buildSIPaymentFixedAPI(context, isLargeScreen, isDark);
      case 1:
        return _buildSIPaymentVariableAPI(context, isLargeScreen, isDark);
      case 2:
        return _buildSIStatusCheckAPI(context, isLargeScreen, isDark);
      case 3:
        return _buildSIPauseAPI(context, isLargeScreen, isDark);
      case 4:
        return _buildSIActivateAPI(context, isLargeScreen, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSIPaymentFixedAPI(BuildContext context, bool isLargeScreen, bool isDark) {
    const requestExample = '''{
  "merchantTxnId":"23AEE8CB6B62EE2AF07",
  "standingInstruction": {
    "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15"
  }
}''';

    const successResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "SENT_FOR_CAPTURE",
  "message": "Sent for Capture Successfully",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "errors": null
}''';

    const mandateNotFoundResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "REQUEST_ERROR",
  "message": "Mandate is not found",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "errors": null
}''';

    const mandateInactiveResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "REQUEST_ERROR",
  "message": "Mandate is inactive",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "errors": null
}''';

    const mandateExhaustedResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "REQUEST_ERROR",
  "message": "Mandate is exhausted",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "errors": null
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAPIHeader('Standing Instruction Payment - FIXED', 'POST /gl/v1/payments/si/sale', Colors.green, isDark),
        const SizedBox(height: AppTheme.spacing24),
        _buildAPIDescriptionCard(
          'Initiate a subsequent payment using an existing FIXED Standing Instruction mandate. The amount is automatically taken from the SI data block submitted in the initial GPI request. No amount field is required in this request.',
          isDark,
        ),
        const SizedBox(height: AppTheme.spacing24),
        PremiumCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Important: This service can ONLY be used when a valid Mandate ID was received in the Get Status response of the first payment.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Request Body',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', requestExample, isDark),
        const SizedBox(height: AppTheme.spacing32),
        Text(
          'Response Examples',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success Response', successResponse, AppTheme.success, isDark),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Mandate Not Found', mandateNotFoundResponse, Colors.orange, isDark),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Mandate Inactive', mandateInactiveResponse, const Color(0xFFDC2626), isDark),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Mandate Exhausted', mandateExhaustedResponse, Colors.purple, isDark),
      ],
    );
  }

  Widget _buildSIPaymentVariableAPI(BuildContext context, bool isLargeScreen, bool isDark) {
    const requestExample = '''{
  "merchantTxnId":"23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount":"89"
  },
  "standingInstruction": {
    "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15"
  }
}''';

    const successResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "SENT_FOR_CAPTURE",
  "message": "Sent for Capture Successfully",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "errors": null
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAPIHeader('Standing Instruction Payment - VARIABLE', 'POST /gl/v1/payments/si/sale', Colors.blue, isDark),
        const SizedBox(height: AppTheme.spacing24),
        _buildAPIDescriptionCard(
          'Initiate a subsequent payment using an existing VARIABLE Standing Instruction mandate. The amount field is REQUIRED and must be less than or equal to the maximum amount set during mandate creation.',
          isDark,
        ),
        const SizedBox(height: AppTheme.spacing24),
        PremiumCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber, color: const Color(0xFF7C3AED), size: 20),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'The amount must be within the maxAmount specified in the initial GPI request.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Request Body',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', requestExample, isDark),
        const SizedBox(height: AppTheme.spacing32),
        Text(
          'Response Examples',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success Response', successResponse, AppTheme.success, isDark),
        const SizedBox(height: AppTheme.spacing16),
        PremiumCard(
          child: Text(
            'Note: VARIABLE SI follows the same error responses as FIXED SI (Mandate Not Found, Inactive, Exhausted)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSIStatusCheckAPI(BuildContext context, bool isLargeScreen, bool isDark) {
    const requestExample = '''{
  "merchantTxnId":"23AEE8CB6B62EE2AF07",
  "standingInstruction": {
    "mandateId": "md_c87fcf0a-a62c-4dae-b001-ee69fee587c3"
  }
}''';

    const activeSuccessResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "SUCCESS",
  "message": "Successfully retrieved mandate details",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "data": {
    "mandateData": {
      "mandateStatus":"ACTIVE",
      "mandateCreateDate":"20211204",
      "maskedMandateId":"md_94fxxxxxx3e15",
      "siId":"si_cd2f0a1c-4dec-44d5-b0f3-297aee590d32",
      "numberOfPaymentsProcessed":"4",
      "numberOfPaymentsRemaining":"2"
    }
  },
  "errors": null
}''';

    const exhaustedSuccessResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "SUCCESS",
  "message": "Successfully retrieved mandate details",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "data": {
    "mandateData": {
      "mandateStatus":"EXHAUSTED",
      "mandateCreateDate":"20211204",
      "mandateExhaustionDate":"20211209",
      "maskedMandateId":"md_94fxxxxxx3e15",
      "siId":"si_cd2f0a1c-4dec-44d5-b0f3-297aee590d32",
      "numberOfPaymentsProcessed":"6",
      "numberOfPaymentsRemaining":"0"
    }
  },
  "errors": null
}''';

    const notFoundResponse = '''{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "NOT_FOUND",
  "message": "Mandate id not found",
  "timestamp": "2021-04-12T07:47:18Z",
  "transactionCreationTime": "25/08/2021 14:24:12",
  "data": null,
  "errors": null
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAPIHeader('Standing Instruction Status Check', 'POST /gl/v1/payments/si/status', Colors.purple, isDark),
        const SizedBox(height: AppTheme.spacing24),
        _buildAPIDescriptionCard(
          'Check if a Standing Instruction is active or not and retrieve associated information including payments processed, remaining payments, and mandate status.',
          isDark,
        ),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Request Body',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', requestExample, isDark),
        const SizedBox(height: AppTheme.spacing32),
        Text(
          'Response Examples',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success - Active Mandate', activeSuccessResponse, AppTheme.success, isDark),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success - Exhausted Mandate', exhaustedSuccessResponse, Colors.purple, isDark),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Mandate Not Found', notFoundResponse, const Color(0xFFDC2626), isDark),
      ],
    );
  }

  Widget _buildSIPauseAPI(BuildContext context, bool isLargeScreen, bool isDark) {
    const pauseRequestExample = '''{
  "merchantTxnId": "PAUSE_123456",
  "standingInstruction": {
    "action": "PAUSE",
    "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15"
  }
}''';

    const pauseWithDataRequestExample = '''{
  "merchantTxnId": "PAUSE_789123",
  "standingInstruction": {
    "action": "PAUSE",
    "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15",
    "data": {
      "startDate": "20250101"
    }
  }
}''';

    const successResponse = '''{
  "status": "SUCCESS",
  "message": "SI PAUSE completed successfully",
  "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15",
  "action": "PAUSE",
  "transactionStatus": "SUCCESS"
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAPIHeader('SI Pause (Modify)', 'POST /gl/v1/payments/si/modify', Colors.purple, isDark),
        const SizedBox(height: AppTheme.spacing24),
        _buildAPIDescriptionCard(
          'Temporarily pause a Standing Instruction mandate. All mandate data is preserved and can be reactivated later. Optionally include data.startDate to reschedule the mandate.',
          isDark,
        ),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Pause Without Data',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', pauseRequestExample, isDark),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Pause With Data (Rescheduling)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        PremiumCard(
          child: Text(
            'Use data.startDate to pause and reschedule the mandate with a new start date in YYYYMMDD format',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', pauseWithDataRequestExample, isDark),
        const SizedBox(height: AppTheme.spacing32),
        Text(
          'Response Example',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success Response', successResponse, AppTheme.success, isDark),
      ],
    );
  }

  Widget _buildSIActivateAPI(BuildContext context, bool isLargeScreen, bool isDark) {
    const requestExample = '''{
  "merchantTxnId": "ACTIVATE_456789",
  "standingInstruction": {
    "action": "ACTIVATE",
    "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15"
  }
}''';

    const successResponse = '''{
  "status": "SUCCESS",
  "message": "SI ACTIVATE completed successfully",
  "mandateId": "md_94f0bb40-2664-4851-ab83-b86c618d3e15",
  "action": "ACTIVATE",
  "transactionStatus": "SUCCESS"
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAPIHeader('SI Activate (Status Update)', 'PUT /gl/v1/payments/si/status', Colors.green, isDark),
        const SizedBox(height: AppTheme.spacing24),
        _buildAPIDescriptionCard(
          'Reactivate a paused Standing Instruction mandate. Charging resumes from the next scheduled payment date. All mandate details are preserved.',
          isDark,
        ),
        const SizedBox(height: AppTheme.spacing24),
        Text(
          'Request Body',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        _buildCodeExampleWithCopy('Request Example', requestExample, isDark),
        const SizedBox(height: AppTheme.spacing32),
        Text(
          'Response Example',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildResponseSection('Success Response', successResponse, AppTheme.success, isDark),
        const SizedBox(height: AppTheme.spacing24),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Key Points',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• PAUSE uses /si/modify endpoint with POST method\n• ACTIVATE uses /si/status endpoint with PUT method\n• Both require action field and mandateId\n• PAUSE can include optional data.startDate for rescheduling',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildAPIHeader(String title, String endpoint, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              endpoint,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIDescriptionCard(String description, bool isDark) {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExampleWithCopy(String title, String code, bool isDark) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(code, 'Code'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey[300]!,
                ),
              ),
              child: Text(
                code,
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseSection(String title, String response, Color color, bool isDark) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                response,
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
