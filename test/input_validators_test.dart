import 'package:bd_sports/core/security/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone', () {
    test('accepts common Bangladesh formats', () {
      expect(InputValidators.normalizeBdPhone('01712345678'), '+8801712345678');
      expect(InputValidators.normalizeBdPhone('+8801712345678'), '+8801712345678');
      expect(InputValidators.normalizeBdPhone('8801712345678'), '+8801712345678');
      expect(InputValidators.normalizeBdPhone('017 1234-5678'), '+8801712345678');
    });

    test('accepts Bangla digits', () {
      expect(InputValidators.normalizeBdPhone('০১৭১২৩৪৫৬৭৮'), '+8801712345678');
    });

    test('rejects wrong numbers', () {
      expect(InputValidators.normalizeBdPhone('01212345678'), isNull);
      expect(InputValidators.normalizeBdPhone('0171234567'), isNull);
      expect(InputValidators.normalizeBdPhone('abc'), isNull);
      expect(InputValidators.validatePhone(''), isNotNull);
      expect(InputValidators.validatePhone('01712345678'), isNull);
    });
  });

  group('sanitizeText', () {
    test('removes control characters and tidies spaces', () {
      expect(InputValidators.sanitizeText('  Hello \u0007   World  '), 'Hello World');
    });

    test('removes invisible text-direction tricks', () {
      expect(InputValidators.sanitizeText('ab\u202Ecd\u200Bef'), 'abcdef');
    });

    test('keeps the joiners that Bangla letters need', () {
      const word = 'ক্\u200Cষ র\u200D্য';
      expect(InputValidators.sanitizeText(word), word);
    });

    test('cuts text that is too long', () {
      expect(InputValidators.sanitizeText('abcdef', maxLength: 3), 'abc');
    });
  });

  group('names and titles', () {
    test('accepts English and Bangla names', () {
      expect(InputValidators.validatePersonName('Rakib Hasan'), isNull);
      expect(InputValidators.validatePersonName('রাকিব হাসান'), isNull);
      expect(InputValidators.validatePersonName("Md. Abdul-Karim O'Neil"), isNull);
    });

    test('rejects short names and code-like text', () {
      expect(InputValidators.validatePersonName('A'), isNotNull);
      expect(InputValidators.validatePersonName('<script>x</script>'), isNotNull);
      expect(InputValidators.validatePersonName('12345'), isNotNull);
    });

    test('tournament title rules', () {
      expect(InputValidators.validateTournamentTitle('Pirgachha Premier 2026'), isNull);
      expect(InputValidators.validateTournamentTitle('ab'), isNotNull);
      expect(InputValidators.validateTournamentTitle('!!!'), isNotNull);
      expect(InputValidators.validateTournamentTitle('x' * 81), isNotNull);
    });
  });

  group('amount', () {
    test('reads taka with commas and Bangla digits', () {
      expect(InputValidators.parseAmountBdt('50,000'), 50000);
      expect(InputValidators.parseAmountBdt('১০০০'), 1000);
      expect(InputValidators.parseAmountBdt('0'), 0);
    });

    test('rejects bad amounts', () {
      expect(InputValidators.parseAmountBdt('-5'), isNull);
      expect(InputValidators.parseAmountBdt('12.5'), isNull);
      expect(InputValidators.parseAmountBdt('abc'), isNull);
      expect(InputValidators.parseAmountBdt('99999999'), isNull);
      expect(InputValidators.validateAmountBdt(''), isNotNull);
    });
  });

  group('links', () {
    test('accepts plain https links', () {
      expect(InputValidators.safeHttpsUrl('https://facebook.com/page'), isNotNull);
    });

    test('rejects http, scripts and hidden user names', () {
      expect(InputValidators.safeHttpsUrl('http://example.com'), isNull);
      expect(InputValidators.safeHttpsUrl('javascript:alert(1)'), isNull);
      expect(InputValidators.safeHttpsUrl('https://good.com@evil.com'), isNull);
      expect(InputValidators.safeHttpsUrl('not a url'), isNull);
    });

    test('can limit links to allowed sites', () {
      const allowed = {'facebook.com'};
      expect(
        InputValidators.safeHttpsUrl('https://facebook.com/x', allowedHosts: allowed),
        isNotNull,
      );
      expect(
        InputValidators.safeHttpsUrl('https://other.com/x', allowedHosts: allowed),
        isNull,
      );
    });
  });
}
