import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthServicesScreen extends StatefulWidget {
  const AuthServicesScreen({super.key});

  @override
  State<AuthServicesScreen> createState() => _AuthServicesScreenState();
}

class _AuthServicesScreenState extends State<AuthServicesScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _authKey = GlobalKey();
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey _reversalKey = GlobalKey();
  bool _hAuth = false, _hCap = false, _hRev = false;

  Widget _header(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF065F46),
        ),
      );
  Widget _title(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF111827)));
  Widget _sub(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151)));
  Widget _mono(BuildContext context, String content) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: SelectableText(content, style: GoogleFonts.robotoMono(fontSize: 13, color: const Color(0xFF111827), height: 1.4)),
      );

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.05);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 900;
    final pad = isLarge ? 24.0 : 16.0;

    // Full UAT endpoints from SDK
    const epAuth = 'https://api.uat.payglocal.in/gl/v1/payments/auth';
    const epCapture = 'https://api.uat.payglocal.in/gl/v1/payments/<gid>/capture';
    const epAuthReversal = 'https://api.uat.payglocal.in/gl/v1/payments/<gid>/auth-reversal';
    const epTxnStatus = 'https://api.uat.payglocal.in/gl/v1/payments/<gid>/status';

    // Payloads from frontend
    const authPayload = '{\n  "merchantTxnId": "<merchantTxnId>",\n  "paymentData": {\n    "totalAmount": "<amount>",\n    "txnCurrency": "INR"\n  },\n  "captureTxn": false,\n  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"\n}';

    const captureFullPayload = '{\n  "gid": "<gid>",\n  "merchantTxnId": "<merchantTxnId>",\n  "captureType": "F"\n}';

    const capturePartialPayload = '{\n  "gid": "<gid>",\n  "merchantTxnId": "<merchantTxnId>",\n  "captureType": "P",\n  "paymentData": { "totalAmount": "<amount>" }\n}';

    const authReversalPayload = '{\n  "gid": "<gid>",\n  "merchantTxnId": "<merchantTxnId>"\n}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFEF5),
      appBar: AppBar(title: const Text('Auth & Capture Services'), backgroundColor: const Color(0xFF065F46), foregroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Top nav cards (green theme)
                Row(children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hAuth = true),
                      onExit: (_) => setState(() => _hAuth = false),
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => _scrollTo(_authKey),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          transform: Matrix4.identity()..translate(0.0, _hAuth ? -2.0 : 0.0),
                          height: 110,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981).withOpacity(_hAuth ? 0.18 : 0.12), blurRadius: _hAuth ? 14 : 10, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Initiate Auth', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF065F46))),
                            const SizedBox(height: 6),
                            Text('Reserve funds (no charge)', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hCap = true),
                      onExit: (_) => setState(() => _hCap = false),
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => _scrollTo(_captureKey),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          transform: Matrix4.identity()..translate(0.0, _hCap ? -2.0 : 0.0),
                          height: 110,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981).withOpacity(_hCap ? 0.18 : 0.12), blurRadius: _hCap ? 14 : 10, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Capture', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF065F46))),
                            const SizedBox(height: 6),
                            Text('Charge a prior authorization', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hRev = true),
                      onExit: (_) => setState(() => _hRev = false),
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => _scrollTo(_reversalKey),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          transform: Matrix4.identity()..translate(0.0, _hRev ? -2.0 : 0.0),
                          height: 110,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981).withOpacity(_hRev ? 0.18 : 0.12), blurRadius: _hRev ? 14 : 10, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Auth Reversal', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF065F46))),
                            const SizedBox(height: 6),
                            Text('Release held funds', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                          ]),
                        ),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Initiate Auth section (green accent)
                Container(
                  key: _authKey,
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [const Color(0xFFECFDF5), const Color(0xFFFAFEF5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _header('Initiate Authorization'),
                    const SizedBox(height: 8),
                    Text('Authorization (auth) reserves funds without charging. Useful to verify availability while you fulfill the order.', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151))),
                    const SizedBox(height: 12),
                    _sub('UAT Endpoint'),
                    const SizedBox(height: 6),
                    _mono(context, epAuth),
                    const SizedBox(height: 8),
                    _sub('Payload'),
                    const SizedBox(height: 6),
                    _mono(context, authPayload),
                    const SizedBox(height: 8),
                    _sub('Status Check (UAT)'),
                    const SizedBox(height: 6),
                    _mono(context, epTxnStatus),
                  ]),
                ),

                const SizedBox(height: 24),

                // Capture section
                Container(
                  key: _captureKey,
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _header('Capture'),
                    const SizedBox(height: 8),
                    Text('Capture charges the reserved amount from a prior authorization. Can be full or partial.', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151))),
                    const SizedBox(height: 12),
                    _sub('UAT Endpoint'),
                    const SizedBox(height: 6),
                    _mono(context, epCapture),
                    const SizedBox(height: 8),
                    _sub('Full Capture Payload'),
                    const SizedBox(height: 6),
                    _mono(context, captureFullPayload),
                    const SizedBox(height: 8),
                    _sub('Partial Capture Payload'),
                    const SizedBox(height: 6),
                    _mono(context, capturePartialPayload),
                  ]),
                ),

                const SizedBox(height: 24),

                // Auth Reversal section
                Container(
                  key: _reversalKey,
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _header('Authorization Reversal'),
                    const SizedBox(height: 8),
                    Text('Auth reversal releases previously reserved funds when no capture is needed.', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151))),
                    const SizedBox(height: 12),
                    _sub('UAT Endpoint'),
                    const SizedBox(height: 6),
                    _mono(context, epAuthReversal),
                    const SizedBox(height: 8),
                    _sub('Payload'),
                    const SizedBox(height: 6),
                    _mono(context, authReversalPayload),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
} 