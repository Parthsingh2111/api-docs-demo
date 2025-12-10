
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/themed_scaffold.dart';
import '../theme/app_theme.dart';
import '../navigation/app_navigation.dart';

class PayCollectScreen extends StatefulWidget {
  const PayCollectScreen({super.key});

  @override
  _PayCollectScreenState createState() => _PayCollectScreenState();
}

class _PayCollectScreenState extends State<PayCollectScreen>
    with TickerProviderStateMixin {
  late AnimationController _appBarFadeController;
  late Animation<double> _appBarFadeAnimation;
  late AnimationController _decorationAnimationController;
  late Animation<double> _decorationAnimation;
  int _animationCycles = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _appBarFadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _appBarFadeAnimation = CurvedAnimation(
      parent: _appBarFadeController,
      curve: Curves.easeIn,
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
  }

  @override
  void dispose() {
    _appBarFadeController.dispose();
    _decorationAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final titleFontSize = isLargeScreen ? 28.0 : 22.0;
    final subtitleFontSize = isLargeScreen ? 16.0 : 14.0;
    final overlayPadding = isLargeScreen ? AppTheme.spacing16 : AppTheme.spacing12;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ThemedScaffold(
      appBar: SharedAppBar(
        title: 'PayCollect Payment Methodssssssss',
        fadeAnimation: _appBarFadeAnimation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.getTextPrimary(context),
          ),
          onPressed: () {
            AppNavigation.replace('/overview');
          },
          tooltip: 'Back to Overview',
        ),
      ),
      useSafeArea: false, // We'll handle SafeArea inside
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(overlayPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      boxShadow: isDark ? AppTheme.shadowLG : AppTheme.shadowMD,
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark ? [
                                    AppTheme.darkJwtBlue.withOpacity(0.08),
                                    AppTheme.darkRecurringAmber.withOpacity(0.05),
                                  ] : [
                                    AppTheme.lightJwtBlue.withOpacity(0.05),
                                    AppTheme.gray200.withOpacity(0.1),
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
                          padding: EdgeInsets.all(AppTheme.spacing24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(AppTheme.spacing8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getJwtColor(context).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.payment,
                                      size: 24,
                                      color: AppTheme.getJwtColor(context),
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing12),
                                  Expanded(
                                    child: Text(
                                      'PayCollect Payment Solutions',
                                      style: GoogleFonts.poppins(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.getJwtColor(context),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppTheme.spacing12),
                              Text(
                                'Empowering non-PCI DSS certified merchants with secure, flexible, and seamless payment methods. PayGlocal handles card details, ensuring compliance and simplicity.',
                                style: GoogleFonts.poppins(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.getTextSecondary(context),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing16),
                              const SizedBox.shrink(),
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
                              color: AppTheme.getJwtColor(context).withOpacity(0.2),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(AppTheme.radiusLG),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing40),
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
                            title: 'JWT Authentication',
                            description: 'Secure payment initiation using JWT for advanced integrations.',
                            route: '/paycollect-jwt-detail',
                            details: '''
**JWT Authentication Overview**  
JWT-based authentication ensures secure payment initiation across all PayGlocal APIs. It uses asymmetric and symmetric keys (JWE/JWS) for enhanced security, ideal for merchants requiring robust data protection. Contact our integration team for SDK support.  

**Key Features:**  
- Utilizes JWE/JWS encryption for secure data transfer.  
- Applicable to all PayGlocal APIs.  
- Provides data integrity, non-repudiation, and confidentiality.  

**Use Cases:**  
- High-security payment integrations.  
- Merchants needing advanced API access with secure authentication.  

**Integration Steps:**  
- Contact PayGlocal integration team for SDKs.  
- Implement asymmetric/symmetric key-based authentication.  
- Use `x-gl-token-external` header for JWT payloads.  

**Sample API Request (Example for PayCollect):**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "89",
    "txnCurrency": "INR"
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate/paycollect`  
**Copyable Endpoint:** `/gl/v1/payments/initiate/paycollect`  

**Benefits:**  
- Enhanced security with JWT encryption.  
- Supports all PayGlocal APIs for flexible integration.  
- Ensures data confidentiality and integrity.  

*For more details on JWT, refer to [RFC 7519](https://tools.ietf.org/html/rfc7519).*
''',
                            icon: Icons.lock,
                            badge: 'JWT Secure',
                            badgeColor: AppTheme.darkJwtBlue,
                            benefits: [
                              'Enhanced security with JWT',
                              'Supports all APIs',
                              'Data integrity and confidentiality',
                            ],
                          ),
                          _PaymentMethodCard(
                            title: 'Standing Instruction',
                            description: 'Automate recurring payments with Fixed or Variable schedules.',
                            route: '/paycollect-si-detail',
                            details: '''
**Standing Instruction Overview**  
Standing Instructions (SI) enable automated recurring payments with Fixed (same amount each cycle) or Variable (up to a maximum limit) schedules. Ideal for subscriptions or utility bills, SI uses JWE/JWS encryption for security.  

**Key Features:**  
- Supports FIXED (e.g., gym membership) and VARIABLE (e.g., utility bills) payment types.  
- Configurable frequency (weekly, monthly) and number of payments.  
- Secure with JWE/JWS encryption via `/gl/v1/payments/initiate/paycollect`.  

**Use Cases:**  
- Fixed SI: Monthly subscriptions like streaming platforms (₹999/month).  
- Variable SI: Utility bills with varying amounts up to a limit.  

**Fixed SI Request:**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "89",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "amount": "1250.00",
      "numberOfPayments": "4",
      "frequency": "MONTHLY",
      "type": "FIXED",
      "startDate": "{DYNAMIC_DATE}"
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
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "maxAmount": "1250.00",
      "numberOfPayments": "4",
      "frequency": "ONDEMAND",
      "type": "VARIABLE",
      "startDate": "{DYNAMIC_DATE}"
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate/paycollect`  
**Copyable Endpoint:** `/gl/v1/payments/initiate/paycollect`  

**Benefits:**  
- Automates recurring payments for subscriptions or bills.  
- Flexible FIXED or VARIABLE scheduling.  
- Secure JWE/JWS encryption.  

*Contact PayGlocal support to configure SI for your merchant account.*
''',
                            icon: Icons.repeat,
                            badge: 'Recurring',
                            badgeColor: AppTheme.darkRecurringAmber,
                            benefits: [
                              'Automates recurring payments',
                              'Flexible FIXED/VARIABLE options',
                              'Secure JWE/JWS encryption',
                            ],
                          ),
                          _PaymentMethodCard(
                            title: 'Auth & Capture',
                            description: 'Separate authorization and capture for flexible payment processing.',
                            route: '/paycollect-auth-detail',
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
      ..color = AppTheme.darkJwtBlue.withOpacity(0.1)
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
  const _FAQSection();

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
        'question': 'For whom is the PayCollect method designed?',
        'answer':
            'PayCollect is designed for non-PCI DSS certified merchants who want to process payments securely without handling card details directly. It’s ideal for businesses like e-commerce platforms, subscription services, travel agencies, and logistics providers seeking seamless and compliant payment solutions.',
      },
      {
        'question': 'What if the merchant wants to collect card details on their own page?',
        'answer':
            'If a merchant prefers to collect card details directly on their page, we recommend using the PayGlocal PayDirect method. PayDirect allows merchants to handle card data on their own interface while ensuring PCI DSS compliance through PayGlocal’s secure processing. Contact our support team for integration details.',
      },
      {
        'question': 'What are the security standards for PayCollect methods?',
        'answer':
            'All PayCollect methods—JWT Authentication, Standing Instruction, and Auth & Capture—utilize JSON Web Encryption (JWE) and JSON Web Signature (JWS) for enhanced security. These standards ensure data confidentiality, integrity, and non-repudiation, making transactions secure and compliant.',
      },
      {
        'question': 'What is this demo website for?',
        'answer':
            'This demo website is designed to explain integration with PayGlocal and its products, including JWT Authentication, Standing Instruction, and Auth & Capture. It showcases minimum required fields for API payloads to simplify onboarding. Merchants wanting to add more fields can refer to our comprehensive documentation for full payload details.',
      },
      {
        'question': 'What support is available for integrating PayCollect?',
        'answer':
            'PayGlocal offers dedicated integration support, including SDKs, detailed documentation, and a technical support team. Merchants can contact our integration team via the "Contact Us" page to access resources, resolve queries, or get assistance with API setup and testing.',
      },
      {
        'question': 'Can PayCollect be used with other payment methods?',
        'answer':
            'Yes, PayCollect can be integrated alongside other payment methods like UPI, net banking, or wallets, depending on the merchant’s needs and PayGlocal’s supported gateways. Contact our support team to configure multi-method payment solutions for your business.',
      },
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: isDark ? AppTheme.shadowLG : AppTheme.shadowMD,
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.getJwtColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 24,
                  color: AppTheme.getJwtColor(context),
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 24.0 : 20.0,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getJwtColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing24),
          ...faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing16),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_hoveredIndex == index ? 1.02 : 1.0),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    boxShadow: _hoveredIndex == index
                        ? (isDark ? AppTheme.shadowLG : AppTheme.shadowMD)
                        : (isDark ? AppTheme.shadowSM : AppTheme.shadowXS),
                    border: Border.all(
                      color: _hoveredIndex == index
                          ? AppTheme.getJwtColor(context).withOpacity(0.5)
                          : AppTheme.getBorderColor(context),
                      width: 1.5,
                    ),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.question_answer,
                      size: isLargeScreen ? 24 : 20,
                      color: _hoveredIndex == index
                          ? AppTheme.getJwtColor(context)
                          : AppTheme.getTextSecondary(context),
                    ),
                    title: Text(
                      faq['question']!,
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: _hoveredIndex == index
                            ? AppTheme.getJwtColor(context)
                            : AppTheme.getTextPrimary(context),
                      ),
                    ),
                    iconColor: AppTheme.getJwtColor(context),
                    collapsedIconColor: AppTheme.getTextSecondary(context),
                    children: [
                      Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkBackground : AppTheme.backgroundSecondary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(AppTheme.radiusMD),
                          ),
                        ),
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                            fontSize: bodyFontSize,
                            color: AppTheme.getTextSecondary(context),
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
        color: AppTheme.getSurfaceColor(context),
        elevation: _isHovered ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          side: BorderSide(color: AppTheme.getBorderColor(context)),
        ),
        child: InkWell(
          onTap: null, // Remove duplicate navigation - button handles it
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          hoverColor: isDark ? AppTheme.darkSurfaceElevated : AppTheme.backgroundSecondary,
          onHover: (hovered) {
            setState(() {
              _isHovered = hovered;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
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
                    SizedBox(width: AppTheme.spacing8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
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
                SizedBox(height: AppTheme.spacing8),
                Text(
                  widget.title,
                  style: GoogleFonts.notoSans(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacing8),
                Text(
                  widget.description,
                  style: GoogleFonts.notoSans(
                    fontSize: isLargeScreen ? 14 : 13,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                SizedBox(height: AppTheme.spacing12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.benefits
                          .map(
                            (benefit) => Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.spacing2,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: isLargeScreen ? 16 : 14,
                                    color: widget.badgeColor,
                                  ),
                                  SizedBox(width: AppTheme.spacing4),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: GoogleFonts.notoSans(
                                        fontSize: isLargeScreen ? 13 : 12,
                                        color: AppTheme.getTextSecondary(context),
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
                    if (widget.route == '/paycollect/airline') ...[
                      OutlinedButton(
                        onPressed: () {
                          AppNavigation.to('/services/auth');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.getJwtColor(context),
                          side: BorderSide(color: AppTheme.getJwtColor(context)),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing10,
                          ),
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
                      SizedBox(width: AppTheme.spacing8),
                    ],
                    if (widget.route == '/standing_instruction') ...[
                      OutlinedButton(
                        onPressed: () {
                          AppNavigation.to('/services/si');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.getJwtColor(context),
                          side: BorderSide(color: AppTheme.getJwtColor(context)),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing10,
                          ),
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
                      SizedBox(width: AppTheme.spacing8),
                    ],
                    if (widget.route == '/paycollect/jwt') ...[
                      Flexible(
                        fit: FlexFit.loose,
                        child: OutlinedButton(
                          onPressed: () {
                            AppNavigation.to('/services/jwt');
                          },
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing12,
                              vertical: AppTheme.spacing10,
                            ),
                            side: BorderSide(color: AppTheme.getJwtColor(context)),
                            foregroundColor: AppTheme.getJwtColor(context),
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
                      SizedBox(width: AppTheme.spacing8),
                    ],
                    Tooltip(
                      message: 'Learn more about ${widget.title}',
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            AppNavigation.to(widget.route);
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
                          backgroundColor: AppTheme.getJwtColor(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                            vertical: AppTheme.spacing12,
                          ),
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
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final screenWidth = MediaQuery.of(context).size.width;
  final isLargeScreen = screenWidth > 800;
  final titleFontSize = isLargeScreen ? 18.0 : 16.0;
  final bodyFontSize = isLargeScreen ? 14.0 : 13.0;
  final codeFontSize = isLargeScreen ? 12.0 : 11.0;
  final iconSize = isLargeScreen ? 28.0 : 24.0;
  final padding = isLargeScreen ? AppTheme.spacing16 : AppTheme.spacing12;

  // Replace {DYNAMIC_DATE} with current date
  final now = DateTime.now();
  final oneMonthLater = DateTime(now.year, now.month + 1, now.day);
  final formattedDate = DateFormat('yyyyMMdd').format(oneMonthLater);

  String updatedDetails = widget.details.replaceAll(
    '"startDate": "{DYNAMIC_DATE}"',
    '"startDate": "$formattedDate"',
  );

  // Define response JSONs
  final Map<String, String> responses = {
    'JWT Authentication': '''{
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
    'Standing Instruction_Fixed': '''{
  "gid": "gl_o-96298b9a848a0553fjo00HwX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:36:58",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4YjlhODQ4YTA1NTNmam8wMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODE4NDI3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGI5YTg0OGEwNTUzNjY5am8wMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.nVeNEP2ks_ixzcA0hXg-SeyFPv7LWX12q7oVl5WGSqytYzQBPy8H050VvbWWzz1tzizFTPBZf242A3DVhTG6JlS5344toykzxjCxtM4fDZcJpnVT0t6hXycyTx2qbgHlTgFineb8o6MlcQPaO-0XgylebxWfTBconrwLaRbN2CDWJt6yaVALpEbOpziZ8b_Yk1LTALiv_pq_A7j7nK1hl9xDjROCv9Y9b58-gUiO4Li1hUaAaT-GREDMqd0gv_gVeYQ7elG0zeshQeL3_mYamM06ZPRJGLzxKDUPwYK0S8KQBoY_pT7dim8cVV7UTHHKLsOaPG77uHZKJgDwYYz0qg",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-96298b9a848a0553fjo00HwX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4YjlhODQ4YTA1NTNmam8wMEh3WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODE4NDI3IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGI5YTg0OGEwNTUzNjY5am8wMEh3WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.nVeNEP2ks_ixzcA0hXg-SeyFPv7LWX12q7oVl5WGSqytYzQBPy8H050VvbWWzz1tzizFTPBZf242A3DVhTG6JlS5344toykzxjCxtM4fDZcJpnVT0t6hXycyTx2qbgHlTgFineb8o6MlcQPaO-0XgylebxWfTBconrwLaRbN2CDWJt6yaVALpEbOpziZ8b_Yk1LTALiv_pq_A7j7nK1hl9xDjROCv9Y9b58-gUiO4Li1hUaAaT-GREDMqd0gv_gVeYQ7elG0zeshQeL3_mYamM06ZPRJGLzxKDUPwYK0S8KQBoY_pT7dim8cVV7UTHHKLsOaPG77uHZKJgDwYYz0qg",
    "mandateId": "md_ff793ab6-b4ff-46c7-927e-ac4676ce8ff6",
    "merchantTxnId": "1753088818061491727"
  },
  "errors": null
}''',
    'Standing Instruction_Variable': '''{
  "gid": "gl_o-96298d64204ca90876lc0CJX2",
  "status": "INPROGRESS",
  "message": "Transaction Created Successfully",
  "timestamp": "21/07/2025 14:38:11",
  "reasonCode": "GL-201-001",
  "data": {
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4ZDY0MjA0Y2E5MDg3NmxjMENKWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODkxNjg2IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGQ2NDIwNGNhOTA4MDE4NmxjMENKWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.joY5aWVM7yNvytI5fHl80UE96AaWfjpBBaTIfTFM7jGEGQf-VKS4W0egNvqGUcguDOoJhve7W6SgNv4OesQT-3Q-j1-rLP-ML7Oac39n7mC1U8XwEcu8DVxVIMxAaxU-Gn-O8gB_Dt9REckHf85JNTg2SjIttlqPYeaonS5yFONsJuUeFnGHZ4YWpym7ZaAUxe-aaSVeYtB6u3tfDHeeaxv6vHPIa_3-XS2fM6vNIVY6I2F-3H3TpzIbUOYB7KAlRUrrkUy985jsFtYLdrcS8EeUhqbWYWsjveabYJAkg6y7rKjQeEVwlKrwCn4ReutRPYUibWBnRSHtzhUzgsh5Aw",
    "statusUrl": "https://api.uat.payglocal.in/gl/v1/payments/gl_o-96298d64204ca90876lc0CJX2/status?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk4ZDY0MjA0Y2E5MDg3NmxjMENKWDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg4ODkxNjg2IiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OGQ2NDIwNGNhOTA4MDE4NmxjMENKWDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.joY5aWVM7yNvytI5fHl80UE96AaWfjpBBaTIfTFM7jGEGQf-VKS4W0egNvqGUcguDOoJhve7W6SgNv4OesQT-3Q-j1-rLP-ML7Oac39n7mC1U8XwEcu8DVxVIMxAaxU-Gn-O8gB_Dt9REckHf85JNTg2SjIttlqPYeaonS5yFONsJuUeFnGHZ4YWpym7ZaAUxe-aaSVeYtB6u3tfDHeeaxv6vHPIa_3-XS2fM6vNIVY6I2F-3H3TpzIbUOYB7KAlRUrrkUy985jsFtYLdrcS8EeUhqbWYWsjveabYJAkg6y7rKjQeEVwlKrwCn4ReutRPYUibWBnRSHtzhUzgsh5Aw",
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
    "redirectUrl": "https://api.uat.payglocal.in/gl/payflow-ui/?x-gl-token=eyJpc3N1ZWQtYnkiOiJHbG9jYWwiLCJpcy1kaWdlc3RlZCI6ImZhbHNlIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJrSWQtRU5oN3Y1bLdTNE56YjhScCJ9.eyJ4LWdsLW9yZGVySWQiOiJnbF9vLTk2Mjk5NDg2MTRmYTg4MjZjZWowZm44WDIiLCJhbXBsaWZpZXItbWlkIjpudWxsLCJpYXQiOiIxNzUzMDg5MTgzODQzIiwieC1nbC1lbmMiOiJ0cnVlIiwieC1nbC1naWQiOiJnbF85NjI5OTQ4NjE0ZmE4ODI2MjZiZWowZm44WDIiLCJ4LWdsLW1lcmNoYW50SWQiOiJ0ZXN0bmV3Z2NjMjYifQ.G1swWlXlDtM46_03GEhSajoX1cGbz150-UbMVVJgmnmQFlSDA4q7gdQtNXUVbQwHQhXaKa1lFyfpaf-V0ASQ5TI0-cqeaUQeCFLwZ-vVWzACRWPIp78OWouavWYvASXRHoBM8HiPes5XpK2DstmRH43exk69xIIvOOh-qNDelLtsHB6odA491E7QGMjDnDvR-IXuR_iFgMv_jVcPgo_AiBZgTLt6A54UDPCCJlO8m_X99-xohpVU-yNSqRD9fJOpCH-_gQekDOaXIxK4hbkKnnpiaIcvQfAGH6xV3adINpSHufErVrTKnKOP61VfysJcI6ZX7JL2a9VmHTHmXUNgRQ",
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
      if (widget.title.contains('Standing Instruction')) {
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
      if (widget.title.contains('Standing Instruction')) {
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
          padding: EdgeInsets.only(bottom: AppTheme.spacing8),
          child: Text(
            line.substring(2, line.length - 2),
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
        ),
      );
    } else if (line.startsWith('- ')) {
      contentWidgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: AppTheme.spacing4,
            left: AppTheme.spacing8,
          ),
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
                    color: AppTheme.getTextSecondary(context),
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
          padding: EdgeInsets.only(bottom: AppTheme.spacing8),
          child: Text(
            line.substring(1, line.length - 1),
            style: GoogleFonts.poppins(
              fontSize: bodyFontSize,
              fontStyle: FontStyle.italic,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ),
      );
    } else if (!line.startsWith('**Copyable Endpoint:**')) {
      contentWidgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacing8),
          child: Text(
            line,
            style: GoogleFonts.poppins(
              fontSize: bodyFontSize,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ),
      );
    }
  }

  for (var endpoint in endpoints) {
    contentWidgets.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              endpoint['label']!,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  endpoint['content']!,
                  style: GoogleFonts.robotoMono(
                    fontSize: codeFontSize,
                    color: AppTheme.getTextPrimary(context),
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
                      padding: EdgeInsets.symmetric(
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
    bool isCopyable = widget.title == 'JWT Authentication' ||
        (widget.title == 'Auth & Capture' && payload['label'] == 'Authorization Payload');
    contentWidgets.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload['label']!,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  payload['content']!,
                  style: GoogleFonts.robotoMono(
                    fontSize: codeFontSize,
                    color: AppTheme.getTextPrimary(context),
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
                        padding: EdgeInsets.symmetric(
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
            if (widget.title == 'JWT Authentication' && payload['label'] == 'Sample Payload' ||
                (widget.title == 'Standing Instruction' &&
                    (payload['label'] == 'Fixed SI Payload' || payload['label'] == 'Variable SI Payload')) ||
                (widget.title == 'Auth & Capture' && payload['label'] == 'Authorization Payload')) ...[
              const SizedBox(height: 16),
              Text(
                widget.title == 'Standing Instruction'
                    ? (payload['label'] == 'Fixed SI Payload'
                        ? 'Fixed SI Response'
                        : 'Variable SI Response')
                    : '${payload['label']} Response',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.gray100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    responses[
                        widget.title == 'Standing Instruction'
                            ? '${widget.title}_${payload['label'] == 'Fixed SI Payload' ? 'Fixed' : 'Variable'}'
                            : widget.title]!,
                    style: GoogleFonts.robotoMono(
                      fontSize: codeFontSize,
                      color: AppTheme.getTextPrimary(context),
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
                                  widget.title == 'Standing Instruction'
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
                          padding: EdgeInsets.symmetric(
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
  if (widget.route == '/paycollect/jwt') {
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
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            content: Container(
              decoration: BoxDecoration(
                gradient: isDark ? LinearGradient(
                  colors: [AppTheme.darkSurface, AppTheme.darkBackground],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : LinearGradient(
                  colors: [AppTheme.backgroundSecondary, AppTheme.gray200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                boxShadow: isDark ? AppTheme.shadowLG : AppTheme.shadowMD,
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
                            padding: EdgeInsets.all(AppTheme.spacing8),
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
                          SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.poppins(
                                fontSize: isLargeScreen ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing16),
                      ...contentWidgets,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => AppNavigation.back(),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigation.back();
                    try {
                      AppNavigation.to(widget.route);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.route} route not found'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getJwtColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Try Now',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w600,
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
