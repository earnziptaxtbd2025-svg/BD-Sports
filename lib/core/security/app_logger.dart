import 'package:flutter/foundation.dart';

import 'redactor.dart';

/// The only way the app should write logs.
///
/// - Prints nothing in release builds, so nothing leaks through the phone's log.
/// - In development, every message is scrubbed of phone numbers, emails and tokens.
class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(Redactor.scrub(message));
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      final suffix = error == null ? '' : ' | $error';
      debugPrint(Redactor.scrub('ERROR: $message$suffix'));
    }
  }
}
