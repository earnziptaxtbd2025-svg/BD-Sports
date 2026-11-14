import 'package:bd_sports/core/cache/json_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late JsonCache cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    cache = JsonCache(await SharedPreferences.getInstance());
  });

  test('returns nothing for an unknown key', () {
    expect(cache.read('missing'), isNull);
  });

  test('stores and reads back data with its save time', () async {
    await cache.write('fixtures:t1', <String, dynamic>{'teams': 8});

    final value = cache.read('fixtures:t1');
    expect(value, isNotNull);
    expect((value!.json as Map<String, dynamic>)['teams'], 8);
    expect(value.isOlderThan(const Duration(minutes: 1)), isFalse);
    expect(value.isOlderThan(const Duration(seconds: -1)), isTrue);
  });

  test('remove and clear delete saved data', () async {
    await cache.write('a', 1);
    await cache.write('b', 2);

    await cache.remove('a');
    expect(cache.read('a'), isNull);
    expect(cache.read('b'), isNotNull);

    await cache.clear();
    expect(cache.read('b'), isNull);
  });
}
