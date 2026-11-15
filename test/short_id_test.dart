import 'dart:math';

import 'package:bd_sports/core/public_links/short_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShortId', () {
    test('makes 8 readable characters', () {
      final id = ShortId.generate();
      expect(id.length, 8);
      expect(ShortId.isValid(id), isTrue);
    });

    test('never uses confusing characters', () {
      final random = Random(1);
      for (var i = 0; i < 500; i++) {
        final id = ShortId.generate(random);
        expect(RegExp(r'[01oli]').hasMatch(id), isFalse, reason: id);
      }
    });

    test('ids do not repeat in a large sample', () {
      final random = Random(2);
      final ids = <String>{for (var i = 0; i < 2000; i++) ShortId.generate(random)};
      expect(ids.length, 2000);
    });

    test('rejects wrong ids', () {
      expect(ShortId.isValid('abc'), isFalse);
      expect(ShortId.isValid('abcd2345x'), isFalse);
      expect(ShortId.isValid('ABCD2345'), isFalse);
      expect(ShortId.isValid('abcd234o'), isFalse);
      expect(ShortId.isValid('abcd23<5'), isFalse);
      expect(ShortId.isValid(''), isFalse);
    });
  });

  group('slugify', () {
    test('makes a clean English ending', () {
      expect(ShortId.slugify('Pirgachha Premier 2026'), 'pirgachha-premier-2026');
      expect(ShortId.slugify('  Hello,   World!! '), 'hello-world');
    });

    test('returns null when nothing usable is left', () {
      expect(ShortId.slugify('পীরগাছা প্রিমিয়ার'), isNull);
      expect(ShortId.slugify('!!!'), isNull);
    });

    test('cuts long titles without a trailing dash', () {
      final slug = ShortId.slugify('a' * 38 + ' bbbbbb', maxLength: 40);
      expect(slug!.length <= 40, isTrue);
      expect(slug.endsWith('-'), isFalse);
    });
  });
}
