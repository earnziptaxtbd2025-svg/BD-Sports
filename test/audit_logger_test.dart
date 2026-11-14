import 'package:bd_sports/core/security/audit_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records the action, target and who did it', () async {
    String? type;
    Map<String, dynamic>? payload;

    final logger = OutboxAuditLogger(
      enqueue: (t, p) async {
        type = t;
        payload = p;
      },
      actorId: () => 'user-1',
      clock: () => DateTime.utc(2026, 1, 1, 10),
    );

    await logger.log(
      AuditAction.scoreEntered,
      targetType: 'match',
      targetId: 'm-7',
      details: <String, Object?>{'score': '2-1'},
    );

    expect(type, auditOperationType);
    expect(payload!['action'], 'scoreEntered');
    expect(payload!['targetType'], 'match');
    expect(payload!['targetId'], 'm-7');
    expect(payload!['actorId'], 'user-1');
    expect(payload!['clientTime'], '2026-01-01T10:00:00.000Z');
    expect((payload!['details'] as Map)['score'], '2-1');
  });

  test('hides phone numbers and secrets inside the details', () async {
    Map<String, dynamic>? payload;

    final logger = OutboxAuditLogger(
      enqueue: (t, p) async {
        payload = p;
      },
      actorId: () => null,
    );

    await logger.log(
      AuditAction.roleChanged,
      targetType: 'user',
      targetId: 'u-2',
      details: <String, Object?>{'note': 'called 01712345678, password=abc'},
    );

    final note = (payload!['details'] as Map)['note'] as String;
    expect(note.contains('01712345678'), isFalse);
    expect(note.contains('abc'), isFalse);
  });
}
