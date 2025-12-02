import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static const Environment _environment = Environment.development;
  
  // API Configuration
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000';  //js - 3000, php - 3001, csh - 5000
      case Environment.staging:
        return 'https://api-staging.payglocal.in';
      case Environment.production:
        return 'https://api.payglocal.in';
    }
  }
  
  // Updated to match backend routes (using /api/pay/ instead of /api/payment/)
  static String get jwtPaymentUrl => '$baseUrl/api/pay/jwt';
  static String get apiKeyPaymentUrl => '$baseUrl/api/pay/apikey';
  static String get statusUrl => '$baseUrl/api/status';
  static String get refundUrl => '$baseUrl/api/refund';
  static String get siPaymentUrl => '$baseUrl/api/pay/si';
  static String get authUrl => '$baseUrl/api/pay/auth';
  static String get altPayUrl => '$baseUrl/api/pay/alt';
  static String get captureUrl => '$baseUrl/api/cap';
  static String get authReversalUrl => '$baseUrl/api/authreversal';
  static String get pauseActivateUrl => '$baseUrl/api/pauseActivate';
  static String get siOnDemandUrl => '$baseUrl/api/siOnDemand';
  static String get codeDropUrl => '$baseUrl/api/codedrop';
  static String get siStatusUrl => '$baseUrl/api/siStatus';
    
  // App Configuration
  static bool get isDebugMode => kDebugMode;
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  
  // Logging Configuration
  static bool get enableLogging => !isProduction || kDebugMode;
  
  // Timeout Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration paymentTimeout = Duration(minutes: 5);
  
  // Security Configuration
  static bool get enableCertificatePinning => isProduction;
  static bool get enableHttpsOnly => isProduction || isStaging;
}
