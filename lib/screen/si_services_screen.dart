import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SiServicesScreen extends StatefulWidget {
  const SiServicesScreen({super.key});

  @override
  State<SiServicesScreen> createState() => _SiServicesScreenState();
}

class _SiServicesScreenState extends State<SiServicesScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _deductionKey = GlobalKey();
  final GlobalKey _mandateKey = GlobalKey();
  final GlobalKey _statusKey = GlobalKey();
  bool _hoverDeduction = false;
  bool _hoverMandate = false;
  bool _hoverStatus = false;

  Widget _header(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF7C2D12),
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _sub(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _mono(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SelectableText(
        content,
        style: GoogleFonts.robotoMono(fontSize: 13, color: const Color(0xFF111827), height: 1.4),
      ),
    );
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
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
    const epInitiatePaycollect = 'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect';
    const epSiSale = 'https://api.uat.payglocal.in/gl/v1/payments/si/sale';
    const epSiModify = 'https://api.uat.payglocal.in/gl/v1/payments/si/modify';
    const epSiStatus = 'https://api.uat.payglocal.in/gl/v1/payments/si/status';

    // Payloads from frontend/service screen/index.js (authoritative)
    const siFixedPayload = '{\n  "merchantTxnId": "<merchantTxnId>",\n  "paymentData": {\n    "totalAmount": "<amount>",\n    "txnCurrency": "INR"\n  },\n  "standingInstruction": {\n    "data": {\n      "amount": "<fixedAmount>",\n      "numberOfPayments": "<count>",\n      "frequency": "MONTHLY",\n      "type": "FIXED",\n      "startDate": "YYYYMMDD"\n    }\n  },\n  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"\n}';

    const siVariablePayload = '{\n  "merchantTxnId": "<merchantTxnId>",\n  "paymentData": {\n    "totalAmount": "<amount>",\n    "txnCurrency": "INR"\n  },\n  "standingInstruction": {\n    "data": {\n      "maxAmount": "<maxAmount>",\n      "numberOfPayments": "<count>",\n      "frequency": "ONDEMAND",\n      "type": "VARIABLE"\n    }\n  },\n  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"\n}';

    const siOnDemandVariablePayload = '{\n  "merchantTxnId": "SI_ON_DEMAND_<ts>",\n  "paymentData": { "totalAmount": "<amount>" },\n  "standingInstruction": { "mandateId": "<mandateId>" }\n}';

    const siOnDemandFixedPayload = '{\n  "merchantTxnId": "SI_ON_DEMAND_<ts>",\n  "standingInstruction": { "mandateId": "<mandateId>" }\n}';

    const activatePayload = '{\n  "merchantTxnId": "ACTIVATE_SI_<ts>",\n  "standingInstruction": {\n    "action": "ACTIVATE",\n    "mandateId": "<mandateId>"\n  }\n}';

    const pauseNowPayload = '{\n  "merchantTxnId": "PAUSE_SI_<ts>",\n  "standingInstruction": {\n    "action": "PAUSE",\n    "mandateId": "<mandateId>"\n  }\n}';

    const pauseByDatePayload = '{\n  "merchantTxnId": "PAUSE_SI_<ts>",\n  "standingInstruction": {\n    "action": "PAUSE",\n    "mandateId": "<mandateId>",\n    "data": { "startDate": "YYYYMMDD" }\n  }\n}';

    const siStatusCheckPayload = '{\n  "standingInstruction": { "mandateId": "<mandateId>" }\n}';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        title: const Text('SI Services'),
        backgroundColor: const Color(0xFFFFA500),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top nav cards
                  Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverDeduction = true),
                          onExit: (_) => setState(() => _hoverDeduction = false),
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () => _scrollTo(_deductionKey),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              transform: Matrix4.identity()..translate(0.0, _hoverDeduction ? -2.0 : 0.0),
                              height: 110,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA500).withOpacity(_hoverDeduction ? 0.18 : 0.12),
                                    blurRadius: _hoverDeduction ? 14 : 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFFFA500)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SI Amount Deduction Method', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF7C2D12))),
                                  const SizedBox(height: 6),
                                  Text('Fixed & Variable (auto-debit / on-demand)', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverMandate = true),
                          onExit: (_) => setState(() => _hoverMandate = false),
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () => _scrollTo(_mandateKey),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              transform: Matrix4.identity()..translate(0.0, _hoverMandate ? -2.0 : 0.0),
                              height: 110,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA500).withOpacity(_hoverMandate ? 0.18 : 0.12),
                                    blurRadius: _hoverMandate ? 14 : 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFFFA500)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SI Mandate Update', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF7C2D12))),
                                  const SizedBox(height: 6),
                                  Text('Activate, Pause (by date/now), Status', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoverStatus = true),
                          onExit: (_) => setState(() => _hoverStatus = false),
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () => _scrollTo(_statusKey),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              transform: Matrix4.identity()..translate(0.0, _hoverStatus ? -2.0 : 0.0),
                              height: 110,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA500).withOpacity(_hoverStatus ? 0.18 : 0.12),
                                    blurRadius: _hoverStatus ? 14 : 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFFFA500)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SI Mandate Status Check', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF7C2D12))),
                                  const SizedBox(height: 6),
                                  Text('Check current state of mandates', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF4B5563)))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Deduction section with clear separation
                  Container(
                    key: _deductionKey,
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFEDD5),
                          const Color(0xFFFFFBF2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD199), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header('SI Amount Deduction Method'),
                        const SizedBox(height: 8),
                        Text(
                          'Understand how monthly deductions are set up and executed under Fixed and Variable styles.',
                          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151)),
                        ),
                        const SizedBox(height: 16),

                        // Fixed card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE0B3)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _chip('Fixed', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Auto-debit same amount every cycle', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4B5563))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _sub('UAT Initiate Endpoint'),
                              const SizedBox(height: 6),
                              _mono(context, epInitiatePaycollect),
                              const SizedBox(height: 8),
                              _sub('Payload'),
                              const SizedBox(height: 6),
                              _mono(context, siFixedPayload),
                              const SizedBox(height: 12),
                              Row(children: [ _chip('On-Demand (Fixed)', const Color(0xFFFFF7ED), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 8),
                              _sub('UAT On-Demand Endpoint'),
                              const SizedBox(height: 6),
                              _mono(context, epSiSale),
                              const SizedBox(height: 8),
                              _sub('On-Demand Payload (Fixed Mandate — no amount in payload)'),
                              const SizedBox(height: 6),
                              _mono(context, siOnDemandFixedPayload),
                              const SizedBox(height: 8),
                              _sub('Notes'),
                              const SizedBox(height: 6),
                              _mono(context, '- Provide startDate for the first cycle.\n- amount is mandatory for Fixed initiation; do not send maxAmount.\n- For On-Demand (Fixed), amount is not included in payload (fixed plan handles amount).'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Variable card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE0B3)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _chip('Variable', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Auto-debit up to maxAmount + supports on-demand charges', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4B5563))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [ _chip('Auto-Debit (Variable)', const Color(0xFFFFF7ED), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 8),
                              _sub('UAT Initiate Endpoint'),
                              const SizedBox(height: 6),
                              _mono(context, epInitiatePaycollect),
                              const SizedBox(height: 8),
                              _sub('Payload (Initiate Variable SI)'),
                              const SizedBox(height: 6),
                              _mono(context, siVariablePayload),
                              const SizedBox(height: 12),
                              Row(children: [ _chip('On-Demand (Variable)', const Color(0xFFFFF7ED), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 8),
                              _sub('UAT On-Demand Endpoint'),
                              const SizedBox(height: 6),
                              _mono(context, epSiSale),
                              const SizedBox(height: 8),
                              _sub('On-Demand Payload (Variable Mandate — amount included)'),
                              const SizedBox(height: 6),
                              _mono(context, siOnDemandVariablePayload),
                              const SizedBox(height: 8),
                              _sub('Notes'),
                              const SizedBox(height: 6),
                              _mono(context, '- Do not send startDate for Variable initiation.\n- Auto-debit uses actual bill up to maxAmount.\n- On-Demand requires amount in payload and a valid mandateId.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mandate section
                  Container(
                    key: _mandateKey,
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header('SI Mandate Update'),
                        const SizedBox(height: 8),
                        Text('Lifecycle operations for mandates: Activation, Pause (by date / now), and Status.', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151))),
                        const SizedBox(height: 16),

                        // Activate
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [ _chip('Activate', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 12),
                              _sub('UAT Endpoint (PUT)'),
                              const SizedBox(height: 6),
                              _mono(context, epSiStatus),
                              const SizedBox(height: 8),
                              _sub('Payload'),
                              const SizedBox(height: 6),
                              _mono(context, activatePayload),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pause now
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [ _chip('Pause Now', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 12),
                              _sub('UAT Endpoint (POST)'),
                              const SizedBox(height: 6),
                              _mono(context, epSiModify),
                              const SizedBox(height: 8),
                              _sub('Payload'),
                              const SizedBox(height: 6),
                              _mono(context, pauseNowPayload),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pause by date
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [ _chip('Pause By Date', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 12),
                              _sub('UAT Endpoint (POST)'),
                              const SizedBox(height: 6),
                              _mono(context, epSiModify),
                              const SizedBox(height: 8),
                              _sub('Payload'),
                              const SizedBox(height: 6),
                              _mono(context, pauseByDatePayload),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Status
                        Container(
                          key: _statusKey,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [ _chip('Status', const Color(0xFFFFEDD5), const Color(0xFF7C2D12)) ]),
                              const SizedBox(height: 12),
                              _sub('UAT Endpoint (POST)'),
                              const SizedBox(height: 6),
                              _mono(context, epSiStatus),
                              const SizedBox(height: 8),
                              _sub('Payload'),
                              const SizedBox(height: 6),
                              _mono(context, siStatusCheckPayload),
                              const SizedBox(height: 8),
                              _sub('Notes'),
                              const SizedBox(height: 6),
                              _mono(context, '- Expect status, message, mandateId, and transactionStatus on success.\n- Errors: missing mandateId, invalid field placement, or invalid action.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 