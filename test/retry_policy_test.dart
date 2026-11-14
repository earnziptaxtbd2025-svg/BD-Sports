import 'package:bd_sports/core/sync/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('waits longer after each failed attempt', () {
    expect(retryDelay(1), const Duration(seconds: 5));
    expect(retryDelay(2), const Duration(seconds: 10));
    expect(retryDelay(3), const Duration(seconds: 20));
  });

  test('never waits more than five minutes', () {
    expect(retryDelay(7), const Duration(minutes: 5));
    expect(retryDelay(50), const Duration(minutes: 5));
  });

  test('handles zero or negative attempts', () {
    expect(retryDelay(0), const Duration(seconds: 5));
    expect(retryDelay(-3), const Duration(seconds: 5));
  });
}
