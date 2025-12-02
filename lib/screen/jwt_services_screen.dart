import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_app_bar.dart';

class JwtServicesScreen extends StatelessWidget {
  const JwtServicesScreen({super.key});

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _subTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _monoBox(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SelectableText(
        content,
        style: GoogleFonts.robotoMono(fontSize: 13, color: const Color(0xFF111827), height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final padding = isLargeScreen ? 24.0 : 16.0;

    // UAT endpoints (SDK → PayGlocal)
    final uatStatusEndpoint = 'https://api.uat.payglocal.in/gl/v1/payments/<gid>/status';
    final uatRefundEndpoint = 'https://api.uat.payglocal.in/gl/v1/payments/<gid>/refund';

    // Payloads (from our frontend/backend shapes for context)
    final refundFullPayload = '{\n  "gid": "<gid>",\n  "refundType": "F",\n }';
    final refundPartialPayload = '{\n  "gid": "<gid>",\n  "refundType": "P",\n  "paymentData": { "totalAmount": "<amount>" }\n}';

    // UAT curl examples (SDK usage)
    final curlStatusUat = 'curl -X GET "$uatStatusEndpoint" -H "x-gl-token-external: <JWS>"';
    final curlRefundUat = 'curl -X POST "$uatRefundEndpoint" \\\n  -H "Content-Type: text/plain" \\\n  -H "x-gl-token-external: <JWS>" \\\n  --data-raw "<JWE>"';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const SharedAppBar(title: 'JWT Services'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.06),
                      const Color(0xFF1E40AF).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF93C5FD), width: 1),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JWT Payment Services',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 28 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For JWT authentication, two key services are available: Status Check and Refund. Below are UAT endpoints (from SDK) and example payloads, with guidance on how to call them using JWE/JWS.',
                      style: GoogleFonts.poppins(fontSize: isLargeScreen ? 16 : 14, color: const Color(0xFF1F3B8A)),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('1) Status Check'),
                    const SizedBox(height: 8),
                    Text(
                      'Purpose: Retrieve the current payment status by its Global ID (gid).',
                      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    _subTitle('UAT Endpoint (SDK → PayGlocal)'),
                    const SizedBox(height: 6),
                    _monoBox(context, uatStatusEndpoint),
                    const SizedBox(height: 12),
                    _subTitle('UAT Example'),
                    const SizedBox(height: 6),
                    _monoBox(context, curlStatusUat),

                    const SizedBox(height: 24),
                    _sectionTitle('2) Refund'),
                    const SizedBox(height: 8),
                    Text(
                      'Purpose: Refund a payment fully or partially. Partial refunds require an amount.',
                      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    _subTitle('UAT Endpoint (SDK → PayGlocal)'),
                    const SizedBox(height: 6),
                    _monoBox(context, uatRefundEndpoint),
                    const SizedBox(height: 12),
                    _subTitle('Payloads (from this frontend)'),
                    const SizedBox(height: 6),
                    _monoBox(context, refundFullPayload),
                    const SizedBox(height: 6),
                    _monoBox(context, refundPartialPayload),
                    const SizedBox(height: 12),
                    _subTitle('UAT Example'),
                    const SizedBox(height: 6),
                    _monoBox(context, curlRefundUat),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 