import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui_web;
import '../constants/api_constants.dart';
import '../models/cart_item.dart';
import '../widgets/shared_app_bar.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String cdId;

  const PaymentCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.cdId = "cd_123456789",
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  bool _isLoadingPayment = true;
  String? _errorMessage;
  String? _redirectUrl;
  String? _gid;
  html.IFrameElement? _iframe;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  Completer<void>? _iframeReadyCompleter;

  final TextEditingController _emailCtrl = TextEditingController(text: 'customer@example.com');
  final TextEditingController _phoneCtrl = TextEditingController(text: '+91 9876543210');
  final TextEditingController _nameCtrl = TextEditingController(text: 'John Doe');
  final TextEditingController _addressCtrl = TextEditingController(text: '123 Main Street, Mumbai');

  @override
  void initState() {
    super.initState();
    print('💳 PaymentCheckoutScreen initState');
    if (kIsWeb) {
      _iframeReadyCompleter = Completer<void>();

      // Register iframe view factory
      _registerIframeViewFactory();

      // Listen for messages from iframe
      _setupMessageListener();

      // Initialize payment after a short delay to ensure DOM is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        _initializeInlinePayment();
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Register iframe view factory for payment
  void _registerIframeViewFactory() {
    final viewId = 'payglocal-inline-iframe';

    // Ignore if already registered
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        _iframe = html.IFrameElement()
          ..src = 'inline_helper.html'
          ..style.width = '100%'
          ..style.height = '600px'
          ..style.border = 'none'
          ..style.borderRadius = '12px'
          ..style.overflow = 'hidden'
          ..onLoad.listen((event) {
            print('🎉 Iframe loaded successfully');
          })
          ..onError.listen((event) {
            print('❌ Iframe failed to load');
          });

        print('🖼️ Created iframe for PayGlocal inline payment, src: ${_iframe!.src}');
        return _iframe!;
      },
    );
  }

  /// Setup message listener for iframe communication
  void _setupMessageListener() {
    _messageSubscription = html.window.onMessage.listen((event) {
      final data = event.data;

      if (data is Map || (data.toString().contains('type'))) {
        print('📨 Message from iframe: $data');

        try {
          Map<String, dynamic> messageData;
          if (data is Map) {
            messageData = Map<String, dynamic>.from(data);
          } else {
            // Try to parse as JSON string
            return;
          }

          final type = messageData['type'];

          if (type == 'IFRAME_READY') {
            print('✅ Iframe is ready');
            if (_iframeReadyCompleter != null && !_iframeReadyCompleter!.isCompleted) {
              _iframeReadyCompleter!.complete();
            }
          } else if (type == 'PAYMENT_CALLBACK') {
            final callbackData = messageData['data'];
            _handlePaymentCallback(callbackData, _gid ?? '');
          } else if (type == 'PAYMENT_ERROR') {
            final error = messageData['error'];
            print('❌ Payment error from iframe: $error');
            setState(() {
              _isLoadingPayment = false;
              _errorMessage = error?.toString() ?? 'Unknown error';
            });
          }
        } catch (e) {
          print('Error processing message: $e');
        }
      }
    });
  }

  /// Initialize inline payment
  Future<void> _initializeInlinePayment() async {
    try {
      print('🔄 Starting inline payment initialization...');
      setState(() {
        _isLoadingPayment = true;
        _errorMessage = null;
      });

      // Fetch redirect URL first
      print('🌐 Fetching redirect URL...');
      final paymentData = await _fetchRedirectUrl();
      _redirectUrl = paymentData['redirectUrl'] as String?;
      _gid = paymentData['gid'] as String?;

      print('✅ RedirectURL: $_redirectUrl');
      print('✅ GID: $_gid');

      if (_redirectUrl == null || _redirectUrl!.trim().isEmpty) {
        throw Exception('Missing redirect URL');
      }

      // Wait for iframe to be ready (with timeout)
      print('⏳ Waiting for iframe to be ready...');
      await _iframeReadyCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Iframe ready timeout - will try to send message anyway');
        },
      );

      print('✅ Iframe should be ready, sending init message...');

      // Send initialization message
      final message = {
        'type': 'INIT_PAYMENT',
        'redirectUrl': _redirectUrl,
        'cdId': widget.cdId,
      };

      // Find and send to all inline_helper.html iframes
      final iframes = html.document.querySelectorAll('iframe');
      print('🔍 Found ${iframes.length} iframes in DOM');

      var sentCount = 0;
      for (var iframe in iframes) {
        try {
          final iframeElement = iframe as html.IFrameElement;
          final src = iframeElement.src ?? '';
          print('  - Iframe src: $src');

          if (src.contains('inline_helper.html')) {
            print('  ✅ Found inline_helper iframe, sending message...');
            iframeElement.contentWindow?.postMessage(message, '*');
            sentCount++;
          }
        } catch (e) {
          print('  ❌ Failed to send to iframe: $e');
        }
      }

      if (sentCount == 0) {
        print('⚠️ No inline_helper.html iframes found, broadcasting to all...');
        // Broadcast to all iframes as fallback
        for (var iframe in iframes) {
          try {
            (iframe as html.IFrameElement).contentWindow?.postMessage(message, '*');
          } catch (e) {
            // Ignore
          }
        }
      }

      print('📤 Message sent to $sentCount iframe(s)');

      setState(() {
        _isLoadingPayment = false;
      });
    } catch (e, stack) {
      print('❌ Error: $e');
      print('Stack: $stack');
      setState(() {
        _isLoadingPayment = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Fetch redirect URL from backend
  Future<Map<String, dynamic>> _fetchRedirectUrl() async {
    final payload = {
      "merchantTxnId": "TXN_${DateTime.now().millisecondsSinceEpoch}",
      "paymentData": {
        "totalAmount": widget.total.toStringAsFixed(2),
        "txnCurrency": "INR",
        "billingData": {
          "emailId": _emailCtrl.text.trim(),
          "firstName": _nameCtrl.text.trim().split(' ').first,
          "lastName": _nameCtrl.text.trim().split(' ').skip(1).join(' '),
          "phoneNumber": _phoneCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
        },
      },
      "riskData": {},
      "merchantCallbackURL": "https://your-site.com/callback",
    };

    final res = await http.post(
      Uri.parse(codeDropUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return {
        'redirectUrl': body['redirectUrl'],
        'gid': body['gid'],
        'statusUrl': body['statusUrl'],
      };
    } else {
      throw Exception("Backend error: ${res.body}");
    }
  }

  /// Handle payment callback
  void _handlePaymentCallback(dynamic data, String gid) {
    final status = _extractStatusFromData(data);
    print('Payment callback: $status');

    if (status == null || (status != 'SUCCESS' && status != 'FAILED' && status != 'CANCELLED')) {
      _pollStatusAndNavigate(gid);
    } else {
      _handleStatusAndNavigate(status);
    }
  }

  /// Extract status from callback data
  String? _extractStatusFromData(dynamic data) {
    try {
      if (data is Map) {
        final s = data['status'];
        if (s is String) return s.toUpperCase();
      }
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map && decoded['status'] is String) {
            return (decoded['status'] as String).toUpperCase();
          }
        } catch (_) {
          // Not JSON, check string content
          if (data.toUpperCase().contains('SUCCESS')) return 'SUCCESS';
          if (data.toUpperCase().contains('FAILED')) return 'FAILED';
          if (data.toUpperCase().contains('CANCELLED')) return 'CANCELLED';
        }
      }
    } catch (e) {
      print('Error extracting status: $e');
    }
    return null;
  }

  /// Poll status
  Future<void> _pollStatusAndNavigate(String gid) async {
    if (gid.isEmpty) {
      _handleStatusAndNavigate(null);
      return;
    }

    for (int i = 0; i < 6; i++) {
      try {
        final resp = await http.get(Uri.parse('$codeDropUrl/status?gid=$gid'));
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          final txStatus = (body['transactionStatus'] ?? '').toString().toUpperCase();
          if (txStatus.isNotEmpty) {
            if (['CAPTURED', 'SUCCESS', 'SENT_FOR_CAPTURE', 'APPROVED'].contains(txStatus)) {
              if (!mounted) return;
              _handleStatusAndNavigate('SUCCESS');
              return;
            }
            if (['FAILED', 'CANCELLED', 'DECLINED'].contains(txStatus)) {
              if (!mounted) return;
              _handleStatusAndNavigate('FAILED');
              return;
            }
          }
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    if (!mounted) return;
    _handleStatusAndNavigate(null);
  }

  /// Navigate based on status
  void _handleStatusAndNavigate(String? status) {
    if (status == 'SUCCESS') {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-success', (route) => false);
      });
    } else if (status == 'FAILED') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Payment failed');
      });
    } else if (status == 'CANCELLED') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Payment cancelled');
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Unknown status');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: SharedAppBar(title: 'Checkout'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: isLargeScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildPaymentSection()),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildOrderSummarySection()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildOrderSummarySection(),
                        const SizedBox(height: 24),
                        _buildPaymentSection(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payment, color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                    ),
                    Text(
                      'Secure payment powered by PayGlocal',
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoadingPayment)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else
              _buildPaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6))),
            ),
            const SizedBox(height: 20),
            Text(
              'Initializing secure payment...',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade600),
              const SizedBox(height: 16),
              Text(
                'Payment Initialization Failed',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade900),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeInlinePayment,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      children: [
        Container(
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const HtmlElementView(
              viewType: 'payglocal-inline-iframe',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    return Column(
      children: [
        // Customer Info
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Name', _nameCtrl.text),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.email, 'Email', _emailCtrl.text),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'Phone', _phoneCtrl.text),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on, 'Address', _addressCtrl.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Order Summary
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                const SizedBox(height: 16),
                ...widget.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOrderItem(item),
                    )),
                const Divider(height: 24, color: Color(0xFFE5E7EB)),
                _buildSummaryRow('Subtotal', widget.subtotal),
                const SizedBox(height: 8),
                _buildSummaryRow('GST (18%)', widget.tax),
                const SizedBox(height: 8),
                _buildSummaryRow('Shipping', widget.shipping),
                const Divider(height: 24, color: Color(0xFFE5E7EB)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                    Text('₹${widget.total.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF111827), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Center(child: Text(item.image, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Qty: ${item.quantity} • ${item.size} • ${item.color}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
        Text('₹${item.totalPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280))),
        Text('₹${amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111827))),
      ],
    );
  }
}
