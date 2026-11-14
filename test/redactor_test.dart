import 'package:bd_sports/core/security/redactor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('masks phone numbers', () {
    expect(Redactor.maskPhone('01712345678'), '017****678');
    expect(Redactor.maskPhone('12'), '***');
  });

  test('masks emails', () {
    expect(Redactor.maskEmail('rakib@gmail.com'), 'r***@gmail.com');
  });

  test('scrub hides phone numbers and emails inside text', () {
    final text = Redactor.scrub('Call 01712345678 or mail rakib@gmail.com now');
    expect(text.contains('01712345678'), isFalse);
    expect(text.contains('rakib@gmail.com'), isFalse);
    expect(text.contains('017****678'), isTrue);
  });

  test('scrub hides login tokens and secrets', () {
    final jwt =
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.abcDEF123_-xyz';
    expect(Redactor.scrub('token $jwt end').contains('abcDEF123'), isFalse);

    final secret = Redactor.scrub('password=hunter2 and otp: 123456');
    expect(secret.contains('hunter2'), isFalse);
    expect(secret.contains('123456'), isFalse);
  });

  test('scrub leaves normal text alone', () {
    expect(Redactor.scrub('Goal by Team A at 45 minutes'), 'Goal by Team A at 45 minutes');
  });
}
