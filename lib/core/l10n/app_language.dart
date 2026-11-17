import 'package:flutter/widgets.dart';

/// Languages the app is available in.
enum AppLanguage {
  bangla('bn', 'বাংলা'),
  english('en', 'English');

  const AppLanguage(this.code, this.nativeName);

  /// Language code, also the value saved on the phone.
  final String code;

  /// The language's name written in that language, shown in the language screen.
  final String nativeName;

  Locale get locale => Locale(code);

  /// Bangla first: most people using this app read Bangla.
  static const AppLanguage defaultLanguage = AppLanguage.bangla;

  static AppLanguage fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }
    return defaultLanguage;
  }
}
