import 'package:bd_sports/core/l10n/app_formats.dart';
import 'package:bd_sports/core/l10n/app_language.dart';
import 'package:bd_sports/core/security/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bn = AppFormats(AppLanguage.bangla);
  const en = AppFormats(AppLanguage.english);

  group('digits and numbers', () {
    test('Bangla digits in Bangla, normal digits in English', () {
      expect(bn.digits('2026'), '২০২৬');
      expect(en.digits('2026'), '2026');
      expect(bn.number(45), '৪৫');
      expect(bn.digits('ধাপ 1B.4'), 'ধাপ ১B.৪');
    });
  });

  group('money', () {
    test('groups in lakh and crore like Bangladesh does', () {
      expect(en.amount(999), '999');
      expect(en.amount(50000), '50,000');
      expect(en.amount(100000), '1,00,000');
      expect(en.amount(12345678), '1,23,45,678');
      expect(en.amount(0), '0');
      expect(en.amount(-1500), '-1,500');
    });

    test('Bangla amounts use Bangla digits', () {
      expect(bn.amount(50000), '৫০,০০০');
      expect(bn.amount(100000), '১,০০,০০০');
      expect(bn.amount(-1500), '-১,৫০০');
    });

    test('money text in both languages', () {
      expect(en.money(50000), '৳50,000');
      expect(bn.money(50000), '৫০,০০০ টাকা');
    });

    test('the largest allowed amount matches the text in the error message', () {
      expect(bn.amount(InputValidators.maxAmountBdt), '১,০০,০০,০০০');
      expect(en.amount(InputValidators.maxAmountBdt), '1,00,00,000');
    });
  });

  group('dates and times use Bangladesh time (UTC+6)', () {
    // 09:00 UTC is 15:00 in Bangladesh.
    final afternoon = DateTime.utc(2026, 12, 15, 9, 0);

    test('date', () {
      expect(en.date(afternoon), '15 December 2026');
      expect(bn.date(afternoon), '১৫ ডিসেম্বর ২০২৬');
    });

    test('afternoon time', () {
      expect(en.time(afternoon), '3:00 PM');
      expect(bn.time(afternoon), 'বিকেল ৩:০০');
    });

    test('just after midnight is the next day in Bangladesh', () {
      final late = DateTime.utc(2026, 12, 14, 18, 5); // 00:05 on the 15th
      expect(en.date(late), '15 December 2026');
      expect(en.time(late), '12:05 AM');
      expect(bn.time(late), 'রাত ১২:০৫');
    });

    test('parts of the day in Bangla', () {
      DateTime at(int dhakaHour, [int minute = 0]) =>
          DateTime.utc(2026, 6, 1, dhakaHour - 6 < 0 ? dhakaHour + 18 : dhakaHour - 6, minute);

      expect(bn.time(at(5, 30)), 'ভোর ৫:৩০');
      expect(bn.time(at(6)), 'সকাল ৬:০০');
      expect(bn.time(at(12)), 'দুপুর ১২:০০');
      expect(bn.time(at(16)), 'বিকেল ৪:০০');
      expect(bn.time(at(18, 15)), 'সন্ধ্যা ৬:১৫');
      expect(bn.time(at(19)), 'রাত ৭:০০');
    });

    test('noon in English', () {
      expect(en.time(DateTime.utc(2026, 6, 1, 6, 0)), '12:00 PM');
    });

    test('date and time together', () {
      expect(bn.dateTime(afternoon), '১৫ ডিসেম্বর ২০২৬, বিকেল ৩:০০');
      expect(en.dateTime(afternoon), '15 December 2026, 3:00 PM');
    });

    test('date range', () {
      final start = DateTime.utc(2026, 12, 15, 4);
      final sameDay = DateTime.utc(2026, 12, 15, 12);
      final later = DateTime.utc(2026, 12, 30, 4);
      expect(en.dateRange(start, sameDay), '15 December 2026');
      expect(en.dateRange(start, later), '15 December 2026 – 30 December 2026');
      expect(bn.dateRange(start, later), '১৫ ডিসেম্বর ২০২৬ – ৩০ ডিসেম্বর ২০২৬');
    });
  });
}
