import 'package:bd_sports/core/security/rate_limiter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows actions up to the limit, then blocks', () {
    var now = DateTime(2026, 1, 1, 12);
    final limiter = RateLimiter(
      maxActions: 3,
      window: const Duration(minutes: 1),
      clock: () => now,
    );

    expect(limiter.tryAcquire(), isTrue);
    expect(limiter.tryAcquire(), isTrue);
    expect(limiter.tryAcquire(), isTrue);
    expect(limiter.tryAcquire(), isFalse);
  });

  test('allows again after the window passes', () {
    var now = DateTime(2026, 1, 1, 12);
    final limiter = RateLimiter(
      maxActions: 1,
      window: const Duration(seconds: 30),
      clock: () => now,
    );

    expect(limiter.tryAcquire(), isTrue);
    expect(limiter.tryAcquire(), isFalse);

    now = now.add(const Duration(seconds: 31));
    expect(limiter.tryAcquire(), isTrue);
  });

  test('tells how long to wait', () {
    var now = DateTime(2026, 1, 1, 12);
    final limiter = RateLimiter(
      maxActions: 1,
      window: const Duration(seconds: 60),
      clock: () => now,
    );

    expect(limiter.retryAfter(), isNull);
    limiter.tryAcquire();
    now = now.add(const Duration(seconds: 20));
    expect(limiter.retryAfter(), const Duration(seconds: 40));
  });
}
