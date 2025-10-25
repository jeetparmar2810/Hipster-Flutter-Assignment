import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = '📱 AppLog';

  static void i(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [INFO] $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [WARN] $message');
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag [ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}