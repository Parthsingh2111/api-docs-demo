import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';
// import 'payglocal_interop.dart'; // File missing - interop functionality disabled

// Stub definitions for missing interop functionality
dynamic get PGPayGlobal => null;

class LaunchOptions {
  final String redirectUrl;
  final String cdId;
  final String displayMode;

  LaunchOptions({
    required this.redirectUrl,
    required this.cdId,
    required this.displayMode,
  });
}

void pgpayLaunchPayment(LaunchOptions options, Function callback) {
  // Stub - would normally launch payment
  print('Payment launch disabled - interop file missing');
}

void pgpayHandlePayNow(dynamic event) {
  // Stub
}

void pgpayUpdateDetails(dynamic payload) {
  // Stub - accepts any type
}

void pgpayModifyPayment(dynamic payload) {
  // Stub - accepts any type
}

enum CodeDropMode { modal, drawer, inline }

class PayGlocalCodedropScreen extends StatefulWidget {
  final String cdId;
  final Map<String, dynamic> paymentData;

  const PayGlocalCodedropScreen({super.key, this.paymentData = const {}, this.cdId = "cd_123456789"});

  @override
  State<PayGlocalCodedropScreen> createState() => _PayGlocalCodedropScreenState();
}

class _PayGlocalCodedropScreenState extends State<PayGlocalCodedropScreen> {
  CodeDropMode _mode = CodeDropMode.modal;
  static const String _inlineViewType = 'payglocal-inline-host';
  bool _inlineLaunched = false;

  final TextEditingController _amountCtrl = TextEditingController(text: '1000.00');
  final TextEditingController _currencyCtrl = TextEditingController(text: 'INR');
  final TextEditingController _emailCtrl = TextEditingController(text: 'customer@example.com');
  final TextEditingController _inlineWidthCtrl = TextEditingController(text: '400');
  // Extra fields for inline billing/shipping
  final TextEditingController _billingNameCtrl = TextEditingController();
  final TextEditingController _billingPhoneCtrl = TextEditingController();
  final TextEditingController _shippingAddressCtrl = TextEditingController();

