import 'dart:math';

/// Short public ids used in shareable links, like `k7m2xq9d`.
///
/// 8 characters from 31 easy-to-read symbols (no 0/o, 1/l/i), so ids are safe to
/// read aloud, type from a poster, and hard to guess by trying numbers.
/// The id is not a secret. A tournament is visible only if it is published.
class ShortId {
  const ShortId._();

  static const String _alphabet = '23456789abcdefghjkmnpqrstuvwxyz';
  static const int length = 8;

  static final RegExp _pattern = RegExp(r'^[2-9a-hj-km-np-z]{8}$');

  static String generate([Random? random]) {
    final source = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_alphabet[source.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  static bool isValid(String value) => _pattern.hasMatch(value);

  /// Turns a title into a readable link ending, like `pirgachha-premier-2026`.
  /// Only English letters and digits are kept. Returns null when nothing is left
  /// (for example a Bangla-only title), and the link simply has no ending.
  static String? slugify(String title, {int maxLength = 40}) {
    var slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > maxLength) {
      slug = slug.substring(0, maxLength).replaceAll(RegExp(r'-+$'), '');
    }
    return slug.isEmpty ? null : slug;
  }
}
