import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_card.dart';
import '../theme/app_theme.dart';

class VisualizationScreen extends StatefulWidget {
  final int? initialStep;
  const VisualizationScreen({super.key, this.initialStep});

  @override
  _VisualizationScreenState createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  int _selectedStep = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialStep != null) {
      _selectedStep = widget.initialStep!.clamp(0, 3);
    }
  }

  @override
  void dispose() {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
      appBar: const PremiumAppBar(
        title: 'PayGlocal Encryption Flow',
      ),
      body: SingleChildScrollView(
          controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Center(
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildOverviewSection(isDark),
                  const SizedBox(height: AppTheme.spacing32),
                _buildStepTabs(isDark),
                const SizedBox(height: AppTheme.spacing24),
                _buildStepContent(isDark),
                  const SizedBox(height: AppTheme.spacing32),
                _buildFlowDiagram(isDark),
                const SizedBox(height: AppTheme.spacing24),
                ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(bool isDark) {
    return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                child: const Icon(Icons.security, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                  'How PayGlocal SDK Encrypts Data',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing20),
              Text(
            'The SDK uses a 4-step process to secure your payment data before sending it to PayGlocal:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6,
                ),
              ),
          const SizedBox(height: AppTheme.spacing16),
          _buildInfoChip('JWE', 'Encrypts payload with RSA-OAEP-256 + AES-128-CBC-HS256', isDark ? AppTheme.darkSIPausePurple : AppTheme.accent, isDark),
          const SizedBox(height: 8),
          _buildInfoChip('JWS', 'Signs encrypted data with RS256 (RSA + SHA-256)', isDark ? AppTheme.darkCodedropTeal : AppTheme.info, isDark),
          const SizedBox(height: 8),
          _buildInfoChip('Headers', 'JWS goes in x-gl-token-external, JWE in body', isDark ? AppTheme.darkSuccessEmerald : AppTheme.success, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String title, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTabs(bool isDark) {
    final steps = [
      {'title': 'Step 1', 'subtitle': 'Create JWE'},
      {'title': 'Step 2', 'subtitle': 'Create JWS'},
      {'title': 'Step 3', 'subtitle': 'Build Headers'},
      {'title': 'Step 4', 'subtitle': 'Send Request'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          steps.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedStep = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: _selectedStep == index
                      ? LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                        )
                      : null,
                  color: _selectedStep == index
                      ? null
                      : (isDark ? AppTheme.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedStep == index
                        ? Colors.transparent
                        : AppTheme.borderMedium,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index]['title'] as String,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _selectedStep == index
                            ? Colors.white
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index]['subtitle'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedStep == index
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
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

  Widget _buildStepContent(bool isDark) {
    switch (_selectedStep) {
      case 0:
        return _buildStep1Content(isDark);
      case 1:
        return _buildStep2Content(isDark);
      case 2:
        return _buildStep3Content(isDark);
      case 3:
        return _buildStep4Content(isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Content(bool isDark) {
    const code = '''// Step 1: Generate JWE (JSON Web Encryption)
const jose = require('jose');

async function generateJWE(payload, config) {
  // 1. Create timestamps (milliseconds)
  const iat = Date.now();
  const exp = iat + 300000; // 5 minutes expiry
  
  // 2. Import PayGlocal public key
  const publicKey = await jose.importSPKI(
    config.payglocalPublicKey, 
    'RSA-OAEP-256'
  );
  
  // 3. Stringify payload
  const payloadStr = JSON.stringify(payload);
  
  // 4. Create JWE using jose library
  // This internally:
  //   - Generates random CEK (Content Encryption Key)
  //   - Encrypts payload with AES-128-CBC-HS256
  //   - Encrypts CEK with RSA-OAEP-256
  //   - Assembles 5-part token
  const jwe = await new jose.CompactEncrypt(
    new TextEncoder().encode(payloadStr)
  )
    .setProtectedHeader({
      alg: 'RSA-OAEP-256',    // CEK encryption
      enc: 'A128CBC-HS256',    // Payload encryption
      iat: iat.toString(),
      exp: exp.toString(),
      kid: config.publicKeyId,
      'issued-by': config.merchantId,
    })
    .encrypt(publicKey);
  
  return jwe; // Returns: header.encryptedKey.iv.ciphertext.tag
}''';

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Step 1: Generate JWE', 'Encrypt payload using jose library', isDark ? AppTheme.darkSIPausePurple : AppTheme.accent, isDark),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            'What happens:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Algorithm', 'RSA-OAEP-256 for CEK, AES-128-CBC-HS256 for payload', isDark),
          _buildDetailRow('Input', 'Payload JSON + PayGlocal public key', isDark),
          _buildDetailRow('Output', '5-part JWE token (base64url encoded)', isDark),
          _buildDetailRow('Format', 'header.encryptedKey.iv.ciphertext.tag', isDark),
          const SizedBox(height: AppTheme.spacing20),
          _buildCodeBlock(code, 'JavaScript', isDark),
          const SizedBox(height: AppTheme.spacing16),
          _buildNote(
            'The jose library handles CEK generation, AES encryption, RSA wrapping, and token assembly automatically.',
            isDark ? AppTheme.darkJwtBlue : AppTheme.info,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Content(bool isDark) {
    const code = '''// Step 2: Generate JWS (JSON Web Signature)
const crypto = require('crypto');
const jose = require('jose');

async function generateJWS(jwe, config) {
  // 1. Create timestamps
  const iat = Date.now();
  const exp = iat + 300000;
  
  // 2. Hash the JWE with SHA-256
  const digest = crypto
    .createHash('sha256')
    .update(jwe)
    .digest('base64');
  
  // 3. Create JWS payload
  const jwsPayload = {
    digest: digest,
    digestAlgorithm: 'SHA-256',
    exp: exp,
    iat: iat.toString(),
  };
  
  // 4. Import merchant private key
  const privateKey = await jose.importPKCS8(
    config.merchantPrivateKey, 
    'RS256'
  );
  
  // 5. Sign the payload
  const jws = await new jose.SignJWT(jwsPayload)
    .setProtectedHeader({
      'issued-by': config.merchantId,
      alg: 'RS256',
      kid: config.privateKeyId,
      'x-gl-merchantId': config.merchantId,
      'x-gl-enc': 'true',
      'is-digested': 'true',
    })
    .sign(privateKey);
  
  return jws; // Returns: header.payload.signature
}''';

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Step 2: Generate JWS', 'Sign JWE with merchant private key', isDark ? AppTheme.darkCodedropTeal : AppTheme.info, isDark),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            'What happens:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Algorithm', 'RS256 (RSA + SHA-256)', isDark),
          _buildDetailRow('Input', 'JWE token + Merchant private key', isDark),
          _buildDetailRow('Process', 'SHA-256 hash of JWE → Sign with RSA', isDark),
          _buildDetailRow('Output', '3-part JWS token (header.payload.signature)', isDark),
          const SizedBox(height: AppTheme.spacing20),
          _buildCodeBlock(code, 'JavaScript', isDark),
          const SizedBox(height: AppTheme.spacing16),
          _buildNote(
            'JWS proves authenticity. PayGlocal verifies signature using your public key to ensure data hasn\'t been tampered with.',
            isDark ? AppTheme.darkWarningOrange : AppTheme.warning,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Content(bool isDark) {
    const code = '''// Step 3: Build HTTP Headers
function buildJwtHeaders(jws) {
  return {
    'Content-Type': 'text/plain',
    'x-gl-token-external': jws,  // JWS goes here!
  };
}

// Usage in SDK:
const { jwe, jws } = await generateTokens(params, config);
const headers = buildJwtHeaders(jws);
const requestData = jwe;  // JWE goes in body

// Final request structure:
// POST /gl/v1/payments/initiate/paycollect
// Headers:
//   Content-Type: text/plain
//   x-gl-token-external: <JWS_TOKEN>
// Body: <JWE_TOKEN>''';

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Step 3: Build Headers', 'Prepare request headers and body', isDark ? AppTheme.darkSuccessEmerald : AppTheme.success, isDark),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            'Critical points:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Content-Type', 'Must be text/plain (not application/json)', isDark),
          _buildDetailRow('x-gl-token-external', 'Contains the JWS token', isDark),
          _buildDetailRow('Request Body', 'Contains the raw JWE token (no JSON wrapper)', isDark),
          _buildDetailRow('x-gl-merchantId', 'Not needed (already in JWS header)', isDark),
          const SizedBox(height: AppTheme.spacing20),
          _buildCodeBlock(code, 'JavaScript', isDark),
          const SizedBox(height: AppTheme.spacing16),
          _buildNote(
            'Common mistake: Sending {"data": JWE, "signature": JWS} as JSON. This causes GL-400-001 auth errors.',
            isDark ? AppTheme.darkErrorCoral : AppTheme.error,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Content(bool isDark) {
    const code = '''// Step 4: Send HTTP Request
async function makeRequest(url, jwe, jws) {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'text/plain',
      'x-gl-token-external': jws,
      'pg-sdk-version': 'PayGlocal-SDK/1.0.3',
    },
    body: jwe,  // Raw JWE string, not JSON!
  });
  
  return await response.json();
}

// Complete flow:
const payload = {
  merchantTxnId: "1729704385000555888",
  paymentData: {
    totalAmount: "5000",
    txnCurrency: "INR"
  },
  merchantCallbackURL: "https://example.com/callback"
};

const { jwe, jws } = await generateTokens(payload, config);
const response = await makeRequest(
  'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect',
  jwe,
  jws
);''';

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Step 4: Send Request', 'Make HTTP POST to PayGlocal', isDark ? AppTheme.darkWarningOrange : AppTheme.warning, isDark),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            'Request structure:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
          _buildDetailRow('Method', 'POST', isDark),
          _buildDetailRow('Endpoint', '/gl/v1/payments/initiate/paycollect', isDark),
          _buildDetailRow('Headers', 'Content-Type: text/plain, x-gl-token-external: JWS', isDark),
          _buildDetailRow('Body', 'Raw JWE string (not JSON)', isDark),
          const SizedBox(height: AppTheme.spacing20),
          _buildCodeBlock(code, 'JavaScript', isDark),
          const SizedBox(height: AppTheme.spacing16),
          _buildNote(
            'PayGlocal receives the request, verifies JWS signature, decrypts JWE, and processes payment.',
            isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.play_arrow, color: color, size: 24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code, String language, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.cyanAccent,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyToClipboard(code, 'Code'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 12, color: Colors.cyanAccent),
                        const SizedBox(width: 5),
                        Text(
                          'Copy',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: SelectableText(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.greenAccent,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
            child: Row(
              children: [
          Icon(Icons.info_outline, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
              text,
                    style: GoogleFonts.poppins(
                fontSize: 12,
                      fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFlowDiagram(bool isDark) {
    return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
            'Complete Flow',
                    style: GoogleFonts.poppins(
              fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
          const SizedBox(height: AppTheme.spacing20),
          _buildFlowStep('1', 'Payload JSON', 'Payment data', isDark ? AppTheme.darkSIPausePurple : AppTheme.accent, isDark),
          _buildArrow(isDark),
          _buildFlowStep('2', 'Generate JWE', 'jose.CompactEncrypt → RSA-OAEP-256 + AES-128-CBC-HS256', isDark ? AppTheme.darkJwtBlue : AppTheme.info, isDark),
          _buildArrow(isDark),
          _buildFlowStep('3', 'Generate JWS', 'SHA-256 hash of JWE → Sign with RS256', isDark ? AppTheme.darkCodedropTeal : AppTheme.info, isDark),
          _buildArrow(isDark),
          _buildFlowStep('4', 'Build Request', 'Headers: x-gl-token-external=JWS, Body: JWE', isDark ? AppTheme.darkSuccessEmerald : AppTheme.success, isDark),
          _buildArrow(isDark),
          _buildFlowStep('5', 'Send to PayGlocal', 'POST /gl/v1/payments/initiate/paycollect', isDark ? AppTheme.darkWarningOrange : AppTheme.warning, isDark),
          const SizedBox(height: AppTheme.spacing16),
              Container(
            padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: isDark 
                  ? [AppTheme.darkSuccessEmerald.withOpacity(0.15), AppTheme.darkCodedropTeal.withOpacity(0.15)]
                  : [AppTheme.success.withOpacity(0.15), AppTheme.info.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
                width: 2,
              ),
                ),
                child: Row(
                  children: [
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppTheme.darkSuccessEmerald : AppTheme.success,
                  size: 28,
                ),
                const SizedBox(width: 12),
                    Expanded(
                  child: Text(
                    'PayGlocal receives, verifies signature, decrypts JWE, and processes payment',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFlowStep(String number, String title, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isDark
                ? LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.2)])
                : LinearGradient(colors: [color, color.withOpacity(0.7)]),
              shape: BoxShape.circle,
              border: isDark ? Border.all(color: color.withOpacity(0.4)) : null,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? color : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Icon(
                    Icons.arrow_downward,
                    color: AppTheme.accent,
          size: 20,
        ),
      ),
    );
  }
}
