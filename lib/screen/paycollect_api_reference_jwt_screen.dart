import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_router.dart';
import '../navigation/app_navigation.dart';

class PayCollectJWTAPIReferenceScreen extends StatefulWidget {
  const PayCollectJWTAPIReferenceScreen({super.key});

  @override
  _PayCollectJWTAPIReferenceScreenState createState() => _PayCollectJWTAPIReferenceScreenState();
}

class _PayCollectJWTAPIReferenceScreenState extends State<PayCollectJWTAPIReferenceScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String _selectedSection = 'payment-initiate';
  String _selectedLanguage = 'curl';

  @override
  void initState() {
    super.initState();
    _initializeSectionKeys();
  }

  void _initializeSectionKeys() {
    _sectionKeys['payment-initiate'] = GlobalKey();
    _sectionKeys['status-check'] = GlobalKey();
    _sectionKeys['refund-partial'] = GlobalKey();
    _sectionKeys['refund-full'] = GlobalKey();
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
            // Simply pop to go back to the previous page (JWT Detail)
            if (AppNavigation.canPop()) {
              AppNavigation.back();
            } else {
              // Fallback: navigate to JWT Detail if can't pop
              AppNavigation.to(AppRouter.paycollectJwtDetail);
            }
          },
          tooltip: 'Back to JWT Documentation',
        ),
        title: Row(
                children: [
            Icon(Icons.api, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'API Reference - JWT',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        elevation: 0,
        actions: [
          if (showSidebar)
            TextButton.icon(
              onPressed: () {
                // Pop back to JWT Detail page
                if (AppNavigation.canPop()) {
                  AppNavigation.back();
                } else {
                  AppNavigation.to(AppRouter.paycollectJwtDetail);
                }
              },
              icon: Icon(Icons.menu_book, size: 18, color: AppTheme.accent),
              label: Text(
                'JWT Docs',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          const SizedBox(width: 16),
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
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          
          _buildSidebarSection(isDark, 'PAYMENT API', [
            _buildSidebarItem(isDark, 'Initiate Payment', 'payment-initiate', Icons.payment, method: 'POST'),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'TRANSACTION SERVICE API', [
            _buildSidebarItem(isDark, 'Status Check', 'status-check', Icons.info_outline, method: 'GET'),
            _buildSidebarItem(isDark, 'Partial Refund', 'refund-partial', Icons.refresh, method: 'POST'),
            _buildSidebarItem(isDark, 'Full Refund', 'refund-full', Icons.refresh, method: 'POST'),
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
                    color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
          Divider(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          
          _buildSidebarSection(isDark, 'PAYMENT API', [
            _buildSidebarItem(
              isDark,
              'Initiate Payment',
              'payment-initiate',
              Icons.payment,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSidebarSection(isDark, 'TRANSACTION SERVICE API', [
            _buildSidebarItem(
              isDark,
              'Status Check',
              'status-check',
              Icons.info_outline,
              method: 'GET',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Partial Refund',
              'refund-partial',
              Icons.refresh,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Full Refund',
              'refund-full',
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
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSidebarItem(bool isDark, String label, String sectionId, IconData icon, {String? method, List<Widget>? children, bool closeDrawerOnTap = false}) {
    final isActive = _selectedSection == sectionId || (children != null && children.any((child) {
      return _selectedSection.startsWith(sectionId);
    }));
    
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

    // If it has children, use ExpansionTile
    if (children != null) {
      return ExpansionTile(
        leading: Icon(
          icon,
          size: 18,
          color: isActive
              ? AppTheme.accent
              : (isDark ? Colors.white60 : Colors.black54),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? (AppTheme.getTextPrimary(context))
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        initiallyExpanded: isActive,
        children: children,
      );
    }

    // Regular item without children
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
              else
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? AppTheme.accent
                      : (isDark ? Colors.white60 : Colors.black54),
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
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSubItem(bool isDark, String label, String sectionId, {String? method, bool closeDrawerOnTap = false}) {
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
          if (closeDrawerOnTap && AppNavigation.canPop()) {
            AppNavigation.back();
          }
        },
        borderRadius: BorderRadius.circular(8),
                child: Container(
          margin: const EdgeInsets.only(left: 32, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withOpacity(isDark ? 0.2 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                      color: getMethodColor(method),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? (AppTheme.getTextPrimary(context))
                        : (isDark ? Colors.white70 : Colors.black54),
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
          // Authentication Section
          _buildAuthenticationSection(isDark),
          const SizedBox(height: 64),

          // Payment Initiate API
          Container(key: _sectionKeys['payment-initiate']),
          _buildPaymentInitiateSection(isDark),
          const SizedBox(height: 64),

          // Status Check API
          Container(key: _sectionKeys['status-check']),
          _buildStatusCheckSection(isDark),
          const SizedBox(height: 64),

          // Partial Refund API
          Container(key: _sectionKeys['refund-partial']),
          _buildPartialRefundSection(isDark),
          const SizedBox(height: 64),

          // Full Refund API
          Container(key: _sectionKeys['refund-full']),
          _buildFullRefundSection(isDark),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  // ===== AUTHENTICATION SECTION =====
  Widget _buildAuthenticationSection(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
        padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withOpacity(0.1),
              AppTheme.info.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accent.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            Row(
              children: [
                Icon(Icons.security, color: AppTheme.accent, size: 28),
                const SizedBox(width: 12),
                      Text(
                  'Authentication Required',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                  fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.darkTextPrimary.withOpacity(0.85) 
                      : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            Text(
              'All JWT API endpoints require JWE/JWS encryption for secure communication. The request payload is encrypted with JWE and signed with JWS.',
                style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF64748B),
                  height: 1.6,
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ===== PAYMENT INITIATE SECTION =====
  Widget _buildPaymentInitiateSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Initiate Payment',
      description: 'Create a new payment transaction with JWT authentication. This API immediately captures the payment upon successful authorization.',
      method: 'POST',
      endpoint: '/gl/v1/payments/initiate/paycollect',
      payloadJson: '''{
  "merchantTxnId": "TXN_20250122_001",
  "paymentData": {
    "totalAmount": "1000.00",
    "txnCurrency": "INR"
  },
  "merchantCallbackURL": "https://yourwebsite.com/callback"
}''',
      responseJson: '''{
  "gid": "gl_o-9a713b19377b3a33b41aj0vq8",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "01/12/2025 14:01:54",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjE5Mzc3YjNhMzNiNDFhajB2cTgiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTEzOTIwIiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxOTM3N2IzYTMzMTk5NDFhajB2cTgiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.GzA1auz12WY9d6RH0EC5R8fcR-sfppLy_cL-RLRGdR-m4DF-9B6bXM56ydy7QoGnvO_NvEzy2kg5wtF-J5ahh7MJpUU6EtDmzGTj0wFuRRrNCiXfc8K9-zlIcToUQoK_TrJNxfRLQyrXiBs3evD1MiAlvZNzKfUvsdm--tGldRhcHZYeyicfK7z6r1QXLBl9GmlbVdk9kIS5pZ_bm-2pGu6DuYoBKJ8DGKM2Pxw1KBuWlzoCIuoaSXRkCOZe0upfJj_pDTC_05TZK9jDjLGqvYASaYq-J_KzKZhtNKPc-c7iGa9QsQroXGAfXjc3m5dsrJKrVur_0vQJ1UYXT825AQ",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-9a713b19377b3a33b41aj0vq8/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjE5Mzc3YjNhMzNiNDFhajB2cTgiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTEzOTIwIiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxOTM3N2IzYTMzMTk5NDFhajB2cTgiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.GzA1auz12WY9d6RH0EC5R8fcR-sfppLy_cL-RLRGdR-m4DF-9B6bXM56ydy7QoGnvO_NvEzy2kg5wtF-J5ahh7MJpUU6EtDmzGTj0wFuRRrNCiXfc8K9-zlIcToUQoK_TrJNxfRLQyrXiBs3evD1MiAlvZNzKfUvsdm--tGldRhcHZYeyicfK7z6r1QXLBl9GmlbVdk9kIS5pZ_bm-2pGu6DuYoBKJ8DGKM2Pxw1KBuWlzoCIuoaSXRkCOZe0upfJj_pDTC_05TZK9jDjLGqvYASaYq-J_KzKZhtNKPc-c7iGa9QsQroXGAfXjc3m5dsrJKrVur_0vQJ1UYXT825AQ",
    "merchantTxnId": "23AEE8CB6B62EE2AF07"
  },
  "errors": null
}''',
    );
  }

  // ===== STATUS CHECK SECTION =====
  Widget _buildStatusCheckSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Status Check',
      description: 'Check the current status of a payment transaction using the Global ID (gid).',
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

  // ===== PARTIAL REFUND SECTION =====
  Widget _buildPartialRefundSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Partial Refund',
      description: 'Refund a specific amount from a completed transaction. This is useful for partial returns or price adjustments. Multiple partial refunds can be processed until the full amount is refunded.',
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

  // ===== FULL REFUND SECTION =====
  Widget _buildFullRefundSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Full Refund',
      description: 'Refund the entire transaction amount in one operation. This is the quickest way to process a complete refund. Use refundType "F" and omit the paymentData.totalAmount field.',
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
            // For now, show the raw JSON payload for all languages.
            // (Request formation is still language-specific in Token Creation and API Request steps.)
            _buildCodeBlock(payloadJson, 'json'),
          ]),
          const SizedBox(height: 32),

          // STEP 2: Token Creation
          _buildStep(
            '2',
            endpoint.contains('/status')
                ? 'Token Creation (JWS with pathAsPayload)'
                : 'Token Creation (JWE & JWS)',
            [
              _buildCodeBlock(
                endpoint.contains('/status')
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
                    color: Colors.white,
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
        color: Colors.white,
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
    final isStatusEndpoint = endpoint.contains('/status');
    
    switch (language) {
      case 'curl':
        if (isStatusEndpoint) {
          return '''curl -X GET '$fullUrl' \\
  -H 'Content-Type: text/plain' \\
  -H 'X-GL-TOKEN-EXTERNAL: '\$token''';
        }
        return '''curl -X $method '$fullUrl' \\
  -H 'Content-Type: application/jose' \\
  -H 'X-GL-TOKEN-EXTERNAL: '\$jws \\
  -d '\$jwe\'''';
      
      case 'nodejs':
        if (isStatusEndpoint) {
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
        if (isStatusEndpoint) {
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
        if (isStatusEndpoint) {
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

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Header with language badge and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
      child: Row(
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF60A5FA),
                ),
              ),
            ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: const Color(0xFF94A3B8),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
              children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
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
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: const Color(0xFFE2E8F0),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
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
}
