import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class Logger {
  static void debug(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      if (kDebugMode) {
        print('[DEBUG${tag != null ? ' - $tag' : ''}] $message');
      }
    }
  }
  
  static void info(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      print('[INFO${tag != null ? ' - $tag' : ''}] $message');
    }
  }
  
  static void warning(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      print('[WARNING${tag != null ? ' - $tag' : ''}] $message');
    }
  }
  
  static void error(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      print('[ERROR${tag != null ? ' - $tag' : ''}] $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null && kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  static void payment(String message, [Map<String, dynamic>? data]) {
    if (AppConfig.enableLogging) {
      print('[PAYMENT] $message');
      if (data != null && kDebugMode) {
        print('Payment data: $data');
      }
    }
  }
}


 
