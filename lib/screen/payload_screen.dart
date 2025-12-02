import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PayloadScreen extends StatefulWidget {
  const PayloadScreen({super.key});

  @override
  State<PayloadScreen> createState() => _PayloadScreenState();
}

class _PayloadScreenState extends State<PayloadScreen> {
  late final Map<String, String> templateNameToJson;
  String selectedTemplate = 'Minimum Required Payload';

  @override
  void initState() {
    super.initState();
    templateNameToJson = {
      'Minimum Required Payload': '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "15",
    "txnCurrency": "USD"
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''',
      'E-commerce': '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "15",
    "txnCurrency": "USD"
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
}''',
      'Digital Product/Service': '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
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
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''',
      'Flight Oneway': '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF07",
  "paymentData": {
    "totalAmount": "101",
    "txnCurrency": "INR",
    "billingData": {
      "firstName": "Sam",
      "lastName": "Thomas",
      "addressStreet1": "Apartment 9B,235 East,43rd Street",
      "addressCity": "New York",
      "addressState": "New York",
      "addressCountry": "US",
      "emailId": "sam.thomas@gmail.com"
    }
  },
  "riskData": {
    "flightData": [
      {
        "journeyType": "ONEWAY",
        "ticketNumber": "ticket12345",
        "reservationDate": "20251201",
        "legData": [
          {
            "routeId": "1",
            "legId": "1",
            "flightNumber": "flight123",
            "departureAirportCode": "AUH",
            "departureCity": "Abu Dhabi",
            "departureCountry": "AE",
            "departureDate": "2023-03-20T09:01:56Z",
            "arrivalAirportCode": "BLR",
            "arrivalCity": "Bangalore",
            "arrivalCountry": "IN",
            "arrivalDate": "2023-03-21T09:01:56Z",
            "carrierCode": "AAL",
            "airlineServiceClass": "ECONOMY"
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
}''',
      'Flight Return': '''{
  "merchantTxnId": "23AEE8CB6B62EE2AF08",
  "paymentData": {
    "totalAmount": "2902",
    "txnCurrency": "INR",
    "billingData": {
      "firstName": "Roy",
      "lastName": "Thomas",
      "addressStreet1": "Apartment 9B, 235 East, 43rd Street",
      "addressCity": "New York",
      "addressState": "New York",
      "addressCountry": "US",
      "emailId": "sam.thomas@gmail.com"
    }
  },
  "riskData": {
    "billingData": {
      "emailId": "sam.thomas@gmail.com"
    },
    "flightData": [
      {
        "journeyType": "RETURN",
        "ticketNumber": "ticket56789",
        "reservationDate": "20250601",
        "legData": [
          {
            "routeId": "1",
            "legId": "1",
            "flightNumber": "NY123",
            "departureAirportCode": "JFK",
            "departureCity": "New York",
            "departureCountry": "US",
            "departureDate": "2024-06-10T08:00:00Z",
            "arrivalAirportCode": "AUH",
            "arrivalCity": "Abu Dhabi",
            "arrivalCountry": "AE",
            "arrivalDate": "2024-06-10T20:00:00Z",
            "carrierCode": "AAL",
            "airlineServiceClass": "ECONOMY"
          },
          {
            "routeId": "1",
            "legId": "2",
            "flightNumber": "AUH456",
            "departureAirportCode": "AUH",
            "departureCity": "Abu Dhabi",
            "departureCountry": "AE",
            "departureDate": "2024-06-11T02:00:00Z",
            "arrivalAirportCode": "BLR",
            "arrivalCity": "Bangalore",
            "arrivalCountry": "IN",
            "arrivalDate": "2024-06-11T08:00:00Z",
            "carrierCode": "AAL",
            "airlineServiceClass": "ECONOMY"
          },
          {
            "routeId": "2",
            "legId": "1",
            "flightNumber": "BLR789",
            "departureAirportCode": "BLR",
            "departureCity": "Bangalore",
            "departureCountry": "IN",
            "departureDate": "2024-06-20T10:00:00Z",
            "arrivalAirportCode": "AUH",
            "arrivalCity": "Abu Dhabi",
            "arrivalCountry": "AE",
            "arrivalDate": "2024-06-20T16:00:00Z",
            "carrierCode": "AAL",
            "airlineServiceClass": "ECONOMY"
          },
          {
            "routeId": "2",
            "legId": "2",
            "flightNumber": "AUH321",
            "departureAirportCode": "AUH",
            "departureCity": "Abu Dhabi",
            "departureCountry": "AE",
            "departureDate": "2024-06-21T00:00:00Z",
            "arrivalAirportCode": "JFK",
            "arrivalCity": "New York",
            "arrivalCountry": "US",
            "arrivalDate": "2024-06-21T10:00:00Z",
            "carrierCode": "AAL",
            "airlineServiceClass": "ECONOMY"
          }
        ],
        "passengerData": [
          {
            "firstName": "Sam",
            "lastName": "Thomas"
          },
          {
            "firstName": "John",
            "lastName": "Denver"
          }
        ]
      }
    ]
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''',
      'Token': '''{
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
  "merchantCallbackURL": "https://your-domain.com/callback"
}''',
      'SI Fixed': '''{
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
}''',
      'Hotel': '''{
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
}''',
      'Car Booking': '''{
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
}''',
      'Train': '''{
  "merchantTxnId": "1756728697873338303",
  "captureTxn": false,
  "paymentData": {
    "totalAmount": "117800.00",
    "txnCurrency": "INR"
  },
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
          {
            "firstName": "Sam",
            "lastName": "Thomas",
            "dateOfBirth": "19980320",
            "passportCountry": "IN"
          }
        ]
      }
    ]
  },
  "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
}''',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final String code = templateNameToJson[selectedTemplate] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payloads',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Select a template to view or copy a ready-to-use payload',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.spacing12),
              border: Border.all(color: isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TemplateDropdown(
                        isDarkMode: isDarkMode,
                        value: selectedTemplate,
                        items: templateNameToJson.keys.toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedTemplate = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Tooltip(
                      message: 'Copy to clipboard',
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: code));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied payload to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                            vertical: AppTheme.spacing8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                _codeBox(isDarkMode, code),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeBox(bool isDarkMode, String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppTheme.spacing8),
        border: Border.all(color: isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
      ),
      child: SelectableText(
        code,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _TemplateDropdown extends StatelessWidget {
  final bool isDarkMode;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _TemplateDropdown({
    required this.isDarkMode,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Template',
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.spacing8),
          borderSide: BorderSide(
            color: isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
