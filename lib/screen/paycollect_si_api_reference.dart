import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_navigation.dart';

class PayCollectSiApiReferenceScreen extends StatefulWidget {
  const PayCollectSiApiReferenceScreen({super.key});

  @override
  State<PayCollectSiApiReferenceScreen> createState() =>
      _PayCollectSiApiReferenceScreenState();
}

class _PayCollectSiApiReferenceScreenState
    extends State<PayCollectSiApiReferenceScreen> {
  String _selectedLanguage = 'curl';
  String _selectedSection = 'si-initiate-fixed';
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize section keys
    _sectionKeys['si-initiate-fixed'] = GlobalKey();
    _sectionKeys['si-initiate-variable'] = GlobalKey();
    _sectionKeys['deduction-fixed'] = GlobalKey();
    _sectionKeys['deduction-ondemand'] = GlobalKey();
    _sectionKeys['status-check'] = GlobalKey();
    _sectionKeys['pause-mandate'] = GlobalKey();
    _sectionKeys['activate-mandate'] = GlobalKey();
    _sectionKeys['tx-status-check'] = GlobalKey();
    _sectionKeys['tx-refund-partial'] = GlobalKey();
    _sectionKeys['tx-refund-full'] = GlobalKey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionId) {
    setState(() {
      _selectedSection = sectionId;
    });
    
    // Use post-frame callback to ensure widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final key = _sectionKeys[sectionId];
    if (key?.currentContext != null) {
        try {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
            alignment: 0.1,
          );
        } catch (e) {
          // Fallback: scroll using controller if ensureVisible fails
          if (_scrollController.hasClients && key?.currentContext != null) {
            final renderObject = key?.currentContext?.findRenderObject();
            if (renderObject is RenderBox && renderObject.attached && renderObject.hasSize) {
              final position = renderObject.localToGlobal(Offset.zero).dy;
              _scrollController.animateTo(
                _scrollController.offset + position - 100,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 1200;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.getTextPrimary(context),
          ),
          onPressed: () {
            // Simply pop to go back to the previous page (SI Detail)
            if (AppNavigation.canPop()) {
              AppNavigation.back();
            } else {
              // Fallback: navigate to SI Detail if can't pop
              AppNavigation.to('/paycollect-si-detail');
            }
          },
          tooltip: 'Back to SI Documentation',
        ),
        title: Row(
          children: [
            Icon(Icons.api, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
          'API Reference - Standing Instructions',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        elevation: 0,
        actions: [
          if (showSidebar)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () {
                  // Pop back to SI Detail page
                  if (AppNavigation.canPop()) {
                    AppNavigation.back();
                  } else {
                    AppNavigation.to('/paycollect-si-detail');
                  }
                },
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(
                  'SI Docs',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      drawer: !showSidebar ? _buildDrawer(isDark) : null,
      body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Sidebar (desktop only)
          if (showSidebar) _buildSidebar(isDark),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildMainContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        border: Border(
          right: BorderSide(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.api, color: AppTheme.accent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'API REFERENCE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextPrimary(context),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete API Documentation',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          
          _buildSidebarSection(isDark, 'SI PAYMENT INITIATION', [
            _buildSidebarItem(isDark, 'Fixed SI', 'si-initiate-fixed', Icons.attach_money, method: 'POST'),
            _buildSidebarItem(isDark, 'Variable SI', 'si-initiate-variable', Icons.money, method: 'POST'),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'DEDUCTION', [
            _buildSidebarItem(
              isDark,
              'Fixed Auto-Debit',
              'deduction-fixed',
              Icons.schedule,
              hideIcon: true,
            ),
            _buildSidebarItem(
              isDark,
              'On-Demand Deduction',
              'deduction-ondemand',
              Icons.payment,
              method: 'POST',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'MANDATE MANAGEMENT', [
            _buildSidebarItem(isDark, 'Status Check', 'status-check', Icons.info_outline, method: 'POST'),
            _buildSidebarItem(isDark, 'Pause Mandate', 'pause-mandate', Icons.pause_circle_outline, method: 'POST'),
            _buildSidebarItem(isDark, 'Activate Mandate', 'activate-mandate', Icons.play_circle_outline, method: 'PUT'),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'TRANSACTION SERVICE API', [
            _buildSidebarItem(isDark, 'Status Check', 'tx-status-check', Icons.info_outline, method: 'GET'),
            _buildSidebarItem(isDark, 'Partial Refund', 'tx-refund-partial', Icons.refresh, method: 'POST'),
            _buildSidebarItem(isDark, 'Full Refund', 'tx-refund-full', Icons.refresh, method: 'POST'),
          ]),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: AppTheme.getSurfaceColor(context),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.api, color: AppTheme.accent, size: 24),
                    const SizedBox(width: 8),
          Text(
                      'API REFERENCE',
            style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
              color: AppTheme.getTextPrimary(context),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete API Documentation',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          
          _buildSidebarSection(isDark, 'SI PAYMENT INITIATION', [
            _buildSidebarItem(isDark, 'Fixed SI', 'si-initiate-fixed', Icons.attach_money, method: 'POST', closeDrawerOnTap: true),
            _buildSidebarItem(isDark, 'Variable SI', 'si-initiate-variable', Icons.money, method: 'POST', closeDrawerOnTap: true),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'DEDUCTION', [
            _buildSidebarItem(
              isDark,
              'Fixed Auto-Debit',
              'deduction-fixed',
              Icons.schedule,
              closeDrawerOnTap: true,
              hideIcon: true,
            ),
            _buildSidebarItem(
              isDark,
              'On-Demand Deduction',
              'deduction-ondemand',
              Icons.payment,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'MANDATE MANAGEMENT', [
            _buildSidebarItem(isDark, 'Status Check', 'status-check', Icons.info_outline, method: 'POST', closeDrawerOnTap: true),
            _buildSidebarItem(isDark, 'Pause Mandate', 'pause-mandate', Icons.pause_circle_outline, method: 'POST', closeDrawerOnTap: true),
            _buildSidebarItem(isDark, 'Activate Mandate', 'activate-mandate', Icons.play_circle_outline, method: 'PUT', closeDrawerOnTap: true),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'TRANSACTION SERVICE API', [
            _buildSidebarItem(
              isDark,
              'Status Check',
              'tx-status-check',
              Icons.info_outline,
              method: 'GET',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Partial Refund',
              'tx-refund-partial',
              Icons.refresh,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Full Refund',
              'tx-refund-full',
              Icons.refresh,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSidebarSection(bool isDark, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSidebarItem(
    bool isDark,
    String label,
    String sectionId,
    IconData icon, {
    String? method,
    bool closeDrawerOnTap = false,
    bool hideIcon = false,
  }) {
    final isActive = _selectedSection == sectionId;
    
    Color getMethodColor(String? m) {
      if (m == null) return AppTheme.accent;
      switch (m) {
        case 'GET': return AppTheme.info;
        case 'POST': return AppTheme.success;
        case 'PUT': return AppTheme.warning;
        case 'DELETE': return AppTheme.error;
        default: return AppTheme.accent;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _scrollToSection(sectionId);
          // Only close drawer on mobile when explicitly requested
          if (closeDrawerOnTap && AppNavigation.canPop()) {
            AppNavigation.back();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withOpacity(isDark ? 0.2 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: isActive ? AppTheme.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              if (method != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getMethodColor(method).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
                    method,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: getMethodColor(method),
                    ),
                  ),
                )
              else if (!hideIcon)
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? AppTheme.accent
                      : (AppTheme.getTextSecondary(context)),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? (AppTheme.getTextPrimary(context))
                        : (AppTheme.getTextSecondary(context)),
                  ),
          ),
        ),
      ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed SI Initiation
          Container(key: _sectionKeys['si-initiate-fixed']),
          _buildFixedSiSection(isDark),
          const SizedBox(height: 64),

          // Variable SI Initiation
          Container(key: _sectionKeys['si-initiate-variable']),
          _buildVariableSiSection(isDark),
          const SizedBox(height: 64),

          // Fixed Auto-Debit Explanation
          Container(key: _sectionKeys['deduction-fixed']),
          _buildFixedAutoDebitSection(isDark),
          const SizedBox(height: 64),

          // On-Demand Deduction API
          Container(key: _sectionKeys['deduction-ondemand']),
          _buildOnDemandDeductionSection(isDark),
          const SizedBox(height: 64),

          // Status Check API
          Container(key: _sectionKeys['status-check']),
          _buildStatusCheckSection(isDark),
          const SizedBox(height: 64),

          // Pause Mandate API
          Container(key: _sectionKeys['pause-mandate']),
          _buildPauseMandateSection(isDark),
          const SizedBox(height: 64),

          // Activate Mandate API
          Container(key: _sectionKeys['activate-mandate']),
          _buildActivateMandateSection(isDark),
          const SizedBox(height: 64),

          // Transaction Service - Status Check
          Container(key: _sectionKeys['tx-status-check']),
          _buildTransactionStatusSection(isDark),
          const SizedBox(height: 64),

          // Transaction Service - Partial Refund
          Container(key: _sectionKeys['tx-refund-partial']),
          _buildTransactionPartialRefundSection(isDark),
          const SizedBox(height: 64),

          // Transaction Service - Full Refund
          Container(key: _sectionKeys['tx-refund-full']),
          _buildTransactionFullRefundSection(isDark),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  // ===== SECTION BUILDERS =====

  // ===== FIXED SI SECTION =====
  Widget _buildFixedSiSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Fixed SI - Standing Instruction Setup',
      description: 'Create a recurring payment mandate with a fixed amount per billing cycle. Ideal for subscriptions, loan EMIs, and regular payments.',
      method: 'POST',
      endpoint: '/gl/v1/payments/initiate/paycollect',
      payloadJson: '''{
  "merchantTxnId": "1756728757520948273",
  "paymentData": {
    "totalAmount": "1000.00",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "numberOfPayments": "12",
      "frequency": "MONTHLY",
      "type": "FIXED",
      "amount": "1000.00",
      "startDate": "2025-09-01"
    }
  },
  "merchantCallbackURL": "https://yourwebsite.com/callback"
}''',
      responseJson: '''{
  "gid": "gl_o-9a713b1b90453a3365i30HwX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "01/12/2025 14:01:54",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjFiOTA0NTNhMzM2NWkzMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTE0Mjg3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxYjkwNDUzYTMzYTQzNWkzMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.Pxj1tEGTyi6ucEAONhgeixLusPglP9F86dbactUqan8lZWvh6bCxsRIxgYATVjDKOZ5Wass5J-qATksLL6dL3gOcjG76cfl6gpPZARa5koD3rY7kcdIg3OMQxz53gsdnFfXbQb2IMJn-FmDwjEpwPTS8slfKcFyF2zXM_gGzI0HygZaxvDW8bMvlhyjUoUmTEOr3A2xWsM7gLW_eDdjl_QOLEyP_eEOI-yU4LovH7cl7Pb5GLQMt2oiFMLiAM4FAjTpy2K8J6XZFTqpd88nDrLuUxHWmrvGT8xqfdTmX82xuaGvdQqBQCr6NkqElRvwFgXfsK8Q1BhUl6dneEac91Q",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-9a713b1b90453a3365i30HwX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjFiOTA0NTNhMzM2NWkzMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTE0Mjg3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxYjkwNDUzYTMzYTQzNWkzMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.Pxj1tEGTyi6ucEAONhgeixLusPglP9F86dbactUqan8lZWvh6bCxsRIxgYATVjDKOZ5Wass5J-qATksLL6dL3gOcjG76cfl6gpPZARa5koD3rY7kcdIg3OMQxz53gsdnFfXbQb2IMJn-FmDwjEpwPTS8slfKcFyF2zXM_gGzI0HygZaxvDW8bMvlhyjUoUmTEOr3A2xWsM7gLW_eDdjl_QOLEyP_eEOI-yU4LovH7cl7Pb5GLQMt2oiFMLiAM4FAjTpy2K8J6XZFTqpd88nDrLuUxHWmrvGT8xqfdTmX82xuaGvdQqBQCr6NkqElRvwFgXfsK8Q1BhUl6dneEac91Q",
    "mandateId": "md_9cd24112-efae-4832-b4bf-b1911459895f",
    "merchantTxnId": "1756728757520948273"
  },
  "errors": null
}''',
    );
  }

  // ===== VARIABLE SI SECTION =====
  Widget _buildVariableSiSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Variable SI - Standing Instruction Setup',
      description: 'Create a recurring payment mandate with variable amounts up to a maximum limit. Perfect for utility bills, usage-based services, and on-demand charges.',
      method: 'POST',
      endpoint: '/gl/v1/payments/initiate/paycollect',
      payloadJson: '''{
  "merchantTxnId": "TXN_VARIABLE_20250122_002",
  "paymentData": {
    "totalAmount": "500.00",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "type": "VARIABLE",
      "frequency": "ONDEMAND",
      "numberOfPayments": "999",
      "maxAmount": "5000.00"
    }
  },
  "merchantCallbackURL": "https://yourwebsite.com/callback"
}''',
      responseJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=...",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/.../status",
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197",
    "merchantTxnId": "1762340710458550873"
  }
}''',
    );
  }

  // ===== FIXED AUTO-DEBIT EXPLANATION =====
  Widget _buildFixedAutoDebitSection(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Fixed Auto-Debit',
            style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppTheme.darkTextPrimary 
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Text(
            'For FIXED SI mandates, PayGlocal automatically processes recurring payments on the scheduled dates.',
            style: GoogleFonts.poppins(
            fontSize: 16,
              color: const Color(0xFF64748B),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Row(
                  children: [
                    Icon(Icons.info, color: const Color(0xFF3B82F6), size: 24),
                    const SizedBox(width: 12),
        Text(
                      'Automatic Processing',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                          : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                    Text(
                  'No API calls required! PayGlocal handles the entire recurring billing cycle:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
        const SizedBox(height: 12),
                _buildBulletPoint('Charges on scheduled dates automatically'),
                _buildBulletPoint('Sends payment status via webhooks'),
                _buildBulletPoint('Continues until numberOfPayments reached'),
                _buildBulletPoint('You only need to handle webhooks for payment confirmations'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF475569))),
          Expanded(
                    child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF475569), height: 1.5),
            ),
          ),
        ],
        ),
    );
  }

  // ===== ON-DEMAND DEDUCTION SECTION =====
  Widget _buildOnDemandDeductionSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'On-Demand Deduction',
      description: 'Execute a payment using an existing mandate. For VARIABLE mandates, specify the amount (must be ≤ maxAmount). For FIXED mandates, no amount needed.',
      method: 'POST',
      endpoint: '/gl/v1/payments/si/sale',
      payloadJson: '''{
  "merchantTxnId": "SI_SALE_1762341166224",
  "standingInstruction": {
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  },
  "paymentData": {
    "totalAmount": "750.00",
    "txnCurrency": "INR"
  }
}''',
      responseJson: '''{
  "gid": "gl_999beb05f5bb23ff",
  "status": "SENT_FOR_CAPTURE",
  "message": "Sent for capture successfully",
  "data": {
    "merchantTxnId": "SI_SALE_1762341166224"
  }
}''',
    );
  }

  // ===== STATUS CHECK SECTION =====
  Widget _buildStatusCheckSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Status Check',
      description: 'Retrieve detailed information about a Standing Instruction mandate including current status, payment history, and remaining deductions.',
      method: 'POST',
      endpoint: '/gl/v1/payments/si/status',
      payloadJson: '''{
  "standingInstruction": {
    "mandateId": "md_afb1b562-ecc9-4df8-a203-c172fa6f916b"
  }
}''',
      responseJson: '''{
  "gid": "gl_9a7154c1b29bc151",
  "status": "SUCCESS",
  "message": "Transaction retrieval status = success",
  "timestamp": "01/12/2025 14:19:24",
  "reasonCode": "GL-201-001",
  "data": {
    "mandateData": {
      "maskedMandateId": "md_afbxxxxxxx916b",
      "siId": "si_PBE0YF1TKyMJE0mP2",
      "gatewaySiId": null,
      "mandateStatus": "ACTIVE",
      "numberOfPaymentsProcessed": "0",
      "numberOfPaymentsRemaining": "12",
      "mandateCreationTime": "01/12/2025 14:17:05",
      "mandateExhaustionTime": null,
      "mandateInactivationTime": null
    }
  },
  "errors": null
}''',
    );
  }

  // ===== PAUSE MANDATE SECTION =====
  Widget _buildPauseMandateSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Pause Mandate',
      description: 'Temporarily pause a Standing Instruction mandate. No charges will occur while paused. You can either pause instantly or schedule a pause from a specific future date.',
      method: 'POST',
      endpoint: '/gl/v1/payments/si/modify',
      payloadJson: '''{
  "merchantTxnId": "PAUSE_SI_1762341166224",
  "standingInstruction": {
    "action": "PAUSE",
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  }
}''',
      responseJson: '''{
  "gid": "gl_9a7154c33316c151",
  "status": "SUCCESS",
  "message": "Modified mandate successfully",
  "timestamp": "01/12/2025 14:19:25",
  "reasonCode": "GL-201-001",
  "data": {
    "mandateStatus": "PAUSED"
  },
  "errors": null
}''',
    );
  }

  // ===== ACTIVATE MANDATE SECTION =====
  Widget _buildActivateMandateSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Activate Mandate',
      description: 'Reactivate a paused Standing Instruction mandate to resume recurring charges after an instant pause or a scheduled pause period.',
      method: 'POST',
      endpoint: '/gl/v1/payments/si/modify',
      payloadJson: '''{
  "merchantTxnId": "ACTIVATE_SI_1764584223507",
  "action": "ACTIVATE",
  "mandateId": "md_afb1b562-ecc9-4df8-a203-c172fa6f916b"
}''',
      responseJson: '''{
  "gid": "gl_9a71d527e6693a33",
  "status": "SUCCESS",
  "message": "Successfully updated the mandate status to ACTIVE",
  "timestamp": "01/12/2025 15:47:04",
  "reasonCode": "GL-201-001",
  "data": null,
  "errors": null
}''',
    );
  }

  // ===== TRANSACTION SERVICE: STATUS CHECK SECTION =====
  Widget _buildTransactionStatusSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Status Check (Transaction)',
      description: 'Check the current status of a payment transaction using the Global ID (gid). This uses the Transaction Service API and path-based payload for JWS.',
      method: 'GET',
      endpoint: '/gl/v1/payments/{gid}/status',
      payloadJson: '''pathAsPayload="/gl/v1/payments/\$GID/status"''',
      responseJson: '''{
  "gid": "gl_9a713b2021633a33",
  "status": "SENT_FOR_CAPTURE",
  "message": "Transaction is sent_for_capture",
  "timestamp": "01/12/2025 14:01:54",
  "reasonCode": "GL-201-001",
  "data": {
    "siStatus": "SUCCESS",
    "transactionCreationTime": "28/11/2025 00:59:09",
    "gid": "gl_o-9a540860426e0b24ad6a0HwX2",
    "payment-method": "CARD",
    "siId": "si_vLssK5CFlyjcj2sPb",
    "Amount": "499.00",
    "txnCurrency": "GBP",
    "merchantTxnId": "1756728757520948273",
    "CardBrand": "VISA",
    "detailedMessage": "Sent for capture successfully",
    "CardType": "DEBIT",
    "Currency": "INR",
    "Country": "United Kingdom",
    "maskedMandateId": "md_a45xxxxxxxc5ce",
    "reasonCode": "GL-201-001",
    "authApprovalCode": "831000",
    "status": "SENT_FOR_CAPTURE"
  },
  "errors": null
}''',
    );
  }

  // ===== TRANSACTION SERVICE: PARTIAL REFUND SECTION =====
  Widget _buildTransactionPartialRefundSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Partial Refund (Transaction)',
      description: 'Refund a specific amount from a completed transaction through the Transaction Service API. Multiple partial refunds can be processed until the full amount is refunded.',
      method: 'POST',
      endpoint: '/gl/v1/payments/refund',
      payloadJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "merchantTxnId": "REFUND_20250122_001",
  "refundType": "P",
  "paymentData": {
    "totalAmount": "500.00"
  }
}''',
      responseJson: '''{
  "gid": "gl_9a7154c7c401c151",
  "status": "SENT_FOR_REFUND",
  "message": "Refund request sent successfully",
  "timestamp": "01/12/2025 14:19:27",
  "reasonCode": "GL-201-001",
  "data": {
    "merchantTxnId": "REFUND_1764578964307",
    "refundCurrency": "INR",
    "refundAmount": "10.00"
  },
  "errors": null
}''',
    );
  }

  // ===== TRANSACTION SERVICE: FULL REFUND SECTION =====
  Widget _buildTransactionFullRefundSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Full Refund (Transaction)',
      description: 'Refund the entire transaction amount in one operation through the Transaction Service API. Use refundType "F" and omit the paymentData.totalAmount field.',
      method: 'POST',
      endpoint: '/gl/v1/payments/refund',
      payloadJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "merchantTxnId": "REFUND_FULL_20250122_001",
  "refundType": "F"
}''',
      responseJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "status": "SUCCESS",
  "message": "Refund initiated successfully",
  "data": {
    "refundId": "rf_abc123xyz",
    "merchantTxnId": "REFUND_FULL_20250122_001",
    "refundAmount": "1000.00"
  }
}''',
    );
  }

  // ===== 4-STEP API SECTION BUILDER =====
  Widget _build4StepApiSection({
    required bool isDark,
    required String title,
    required String description,
    required String method,
    required String endpoint,
    required String payloadJson,
    required String responseJson,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Header
          Row(
                children: [
        Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
                  color: _getMethodColor(method).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  method,
                  style: GoogleFonts.firaCode(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getMethodColor(method),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                      : const Color(0xFF1E293B),
                  ),
                ),
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
            fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // STEP 1: Endpoint & Payload Structure
          _buildStep('1', 'Endpoint & Payload Structure', [
            Text(
              'Method & Endpoint:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                  : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            _buildCodeBlock('$method $endpoint', 'http'),
            const SizedBox(height: 16),
            Text(
              'Payload (Before Encryption):',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                  : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageTabs(),
            const SizedBox(height: 16),
            _buildCodeBlock(
              _getPayloadCodeForLanguage(
                _selectedLanguage,
                payloadJson,
                method,
                endpoint,
              ),
              _selectedLanguage == 'curl' ? 'bash' : _selectedLanguage,
            ),
          ]),
          const SizedBox(height: 32),

          // STEP 2: Token Creation
          _buildStep(
            '2',
            endpoint.contains('{gid}/status')
                ? 'Token Creation (JWS with pathAsPayload)'
                : 'Token Creation (JWE & JWS)',
            [
              _buildCodeBlock(
                endpoint.contains('{gid}/status')
                    ? _getStatusTokenCreationCode(_selectedLanguage)
                    : _getTokenCreationCode(_selectedLanguage, payloadJson),
                _selectedLanguage == 'curl' ? 'bash' : _selectedLanguage,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // STEP 3: API Request
          _buildStep('3', 'API Request', [
            _buildCodeBlock(
              _getApiRequestCode(_selectedLanguage, method, endpoint, payloadJson),
              _selectedLanguage == 'curl' ? 'bash' : _selectedLanguage,
            ),
          ]),
          const SizedBox(height: 32),

          // STEP 4: Response
          _buildStep('4', 'Response', [
                Text(
              'Response (After JWS Decryption):',
              style: GoogleFonts.poppins(
                fontSize: 14,
                    fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                  : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
            _buildCodeBlock(responseJson, 'json'),
          ]),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
          Container(
              width: 36,
              height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                ),
              child: Center(
            child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfacePrimary,
              ),
            ),
          ),
            ),
            const SizedBox(width: 12),
                Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary.withOpacity(0.85) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  // ===== SINGLE LANGUAGE SELECTOR =====
  Widget _buildLanguageTabs() {
    final languages = ['cURL', 'Node.js', 'PHP', 'C#'];
    
    return Container(
                decoration: BoxDecoration(
        color: AppTheme.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: languages.map((lang) {
          final langKey = lang.toLowerCase().replaceAll('.', '').replaceAll('#', 'sharp');
          final isSelected = _selectedLanguage == langKey;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedLanguage = langKey;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                  lang,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                      fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                    ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  // ===== TOKEN CREATION CODE GENERATION =====
  String _getTokenCreationCode(String language, String payloadJson) {
    switch (language) {
      case 'curl':
        return '''# Generate JWE and JWS tokens
generateTokens payload''';
      
      case 'nodejs':
        return '''// Generate JWE (encryption) and JWS (signature) tokens
const { jwe, jws } = await generateTokens(payload);''';
      
      case 'php':
        return '''<?php
// Generate JWE and JWS tokens
\$tokens = generateTokens(\$payload);
\$jwe = \$tokens['jwe'];
\$jws = \$tokens['jws'];''';
      
      case 'csharp':
        return '''// Generate JWE and JWS tokens
var tokens = await GenerateTokens(payload);
var jwe = tokens.Jwe;
var jws = tokens.Jws;''';
      
      default:
        return payloadJson;
    }
  }

  // ===== STATUS CHECK TOKEN CREATION (JWS ONLY, pathAsPayload) =====
  String _getStatusTokenCreationCode(String language) {
    switch (language) {
      case 'curl':
        return '''# Generate JWS token using pathAsPayload
token=\$(generateToken "\$pathAsPayload")''';

      case 'nodejs':
        return '''// Generate JWS token using pathAsPayload
const token = await generateToken(pathAsPayload);''';

      case 'php':
        return '''<?php
// Generate JWS token using pathAsPayload
\$token = generateToken(\$pathAsPayload);''';

      case 'csharp':
        return '''// Generate JWS token using pathAsPayload
var token = await GenerateToken(pathAsPayload);''';

      default:
        return 'token = generateToken(pathAsPayload);';
    }
  }

  // ===== API REQUEST CODE GENERATION =====
  String _getApiRequestCode(String language, String method, String endpoint, String payloadJson) {
    final baseUrl = 'https://api.uat.payglocal.in';
    final fullUrl = baseUrl + endpoint;
    final isTransactionStatusEndpoint = endpoint.contains('{gid}/status');
    
    switch (language) {
      case 'curl':
        if (isTransactionStatusEndpoint) {
          return '''curl -X GET '$fullUrl' \\
  -H 'Content-Type: text/plain' \\
  -H 'X-GL-TOKEN-EXTERNAL: '\$token''';
        }
        return '''curl -X $method '$fullUrl' \\
  -H 'Content-Type: application/jose' \\
  -H 'X-GL-TOKEN-EXTERNAL: '\$jws \\
  -d '\$jwe\'''';
      
      case 'nodejs':
        if (isTransactionStatusEndpoint) {
          return '''// Send status check request to PayGlocal API
const response = await fetch('$fullUrl', {
  method: 'GET',
  headers: {
    'Content-Type': 'text/plain',
    'X-GL-TOKEN-EXTERNAL': token
  }
});

const result = await response.json();''';
        }
        return '''// Send request to PayGlocal API
const response = await fetch('$fullUrl', {
  method: '$method',
  headers: {
    'Content-Type': 'application/jose',
    'X-GL-TOKEN-EXTERNAL': jws
  },
  body: jwe
});

const result = await response.json();''';
      
      case 'php':
        if (isTransactionStatusEndpoint) {
          return '''<?php
// Send status check request to PayGlocal API
\$ch = curl_init('$fullUrl');
curl_setopt(\$ch, CURLOPT_CUSTOMREQUEST, 'GET');
curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt(\$ch, CURLOPT_HTTPHEADER, [
    'Content-Type: text/plain',
    'X-GL-TOKEN-EXTERNAL: ' . \$token,
]);

\$response = curl_exec(\$ch);
curl_close(\$ch);

\$result = json_decode(\$response, true);''';
        }
        return '''<?php
// Send request to PayGlocal API
\$ch = curl_init('$fullUrl');
curl_setopt(\$ch, CURLOPT_CUSTOMREQUEST, '$method');
curl_setopt(\$ch, CURLOPT_POSTFIELDS, \$jwe);
curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt(\$ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/jose',
    'X-GL-TOKEN-EXTERNAL: ' . \$jws,
]);

\$response = curl_exec(\$ch);
curl_close(\$ch);

\$result = json_decode(\$response, true);''';
      
      case 'csharp':
        if (isTransactionStatusEndpoint) {
          return '''// Send status check request to PayGlocal API
using System.Net.Http;
using System.Net.Http.Headers;

var client = new HttpClient();
var request = new HttpRequestMessage(HttpMethod.Get, "$fullUrl");

request.Headers.Add("X-GL-TOKEN-EXTERNAL", token);
request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("text/plain"));

var response = await client.SendAsync(request);
var result = await response.Content.ReadAsStringAsync();''';
        }
        return '''// Send request to PayGlocal API
using System.Net.Http;
using System.Net.Http.Headers;

var client = new HttpClient();
var request = new HttpRequestMessage(HttpMethod.${method.substring(0, 1).toUpperCase()}${method.substring(1).toLowerCase()}, "$fullUrl");

request.Headers.Add("X-GL-TOKEN-EXTERNAL", jws);
request.Content = new StringContent(jwe);
request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/jose");

var response = await client.SendAsync(request);
var result = await response.Content.ReadAsStringAsync();''';
      
      default:
        return payloadJson;
    }
  }

  // ===== PAYLOAD CODE PER LANGUAGE =====
  String _getPayloadCodeForLanguage(
    String language,
    String payloadJson,
    String method,
    String endpoint,
  ) {
    // Show generic language-specific hints for how to hold the JSON payload
    switch (language) {
      case 'curl':
        // Raw JSON is fine for cURL
        return payloadJson;

      case 'nodejs':
        return '''const payload = $payloadJson;''';

      case 'php':
        final escaped = payloadJson
            .replaceAll(r'\', r'\\')
            .replaceAll("'", r"\'")
            .replaceAll('\n', '\\n');
        return '''<?php
// Decode JSON payload into associative array
\$payload = json_decode('$escaped', true);''';

      case 'csharp':
        final csharpJson = payloadJson.replaceAll('"', '""');
        return '''// JSON payload as C# string
var payloadJson = @"$csharpJson";''';

      default:
        return payloadJson;
    }
  }


  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET': return AppTheme.info;
      case 'POST': return AppTheme.success;
      case 'PUT': return AppTheme.warning;
      case 'DELETE': return AppTheme.error;
      default: return AppTheme.accent;
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  icon: const Icon(Icons.copy, color: Color(0xFF94A3B8), size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.surfacePrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('Code copied!', style: GoogleFonts.inter()),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
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

  Widget _buildEndpointHeader(bool isDark, String method, String endpoint, String title, String description) {
    Color getMethodColor() {
    switch (method) {
        case 'GET': return AppTheme.info;
        case 'POST': return AppTheme.success;
        case 'PUT': return AppTheme.warning;
        case 'DELETE': return AppTheme.error;
        default: return AppTheme.accent;
      }
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
            fontSize: 28,
              fontWeight: FontWeight.w700,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
          child: Row(
        children: [
          Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                  color: getMethodColor(),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  method,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.surfacePrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
            child: Row(
              children: [
              Expanded(
                child: Text(
                  endpoint,
                  style: GoogleFonts.jetBrainsMono(
                          fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      tooltip: 'Copy endpoint',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: endpoint));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                            content: Text('Endpoint copied!', style: GoogleFonts.inter()),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            height: 1.7,
            ),
          ),
        ],
    );
  }



  Widget _buildInfoCard(bool isDark, String title, String content, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
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

  Widget _buildAuthRequirement(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard(bool isDark, String label, String url, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              url,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 18),
            tooltip: 'Copy URL',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('URL copied!', style: GoogleFonts.inter()),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCodeTable(bool isDark, List<Map<String, String>> errorCodes) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: errorCodes.asMap().entries.map((entry) {
          final index = entry.key;
          final error = entry.value;
          final isLast = index == errorCodes.length - 1;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : (isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      error['code']!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextPrimary(context),
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
                        error['status']!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error['desc']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                          height: 1.5,
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
    );
  }

  // ===== CODE EXAMPLES GENERATOR =====

  String _getRequestExample(String apiId) {
    final examples = {
      'si-setup': {
        'curl': '''curl -X POST 'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect' \\
  -H 'Content-Type: text/plain' \\
  -H 'x-gl-token-external: <JWS_TOKEN>' \\
  -d '<JWE_ENCRYPTED_PAYLOAD>'

# The JWE payload contains:
{
  "merchantTxnId": "SI_FIXED_123456",
  "paymentData": {
    "totalAmount": "1000.00",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "type": "FIXED",
      "numberOfPayments": "12",
      "frequency": "MONTHLY",
      "amount": "1000.00",
      "startDate": "20250901"
    }
  },
  "merchantCallbackURL": "https://yoursite.com/callback"
}''',
        'node': r'''const PayGlocalClient = require('pg-client-sdk');

const client = new PayGlocalClient({
  merchantId: process.env.MERCHANT_ID,
  privateKeyId: process.env.PRIVATE_KEY_ID,
  privateKeyPath: './keys/private_key.pem'
});

const payload = {
  merchantTxnId: 'SI_FIXED_123456',
  paymentData: {
    totalAmount: '1000.00',
    txnCurrency: 'INR'
  },
  standingInstruction: {
    data: {
      type: 'FIXED',
      numberOfPayments: '12',
      frequency: 'MONTHLY',
      amount: '1000.00',
      startDate: '20250901'
    }
  },
  merchantCallbackURL: 'https://yoursite.com/callback'
};

try {
  const response = await client.initiateSiPayment(payload);
  console.log('Payment initiated:', response);
  console.log('Mandate ID:', response.data.mandateId);
} catch (error) {
  console.error('Error:', error.message);
}''',
        'python': r'''from payglocal_sdk import PayGlocalClient
import os

client = PayGlocalClient(
    merchant_id=os.getenv('MERCHANT_ID'),
    private_key_id=os.getenv('PRIVATE_KEY_ID'),
    private_key_path='./keys/private_key.pem'
)

payload = {
    'merchantTxnId': 'SI_FIXED_123456',
    'paymentData': {
        'totalAmount': '1000.00',
        'txnCurrency': 'INR'
    },
    'standingInstruction': {
        'data': {
            'type': 'FIXED',
            'numberOfPayments': '12',
            'frequency': 'MONTHLY',
            'amount': '1000.00',
            'startDate': '20250901'
        }
    },
    'merchantCallbackURL': 'https://yoursite.com/callback'
}

try:
    response = client.initiate_si_payment(payload)
    print('Payment initiated:', response)
    print('Mandate ID:', response['data']['mandateId'])
except Exception as error:
    print('Error:', str(error))''',
        'php': r'''<?php
require_once 'vendor/autoload.php';

use PayGlocal\PayGlocalClient;

$client = new PayGlocalClient([
    'merchantId' => getenv('MERCHANT_ID'),
    'privateKeyId' => getenv('PRIVATE_KEY_ID'),
    'privateKeyPath' => './keys/private_key.pem'
]);

$payload = [
    'merchantTxnId' => 'SI_FIXED_123456',
    'paymentData' => [
        'totalAmount' => '1000.00',
        'txnCurrency' => 'INR'
    ],
    'standingInstruction' => [
        'data' => [
            'type' => 'FIXED',
            'numberOfPayments' => '12',
            'frequency' => 'MONTHLY',
            'amount' => '1000.00',
            'startDate' => '20250901'
        ]
        ],
    'merchantCallbackURL' => 'https://yoursite.com/callback'
];

try {
    $response = $client->initiateSiPayment($payload);
    echo 'Payment initiated: ' . json_encode($response);
    echo 'Mandate ID: ' . $response['data']['mandateId'];
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}''',
        'java': r'''import com.payglocal.PayGlocalClient;
import com.payglocal.models.*;

PayGlocalClient client = new PayGlocalClient.Builder()
    .merchantId(System.getenv("MERCHANT_ID"))
    .privateKeyId(System.getenv("PRIVATE_KEY_ID"))
    .privateKeyPath("./keys/private_key.pem")
    .build();

SiPaymentRequest request = SiPaymentRequest.builder()
    .merchantTxnId("SI_FIXED_123456")
    .paymentData(PaymentData.builder()
        .totalAmount("1000.00")
        .txnCurrency("INR")
        .build())
    .standingInstruction(StandingInstruction.builder()
        .data(SiData.builder()
            .type("FIXED")
            .numberOfPayments("12")
            .frequency("MONTHLY")
            .amount("1000.00")
            .startDate("20250901")
            .build())
        .build())
    .merchantCallbackURL("https://yoursite.com/callback")
    .build();

try {
    PaymentResponse response = client.initiateSiPayment(request);
    System.out.println("Payment initiated: " + response);
    System.out.println("Mandate ID: " + response.getData().getMandateId());
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}''',
        'csharp': r'''using PayGlocal.SDK;
using PayGlocal.SDK.Models;
using System;

var client = new PayGlocalClient(new PayGlocalConfig
{
    MerchantId = Environment.GetEnvironmentVariable("MERCHANT_ID"),
    PrivateKeyId = Environment.GetEnvironmentVariable("PRIVATE_KEY_ID"),
    PrivateKeyPath = "./keys/private_key.pem"
});

var request = new SiPaymentRequest
{
    MerchantTxnId = "SI_FIXED_123456",
    PaymentData = new PaymentData
    {
        TotalAmount = "1000.00",
        TxnCurrency = "INR"
    },
    StandingInstruction = new StandingInstruction
    {
        Data = new SiData
        {
            Type = "FIXED",
            NumberOfPayments = "12",
            Frequency = "MONTHLY",
            Amount = "1000.00",
            StartDate = "20250901"
        }
    },
    MerchantCallbackURL = "https://yoursite.com/callback"
};

try
{
    var response = await client.InitiateSiPaymentAsync(request);
    Console.WriteLine($"Payment initiated: {response}");
    Console.WriteLine($"Mandate ID: {response.Data.MandateId}");
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}'''
      },
      'si-ondemand': {
        'curl': '''curl -X POST 'https://api.uat.payglocal.in/gl/v1/payments/si/sale' \\
  -H 'Content-Type: text/plain' \\
  -H 'x-gl-token-external: <JWS_TOKEN>' \\
  -d '<JWE_ENCRYPTED_PAYLOAD>'

# The JWE payload contains (for VARIABLE SI):
{
  "merchantTxnId": "SI_SALE_001",
  "paymentData": {
    "totalAmount": "150.00",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  }
}''',
        'node': r'''const response = await client.siOnDemandDeduction({
  merchantTxnId: 'SI_SALE_001',
  paymentData: {
    totalAmount: '150.00',  // Only for VARIABLE SI
    txnCurrency: 'INR'
  },
  standingInstruction: {
    mandateId: 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
  }
});

console.log('Deduction status:', response.status);''',
        'python': r'''response = client.si_ondemand_deduction({
    'merchantTxnId': 'SI_SALE_001',
    'paymentData': {
        'totalAmount': '150.00',  # Only for VARIABLE SI
        'txnCurrency': 'INR'
    },
    'standingInstruction': {
        'mandateId': 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    }
})

print('Deduction status:', response['status'])''',
        'php': r'''$response = $client->siOnDemandDeduction([
    'merchantTxnId' => 'SI_SALE_001',
    'paymentData' => [
        'totalAmount' => '150.00',  // Only for VARIABLE SI
        'txnCurrency' => 'INR'
    ],
    'standingInstruction' => [
        'mandateId' => 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    ]
]);

echo 'Deduction status: ' . $response['status'];''',
        'java': r'''DeductionRequest request = DeductionRequest.builder()
    .merchantTxnId("SI_SALE_001")
    .paymentData(PaymentData.builder()
        .totalAmount("150.00")  // Only for VARIABLE SI
        .txnCurrency("INR")
        .build())
    .standingInstruction(StandingInstruction.builder()
        .mandateId("md_fd8add89-87fa-427c-bd58-8bc585e08197")
        .build())
    .build();

PaymentResponse response = client.siOnDemandDeduction(request);
System.out.println("Deduction status: " + response.getStatus());''',
        'csharp': r'''var request = new DeductionRequest
{
    MerchantTxnId = "SI_SALE_001",
    PaymentData = new PaymentData
    {
        TotalAmount = "150.00",  // Only for VARIABLE SI
        TxnCurrency = "INR"
    },
    StandingInstruction = new StandingInstruction
    {
        MandateId = "md_fd8add89-87fa-427c-bd58-8bc585e08197"
    }
};

var response = await client.SiOnDemandDeductionAsync(request);
Console.WriteLine($"Deduction status: {response.Status}");'''
      },
      'si-status': {
        'curl': '''curl -X POST 'https://api.uat.payglocal.in/gl/v1/payments/si/status' \\
  -H 'Content-Type: text/plain' \\
  -H 'x-gl-token-external: <JWS_TOKEN>' \\
  -d '<JWE_ENCRYPTED_PAYLOAD>'

# The JWE payload contains:
{
  "merchantTxnId": "SI_STATUS_001",
  "standingInstruction": {
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  }
}''',
        'node': r'''const response = await client.siStatusCheck({
  merchantTxnId: 'SI_STATUS_001',
  standingInstruction: {
    mandateId: 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
  }
});

const mandateData = response.data.mandateData;
console.log('Status:', mandateData.mandateStatus);
console.log('Payments processed:', mandateData.numberOfPaymentsProcessed);''',
        'python': r'''response = client.si_status_check({
    'merchantTxnId': 'SI_STATUS_001',
    'standingInstruction': {
        'mandateId': 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    }
})

mandate_data = response['data']['mandateData']
print('Status:', mandate_data['mandateStatus'])
print('Payments processed:', mandate_data['numberOfPaymentsProcessed'])''',
        'php': r'''$response = $client->siStatusCheck([
    'merchantTxnId' => 'SI_STATUS_001',
    'standingInstruction' => [
        'mandateId' => 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    ]
]);

$mandateData = $response['data']['mandateData'];
echo 'Status: ' . $mandateData['mandateStatus'];
echo 'Payments processed: ' . $mandateData['numberOfPaymentsProcessed'];''',
        'java': r'''StatusCheckRequest request = StatusCheckRequest.builder()
    .merchantTxnId("SI_STATUS_001")
    .standingInstruction(StandingInstruction.builder()
        .mandateId("md_fd8add89-87fa-427c-bd58-8bc585e08197")
        .build())
    .build();

StatusResponse response = client.siStatusCheck(request);
MandateData mandateData = response.getData().getMandateData();
System.out.println("Status: " + mandateData.getMandateStatus());''',
        'csharp': r'''var request = new StatusCheckRequest
{
    MerchantTxnId = "SI_STATUS_001",
    StandingInstruction = new StandingInstruction
    {
        MandateId = "md_fd8add89-87fa-427c-bd58-8bc585e08197"
    }
};

var response = await client.SiStatusCheckAsync(request);
var mandateData = response.Data.MandateData;
Console.WriteLine($"Status: {mandateData.MandateStatus}");'''
      },
      'si-pause': {
        'curl': '''curl -X POST 'https://api.uat.payglocal.in/gl/v1/payments/si/modify' \\
  -H 'Content-Type: text/plain' \\
  -H 'x-gl-token-external: <JWS_TOKEN>' \\
  -d '<JWE_ENCRYPTED_PAYLOAD>'

# The JWE payload contains:
{
  "merchantTxnId": "SI_PAUSE_001",
  "standingInstruction": {
    "action": "PAUSE",
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  }
}''',
        'node': r'''const response = await client.siModify({
  merchantTxnId: 'SI_PAUSE_001',
  standingInstruction: {
    action: 'PAUSE',
    mandateId: 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
  }
});

console.log('Mandate paused:', response.status);''',
        'python': r'''response = client.si_modify({
    'merchantTxnId': 'SI_PAUSE_001',
    'standingInstruction': {
        'action': 'PAUSE',
        'mandateId': 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    }
})

print('Mandate paused:', response['status'])''',
        'php': r'''$response = $client->siModify([
    'merchantTxnId' => 'SI_PAUSE_001',
    'standingInstruction' => [
        'action' => 'PAUSE',
        'mandateId' => 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    ]
]);

echo 'Mandate paused: ' . $response['status'];''',
        'java': r'''ModifyRequest request = ModifyRequest.builder()
    .merchantTxnId("SI_PAUSE_001")
    .standingInstruction(StandingInstruction.builder()
        .action("PAUSE")
        .mandateId("md_fd8add89-87fa-427c-bd58-8bc585e08197")
        .build())
    .build();

PaymentResponse response = client.siModify(request);
System.out.println("Mandate paused: " + response.getStatus());''',
        'csharp': r'''var request = new ModifyRequest
{
    MerchantTxnId = "SI_PAUSE_001",
    StandingInstruction = new StandingInstruction
    {
        Action = "PAUSE",
        MandateId = "md_fd8add89-87fa-427c-bd58-8bc585e08197"
    }
};

var response = await client.SiModifyAsync(request);
Console.WriteLine($"Mandate paused: {response.Status}");'''
      },
      'si-activate': {
        'curl': '''curl -X PUT 'https://api.uat.payglocal.in/gl/v1/payments/si/status' \\
  -H 'Content-Type: text/plain' \\
  -H 'x-gl-token-external: <JWS_TOKEN>' \\
  -d '<JWE_ENCRYPTED_PAYLOAD>'

# The JWE payload contains:
{
  "merchantTxnId": "SI_ACTIVATE_001",
  "standingInstruction": {
    "action": "ACTIVATE",
    "mandateId": "md_fd8add89-87fa-427c-bd58-8bc585e08197"
  }
}''',
        'node': r'''const response = await client.siActivate({
  merchantTxnId: 'SI_ACTIVATE_001',
  standingInstruction: {
    action: 'ACTIVATE',
    mandateId: 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
  }
});

console.log('Mandate activated:', response.status);''',
        'python': r'''response = client.si_activate({
    'merchantTxnId': 'SI_ACTIVATE_001',
    'standingInstruction': {
        'action': 'ACTIVATE',
        'mandateId': 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    }
})

print('Mandate activated:', response['status'])''',
        'php': r'''$response = $client->siActivate([
    'merchantTxnId' => 'SI_ACTIVATE_001',
    'standingInstruction' => [
        'action' => 'ACTIVATE',
        'mandateId' => 'md_fd8add89-87fa-427c-bd58-8bc585e08197'
    ]
]);

echo 'Mandate activated: ' . $response['status'];''',
        'java': r'''ActivateRequest request = ActivateRequest.builder()
    .merchantTxnId("SI_ACTIVATE_001")
    .standingInstruction(StandingInstruction.builder()
        .action("ACTIVATE")
        .mandateId("md_fd8add89-87fa-427c-bd58-8bc585e08197")
        .build())
    .build();

PaymentResponse response = client.siActivate(request);
System.out.println("Mandate activated: " + response.getStatus());''',
        'csharp': r'''var request = new ActivateRequest
{
    MerchantTxnId = "SI_ACTIVATE_001",
    StandingInstruction = new StandingInstruction
    {
        Action = "ACTIVATE",
        MandateId = "md_fd8add89-87fa-427c-bd58-8bc585e08197"
    }
};

var response = await client.SiActivateAsync(request);
Console.WriteLine($"Mandate activated: {response.Status}");'''
      },
    };

    final apiExamples = examples[apiId];
    if (apiExamples == null) {
      return '// Example not available';
    }

    return apiExamples[_selectedLanguage] ?? '// ${_selectedLanguage.toUpperCase()} example coming soon';
  }
}
