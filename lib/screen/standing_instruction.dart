
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class StandingInstructionScreen extends StatefulWidget {
  const StandingInstructionScreen({super.key});

  @override
  _StandingInstructionScreenState createState() => _StandingInstructionScreenState();
}

class _StandingInstructionScreenState extends State<StandingInstructionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _appBarFadeController;
  late Animation<double> _appBarFadeAnimation;
  late AnimationController _decorationAnimationController;
  late Animation<double> _decorationAnimation;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  // late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;
  int _animationCycles = 0;

  @override
  void initState() {
    super.initState();
    // Fade animation for hero section
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    // Fade animation for app bar
    _appBarFadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _appBarFadeAnimation = CurvedAnimation(
      parent: _appBarFadeController,
      curve: Curves.easeIn,
    );
    // Footer animation
    _decorationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // _decorationAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      // CurvedAnimation(
      //   parent: _decorationAnimationController,
      //   curve: Curves.easeInOut,
      // ),
    // );
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
    // Icon animation for header
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.bounceOut,
        
      ),
    );
    // Wave animation
    // _waveAnimationController = AnimationController(
    //   duration: const Duration(milliseconds: 1200),
    //   vsync: this,
    // )..repeat(reverse: true);
    // _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(
    //     parent: _waveAnimationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _appBarFadeController.dispose();
    _decorationAnimationController.dispose();
    _iconAnimationController.dispose();
    // _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final titleFontSize = isLargeScreen ? 30.0 : 24.0;
    final subtitleFontSize = isLargeScreen ? 18.0 : 16.0;
    final overlayPadding = isLargeScreen ? 12.0 : 8.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          title: FadeTransition(
            opacity: _appBarFadeAnimation,
            child: Text(
              'Standing Instructions (SI)',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FadeTransition(
                opacity: _appBarFadeAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      Navigator.pushNamed(context, '/services');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Services route not found'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Services',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        margin: EdgeInsets.all(overlayPadding),
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
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Positioned.fill(
                              // child: ClipRRect(
                              //   borderRadius: BorderRadius.circular(16),
                              //   child: AnimatedBuilder(
                              //     animation: _waveAnimation,
                              //     builder: (context, child) {
                              //       return CustomPaint(
                              //         painter: WavePainter(
                              //           animationValue: _waveAnimation.value,
                              //         ),
                              //       );
                              //     },
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         gradient: LinearGradient(
                              //           colors: [
                              //             const Color.fromARGB(255, 51, 102, 184).withOpacity(0.05),
                              //             const Color.fromARGB(255, 189, 95, 45).withOpacity(0.1),
                              //           ],
                              //           begin: Alignment.topLeft,
                              //           end: Alignment.bottomRight,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ScaleTransition(
                                        scale: _iconScaleAnimation,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 200, 105, 28).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.repeat,
                                            size: 28,
                                            color: Color.fromARGB(255, 22, 92, 185),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Standing Instruction Payment Options',
                                          style: GoogleFonts.poppins(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1E3A8A),
                                            height: 1.3,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 2,
                                                offset: const Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Automate recurring payments with Fixed or Variable schedules',
                                    style: GoogleFonts.poppins(
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4B5563),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Positioned(
                            //   top: 0,
                            //   right: 0,
                            //   child: Container(
                            //     width: 60,
                            //     height: 60,
                            //     decoration: BoxDecoration(
                            //       color: const Color.fromARGB(255, 16, 36, 97).withOpacity(0.2),
                            //       borderRadius: const BorderRadius.only(
                            //         bottomLeft: Radius.circular(16),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: constraints.maxWidth > 800 ? 2 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          _PaymentMethodCard(
                            title: 'Fixed Standing Instruction',
                            description: 'Automate recurring payments with a fixed amount each cycle.',
                            details: '''
**Fixed Standing Instruction Overview**  
Fixed Standing Instructions (SI) enable automated recurring payments of a predefined amount at regular intervals (e.g., monthly, yearly). Ideal for subscriptions, EMIs, and fixed-fee services, it uses JWE/JWS encryption for security.

**Key Features:**  
- Fixed amount debited each cycle (e.g., ₹199/month).  
- Configurable frequency (weekly, monthly, yearly).  
- One-time user consent for recurring payments.  
- Secure with JWE/JWS encryption via `/gl/v1/payments/initiate/paycollect`.  

**Use Cases:**  
- Subscriptions: Netflix, Amazon Prime (₹199/month).  
- EMI Payments: HDFC Loan (₹8,000/month).  
- Gym Memberships: Cult Fit (₹999/month).  
- Rent: Fixed monthly rent payments.  
- Hosting/Domain: GoDaddy (fixed yearly fees).  

**Fixed SI Request:**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "0.0",         //As per requirement 
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "amount": "0.0",            //As per requirement 
      "numberOfPayments": "n",    //As per requirement 
      "frequency": "MONTHLY",
      "type": "FIXED",
      "startDate": "20220510"
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate/paycollect`  
**Copyable Endpoint:** `/gl/v1/payments/initiate/paycollect`  

**Benefits:**  
- Predictable recurring payments for subscriptions or EMIs.  
- One-time setup automates billing.  
- Secure JWE/JWS encryption.  

*Contact PayGlocal support to configure Fixed SI for your merchant account.*
''',
                            route: '/paycollect/ott_subscription_checkout',
                            icon: Icons.repeat,
                            badge: 'Fixed SI',
                            badgeColor: AppTheme.darkJwtBlue,
                            benefits: [
                              'Predictable fixed payments',
                              'Automates subscriptions/EMIs',
                              'Secure JWE/JWS encryption',
                            ],
                          ),
                          _PaymentMethodCard(
                            title: 'Variable Standing Instruction',
                            description: 'Automate recurring payments with variable amounts based on usage.',
                            details: '''
**Variable Standing Instruction Overview**  
Variable Standing Instructions (SI) enable automated recurring payments where the amount varies based on usage or consumption, up to a maximum limit, at regular intervals (e.g., monthly). Ideal for utility bills, cloud services, or ad spends, it uses JWE/JWS encryption for security.

**Key Features:**  
- Variable amount debited each cycle (up to a max limit, e.g., ₹1250/month).  
- Configurable frequency (weekly, monthly).  
- One-time user consent for recurring payments.  
- Secure with JWE/JWS encryption via `/gl/v1/payments/initiate/paycollect`.  

**Use Cases:**  
- Utility Bills: Tata Power, BSES (varies by kWh).  
- Cloud Services: AWS, GCP (based on compute/storage).  
- Credit Card Payments: HDFC, ICICI (minimum/total due).  
- Ad Platforms: Google Ads, Meta Ads (varies with spend).  
- APIs/SaaS: Twilio, SendGrid (pay-as-you-go).  

**Variable SI Request:**  
```json
{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "0.0",           //As per requirement 
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "maxAmount": "0.0",            //As per requirement 
      "numberOfPayments": "n",
      "frequency": "ONDEMAND",        //As per requirement 
      "type": "VARIABLE",
    }
  },
  "merchantCallbackURL": "https://api.prod.payglocal.in/gl/v1/payments/merchantCallback"
}
```  

**Endpoint:** `/gl/v1/payments/initiate/paycollect`  
**Copyable Endpoint:** `/gl/v1/payments/initiate/paycollect`  

**Benefits:**  
- Flexible payments for usage-based billing.  
- One-time setup automates variable billing.  
- Secure JWE/JWS encryption.  

*Contact PayGlocal support to configure Variable SI for your merchant account.*
''',
                            route: '/paycollect/bill_payment',
                            icon: Icons.repeat,
                            badge: 'Variable SI',
                            badgeColor: AppTheme.darkRecurringAmber,
                            benefits: [
                              'Flexible variable payments',
                              'Automates usage-based billing',
                              'Secure JWE/JWS encryption',
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  // const SizedBox(height: 24),
                  // ScaleTransition(
                  //   scale: _decorationAnimation,
                  //   child: Container(
                  //     height: 10,
                  //     width: 300,
                  //     decoration: BoxDecoration(
                  //       gradient: const LinearGradient(
                  //         colors: [
                  //           Color(0xFF8B5CF6),
                  //           Color(0xFFEC4899),
                  //         ],
                  //         begin: Alignment.bottomLeft,
                  //         end: Alignment.bottomRight,
                  //       ),
                  //       borderRadius: BorderRadius.circular(4),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.1),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 28, 110, 197),
                              Color.fromARGB(255, 236, 137, 32),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        // child: Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     Text(
                        //       '\$',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       '€',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       '₹',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       '£',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       '¥',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       'A\$',
                        //       style: GoogleFonts.notoSans(
                        //         fontSize: isLargeScreen ? 24 : 20,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ],
                        // ),
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

// class WavePainter extends CustomPainter {
//   final double animationValue;

//   WavePainter({required this.animationValue});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF6D28D9).withOpacity(0.1)
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     final waveHeight = size.height * 0.2;
//     final waveCount = 3; // Number of wave cycles
//     final offset = animationValue * size.width / waveCount;

//     path.moveTo(0, size.height * 0.7);
//     for (double x = 0; x <= size.width; x += size.width / (waveCount * 20)) {
//       final t = (x / size.width) * waveCount * 2 * 3.14159 + offset;
//       final y = size.height * 0.7 + waveHeight * (sin(t) * 0.5 + 0.5);
//       if (x == 0) {
//         path.moveTo(x - offset, y);
//       } else {
//         final prevX = x - size.width / (waveCount * 20);
//         final prevT = (prevX / size.width) * waveCount * 2 * 3.14159 + offset;
//         final prevY = size.height * 0.7 + waveHeight * (sin(prevT) * 0.5 + 0.5);
//         final controlX1 = prevX + (x - prevX) / 3;
//         final controlY1 = prevY + (y - prevY) / 3;
//         final controlX2 = prevX + 2 * (x - prevX) / 3;
//         final controlY2 = prevY + 2 * (y - prevY) / 3;
//         path.cubicTo(controlX1, controlY1, controlX2, controlY2, x - offset, y);
//       }
//     }
//     path.lineTo(size.width - offset, size.height);
//     path.lineTo(-offset, size.height);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
      child: Card(
        color: const Color(0xFFF9FAFB),
        elevation: _isHovered ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
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
          hoverColor: const Color(0xFFF3F4F6),
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
                        style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 14 : 13,
                    color: const Color(0xFF4B5563),
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
                                      style: GoogleFonts.poppins(
                                        fontSize: isLargeScreen ? 13 : 12,
                                        color: const Color(0xFF4B5563),
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
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.route == '/paydirect/airline')
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/services/auth');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    Tooltip(
                      message: 'Learn more about ${widget.title}',
                      child: ElevatedButton(
                        onPressed: () => _showDetailsDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: _isHovered ? 2 : 0,
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.poppins(
                            fontSize: isLargeScreen ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Try ${widget.title} now',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: _isHovered ? 2 : 0,
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

    // Get today's date in YYYYMMDD format
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(today);

    // Replace startDate in payloads
    String updatedDetails = widget.details.replaceAll(
      '"startDate": "20220510"',
      '"startDate": "$formattedDate"',
    );

    List<Map<String, String>> payloads = [];
    RegExp payloadRegex = RegExp(r'```json\n([\s\S]*?)\n```', multiLine: true);
    Iterable<Match> payloadMatches = payloadRegex.allMatches(updatedDetails);
    for (var match in payloadMatches) {
      String? payload = match.group(1)?.trim();
      if (payload != null) {
        payloads.add({
          'content': payload,
          'label': widget.title.contains('Fixed')
              ? 'Fixed SI Payload'
              : 'Variable SI Payload',
        });
      }
    }

    List<Map<String, String>> endpoints = [];
    RegExp endpointRegex = RegExp(
      r'\*\*Copyable Endpoint:\*\* `(.*?)(?<!\\)`',
      multiLine: true,
    );
    Iterable<Match> endpointMatches = endpointRegex.allMatches(updatedDetails);
    for (var match in endpointMatches) {
      String? endpoint = match.group(1)?.trim();
      if (endpoint != null) {
        endpoints.add({
          'content': endpoint,
          'label': 'SI Endpoint',
        });
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
                      color:Color(0xFF1F2937),
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
                            })
                            .catchError((e) {
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
              const SizedBox(height: 8),
              Text(
                'Payload SI Field Explanations:',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              ...[
                {
                  'field': widget.title.contains('Fixed')
                      ? 'standingInstruction.data.amount'
                      : 'standingInstruction.data.maxAmount',
                  'description': widget.title.contains('Fixed')
                      ? 'Fixed amount debited each cycle.'
                      : 'Maximum amount debited each cycle based on usage.'
                },
                {
                  'field': 'standingInstruction.data.numberOfPayments',
                  'description': 'Total number of recurring payments.'
                },
                {
                  'field': 'standingInstruction.data.frequency',
                  'description': 'Frequency of payments (e.g., MONTHLY).'
                },
                {
                  'field': 'standingInstruction.data.type',
                  'description': widget.title.contains('Fixed')
                      ? 'Set to "FIXED" for fixed-amount SI.'
                      : 'Set to "VARIABLE" for variable-amount SI.'
                },
                {
                  'field': 'standingInstruction.data.startDate',
                  'description': 'Start date of recurring payments (YYYYMMDD).'
                },
                {
                  'field': 'merchantCallbackURL',
                  'description': 'URL to receive payment status callback.'
                },
              ].map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: isLargeScreen ? 16 : 14,
                        color: widget.badgeColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${field['field']}: ${field['description']}',
                          style: GoogleFonts.poppins(
                            fontSize: bodyFontSize,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
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
                              ClipboardData(text: payload['content']!),
                            )
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payload copied to clipboard'),
                                ),
                              );
                            })
                            .catchError((e) {
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
