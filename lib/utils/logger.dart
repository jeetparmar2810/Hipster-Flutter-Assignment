import 'package:flutter/foundation.dart';

/// A simple centralized logger utility for the app.
/// Use `Logger.i()`, `Logger.w()`, or `Logger.e()` instead of print().
class Logger {
  static const String _tag = '📱 AppLog';

  /// Info log (normal flow)
  static void i(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [INFO] $message');
    }
  }

  /// Warning log (something unexpected but not fatal)
  static void w(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [WARN] ⚠️ $message');
    }
  }

  /// Error log (exception, failure, etc.)
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag [ERROR] ❌ $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}