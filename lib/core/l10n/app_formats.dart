import 'app_language.dart';

/// Numbers, money, dates and times written the way people read them in each
/// language. Bangla uses Bangla digits, lakh/crore grouping (12,34,567) and
/// Bangladesh time (UTC+6), whatever the phone's own time zone is.
class AppFormats {
  const AppFormats(this.language);

  final AppLanguage language;

  bool get _bangla => language == AppLanguage.bangla;

  static const String _banglaDigits = '০১২৩৪৫৬৭৮৯';

  static const List<String> _monthsEnglish = <String>[
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _monthsBangla = <String>[
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই',
    'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  /// Turns 0-9 into Bangla digits when the language is Bangla.
  String digits(String input) {
    if (!_bangla) {
      return input;
    }
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(_banglaDigits[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  String number(int value) => digits('$value');

  /// 100000 becomes 1,00,000 (and ১,০০,০০০ in Bangla).
  String amount(int value) {
    final negative = value < 0;
    final grouped = _groupLakh(value.abs().toString());
    return digits(negative ? '-$grouped' : grouped);
  }

  /// 50000 becomes ৳50,000 in English and ৫০,০০০ টাকা in Bangla.
  String money(int value) =>
      _bangla ? '${amount(value)} টাকা' : '৳${amount(value)}';

  static String _groupLakh(String digits) {
    if (digits.length <= 3) {
      return digits;
    }
    final lastThree = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      parts.insert(0, rest);
    }
    return '${parts.join(',')},$lastThree';
  }

  /// Converts a moment in time to Bangladesh time.
  static DateTime inDhaka(DateTime instant) =>
      instant.toUtc().add(const Duration(hours: 6));

  String month(int month) =>
      (_bangla ? _monthsBangla : _monthsEnglish)[month - 1];

  /// 12 December 2026, or ১২ ডিসেম্বর ২০২৬.
  String date(DateTime instant) {
    final d = inDhaka(instant);
    return '${number(d.day)} ${month(d.month)} ${number(d.year)}';
  }

  /// 3:30 PM, or বিকেল ৩:৩০.
  String time(DateTime instant) {
    final d = inDhaka(instant);
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minutes = d.minute.toString().padLeft(2, '0');
    final clock = digits('$hour12:$minutes');

    if (!_bangla) {
      return '$clock ${d.hour < 12 ? 'AM' : 'PM'}';
    }
    return '${_banglaDayPeriod(d.hour)} $clock';
  }

  String dateTime(DateTime instant) => '${date(instant)}, ${time(instant)}';

  /// One date when both ends fall on the same day, otherwise "start – end".
  String dateRange(DateTime start, DateTime end) {
    final first = date(start);
    final last = date(end);
    return first == last ? first : '$first – $last';
  }

  static String _banglaDayPeriod(int hour) {
    if (hour >= 4 && hour < 6) {
      return 'ভোর';
    }
    if (hour >= 6 && hour < 12) {
      return 'সকাল';
    }
    if (hour >= 12 && hour < 15) {
      return 'দুপুর';
    }
    if (hour >= 15 && hour < 17) {
      return 'বিকেল';
    }
    if (hour >= 17 && hour < 19) {
      return 'সন্ধ্যা';
    }
    return 'রাত';
  }
}
