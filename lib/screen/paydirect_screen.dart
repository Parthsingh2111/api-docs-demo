import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/shared_app_bar.dart';
import '../theme/app_theme.dart';

class PayDirectScreen extends StatefulWidget {
  const PayDirectScreen({super.key});

  @override
  _PayDirectScreenState createState() => _PayDirectScreenState();
}

class _PayDirectScreenState extends State<PayDirectScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _appBarFadeController;
  late Animation<double> _appBarFadeAnimation;
  late AnimationController _decorationAnimationController;
  late Animation<double> _decorationAnimation;
  int _animationCycles = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _faqKey = GlobalKey();
  bool _showFAQ = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.bounceInOut, // Changed from easeIn
    );
    _appBarFadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _appBarFadeAnimation = CurvedAnimation(
      parent: _appBarFadeController,
      curve: Curves.bounceInOut, // Changed from easeIn
    );
    _decorationAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _decorationAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _decorationAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _decorationAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationCycles++;
        if (_animationCycles < 2) {
          _decorationAnimationController.reverse();
        } else {
          _decorationAnimationController.stop();
        }
      } else if (status == AnimationStatus.dismissed && _animationCycles < 2) {
        _decorationAnimationController.forward();
      }
    });
    _decorationAnimationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 600 && !_showFAQ) {
        setState(() {
          _showFAQ = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _appBarFadeController.dispose();
    _decorationAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFAQ() {
    setState(() {
      _showFAQ = true;
    });
    final context = _faqKey.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy +
          _scrollController.offset -
          MediaQuery.of(context).padding.top -
          70;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final titleFontSize = isLargeScreen ? 28.0 : 22.0;
    final subtitleFontSize = isLargeScreen ? 16.0 : 14.0;
    final overlayPadding = isLargeScreen ? 16.0 : 12.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
      appBar: SharedAppBar(
        title: 'PayDirect Payment Methods',
        fadeAnimation: _appBarFadeAnimation,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: EdgeInsets.all(overlayPadding),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark ? [
                                      AppTheme.darkSuccessEmerald.withOpacity(0.08),
                                      AppTheme.darkJwtBlue.withOpacity(0.05),
                                    ] : [
                                      const Color(0xFF3B82F6).withOpacity(0.05),
                                      const Color(0xFFE5E7EB).withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: WavePainter(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (isDark ? AppTheme.darkSuccessEmerald : AppTheme.success).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.payment,
                                        size: 24,
                                        color: isDark ? AppTheme.darkSuccessEmeraldLight : const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'PayDirect Payment Solutions',
                                        style: GoogleFonts.poppins(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppTheme.darkSuccessEmeraldLight : const Color(0xFF1E3A8A),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Secure and fast direct payment methods for PCI DSS compliant merchants who collect card details on their own interface.',
                                  style: GoogleFonts.poppins(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF4B5563),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _scrollToFAQ,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        elevation: 2,
                                      ),
                                      child: Text(
                                        'FAQ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isLargeScreen)
                                      OutlinedButton(
                                        onPressed: () {
                                          try {
                                            Navigator.pushNamed(context, '/contact');
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Contact route not found'),
                                              ),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.success,
                                          side: BorderSide(color: AppTheme.success),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          'Contact Us',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: constraints.maxWidth > 800 ? 3 : 1,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.9,
                        children: [
                          _PaymentMethodCard(
                            title: 'JWT PayDirect',
                            description: 'Direct payment initiation using JWT for seamless transactions.',
                            details: '''
**JWT PayDirect Overview**  
JWT-based authentication enables fast and secure direct payment initiation for PayDirect APIs. It uses asymmetric and symmetric keys (JWE/JWS) for robust security, perfect for merchants seeking seamless payment processing. Contact our integration team for SDK support.  

**Key Features:**  
- Utilizes JWE/JWS encryption for secure direct payments.  
- Streamlined for PayDirect API integrations.  
- Ensures data integrity, non-repudiation, and confidentiality.  

**Use Cases:**  
- Instant payment processing for e-commerce.  
- Merchants requiring secure, direct payment flows.  

**Integration Steps:**  
- Contact PayGlocal integration team for SDKs.  
- Implement asymmetric/symmetric key-based authentication.  
- Use `x-gl-token-external` header for JWT payloads.  

**Sample API Request (PayDirect):**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "89",
    "txnCurrency": "INR",
    "cardData": {
      "number": "5132552222223470",
      "expiryMonth": "12",
      "expiryYear": "2030",
      "securityCode": "123"
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate`  
**Copyable Endpoint:** `/gl/v1/payments/initiate`  

**Benefits:**  
- Fast and secure direct payment processing.  
- Supports PayDirect API for seamless integration.  
- Ensures data confidentiality and integrity.  

*For more details on JWT, refer to [RFC 7519](https://tools.ietf.org/html/rfc7519).*
''',
                            route: '/paydirect-jwt-detail',
                            icon: Icons.lock,
                            badge: 'Direct JWT',
                            badgeColor: AppTheme.darkJwtBlue,
                            benefits: [
                              'Fast direct payment processing',
                              'Supports PayDirect API',
                              'Secure JWT encryption',
                            ],
                          ),
                          _PaymentMethodCard(
                            title: 'SI PayDirect',
                            description: 'Automate recurring direct payments with Fixed or Variable schedules.',
                            details: '''
**SI PayDirect Overview**  
Standing Instructions (SI) for PayDirect enable automated recurring direct payments with Fixed (same amount each cycle) or Variable (up to a maximum limit) schedules. Ideal for subscriptions or utility bills, SI uses JWE/JWS encryption for security.  

**Key Features:**  
- Supports FIXED (e.g., subscriptions) and VARIABLE (e.g., utility bills) payment types.  
- Configurable frequency (weekly, monthly) and number of payments.  
- Secure with JWE/JWS encryption via `/gl/v1/payments/initiate`.  

**Use Cases:**  
- Fixed SI: Monthly subscriptions like streaming platforms (₹999/month).  
- Variable SI: Utility bills with varying amounts up to a limit.  

**Fixed SI Request:**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "89",
    "txnCurrency": "INR",
    "cardData": {
      "number": "5132552222223470",
      "expiryMonth": "12",
      "expiryYear": "2030",
      "securityCode": "123"
    }
  },
  "standingInstruction": {
    "data": {
      "amount": "1250.00",
      "numberOfPayments": "4",
      "frequency": "MONTHLY",
      "type": "FIXED",
      "startDate": "20220510"
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Variable SI Request:**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "89",
    "txnCurrency": "INR",
    "cardData": {
      "number": "5132552222223470",
      "expiryMonth": "12",
      "expiryYear": "2030",
      "securityCode": "123"
    }
  },
  "standingInstruction": {
    "data": {
      "maxAmount": "1250.00",
      "numberOfPayments": "4",
      "frequency": "ONDEMAND",
      "type": "VARIABLE"
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate`  
**Copyable Endpoint:** `/gl/v1/payments/initiate`  

**Benefits:**  
- Automates recurring direct payments.  
- Flexible FIXED or VARIABLE scheduling.  
- Secure JWE/JWS encryption.  

*Contact PayGlocal support to configure SI for your merchant account.*
''',
                            route: '/paydirect/si',
                            icon: Icons.repeat,
                            badge: 'Direct SI',
                            badgeColor: AppTheme.darkRecurringAmber,
                            benefits: [
                              'Automates recurring direct payments',
                              'Flexible FIXED/VARIABLE options',
                              'Secure JWE/JWS encryption',
                            ],
                          ),
                          _PaymentMethodCard(
                            title: 'Auth & Capture',
                            description: 'Separate authorization and capture for flexible payment processing.',
                            details: '''
**Auth & Capture Overview**  
The Standalone flow separates authorization, capture, and reversal phases, allowing merchants to reserve funds and capture later. Ideal for e-commerce, travel, or logistics requiring delayed fulfillment.  

**Key Components:**  
- **Authorization**: Reserves funds without debiting (e.g., check inventory).  
- **Capture**: Charges the reserved amount after confirmation (e.g., after shipping).  
- **Reversal**: Releases held funds if the transaction is canceled (e.g., out of stock).  

**Use Cases:**  
- E-commerce: Authorize payment, capture after stock confirmation.  
- Travel: Reserve funds for flight bookings, capture after seat confirmation.  
- Hotels: Authorize for reservations, capture after stay.  

**Authorization Request**  
**Endpoint:** `/gl/v1/payments/auth` (POST)  
**Copyable Endpoint:** `/gl/v1/payments/auth`  
```json
{
  "paymentData": {
    "totalAmount": "100",
    "txnCurrency": "INR"
  }
}
```  

**Authorization Response**  
**Endpoint:** `/gl/v1/payments/auth` (POST)  
**Copyable Endpoint:** `/gl/v1/payments/auth`  
```json
{
  "gid": "gl-13bbd3c4-9817-4786-96c6-12fa6191f118",
  "status": "AUTHORIZED",
  "message": "Authorization Successful",
  "timestamp": "2021-04-12T07:47:18Z"
}
```  

**Capture Request**  
**Endpoint:** `/gl/v1/payments/{gid}/capture` (POST)  
**Copyable Endpoint:** `/gl/v1/payments/{gid}/capture`  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": ""
  },
  "captureType": "F"
}
```  

**Reversal Request**  
**Endpoint:** `/gl/v1/payments/{gid}/auth-reversal` (POST)  
**Copyable Endpoint:** `/gl/v1/payments/{gid}/auth-reversal`  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07"
}
```  

**Why Use It?**  
- Fine control over funds movement.  
- Prevents premature charges for unfulfilled orders.  
- Ideal for businesses with inventory or confirmation delays.  

**Who Uses It?**  
- E-commerce, travel, hotels, logistics, and event ticketing merchants.  

**Benefits:**  
- Flexible authorization and capture process.  
- Clean reversal without refund flows.  
- Supports delayed fulfillment workflows.  

*Contact PayGlocal support to configure Standalone services for your account.*
''',
                            route: '/paydirect/airline',
                            icon: Icons.swap_horiz,
                            badge: 'Flexible',
                            badgeColor: AppTheme.darkSuccessEmerald,
                            benefits: [
                              'Flexible authorization and capture',
                              'Prevents premature charges',
                              'Ideal for delayed fulfillment',
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Visibility(
                    visible: _showFAQ,
                    child: _FAQSection(key: _faqKey),
                  ),
                  if (_showFAQ) ...[
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _decorationAnimation,
                      child: Container(
                        height: 8,
                        width: 300,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF10B981),
                              Color(0xFFFFA500),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(2),
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
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FAQSection extends StatefulWidget {
  const _FAQSection({super.key});

  @override
  _FAQSectionState createState() => _FAQSectionState();
}

class _FAQSectionState extends State<_FAQSection> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final titleFontSize = isLargeScreen ? 20.0 : 18.0;
    final bodyFontSize = isLargeScreen ? 16.0 : 14.0;
    final cardPadding = isLargeScreen ? 24.0 : 16.0;

    final faqs = [
      {
        'question': 'For whom is the PayDirect method designed?',
        'answer':
            'PayDirect is designed for PCI DSS certified merchants who prefer to collect card details directly on their own interface. It\'s ideal for businesses like e-commerce platforms, subscription services, or travel agencies that want to control the payment UI while ensuring secure processing through PayGlocal.',
      },
      {
        'question': 'What if a merchant doesn\'t want to collect card details directly?',
        'answer':
            'Merchants who prefer not to handle card details directly should use the PayCollect method. PayCollect allows PayGlocal to manage card data securely, ensuring compliance without requiring merchants to maintain PCI DSS certification.',
      },
      {
        'question': 'What are the security standards for PayDirect methods?',
        'answer':
            'PayDirect methods (JWT PayDirect, SI PayDirect, and Auth & Capture) utilize JSON Web Encryption (JWE) and JSON Web Signature (JWS) for robust security. These standards ensure data confidentiality, integrity, and non-repudiation during payment processing.',
      },
      {
        'question': 'What is this demo website for?',
        'answer':
            'This demo website showcases PayGlocal\'s PayDirect integration, including JWT PayDirect, SI PayDirect, and Auth & Capture. It provides minimum required API payload fields to simplify onboarding. For full payload details, merchants can refer to our comprehensive documentation.',
      },
      {
        'question': 'What support is available for integrating PayDirect?',
        'answer':
            'PayGlocal provides dedicated integration support, including SDKs, detailed documentation, and a technical support team. Merchants can contact our integration team via the "Contact Us" page for assistance with API setup, testing, or resolving queries.',
      },
      // {
      //   'question': 'Can PayDirect be used with other payment methods?',
      //   'answer':
      //       'Yes, PayDirect can be integrated with other payment methods like UPI, net banking, or wallets, depending on the merchant's requirements and PayGlocal's supported gateways. Contact our support team to configure multi-method payment solutions.',
      // },
    ];

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 24,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 24.0 : 20.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_hoveredIndex == index ? 1.02 : 1.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_hoveredIndex == index ? 0.15 : 0.05),
                        blurRadius: _hoveredIndex == index ? 10 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: _hoveredIndex == index
                          ? const Color(0xFF3B82F6).withOpacity(0.5)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.question_answer,
                      size: isLargeScreen ? 24 : 20,
                      color: _hoveredIndex == index
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF4B5563),
                    ),
                    title: Text(
                      faq['question']!,
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: _hoveredIndex == index
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF111827),
                      ),
                    ),
                    iconColor: const Color(0xFF3B82F6),
                    collapsedIconColor: const Color(0xFF4B5563),
                    children: [
                      Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                            fontSize: bodyFontSize,
                            color: const Color(0xFF4B5563),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatefulWidget {
  final String title;
  final String description;
  final String details;
  final String route;
  final IconData icon;
  final String badge;
  final Color badgeColor;
  final List<String> benefits;

  const _PaymentMethodCard({
    required this.title,
    required this.description,
    required this.details,
    required this.route,
    required this.icon,
    required this.badge,
    required this.badgeColor,
    required this.benefits,
  });

  @override
  _PaymentMethodCardState createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<_PaymentMethodCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogFadeAnimation;
  late Animation<double> _dialogScaleAnimation;

  @override
  void initState() {
    super.initState();
    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _dialogFadeAnimation = CurvedAnimation(
      parent: _dialogAnimationController,
      curve: Curves.easeInOut,
    );
    _dialogScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
      child: Card(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF9FAFB),
        elevation: _isHovered ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFD1D5DB)),
        ),
        child: InkWell(
          onTap: () {
            try {
              Navigator.pushNamed(context, widget.route);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.route} route not found')),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF3F4F6),
          onHover: (hovered) {
            setState(() {
              _isHovered = hovered;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
                      child: Icon(
                        widget.icon,
                        size: isLargeScreen ? 32 : 28,
                        color: widget.badgeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.badge,
                        style: GoogleFonts.notoSans(
                          fontSize: isLargeScreen ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: widget.badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.notoSans(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: GoogleFonts.notoSans(
                    fontSize: isLargeScreen ? 14 : 13,
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.benefits
                          .map(
                            (benefit) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: isLargeScreen ? 16 : 14,
                                    color: widget.badgeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: GoogleFonts.notoSans(
                                        fontSize: isLargeScreen ? 13 : 12,
                                        color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.route == '/paydirect-jwt-detail')
                      Flexible(
                        fit: FlexFit.loose,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/services/jwt');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            'JWT Services',
                            style: GoogleFonts.notoSans(
                              fontSize: isLargeScreen ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    if (widget.route == '/paydirect-jwt-detail') const SizedBox(width: 8),
                    if (widget.route == '/paydirect/si')
                      Flexible(
                        fit: FlexFit.loose,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/services/si');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            'SI Services',
                            style: GoogleFonts.notoSans(
                              fontSize: isLargeScreen ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    if (widget.route == '/paydirect/si') const SizedBox(width: 8),
                    if (widget.route == '/paydirect/airline')
                      Flexible(
                        fit: FlexFit.loose,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/services/auth');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            'Auth Services',
                            style: GoogleFonts.notoSans(
                              fontSize: isLargeScreen ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    if (widget.route == '/paydirect/airline') const SizedBox(width: 8),
                    Tooltip(
                      message: 'Learn more about ${widget.title}',
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            Navigator.pushNamed(context, widget.route);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.route} route not found',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: _isHovered ? 2 : 0,
                        ),
                        child: Text(
                          'Try Now',
                          style: GoogleFonts.notoSans(
                            fontSize: isLargeScreen ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

void _showDetailsDialog(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isLargeScreen = screenWidth > 800;
  final titleFontSize = isLargeScreen ? 18.0 : 16.0;
  final bodyFontSize = isLargeScreen ? 14.0 : 13.0;
  final codeFontSize = isLargeScreen ? 12.0 : 11.0;
  final iconSize = isLargeScreen ? 28.0 : 24.0;
  final padding = isLargeScreen ? 16.0 : 12.0;

  // Replace "startDate": "20220510" with current date
  final now = DateTime.now();
  final formattedDate = DateFormat('yyyyMMdd').format(now);
  String updatedDetails = widget.details.replaceAll(
    '"startDate": "20220510"',
    '"startDate": "$formattedDate"',
  );

  // Define response JSONs
  final Map<String, String> responses = {
    'JWT PayDirect': '''{
  "gid": "gl_o-962989f8777c7ff29lo0Yd5X2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:35:51",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4OWY4Nzc3YzdmZjI5bG8wWWQ1WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4NzUxNTg1IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5ODlmODc3N2M3ZmYyNWU5bG8wWWQ1WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.nTeZces9c7oltT5ohLiUoUyfBrYxcWmgCXMnqkrznp93yWurisSvqm-cgr0JoGBcZHtxiAvoQsNF116ATHqxj5-3blNkjc8um0ET47g5Qf8-Cv9QcBlL6F62Q_UYZEW6-wxGz3Jwu4IoPboGzVpxP815vCJ91cXKSaesRYumaVR7Ix9ToIAuBdSo-IUR9kJ6fGcXb6ujH4ubUDTytqPGAHyoZj6SptnsSp8yRhs-V_I2peaWzDmzXXSRHlfXTXaaSsDUHW1r4Vb1KqKejV9b7fSQ_8mcpEAGLRFSKbZvbwgSDgB0j6nxE4Qa34AxCqDT13G3NNbhdCgv0mZAX3sWzA",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-962989f8777c7ff29lo0Yd5X2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4OWY4Nzc3YzdmZjI5bG8wWWQ1WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4NzUxNTg1IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5ODlmODc3N2M3ZmYyNWU5bG8wWWQ1WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.nTeZces9c7oltT5ohLiUoUyfBrYxcWmgCXMnqkrznp93yWurisSvqm-cgr0JoGBcZHtxiAvoQsNF116ATHqxj5-3blNkjc8um0ET47g5Qf8-Cv9QcBlL6F62Q_UYZEW6-wxGz3Jwu4IoPboGzVpxP815vCJ91cXKSaesRYumaVR7Ix9ToIAuBdSo-IUR9kJ6fGcXb6ujH4ubUDTytqPGAHyoZj6SptnsSp8yRhs-V_I2peaWzDmzXXSRHlfXTXaaSsDUHW1r4Vb1KqKejV9b7fSQ_8mcpEAGLRFSKbZvbwgSDgB0j6nxE4Qa34AxCqDT13G3NNbhdCgv0mZAX3sWzA",
    "merchantTxnId": "1753088750965749238"
  },
  "errors": null
}''',
    'SI PayDirect_Fixed': '''{
  "gid": "gl_o-96298b9a848a0553fjo00HwX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:36:58",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4YjlhODQ4YTA1NTNmam8wMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODE4NDI3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGI5YTg0OGEwNTUzNjY5am8wMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.nVeNEP2ks_ixzcA0hXg-SeyFPv7LWX12q7oVl5WGSqytYzQBPy8H050VvbWWzz1tzizFTPBZf242A3DVhTG6JlS5344toykzxjCxtM4fDZcJpnVT0t6hXycyTx2qbgHlTgFineb8o6MlcQPaO-0XgylebxWfTBconrwLaRbN2CDWJt6yaVALpEbOpziZ8b_Yk1LTALiv_pq_A7j7nK1hl9xDjROCv9Y9b58-gUiO4Li1hUaAaT-GREDMqd0gv_gVeYQ7elG0zeshQeL3_mYamM06ZPRJGLzxKDUPwYK0S8KQBoY_pT7dim8cVV7UTHHKLsOaPG77uHZKJgDwYYz0qg",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-96298b9a848a0553fjo00HwX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4YjlhODQ4YTA1NTNmam8wMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODE4NDI3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGI5YTg0OGEwNTUzNjY5am8wMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.nVeNEP2ks_ixzcA0hXg-SeyFPv7LWX12q7oVl5WGSqytYzQBPy8H050VvbWWzz1tzizFTPBZf242A3DVhTG6JlS5344toykzxjCxtM4fDZcJpnVT0t6hXycyTx2qbgHlTgFineb8o6MlcQPaO-0XgylebxWfTBconrwLaRbN2CDWJt6yaVALpEbOpziZ8b_Yk1LTALiv_pq_A7j7nK1hl9xDjROCv9Y9b58-gUiO4Li1hUaAaT-GREDMqd0gv_gVeYQ7elG0zeshQeL3_mYamM06ZPRJGLzxKDUPwYK0S8KQBoY_pT7dim8cVV7UTHHKLsOaPG77uHZKJgDwYYz0qg",
    "mandateId": "md_ff793ab6-b4ff-46c7-927e-ac4676ce8ff6",
    "merchantTxnId": "1753088818061491727"
  },
  "errors": null
}''',
    'SI PayDirect_Variable': '''{
  "gid": "gl_o-96298d64204ca90876lc0CJX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:38:11",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4ZDY0MjA0Y2E5MDg3NmxjMENKWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODkxNjg2IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGQ2NDIwNGNhOTA4MDE4NmxjMENKWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.joY5aWVM7yNvytI5fHl80UE96AaWfjpBBaTIfTFM7jGEGQf-VKS4W0egNvqGUcguDOoJhve7W6SgNv4OesQT-3Q-j1-rLP-ML7Oac39n7mC1U8XwEcu8DVxVIMxAaxU-Gn-O8gB_Dt9REckHf85JNTg2SjIttlqPYeaonS5yFONsJuUeFnGHZ4YWpym7ZaAUxe-aaSVeYtB6u3tfDHeeaxv6vHPIa_3-XS2fM6vNIVY6I2F-3H3TpzIbUOYB7KAlRUrrkUy985jsFtYLdrcS8EeUhqbWYWsjveabYJAkg6y7rKjQeEVwlKrwCn4ReutRPYUibWBnRSHtzhUzgsh5Aw",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-96298d64204ca90876lc0CJX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4ZDY0MjA0Y2E5MDg3NmxjMENKWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODkxNjg2IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGQ2NDIwNGNhOTA4MDE4NmxjMENKWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.joY5aWVM7yNvytI5fHl80UE96AaWfjpBBaTIfTFM7jGEGQf-VKS4W0egNvqGUcguDOoJhve7W6SgNv4OesQT-3Q-j1-rLP-ML7Oac39n7mC1U8XwEcu8DVxVIMxAaxU-Gn-O8gB_Dt9REckHf85JNTg2SjIttlqPYeaonS5yFONsJuUeFnGHZ4YWpym7ZaAUxe-aaSVeYtB6u3tfDHeeaxv6vHPIa_3-XS2fM6vNIVY6I2F-3H3TpzIbUOYB7KAlRUrrkUy985jsFtYLdrcS8EeUhqbWYWsjveabYJAkg6y7rKjQeEVwlKrwCn4ReutRPYUibWBnRSHtzhUzgsh5Aw",
    "mandateId": "md_79c4147d-000c-450c-8b1c-1bcbc85c0806",
    "merchantTxnId": "1753088891331898677"
  },
  "errors": null
}''',
    'Auth & Capture': '''{
  "gid": "gl_o-9629948614fa8826cej0fn8X2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:43:03",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk5NDg2MTRmYTg4MjZjZWowZm44WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg5MTgzODQzIiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OTQ4NjE0ZmE4ODI2MjZiZWowZm44WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.G1swWlXlDtM46_03GEhSajoX1cGbz150-UbMVVJgmnmQFlSDA4q7gdQtNXUVbQwHQhXaKa1lFyfpaf-V0ASQ5TI0-cqeaUQeCFLwZ-vVWzACRWPIp78OWouavWYvASXRHoBM8HiPes5XpK2DstmRH43exk69xIIvOOh-qNDelLtsHB6odA491E7QGMjDnDvR-IXuR_iFgMv_jVcPgo_AiBZgTLt6A54UDPCCJlO8m_X99-xohpVU-yNSqRD9fJOpCH-_gQekDOaXIxK4hbkKnnpiaIcvQfAGH6xV3adINpSHufErVrTKnKOP61VfysJcI6ZX7JL2a9VmHTHmXUNgRQ",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-9629948614fa8826cej0fn8X2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk5NDg2MTRmYTg4MjZjZWowZm44WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg5MTgzODQzIiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OTQ4NjE0ZmE4ODI2MjZiZWowZm44WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0nmV3Z2NjMjYifQ.G1swWlXlDtM46_03GEhSajoX1cGbz150-UbMVVJgmnmQFlSDA4q7gdQtNXUVbQwHQhXaKa1lFyfpaf-V0ASQ5TI0-cqeaUQeCFLwZ-vVWzACRWPIp78OWouavWYvASXRHoBM8HiPes5XpK2DstmRH43exk69xIIvOOh-qNDelLtsHB6odA491E7QGMjDnDvR-IXuR_iFgMv_jVcPgo_AiBZgTLt6A54UDPCCJlO8m_X99-xohpVU-yNSqRD9fJOpCH-_gQekDOaXIxK4hbkKnnpiaIcvQfAGH6xV3adINpSHufErVrTKnKOP61VfysJcI6ZX7JL2a9VmHTHmXUNgRQ",
    "merchantTxnId": "1753089183300784289"
  },
  "errors": null
}'''
  };

  List<Map<String, String>> payloads = [];
  RegExp payloadRegex = RegExp(r'```json\n([\s\S]*?)\n```', multiLine: true);
  Iterable<Match> payloadMatches = payloadRegex.allMatches(updatedDetails);
  int payloadIndex = 0;
  for (var match in payloadMatches) {
    String? payload = match.group(1)?.trim();
    if (payload != null) {
      String label;
      if (widget.title.contains('SI PayDirect')) {
        label = payloadIndex == 0 ? 'Fixed SI Payload' : 'Variable SI Payload';
      } else if (widget.title.contains('Auth & Capture')) {
        if (payloadIndex == 0) {
          label = 'Authorization Payload';
        } else {
          continue; // Skip Capture Payload, Reversal Payload
        }
      } else {
        label = 'Sample Payload';
      }
      payloads.add({
        'content': payload,
        'label': label,
      });
      payloadIndex++;
    }
  }

  List<Map<String, String>> endpoints = [];
  RegExp endpointRegex = RegExp(
    r'\*\*Copyable Endpoint:\*\* `(.*?)(?<!\\)`',
    multiLine: true,
  );
  Iterable<Match> endpointMatches = endpointRegex.allMatches(updatedDetails);
  int endpointIndex = 0;
  for (var match in endpointMatches) {
    String? endpoint = match.group(1)?.trim();
    if (endpoint != null) {
      String label;
      if (widget.title.contains('SI PayDirect')) {
        label = 'SI Endpoint';
      } else if (widget.title.contains('Auth & Capture')) {
        if (endpointIndex == 0) {
          label = 'Authorization Endpoint';
        } else {
          continue; // Skip Capture Endpoint, Reversal Endpoint
        }
      } else {
        label = 'Endpoint';
      }
      endpoints.add({
        'content': endpoint,
        'label': label,
      });
      endpointIndex++;
    }
  }

  List<Widget> contentWidgets = [];
  final lines = updatedDetails.split('\n');
  bool inCodeBlock = false;

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) {
      contentWidgets.add(const SizedBox(height: 8));
      continue;
    }

    if (line.startsWith('```json')) {
      inCodeBlock = true;
      continue;
    } else if (line.startsWith('```')) {
      inCodeBlock = false;
      continue;
    } else if (inCodeBlock) {
      continue;
    }

    if (line.startsWith('**') &&
        line.endsWith('**') &&
        !line.startsWith('**Copyable Endpoint:**')) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            line.substring(2, line.length - 2),
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      );
    } else if (line.startsWith('- ')) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: isLargeScreen ? 16 : 14,
                color: widget.badgeColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: GoogleFonts.poppins(
                    fontSize: bodyFontSize,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (line.startsWith('*') && line.endsWith('*')) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            line.substring(1, line.length - 1),
            style: GoogleFonts.poppins(
              fontSize: bodyFontSize,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      );
    } else if (!line.startsWith('**Copyable Endpoint:**')) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            line,
            style: GoogleFonts.poppins(
              fontSize: bodyFontSize,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      );
    }
  }

  for (var endpoint in endpoints) {
    contentWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              endpoint['label']!,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  endpoint['content']!,
                  style: GoogleFonts.robotoMono(
                    fontSize: codeFontSize,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedScale(
                  scale: _isHovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: endpoint['content']!),
                      )
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Endpoint copied to clipboard'),
                          ),
                        );
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to copy endpoint'),
                          ),
                        );
                      });
                    },
                    icon: Icon(
                      Icons.copy,
                      size: isLargeScreen ? 16 : 14,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Copy ${endpoint['label']}',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.badgeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
    );
  }

  for (var payload in payloads) {
    bool isCopyable = widget.title == 'JWT PayDirect' ||
        (widget.title == 'Auth & Capture' && payload['label'] == 'Authorization Payload');
    contentWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload['label']!,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  payload['content']!,
                  style: GoogleFonts.robotoMono(
                    fontSize: codeFontSize,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            if (isCopyable) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: payload['content']!),
                        )
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${payload['label']} copied to clipboard'),
                            ),
                          );
                        }).catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to copy payload'),
                            ),
                          );
                        });
                      },
                      icon: Icon(
                        Icons.copy,
                        size: isLargeScreen ? 16 : 14,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Copy ${payload['label']}',
                        style: GoogleFonts.poppins(
                          fontSize: isLargeScreen ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.badgeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Add response below the payload
            if (widget.title == 'JWT PayDirect' && payload['label'] == 'Sample Payload' ||
                (widget.title == 'SI PayDirect' &&
                    (payload['label'] == 'Fixed SI Payload' || payload['label'] == 'Variable SI Payload')) ||
                (widget.title == 'Auth & Capture' && payload['label'] == 'Authorization Payload')) ...[
              const SizedBox(height: 16),
              Text(
                widget.title == 'SI PayDirect'
                    ? (payload['label'] == 'Fixed SI Payload'
                        ? 'Fixed SI Response'
                        : 'Variable SI Response')
                    : '${payload['label']} Response',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    responses[
                        widget.title == 'SI PayDirect'
                            ? '${widget.title}_${payload['label'] == 'Fixed SI Payload' ? 'Fixed' : 'Variable'}'
                            : widget.title]!,
                    style: GoogleFonts.robotoMono(
                      fontSize: codeFontSize,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: responses[
                                  widget.title == 'SI PayDirect'
                                      ? '${widget.title}_${payload['label'] == 'Fixed SI Payload' ? 'Fixed' : 'Variable'}'
                                      : widget.title]!,
                            ),
                          )
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${payload['label']} Response copied to clipboard',
                                ),
                              ),
                            );
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to copy response'),
                              ),
                            );
                          });
                        },
                        icon: Icon(
                          Icons.copy,
                          size: isLargeScreen ? 16 : 14,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Copy ${payload['label']} Response',
                          style: GoogleFonts.poppins(
                            fontSize: isLargeScreen ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.badgeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
  contentWidgets.add(const SizedBox(height: 12));
  if (widget.route == '/paydirect-jwt-detail') {
    contentWidgets.add(
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/services/jwt');
          },
          icon: const Icon(Icons.menu_book, size: 16),
          label: const Text('View JWT Services'),
        ),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return FadeTransition(
        opacity: _dialogFadeAnimation,
        child: ScaleTransition(
          scale: _dialogScaleAnimation,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9FAFB), Color(0xFFE5E7EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.badgeColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              size: iconSize,
                              color: widget.badgeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.poppins(
                                fontSize: isLargeScreen ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...contentWidgets,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: const Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    try {
                      Navigator.pushNamed(context, widget.route);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.route} route not found'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Try Now',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 13 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}