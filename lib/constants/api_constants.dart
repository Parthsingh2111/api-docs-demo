import '../config/app_config.dart';

// Use centralized configuration instead of hardcoded URLs
String get jwtPaymentUrl => AppConfig.jwtPaymentUrl;
String get apiKeyPaymentUrl => AppConfig.apiKeyPaymentUrl;
String get statusUrl => AppConfig.statusUrl;
String get refundUrl => AppConfig.refundUrl;
String get siPaymentUrl => AppConfig.siPaymentUrl;
String get authUrl => AppConfig.authUrl;
String get altPayUrl => AppConfig.altPayUrl;
String get captureUrl => AppConfig.captureUrl;
String get authReversalUrl => AppConfig.authReversalUrl;
String get pauseActivateUrl => AppConfig.pauseActivateUrl;
String get codeDropUrl => AppConfig.codeDropUrl;
String get siOnDemandUrl => AppConfig.siOnDemandUrl;

String gid = '';

// Legacy commented code for reference
// C# Backend URLs
// String get jwtPaymentUrl => 'http://localhost:5000/api/payment/jwt';
// String get apiKeyPaymentUrl => 'http://localhost:5000/api/payment/apikey';
// String get statusUrl => 'http://localhost:5000/api/status';
// String get refundUrl => 'http://localhost:5000/api/refund';
// String get siPaymentUrl => 'http://localhost:5000/api/payment/si';
// String get authUrl => 'http://localhost:5000/api/payment/auth';
// String get altPayUrl => 'http://localhost:5000/api/payment/alt';
// String get captureUrl => 'http://localhost:5000/api/cap';
// String get authReversalUrl => 'http://localhost:5000/api/authreversal'; 
// String get pauseActivateUrl => 'http://localhost:5000/api/pauseActivate'; 

// js code
// String ngrokUrl = 'https://d318-122-172-84-38.ngrok-free.app';
// String get jwtPaymentUrl => 'http://localhost:3000/api/pay/jwt';
// String get apiKeyPaymentUrl => 'http://localhost:3000/api/pay/apikey';
// String get statusUrl => 'http://localhost:3000/api/status';
// String get refundUrl => 'http://localhost:3000/api/refund';
// String get siPaymentUrl => 'http://localhost:3000/api/pay/si';
// String get authUrl => 'http://localhost:3000/api/pay/auth';
// String get altPayUrl => 'http://localhost:3000/api/pay/alt';
// String get captureUrl => 'http://localhost:3000/api/cap';
// String get authReversalUrl => 'http://localhost:3000/api/authreversal'; 
// String get pauseActivateUrl => 'http://localhost:5000/api/pauseActivate'; 
// String gid = '';

// PHP Backend (commented out)
// String get jwtPaymentUrl => 'http://localhost:3001/api/pay/jwt';
// String get apiKeyPaymentUrl => 'http://localhost:3001/api/pay/apikey';
// String get statusUrl => 'http://localhost:3001/api/status';
// String get refundUrl => 'http://localhost:3001/api/refund';
// String get siPaymentUrl => 'http://localhost:3001/api/pay/si';
// String get authUrl => 'http://localhost:3001/api/pay/auth';
// String get altPayUrl => 'http://localhost:3001/api/pay/alt';
// String get captureUrl => 'http://localhost:3001/api/cap';
// String get authReversalUrl => 'http://localhost:3001/api/authreversal'; 
// String get pauseActivateUrl => 'http://localhost:3001/api/pauseActivate'; 
// String gid = '';

// Java Backend (commented out)
// String get jwtPaymentUrl => 'http://localhost:8085/api/pay/jwt';
// String get apiKeyPaymentUrl => 'http://localhost:8085/api/pay/apikey';
// String get statusUrl => 'http://localhost:8085/api/status';
// String get refundUrl => 'http://localhost:8085/api/refund';
// String get siPaymentUrl => 'http://localhost:8085/api/pay/si';
// String get authUrl => 'http://localhost:8085/api/pay/auth';
// String get altPayUrl => 'http://localhost:8080/api/pay/alt';
// String get captureUrl => 'http://localhost:8085/api/cap';
// String get authReversalUrl => 'http://localhost:8085/api/authreversal'; 
// String get pauseActivateUrl => 'http://localhost:8085/api/pauseActivate'; 
// String gid = '';
