import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:centralproject/constants/api_constants.dart';
import 'package:centralproject/config/app_config.dart';
import 'package:centralproject/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

String? gid; // Declare gid to avoid compilation error

String generateMerchantTxnId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random();
  final randomDigits = List.generate(6, (_) => random.nextInt(10)).join();
  return '$timestamp$randomDigits';
}

////////////////////////////JWT Payment Handlers////////////////////////////////

Future<void> handlePcJwtPayment(
  String amount,
  String currency,
  BuildContext context,
) async {
  try {
    Logger.payment('Initiating PayCollect JWT payment', {
      'amount': amount,
      'currency': currency,
    });
    
    final merchantTxnId = generateMerchantTxnId();
    final payload = {
      "merchantTxnId": merchantTxnId,
       "merchantUniqueId": "123456789012",
      "paymentData": {"totalAmount": amount, "txnCurrency": currency},
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
          // "https://a9f657c269fc.ngrok-free.app/callbackurl"
    };
     
     Logger.payment('payload is', {
      'payloaddd': payload,
    });
    
    
    Logger.debug('Sending payment request', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(jwtPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('Payment request timed out', 'Payment');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request timed out. Please try again.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return http.Response('Timeout', 408);
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('Payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        Logger.error('No payment link received from server', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No payment link received.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('Payment launched successfully', 'Payment');
      } else {
        Logger.error('Could not launch payment link', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch payment link.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('Payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment request failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

     
     


  } catch (error, stackTrace) {
    Logger.error('Unexpected error in payment processing', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// Updated function signature to match existing usage
Future<void> handlePdJwtPayment(
  BuildContext context,
  Map<String, dynamic> payload,
) async {
  try {
    Logger.payment('Initiating PayDirect JWT payment', payload);
    
    final merchantTxnId = generateMerchantTxnId();
    final finalPayload = {
      "merchantTxnId": merchantTxnId,
      ...payload,
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('Sending PayDirect payment request', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(jwtPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(finalPayload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('PayDirect payment request timed out', 'Payment');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request timed out. Please try again.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return http.Response('Timeout', 408);
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('PayDirect payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        Logger.error('No payment link received from server', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No payment link received.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('PayDirect payment launched successfully', 'Payment');
      } else {
        Logger.error('Could not launch PayDirect payment link', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch payment link.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('PayDirect payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment request failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  } catch (error, stackTrace) {
    Logger.error('Unexpected error in PayDirect payment processing', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// Updated function signature to match existing usage
Future<void> handlePdAltPayment(
  BuildContext context,
  Map<String, dynamic> altPayPayload,
) async {
  try {
    Logger.payment('Initiating Alt Payment', altPayPayload);
    
    Logger.debug('Alt Pay payload prepared', 'Payment');

    final response = await http
        .post(
          Uri.parse(altPayUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(altPayPayload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('Alt payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final paymentLink = responseData['payment_link'];
      
      Logger.payment('Alt Pay Response received', responseData);

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('Alt payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alt Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('Alt payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('Alt payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('Alt Payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alt Payment failed: $error',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    throw Exception('Alt Payment error: $error');
  }
}

// Standing Instruction Payment Handlers
final startDate = DateFormat('yyyyMMdd').format(DateTime.now().add(Duration(days: 30)));

Future<void> handlePcFixedSIPayment(
  String amount,
  String currency,
  BuildContext context,
) async {
  try {
    Logger.payment('Initiating PayCollect Fixed SI Payment', {
      'amount': amount,
      'currency': currency,
    });
    
    final merchantTxnId = generateMerchantTxnId();
    final payload = {
      "merchantTxnId": merchantTxnId,
      "paymentData": {"totalAmount": amount, "txnCurrency": currency},
      "standingInstruction": {
        "data": {
          "amount": amount,
          "numberOfPayments": "12",
          "frequency": "MONTHLY",
          "type": "FIXED",
          "startDate": startDate.toString(),
        },
      },
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('Fixed SI payment payload prepared', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(siPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('Fixed SI payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );
        

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('Fixed SI payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('Fixed SI payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('Fixed SI payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('Fixed SI payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('Fixed SI payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    throw Exception('Error: $error');
  }
}

Future<void> handlePdFixedSIPayment(payload, BuildContext context) async {
  try {
    Logger.payment('Initiating PayDirect Fixed SI Payment', payload);
    
    final merchantTxnId = generateMerchantTxnId();
    final finalPayload = {
      "merchantTxnId": merchantTxnId,
      ...payload,
      'standingInstruction': {
        'data': {
          'amount': payload['paymentData']['totalAmount'],
          'numberOfPayments': "12",
          'frequency': 'MONTHLY',
          'type': 'FIXED',
          'startDate': startDate.toString(),
        },
      },
    };
    
    Logger.debug('PayDirect Fixed SI payment payload prepared', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(siPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(finalPayload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('PayDirect Fixed SI payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('PayDirect Fixed SI payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('PayDirect Fixed SI payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('PayDirect Fixed SI payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('PayDirect Fixed SI payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('PayDirect Fixed SI payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    throw Exception('Error: $error');
  }
}

Future<void> handlePdVariableSIPayment(
  String totalBill,
  BuildContext context,
) async {
  try {
    Logger.payment('Initiating PayDirect Variable SI Payment', {
      'bill': totalBill,
    });
    
    final merchantTxnId = generateMerchantTxnId();
    final finalPayload = {
      "merchantTxnId": merchantTxnId,
      "paymentData": {
        "totalAmount": totalBill,
        "txnCurrency": 'INR',
        'cardData': {
            'number': "4242424242424242",
            'expiryMonth': "12",
            'expiryYear': "30",
            'securityCode': "123",
          },
      },
      'standingInstruction': {
        'data': {
          'maxAmount': totalBill,
          'numberOfPayments': "12",
          'frequency': 'MONTHLY',
          'type': 'VARIABLE',
        },
      },
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('PayDirect Variable SI payment payload prepared', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(siPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(finalPayload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('PayDirect Variable SI payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('PayDirect Variable SI payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('PayDirect Variable SI payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('PayDirect Variable SI payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('PayDirect Variable SI payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('PayDirect Variable SI payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    throw Exception('Error: $error');
  }
}

// Add missing handleAuthPayment function
Future<void> handleAuthPayment(BuildContext context, Map<String, dynamic> paymentData) async {
  try {
    Logger.payment('Initiating Auth Payment', paymentData);
    
    final merchantTxnId = generateMerchantTxnId();
    final payload = {
      "merchantTxnId": merchantTxnId,
      "captureTxn": false,
      ...paymentData,
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('Sending auth payment request', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(authUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('Auth payment request timed out', 'Payment');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request timed out. Please try again.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return http.Response('Timeout', 408);
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('Auth payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        Logger.error('No payment link received from server', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No payment link received.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('Auth payment launched successfully', 'Payment');
      } else {
        Logger.error('Could not launch auth payment link', 'Payment');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch payment link.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('Auth payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment request failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  } catch (error, stackTrace) {
    Logger.error('Unexpected error in auth payment processing', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// Add missing handlePcVariableSIPayment function
Future<void> handlePcVariableSIPayment(
  String totalBill,
  BuildContext context,
) async {
  try {
    Logger.payment('Initiating PayCollect Variable SI Payment', {
      'bill': totalBill,
    });
    
    final merchantTxnId = generateMerchantTxnId();
    final payload = {
      "merchantTxnId": merchantTxnId,
      "paymentData": {
        "totalAmount": totalBill,
        "txnCurrency": 'INR',
      },
      'standingInstruction': {
        'data': {
          'maxAmount': totalBill,
          'numberOfPayments': "12",
          'frequency': 'ONDEMAND',
          'type': 'VARIABLE',
        },
      },
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('PayCollect Variable SI payment payload prepared', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(siPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('PayCollect Variable SI payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('PayCollect Variable SI payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('PayCollect Variable SI payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('PayCollect Variable SI payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('PayCollect Variable SI payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('PayCollect Variable SI payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    throw Exception('Error: $error');
  }
}

// Update handlePdVariableSIPayment to match the old signature
Future<void> handlePdVariableSIPaymentOld(
  cardNumber,
  String expiry,
  String cvv,
  String bill,
  BuildContext context,
) async {
  try {
    Logger.payment('Initiating PayDirect Variable SI Payment (Old)', {
      'cardNumber': '****${cardNumber.toString().substring(cardNumber.toString().length - 4)}',
      'bill': bill,
    });
    
    final merchantTxnId = generateMerchantTxnId();
    final finalPayload = {
      "merchantTxnId": merchantTxnId,
      "paymentData": {
        "totalAmount": bill,
        "txnCurrency": 'INR',
        'cardData': {
            'number': cardNumber.toString(),
            'expiryMonth': "12",
            'expiryYear': "30",
            'securityCode': cvv,
          },
      },
      'standingInstruction': {
        'data': {
          'maxAmount': bill,
          'numberOfPayments': "12",
          'frequency': 'MONTHLY',
          'type': 'VARIABLE',
        },
      },
      "merchantCallbackURL":
          "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback",
    };
    
    Logger.debug('PayDirect Variable SI payment payload prepared', 'Payment');
    
    final response = await http
        .post(
          Uri.parse(siPaymentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(finalPayload),
        )
        .timeout(
          AppConfig.apiTimeout,
          onTimeout: () {
            Logger.error('PayDirect Variable SI payment request timed out', 'Payment');
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Logger.payment('PayDirect Variable SI payment response received', responseData);
      
      final paymentLink = responseData['payment_link'];
      gid = responseData['gid'];

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('No payment link received');
      }

      final paymentUri = Uri.parse(paymentLink);
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        Logger.info('PayDirect Variable SI payment launched successfully', 'Payment');
      } else {
        throw Exception('Could not launch payment link');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Initiated! Redirecting...',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      Logger.error('PayDirect Variable SI payment request failed with status: ${response.statusCode}', 'Payment', 
          'Response body: ${response.body}');
      throw Exception('PayDirect Variable SI payment request failed: ${response.statusCode} - ${response.body}');
    }
  } catch (error, stackTrace) {
    Logger.error('PayDirect Variable SI payment error', 'Payment', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    throw Exception('Error: $error');
  }
}