  Future<void> _autoLaunchInline(BuildContext context) async {
    if (_inlineLaunched || _mode != CodeDropMode.inline) return;
    try {
      await _ensureScriptLoaded();
      final init = await fetchRedirectUrl();
      final redirectUrl = (init['redirectUrl'] ?? '').toString();
      final gid = (init['gid'] ?? '').toString();

      if (redirectUrl.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing redirect URL. Please try again.')),
        );
        return;
      }

      if (PGPayGlobal != null) {
        final options = LaunchOptions(
          redirectUrl: redirectUrl.trim(),
          cdId: widget.cdId,
          displayMode: _displayModeStr,
        );
        pgpayLaunchPayment(options, js.allowInterop((dynamic data) {
          final status = _extractStatusFromJs(data);
          if (status == null || (status != 'SUCCESS' && status != 'FAILED' && status != 'CANCELLED')) {
            _pollStatusAndNavigate(context, gid);
          } else {
            _handleStatusAndNavigate(context, status);
          }
        }));
        _inlineLaunched = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment library not available.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inline launch error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Prefill from incoming paymentData if present
    final map = widget.paymentData;
    if (map['amount'] != null) _amountCtrl.text = map['amount'].toString();
    if (map['currency'] != null) _currencyCtrl.text = map['currency'].toString();
    if (map['emailId'] != null) _emailCtrl.text = map['emailId'].toString();

    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(_inlineViewType, (int viewId) {
        final div = html.DivElement()..id = 'PayGlocal_payments';
        // Give the host element a finite size to avoid layout exceptions
        div.style.height = '600px';
        div.style.width = '100%';
        return div;
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _emailCtrl.dispose();
    _inlineWidthCtrl.dispose();
    _billingNameCtrl.dispose();
    _billingPhoneCtrl.dispose();
    _shippingAddressCtrl.dispose();
    super.dispose();
  }

  String get _displayModeStr {
    switch (_mode) {
      case CodeDropMode.drawer: return 'drawer';
      case CodeDropMode.inline: return 'inline';
      case CodeDropMode.modal: default: return 'modal';
    }
  }

  Future<void> _ensureInlineContainer() async {
    // For inline mode, ensure a container with id="PayGlocal_payments" exists with data-width
    final existing = html.document.getElementById('PayGlocal_payments');
    final widthNum = int.tryParse(_inlineWidthCtrl.text.trim()) ?? 400;
    final clamped = widthNum.clamp(350, 450); // as per docs
    final widthStr = '${clamped.toString()}px';

    if (existing != null) {
      existing.setAttribute('data-width', widthStr);
      existing.style.width = widthStr;
      if (existing.style.height.isEmpty) {
        existing.style.height = '600px';
      }
    }

    // Ensure a hidden proxy button exists to forward a real click event to PGPay.handlePayNow(event)
    var proxy = html.document.getElementById('pgpay_paynow_proxy') as html.ButtonElement?;
    if (proxy == null) {
      proxy = html.ButtonElement()
        ..id = 'pgpay_paynow_proxy'
        ..style.display = 'none';
      proxy.onClick.listen((event) {
        try {
          pgpayHandlePayNow(event);
        } catch (_) {}
      });
      html.document.body?.append(proxy);
    }
  }

  Future<void> _ensureScriptLoaded() async {
    final existing = html.document.getElementById('payglocal-script') as html.ScriptElement?;
    if (existing != null) {
      existing.remove();
      // Reset global PGPay so the next script initializes with new config
      final reset = html.ScriptElement()..text = 'try{window.PGPay=undefined;}catch(e){}';
      html.document.body?.append(reset);
      reset.remove();
    }

    if (_mode == CodeDropMode.inline) {
      await _ensureInlineContainer();
    }

    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    final script = html.ScriptElement()
      ..id = 'payglocal-script'
      ..src = 'https://codedrop.uat.payglocal.in/simple.js?v=$cacheBust'
      ..setAttribute('data-display-mode', _displayModeStr)
      ..setAttribute('data-cd-id', widget.cdId)
      ..defer = true;

    final completer = Completer<void>();
    script.onLoad.listen((_) => completer.complete());
    script.onError.listen((e) => completer.completeError('Script load failed: $e'));
    
    html.document.body?.append(script);
    await completer.future;
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mode == CodeDropMode.inline) {
      final host = html.document.getElementById('PayGlocal_payments');
      host?.scrollIntoView();
    }
  }

  Future<Map<String, dynamic>> fetchRedirectUrl() async {
    final payload = {
      "merchantTxnId": widget.paymentData["merchantTxnId"] ?? "TXN_${DateTime.now().millisecondsSinceEpoch}",
      "paymentData": {
        "totalAmount": _amountCtrl.text.trim().isEmpty ? '1000.00' : _amountCtrl.text.trim(),
        "txnCurrency": _currencyCtrl.text.trim().isEmpty ? 'INR' : _currencyCtrl.text.trim(),
        "billingData": {
          "emailId": _emailCtrl.text.trim().isEmpty ? 'customer@example.com' : _emailCtrl.text.trim(),
        },
      },
      "riskData": widget.paymentData["riskData"] ?? {},
      "merchantCallbackURL": widget.paymentData["merchantCallbackURL"] ?? "https://your-site.com/callback",
    };

    final res = await http.post(
      Uri.parse("http://localhost:3000/api/codedrop"),
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

  Future<void> handlePayment(BuildContext context) async {
    try {
      await _ensureScriptLoaded();
      final init = await fetchRedirectUrl();
      final redirectUrl = (init['redirectUrl'] ?? '').toString();
      final gid = (init['gid'] ?? '').toString();
      
      if (redirectUrl.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing redirect URL. Please try again.')),
        );
        return;
      }
      
      if (PGPayGlobal != null) {
        if (_mode == CodeDropMode.inline) {
          // Launch inline using the same options object as modal/drawer
          final options = LaunchOptions(
            redirectUrl: redirectUrl.trim(),
            cdId: widget.cdId,
            displayMode: _displayModeStr,
          );
          pgpayLaunchPayment(options, js.allowInterop((dynamic data) {
            final status = _extractStatusFromJs(data);
            if (status == null || (status != 'SUCCESS' && status != 'FAILED' && status != 'CANCELLED')) {
              _pollStatusAndNavigate(context, gid);
            } else {
              _handleStatusAndNavigate(context, status);
            }
          }));
        } else {
          final options = LaunchOptions(
            redirectUrl: redirectUrl.trim(),
            cdId: widget.cdId,
            displayMode: _displayModeStr,
          );
          pgpayLaunchPayment(options, js.allowInterop((dynamic data) {
            final status = _extractStatusFromJs(data);
            if (status == null || (status != 'SUCCESS' && status != 'FAILED' && status != 'CANCELLED')) {
              _pollStatusAndNavigate(context, gid);
            } else {
              _handleStatusAndNavigate(context, status);
          }
          }));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment library not available.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Exception: $e');
      });
    }
  }

  void _handleStatusAndNavigate(BuildContext context, String? status) {
    if (status != null) {
      switch (status) {
        case 'SUCCESS':
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/payment-success', (route) => false);
          });
          return;
        case 'FAILED':
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Gateway returned FAILED');
          });
          return;
        case 'CANCELLED':
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'User cancelled the payment');
          });
          return;
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'Unknown payment status');
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/payment-failure', (route) => false, arguments: 'No status received from gateway');
      });
    }
  }

  String? _extractStatusFromJs(dynamic data) {
    try {
      if (data is Map) {
        final s = data['status'];
        if (s is String) return s;
      }
      final jsonString = js.context['JSON']?.callMethod('stringify', [data]);
      if (jsonString is String && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString);
        if (decoded is Map && decoded['status'] is String) {
          return decoded['status'] as String;
        }
      }
    } catch (_) {
      final asString = data?.toString();
      if (asString is String) {
        if (asString.contains('SUCCESS')) return 'SUCCESS';
        if (asString.contains('FAILED')) return 'FAILED';
        if (asString.contains('CANCELLED')) return 'CANCELLED';
      }
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, {Icon? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFF4B5563),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildMethodCards() {
    final methods = [
      {
        'mode': CodeDropMode.modal,
        'title': 'Modal',
        'subtitle': 'Opens a focus dialog above the page',
        'icon': Icons.open_in_new,
        'color': const Color(0xFF3B82F6),
        'gradient': const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'mode': CodeDropMode.drawer,
        'title': 'Drawer',
        'subtitle': 'Slides in from the side without leaving the page',
        'icon': Icons.view_sidebar,
        'color': const Color(0xFF10B981),
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'mode': CodeDropMode.inline,
        'title': 'Inline',
        'subtitle': 'Embeds the payment form directly in the page layout',
        'icon': Icons.web,
        'color': const Color(0xFFF59E0B),
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Payment Method',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you want to display the payment form.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: methods.map((method) {
            final isSelected = _mode == method['mode'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mode = method['mode'] as CodeDropMode;
                      // Reset inline flag when switching modes
                      _inlineLaunched = (_mode == CodeDropMode.inline) ? _inlineLaunched : false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${method['title']}')),
                    );
                    if (method['mode'] == CodeDropMode.inline) {
                      _autoLaunchInline(context);
    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? method['gradient'] as LinearGradient
                        : LinearGradient(
                            colors: [Colors.grey.shade50, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                        ? Border.all(
                            color: method['color'] as Color,
                            width: 2,
                          )
                        : Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                      boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (method['color'] as Color).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? Colors.white.withOpacity(0.2)
                              : (method['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            size: 32,
                            color: isSelected 
                              ? Colors.white 
                              : method['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          method['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                              ? Colors.white 
                              : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isSelected 
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _amountCtrl,
                decoration: _inputDecoration('Amount', prefixIcon: const Icon(Icons.attach_money)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _currencyCtrl,
                decoration: _inputDecoration('Currency', prefixIcon: const Icon(Icons.currency_exchange)),
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          decoration: _inputDecoration('Email', prefixIcon: const Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        if (_mode == CodeDropMode.inline) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _inlineWidthCtrl,
            decoration: _inputDecoration('Width (350-450px)', prefixIcon: const Icon(Icons.aspect_ratio)),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
        const SizedBox(height: 24),
        if (_mode != CodeDropMode.inline)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => handlePayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                'Launch Payment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final padding = isLargeScreen ? 24.0 : 16.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: SharedAppBar(
        title: 'PayGlocal Codedrop',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  // Method Selection Cards
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: _buildMethodCards(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Form
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: _buildPaymentForm(),
                    ),
                  ),
                  
                  // Inline Payment Container
                  if (_mode == CodeDropMode.inline) ...[
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Payment Form',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                height: 600,
                                child: HtmlElementView(viewType: _inlineViewType),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                     final amount = _amountCtrl.text.trim().isEmpty ? '1000.00' : _amountCtrl.text.trim();
                                     final currency = _currencyCtrl.text.trim().isEmpty ? 'INR' : _currencyCtrl.text.trim();
                                     final email = _emailCtrl.text.trim().isEmpty ? 'customer@example.com' : _emailCtrl.text.trim();
                                     final merchantPayload = {
                                       'paymentData': {
                                         'totalAmount': amount,
                                         'txnCurrency': currency,
                                       },
                                       'billingData': {
                                         'emailId': email,
                                       },
                                     };
                                     try { pgpayUpdateDetails(merchantPayload); } catch (_) {}
                                     try { pgpayModifyPayment(merchantPayload); } catch (_) {}
                                     try {
                                       final proxy = html.document.getElementById('pgpay_paynow_proxy') as html.ButtonElement?;
                                       proxy?.click();
                                     } catch (e) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(content: Text('Unable to submit inline payment: $e')),
                                       );
                                     }
                                      },
                                    icon: const Icon(Icons.payment),
                                    label: const Text('Pay Now'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pollStatusAndNavigate(BuildContext context, String gid) async {
    if (gid.isEmpty) {
      _handleStatusAndNavigate(context, null);
      return;
    }
    const attempts = 6;
    const delayMs = 1500;
    for (int i = 0; i < attempts; i++) {
      try {
        final resp = await http.get(Uri.parse('http://localhost:3000/api/codedrop/status?gid=$gid'));
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          final txStatus = (body['transactionStatus'] ?? '').toString().toUpperCase();
          if (txStatus.isNotEmpty) {
            if (txStatus == 'CAPTURED' || txStatus == 'SUCCESS' || txStatus == 'SENT_FOR_CAPTURE' || txStatus == 'APPROVED') {
              if (!mounted) return;
              _handleStatusAndNavigate(context, 'SUCCESS');
              return;
            }
            if (txStatus == 'FAILED' || txStatus == 'CANCELLED' || txStatus == 'DECLINED') {
              if (!mounted) return;
              _handleStatusAndNavigate(context, 'FAILED');
              return;
            }
          }
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
    if (!mounted) return;
    _handleStatusAndNavigate(context, null);
  }
}

