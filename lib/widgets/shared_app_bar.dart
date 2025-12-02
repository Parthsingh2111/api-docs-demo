import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../navigation/app_navigation.dart';

class SharedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Animation<double>? fadeAnimation;
  final List<Widget>? additionalActions;
  final Widget? leading;

  const SharedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.fadeAnimation,
    this.additionalActions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<SharedAppBar> createState() => _SharedAppBarState();
}

class _SharedAppBarState extends State<SharedAppBar> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          boxShadow: isDark ? AppTheme.shadowSM : [
            BoxShadow(
              color: AppTheme.gray900.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          leading: widget.leading,
          automaticallyImplyLeading: widget.leading == null,
          title: widget.fadeAnimation != null
            ? FadeTransition(
                  opacity: widget.fadeAnimation!,
                child: _buildTitle(),
              )
            : _buildTitle(),
          actions: isLargeScreen 
              ? _buildLargeScreenActions(context) 
              : isMediumScreen 
                  ? _buildMediumScreenActions(context)
                  : _buildSmallScreenActions(context),
          centerTitle: false,
          titleSpacing: AppTheme.spacing20,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (widget.subtitle == null || widget.subtitle!.isEmpty) {
      return Text(
        widget.title,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimary(context),
          letterSpacing: -0.5,
          height: 1.2,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextPrimary(context),
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.subtitle!,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondary(context),
            letterSpacing: 0.1,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLargeScreenActions(BuildContext context) {
    return [
      const SizedBox(width: AppTheme.spacing12),
      // Dark mode toggle with glassmorphism styling
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return _buildGlassmorphismButton(
            icon: themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: themeProvider.toggleTheme,
          );
        },
      ),
      const SizedBox(width: AppTheme.spacing8),
      // Additional actions if provided
      if (widget.additionalActions != null) ...widget.additionalActions!,
      const SizedBox(width: AppTheme.spacing20),
    ];
  }

  List<Widget> _buildMediumScreenActions(BuildContext context) {
    return [
      const SizedBox(width: AppTheme.spacing12),
      // Dark mode toggle with glassmorphism styling
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return _buildGlassmorphismButton(
            icon: themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: themeProvider.toggleTheme,
          );
        },
      ),
      const SizedBox(width: AppTheme.spacing8),
      // Additional actions if provided
      if (widget.additionalActions != null) ...widget.additionalActions!,
      const SizedBox(width: AppTheme.spacing20),
    ];
  }

  List<Widget> _buildSmallScreenActions(BuildContext context) {
    return [
      const SizedBox(width: AppTheme.spacing12),
      // Dark mode toggle with glassmorphism styling
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return _buildGlassmorphismButton(
            icon: themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: themeProvider.toggleTheme,
          );
        },
      ),
      const SizedBox(width: AppTheme.spacing8),
      // Additional actions if provided
      if (widget.additionalActions != null) ...widget.additionalActions!,
      const SizedBox(width: AppTheme.spacing20),
    ];
  }


  // Helper method to build modern buttons
  Widget _buildGlassmorphismButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _animationController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _animationController.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppTheme.getSurfaceColor(context)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    child: Icon(
                      icon,
                      color: AppTheme.getTextPrimary(context),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

class _PayloadStructureDialog extends StatefulWidget {
  @override
  _PayloadStructureDialogState createState() => _PayloadStructureDialogState();
}

class _PayloadStructureDialogState extends State<_PayloadStructureDialog> {
  String _search = '';
  int _selected = 0;

  final List<_MerchantPayload> _payloads = [
    _MerchantPayload(
      name: 'E-commerce',
      icon: Icons.shopping_cart,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId":"23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "15",
    "txnCurrency": "USD",
    "billingData": {
      "firstName":"John",
      "lastName":"Denver",
      "addressStreet1":"Test123",
      "addressStreet2":"Punctuality lane",
      "addressCity":"Bangalore",
      "addressState":"Karnataka",
      "addressPostalCode":"560094",
      "addressCountry":"IN",
      "emailId": "johndenver@myemail.com"
    }
  },
  "riskData" : {
    "shippingData" : {
      "firstName":"John",
      "lastName":"Denver",
      "addressStreet1":"Test123",
      "addressStreet2":"Punctuality lane",
      "addressCity":"Bangalore",
      "addressState":"Karnataka",
      "addressPostalCode":"560094",
      "addressCountry":"IN",
      "emailId": "johndenver@myemail.com",
      "callingCode" : "+91",
      "phoneNumber": "9008018469"
    }
  },
  "merchantCallbackURL":"https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
    _MerchantPayload(
      name: 'Travel & Airlines',
      icon: Icons.flight,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId": "1756728697873338303",
  "captureTxn": false,
  "paymentData": {
    "totalAmount": "117800.00",
    "txnCurrency": "INR"
  },
  "riskData": {
    "flightData": [
      {
        "journeyType": "ONEWAY",
        "reservationDate": "20250901",
        "legData": [
          {
            "routeId": "1",
            "legId": "1",
            "flightNumber": "BA112",
            "departureAirportCode": "BLR",
            "departureCity": "Bengaluru",
            "departureDate": "2025-09-01T03:45:00Z",
            "arrivalAirportCode": "LAX",
            "arrivalCity": "Los Angeles",
            "arrivalDate": "2025-09-01T13:15:00Z",
            "carrierCode": "B7",
            "serviceClass": "ECONOMY"
          }
        ],
        "passengerData": [
          {
            "firstName": "Sam",
            "lastName": "Thomas"
          }
        ]
      }
    ]
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
    _MerchantPayload(
      name: 'Bill Payment',
      icon: Icons.receipt,
      pretty: _prettyJson({
        "merchantTxnId": "TXN_${DateTime.now().millisecondsSinceEpoch}",
        "paymentData": {
          "totalAmount": "1500.00",
          "txnCurrency": "INR"
        },
        "merchantCallbackURL": "https://your-domain.com/callback",
        "billingData": {
          "firstName": "Sarah",
          "lastName": "Wilson",
          "emailId": "sarah.wilson@example.com",
          "mobileNo": "9876543210",
          "address1": "321 Bill Street",
          "city": "Chennai",
          "state": "Tamil Nadu",
          "country": "IN",
          "postalCode": "600001"
        }
      }),
    ),
    _MerchantPayload(
      name: 'Card (Tokenized)',
      icon: Icons.credit_card,
      pretty: _prettyJson(
        {
        "merchantTxnId": "TXN_1757006600853",
        "paymentData": {
          "totalAmount": "999.00",
          "txnCurrency": "INR",
          "tokenData": {
            "altId": "true",
            "number": "4039073788299302",
            "expiryMonth": "07",
            "expiryYear": "2026",
            "securityCode": "322",
            "cryptogram": "BASE64_CRYPTOGRAM_SAMPLE",
            "requestorID": "REQ123456",
            "hashOfFirstSix": "HASH123ABC",
            "firstSix": "403907",
            "lastFour": "9302",
            "cardBrand": "visa",
            "cardCountryCode": "USA",
            "cardIssuerName": "HDFC Bank",
            "cardType": "Debit",
            "cardCategory": "Classic"
          },
          "billingData": {
            "firstName": "John",
            "lastName": "Denver",
            "emailId": "john.denver@example.com",
            "mobileNo": "9008018469",
            "address1": "Rowley street 1",
            "address2": "Punctuality lane",
            "city": "Bangalore",
            "state": "Karnataka",
            "postalCode": "560094",
            "country": "IN"
          }
        },
        "merchantCallbackURL": "https://your-domain.com/callback",
      }
      ),
    ),
    _MerchantPayload(
      name: 'Standing Instruction',
      icon: Icons.repeat,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId": "1756728757520948273",
  "paymentData": {
    "totalAmount": "499.00",
    "txnCurrency": "INR"
  },
  "standingInstruction": {
    "data": {
      "amount": "499.00",
      "numberOfPayments": "12",
      "frequency": "MONTHLY",
      "type": "FIXED",
      "startDate": "20251001"
    }
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
    _MerchantPayload(
      name: 'Airline Booking',
      icon: Icons.flight_takeoff,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId": "1756728697873338303",
  "captureTxn": false,
  "paymentData": {"totalAmount": "117800.00", "txnCurrency": "INR"},
  "riskData": {
    "flightData": [
      {
        "journeyType": "ONEWAY",
        "reservationDate": "20250901",
        "legData": [
          {
            "routeId": "1",
            "legId": "1",
            "flightNumber": "BA112",
            "departureAirportCode": "BLR",
            "departureCity": "Bengaluru",
            "departureDate": "2025-09-01T03:45:00Z",
            "arrivalAirportCode": "LAX",
            "arrivalCity": "Los Angeles",
            "arrivalDate": "2025-09-01T13:15:00Z",
            "carrierCode": "B7",
            "serviceClass": "ECONOMY"
          }
        ],
        "passengerData": [
          {"firstName": "Sam", "lastName": "Thomas"}
        ]
      }
    ]
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
    _MerchantPayload(
      name: 'Lodging / Hotel',
      icon: Icons.hotel,
      pretty: _prettyJson({
        "merchantTxnId": "TXN_1756806272401",
        "paymentData": {
          "totalAmount": "12000.00",
          "txnCurrency": "INR"
        },
        "merchantCallbackURL": "https://your-domain.com/callback",
        "riskData": {
          "lodgingData": [
            {
              "checkInDate": "20250104",
              "checkOutDate": "20250106",
              "city": "Mumbai",
              "country": "IN",
              "lodgingType": "Hotel",
              "lodgingName": "Lake View",
              "rating": "4",
              "cancellationPolicy": "NC",
              "bookingPersonFirstName": "John",
              "bookingPersonLastName": "Bell",
              "bookingPersonEmailId": "john.bell@example.com",
              "bookingPersonPhoneNumber": "2011915716",
              "bookingPersonCallingCode": "+91",
              "rooms": [
                {
                  "numberOfGuests": "2",
                  "roomType": "Twin",
                  "roomCategory": "Deluxe",
                  "numberOfNights": "2",
                  "roomPrice": "3200",
                  "guestFirstName": "Ricky",
                  "guestLastName": "Martin",
                  "guestEmail": "ricky.martin@example.com"
                }
              ]
            }
          ]
        }
      }
      ),
    ),
    _MerchantPayload(
      name: 'Cab Booking',
      icon: Icons.directions_bus,
      pretty: _prettyJson(jsonDecode(r'''{
        "merchantTxnId": "1756728697873338303",
        "captureTxn": false,
        "paymentData": {
          "totalAmount": "117800.00",
          "txnCurrency": "INR"
        },
        "riskData": {
          "cabData": [
            {
              "legData": [
                {
                  "routeId": "1",
                  "legId": "1",
                  "pickupDate": "2023-03-20T09:01:56Z"
                }
              ],
              "passengerData": [
                {
                  "firstName": "Sam",
                  "lastName": "Thomas"
                }
              ]
            }
          ]
        },
        "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
 _MerchantPayload(
      name: 'Train Booking',
      icon: Icons.train,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId": "1756728697873338303",
  "captureTxn": false,
  "paymentData": {"totalAmount": "117800.00", "txnCurrency": "INR"},
  "riskData": {
    "trainData": [
      {
        "ticketNumber": "ticket12346",
        "reservationDate": "20230220",
        "legData": [
          {
            "routeId": "1",
            "legId": "1",
            "trainNumber": "train123",
            "departureCity": "Kannur",
            "departureCountry": "IN",
            "departureDate": "2023-03-20T09:01:56Z",
            "arrivalCity": "Coimbatore",
            "arrivalCountry": "IN",
            "arrivalDate": "2023-03-21T09:01:56Z"
          }
        ],
        "passengerData": [
          {"firstName": "Sam", "lastName": "Thomas", "dateOfBirth": "19980320", "passportCountry": "IN"}
        ]
      }
    ]
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),

    _MerchantPayload(
      name: 'Ship Booking',
      icon: Icons.local_taxi,
      pretty: _prettyJson(jsonDecode(r'''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "captureTxn": false,
  "paymentData": {
    "totalAmount": "15",
    "txnCurrency": "USD",
    "billingData": {
      "firstName": "John",
      "lastName": "Denver",
      "addressStreet1": "Test123",
      "addressStreet2": "Punctuality lane",
      "addressCity": "Bangalore",
      "addressState": "Karnataka",
      "addressPostalCode": "560094",
      "addressCountry": "IN",
      "emailId": "johndenver@myemail.com"
    }
  },
  "riskData": {
    "shippingData": {
      "firstName": "John",
      "lastName": "Denver",
      "addressStreet1": "Test123",
      "addressStreet2": "Punctuality lane",
      "addressCity": "Bangalore",
      "addressState": "Karnataka",
      "addressPostalCode": "560094",
      "addressCountry": "IN",
      "emailId": "johndenver@myemail.com",
      "callingCode": "+91",
      "phoneNumber": "9008018469"
    }
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''')),
    ),
  ];

  List<_MerchantPayload> get filtered => _payloads
      .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payload Structure',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                IconButton(
                  onPressed: () => AppNavigation.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search merchant type...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: filtered.isNotEmpty
                  ? filtered.indexWhere((p) => p.name == _payloads[_selected].name)
                  : 0,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                labelText: 'Merchant Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              items: filtered.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                return DropdownMenuItem<int>(
                  value: idx,
                  child: Row(
                    children: [
                      Icon(p.icon, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (idx) {
                if (idx != null) {
                  final selectedPayload = filtered[idx];
                  final realIdx = _payloads.indexWhere((p) => p.name == selectedPayload.name);
                  setState(() => _selected = realIdx);
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Payload', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SelectableText(
                    _payloads[_selected].pretty,
                    style: GoogleFonts.robotoMono(
                      fontSize: 15,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _payloads[_selected].pretty));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payload copied!')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MerchantPayload {
  final String name;
  final IconData icon;
  final String pretty;
  _MerchantPayload({required this.name, required this.icon, required this.pretty});
}

// Pretty JSON helper
String _prettyJson(Map<String, dynamic> json) => const JsonEncoder.withIndent('  ').convert(json); 






