import 'validation_issue.dart';

/// Checks and cleans text typed by users. Used before saving or sending anything.
///
/// These checks protect the app. They return a [ValidationIssue], which the screen
/// turns into a message in the current language (see `AppStrings.validation`).
/// The server must repeat every check, because anyone can bypass a phone app.
class InputValidators {
  const InputValidators._();

  static const int maxAmountBdt = 10000000;

  /// Turns Bangla digits into 0-9 so "০১৭১২৩৪৫৬৭৮" works like "01712345678".
  static String toAsciiDigits(String input) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final index = bangla.indexOf(char);
      buffer.write(index >= 0 ? '$index' : char);
    }
    return buffer.toString();
  }

  /// Returns the number as +8801XXXXXXXXX, or null if it is not a valid
  /// Bangladesh mobile number (operators 013 to 019).
  static String? normalizeBdPhone(String input) {
    var digits = toAsciiDigits(input).replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    }
    if (digits.startsWith('880')) {
      digits = '0${digits.substring(3)}';
    }
    if (RegExp(r'^01[3-9]\d{8}$').hasMatch(digits)) {
      return '+88$digits';
    }
    return null;
  }

  /// Removes invisible and dangerous characters and tidies spaces.
  ///
  /// Zero-width joiner and non-joiner (U+200C, U+200D) are kept on purpose,
  /// because Bangla conjunct letters need them.
  static String sanitizeText(String input, {int maxLength = 500}) {
    var text = input
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '')
        // Zero-width space, direction marks and direction overrides, used to
        // disguise text (for example a fake name that reads backwards).
        .replaceAll(RegExp(r'[\u200B\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'), '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    final runes = text.runes.toList();
    if (runes.length > maxLength) {
      text = String.fromCharCodes(runes.take(maxLength));
    }
    return text;
  }

  static ValidationIssue? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationIssue.phoneRequired;
    }
    if (normalizeBdPhone(value) == null) {
      return ValidationIssue.phoneInvalid;
    }
    return null;
  }

  static ValidationIssue? validatePersonName(String? value) {
    final text = sanitizeText(value ?? '', maxLength: 200);
    if (text.length < 2) {
      return ValidationIssue.nameTooShort;
    }
    if (text.length > 60) {
      return ValidationIssue.nameTooLong;
    }
    final allowed = RegExp(
      r"^[\p{L}\p{M}\u200C\u200D\s.\-']+$",
      unicode: true,
    );
    if (!allowed.hasMatch(text)) {
      return ValidationIssue.nameInvalidChars;
    }
    return null;
  }

  static ValidationIssue? validateTournamentTitle(String? value) {
    final text = sanitizeText(value ?? '', maxLength: 300);
    if (text.length < 3) {
      return ValidationIssue.titleTooShort;
    }
    if (text.length > 80) {
      return ValidationIssue.titleTooLong;
    }
    if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text)) {
      return ValidationIssue.titleNeedsLetters;
    }
    return null;
  }

  /// Reads an amount in taka. Accepts commas and Bangla digits.
  static int? parseAmountBdt(String input) {
    final cleaned = toAsciiDigits(input).replaceAll(RegExp(r'[,\s]'), '');
    if (!RegExp(r'^\d{1,9}$').hasMatch(cleaned)) {
      return null;
    }
    final value = int.parse(cleaned);
    return value > maxAmountBdt ? null : value;
  }

  static ValidationIssue? validateAmountBdt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationIssue.amountRequired;
    }
    if (parseAmountBdt(value) == null) {
      return ValidationIssue.amountInvalid;
    }
    return null;
  }

  /// Accepts only normal https links. Rejects links with a hidden user name such as
  /// https://trusted.com@evil.com, which are a common phishing trick.
  static Uri? safeHttpsUrl(String input, {Set<String>? allowedHosts}) {
    final text = input.trim();
    if (text.isEmpty || text.length > 2048) {
      return null;
    }
    final uri = Uri.tryParse(text);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    if (allowedHosts != null && !allowedHosts.contains(uri.host.toLowerCase())) {
      return null;
    }
    return uri;
  }
}
