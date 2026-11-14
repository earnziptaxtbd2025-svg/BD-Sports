/// Hides personal data and secrets so they never appear in logs or error reports.
class Redactor {
  const Redactor._();

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      return '***';
    }
    return '${digits.substring(0, 3)}****${digits.substring(digits.length - 3)}';
  }

  static String maskEmail(String email) {
    final at = email.indexOf('@');
    if (at < 1) {
      return '***';
    }
    return '${email.substring(0, 1)}***${email.substring(at)}';
  }

  /// Masks phone numbers, emails, login tokens and "password=..." style secrets
  /// inside any text.
  static String scrub(String text) {
    var result = text;

    result = result.replaceAllMapped(
      RegExp(r'eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+'),
      (_) => '[token]',
    );

    result = result.replaceAllMapped(
      RegExp(
        r'(api[_-]?key|authorization|password|passwd|secret|token|otp)\s*[:=]\s*\S+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}=[redacted]',
    );

    result = result.replaceAllMapped(
      RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}'),
      (match) => maskEmail(match.group(0)!),
    );

    result = result.replaceAllMapped(
      RegExp(r'(?:\+?88)?01[3-9]\d{8}'),
      (match) => maskPhone(match.group(0)!),
    );

    return result;
  }
}
