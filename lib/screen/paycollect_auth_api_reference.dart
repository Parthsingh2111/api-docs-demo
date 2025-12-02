import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../navigation/app_router.dart';
import '../navigation/app_navigation.dart';

class PayCollectAuthApiReferenceScreen extends StatefulWidget {
  const PayCollectAuthApiReferenceScreen({super.key});

  @override
  _PayCollectAuthApiReferenceScreenState createState() => _PayCollectAuthApiReferenceScreenState();
}

class _PayCollectAuthApiReferenceScreenState extends State<PayCollectAuthApiReferenceScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String _selectedSection = 'auth-payment';
  String _selectedLanguage = 'curl';

  @override
  void initState() {
    super.initState();
    _initializeSectionKeys();
  }

  void _initializeSectionKeys() {
    _sectionKeys['auth-payment'] = GlobalKey();
    _sectionKeys['capture-full'] = GlobalKey();
    _sectionKeys['capture-partial'] = GlobalKey();
    _sectionKeys['status-check'] = GlobalKey();
    _sectionKeys['refund-partial'] = GlobalKey();
    _sectionKeys['refund-full'] = GlobalKey();
    _sectionKeys['auth-reversal'] = GlobalKey();
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
            final RenderBox? box = key?.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) {
              final position = box.localToGlobal(Offset.zero).dy;
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
            AppNavigation.to(AppRouter.paycollectAuthDetail);
          },
          tooltip: 'Back to Auth & Capture Documentation',
        ),
        title: Row(
          children: [
            Icon(Icons.api, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
          'API Reference - Auth & Capture',
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
                AppNavigation.to(AppRouter.paycollectAuthDetail);
              },
              icon: Icon(Icons.menu_book, size: 18, color: AppTheme.accent),
              label: Text(
                'Auth Docs',
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
          
          // 1) Auth Payment Initiation
          _buildSidebarSection(isDark, 'AUTH PAYMENT INITIATION', [
            _buildSidebarItem(
              isDark,
              'Auth Payment Initiate',
              'auth-payment',
              Icons.lock_clock,
              method: 'POST',
            ),
          ]),
          const SizedBox(height: 24),

          // 2) Capture & Auth Reversal
          _buildSidebarSection(isDark, 'CAPTURE & AUTH REVERSAL', [
            _buildSidebarItem(
              isDark,
              'Full Capture',
              'capture-full',
              Icons.check_circle,
              method: 'POST',
            ),
            _buildSidebarItem(
              isDark,
              'Partial Capture',
              'capture-partial',
              Icons.check_circle_outlined,
              method: 'POST',
            ),
            _buildSidebarItem(
              isDark,
              'Auth Reversal',
              'auth-reversal',
              Icons.cancel,
              method: 'POST',
            ),
          ]),
          const SizedBox(height: 24),

          // 3) Transaction Service API
          _buildSidebarSection(isDark, 'TRANSACTION SERVICE API', [
            _buildSidebarItem(
              isDark,
              'Status Check',
              'status-check',
              Icons.info_outline,
              method: 'GET',
            ),
            _buildSidebarItem(
              isDark,
              'Partial Refund',
              'refund-partial',
              Icons.refresh,
              method: 'POST',
            ),
            _buildSidebarItem(
              isDark,
              'Full Refund',
              'refund-full',
              Icons.refresh,
              method: 'POST',
            ),
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
          
          // 1) Auth Payment Initiation
          _buildSidebarSection(isDark, 'AUTH PAYMENT INITIATION', [
            _buildSidebarItem(
              isDark,
              'Auth Payment Initiate',
              'auth-payment',
              Icons.lock_clock,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
          ]),
          const SizedBox(height: 24),

          // 2) Capture & Auth Reversal
          _buildSidebarSection(isDark, 'CAPTURE & AUTH REVERSAL', [
            _buildSidebarItem(
              isDark,
              'Full Capture',
              'capture-full',
              Icons.check_circle,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Partial Capture',
              'capture-partial',
              Icons.check_circle_outlined,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
            _buildSidebarItem(
              isDark,
              'Auth Reversal',
              'auth-reversal',
              Icons.cancel,
              method: 'POST',
              closeDrawerOnTap: true,
            ),
          ]),
          const SizedBox(height: 24),

          // 3) Transaction Service API
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
      // Check if any child section is active
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

          // Auth Payment API
          Container(key: _sectionKeys['auth-payment']),
          _buildAuthPaymentSection(isDark),
          const SizedBox(height: 64),

          // Capture Full API
          Container(key: _sectionKeys['capture-full']),
          _buildCaptureFullSection(isDark),
          const SizedBox(height: 64),

          // Capture Partial API
          Container(key: _sectionKeys['capture-partial']),
          _buildCapturePartialSection(isDark),
          const SizedBox(height: 64),

          // Auth Reversal API
          Container(key: _sectionKeys['auth-reversal']),
          _buildAuthReversalSection(isDark),
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
              'All Auth & Capture API endpoints require JWE/JWS encryption for secure communication. The request payload is encrypted with JWE and signed with JWS.',
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

  // ===== AUTH PAYMENT SECTION =====
  Widget _buildAuthPaymentSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Auth Payment - Hold Funds',
      description: 'Authorize and hold funds without immediate capture. Perfect for hotel bookings, pre-orders, or any scenario where you need to reserve funds before final confirmation.',
      method: 'POST',
      endpoint: '/gl/v1/payments/initiate/paycollect',
      payloadJson: '''{
  "merchantTxnId": "AUTH_TXN_20250122_001",
  "paymentData": {
    "totalAmount": "1000.00",
    "txnCurrency": "INR"
  },
  "captureTxn": false,
  "merchantCallbackURL": "https://yourwebsite.com/callback"
}''',
      responseJson: '''{
  "gid": "gl_o-9a713b1e00fb3a3393b0gIaX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "01/12/2025 14:01:54",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjFlMDBmYjNhMzM5M2IwZ0lhWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTE0NjU5IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxZTAwZmIzYTMzZTViM2IwZ0lhWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.lloFovAhrQjfevRhfkrqbW4NRDH8GX0rXYBk9UOl2u5N6bDAjTiUcAKhgkln0bdX_Kj7C1FSgdjnUHVrjFYBIk67FYMdOwYPSJ-9UVE4JJCQEoqBHTK4bZeNWbYW7oIM7qrSMk-4Emv6rScBC30UY9hdIuYgKDVimomCdjTGnWobww_5I-LSffY_RRXgtgZ2uMiyHcGgjE54konBEj1f-DqX04W-2uuv_XW66y2h6ANPgIz_56MFb9XQUu8nMtUqK5TuFJ5Dt2Cm9OFNOsjDnavnQcn5Ab6XwDyF2JTCLocG9TB6cuNgSfISuGaK_eOtY_nh7Vs3H-fVKK1aiJ239w",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-9a713b1e00fb3a3393b0gIaX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bDdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTlhNzEzYjFlMDBmYjNhMzM5M2IwZ0lhWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzY0NTc3OTE0NjU5IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85YTcxM2IxZTAwZmIzYTMzZTViM2IwZ0lhWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.lloFovAhrQjfevRhfkrqbW4NRDH8GX0rXYBk9UOl2u5N6bDAjTiUcAKhgkln0bdX_Kj7C1FSgdjnUHVrjFYBIk67FYMdOwYPSJ-9UVE4JJCQEoqBHTK4bZeNWbYW7oIM7qrSMk-4Emv6rScBC30UY9hdIuYgKDVimomCdjTGnWobww_5I-LSffY_RRXgtgZ2uMiyHcGgjE54konBEj1f-DqX04W-2uuv_XW66y2h6ANPgIz_56MFb9XQUu8nMtUqK5TuFJ5Dt2Cm9OFNOsjDnavnQcn5Ab6XwDyF2JTCLocG9TB6cuNgSfISuGaK_eOtY_nh7Vs3H-fVKK1aiJ239w",
    "merchantTxnId": "1756728697873338303"
  },
  "errors": null
}''',
    );
  }

  // ===== CAPTURE FULL SECTION =====
  Widget _buildCaptureFullSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Capture Full - Capture All Authorized Funds',
      description: 'Capture the entire authorized amount. Use this when you want to charge the full amount that was held during authorization.',
      method: 'POST',
      endpoint: '/gl/v1/payments/capture',
      payloadJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "merchantTxnId": "CAPTURE_20250122_001",
  "captureType": "F"
}''',
      responseJson: '''{
  "gid": "gl_999c0583327223ff",
  "status": "SENT_FOR_CAPTURE",
  "message": "Sent for Capture Successfully",
  "data": {
    "captureCurrency": "INR",
    "merchantTxnId": "CAPTURE_20250122_001",
    "captureAmount": "1000.00"
  }
}''',
    );
  }

  // ===== CAPTURE PARTIAL SECTION =====
  Widget _buildCapturePartialSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Capture Partial - Capture Specific Amount',
      description: 'Capture a specific amount from the authorized funds. You can call this multiple times to capture incrementally.',
      method: 'POST',
      endpoint: '/gl/v1/payments/capture',
      payloadJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "merchantTxnId": "CAPTURE_PARTIAL_20250122_001",
  "captureType": "P",
  "paymentData": {
    "totalAmount": "500.00"
  }
}''',
      responseJson: '''{
  "gid": "gl_999c0583327223ff",
  "status": "SENT_FOR_CAPTURE",
  "message": "Sent for Capture Successfully",
  "data": {
    "captureCurrency": "INR",
    "merchantTxnId": "CAPTURE_PARTIAL_20250122_001",
    "captureAmount": "500.00"
  }
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
      description: 'Refund a specific amount from a captured transaction. This is useful for partial returns or price adjustments. Multiple partial refunds can be processed until the full captured amount is refunded.',
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
      description: 'Refund the entire captured amount in one operation. This is the quickest way to process a complete refund. Use refundType "F" and omit the paymentData.totalAmount field.',
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

  // ===== AUTH REVERSAL SECTION =====
  Widget _buildAuthReversalSection(bool isDark) {
    return _build4StepApiSection(
      isDark: isDark,
      title: 'Auth Reversal - Release Held Funds',
      description: 'Cancel the authorization and immediately release the reserved funds back to the customer. No capture can occur after reversal.',
      method: 'POST',
      endpoint: '/gl/v1/payments/auth-reversal',
      payloadJson: '''{
  "gid": "gl_o-999bdfe356062074c9ho0LBX2",
  "merchantTxnId": "REVERSAL_20250122_001"
}''',
      responseJson: '''{
  "gid": "gl_9a71608f976147d2",
  "status": "REVERSED",
  "message": "Sent for auth reversal Successfully",
  "timestamp": "01/12/2025 14:27:29",
  "reasonCode": "GL-201-001",
  "data": {
    "merchantTxnId": "REVERSAL_1764579446948"
  },
  "errors": null
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
            // For now, show the raw JSON or string payload for all languages.
            // (Request formation is still language-specific in Token Creation and API Request steps.)
            _buildCodeBlock(payloadJson, 'json'),
          ]),
          const SizedBox(height: 32),

          // STEP 2: Token Creation
          _buildStep('2', 'Token Creation (JWE & JWS)', [
            _buildCodeBlock(
              _getTokenCreationCode(_selectedLanguage, payloadJson),
              _selectedLanguage == 'curl' ? 'bash' : _selectedLanguage,
            ),
          ]),
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
  -H 'X-GL-TOKEN-EXTERNAL: '\$jws''';
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
    'X-GL-TOKEN-EXTERNAL': jws
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
    'X-GL-TOKEN-EXTERNAL: ' . \$jws,
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

request.Headers.Add("X-GL-TOKEN-EXTERNAL", jws);
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
    final isStatusEndpoint = endpoint.contains('/status');

    if (isStatusEndpoint) {
      switch (language) {
        case 'curl':
          return '''# Status check uses gid in the path (no request body)
GID="gl_o-xxxx"
ENDPOINT="/gl/v1/payments/\$GID/status"''';
        case 'nodejs':
          return '''const gid = 'gl_o-xxxx';
const endpoint = '/gl/v1/payments/' + gid + '/status';''';
        case 'php':
          return '''<?php
\$gid = 'gl_o-xxxx';
\$endpoint = "/gl/v1/payments/{\$gid}/status";''';
        case 'csharp':
          return '''var gid = "gl_o-xxxx";
var endpoint = "/gl/v1/payments/" + gid + "/status";''';
        default:
          return payloadJson;
      }
    }

    switch (language) {
      case 'curl':
        return payloadJson;

      case 'nodejs':
        return '''// Use the JSON payload above as your request body
const payload = { /* same fields as JSON above */ };''';

      case 'php':
        return '''<?php
// Use the JSON payload above as an associative array
\$payload = [
    // same fields as JSON above
];''';

      case 'csharp':
        return '''// Use the JSON payload above as a C# string or typed object
var payloadJson = "{ /* same fields as JSON above */ }";''';

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
