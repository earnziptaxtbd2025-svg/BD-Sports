import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/current_user_provider.dart';
import '../sync/outbox.dart';
import 'redactor.dart';

/// Important actions that must leave a permanent record.
enum AuditAction {
  loginSucceeded,
  loginFailed,
  accountSuspended,
  accountRestored,
  accountDeleted,
  dataExported,
  privacyChanged,
  roleChanged,
  tournamentCreated,
  tournamentEdited,
  tournamentApproved,
  teamApproved,
  teamRejected,
  teamDisqualified,
  squadLocked,
  fixtureChanged,
  scoreEntered,
  resultCorrected,
  announcementSent,
  paymentRecorded,
  financeEdited,
  contentRemoved,
}

/// Records who did what, and to which thing.
abstract interface class AuditLogger {
  Future<void> log(
    AuditAction action, {
    required String targetType,
    required String targetId,
    Map<String, Object?> details = const <String, Object?>{},
  });
}

/// Type name of the queued change that carries an audit record to the server.
const String auditOperationType = 'audit.event';

/// Saves audit records in the offline outbox, so they are kept even without
/// internet and reach the server later.
///
/// The server must ignore the actor id and time sent from the phone and use the
/// signed-in user and its own clock. The phone's values are only for reference.
class OutboxAuditLogger implements AuditLogger {
  OutboxAuditLogger({
    required Future<void> Function(String type, Map<String, dynamic> payload)
        enqueue,
    required String? Function() actorId,
    DateTime Function()? clock,
  })  : _enqueue = enqueue,
        _actorId = actorId,
        _clock = clock ?? DateTime.now;

  final Future<void> Function(String type, Map<String, dynamic> payload)
      _enqueue;
  final String? Function() _actorId;
  final DateTime Function() _clock;

  @override
  Future<void> log(
    AuditAction action, {
    required String targetType,
    required String targetId,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    final safeDetails = <String, String>{
      for (final entry in details.entries)
        entry.key: Redactor.scrub('${entry.value}'),
    };

    return _enqueue(auditOperationType, <String, dynamic>{
      'action': action.name,
      'targetType': targetType,
      'targetId': targetId,
      'details': safeDetails,
      'actorId': _actorId(),
      'clientTime': _clock().toUtc().toIso8601String(),
    });
  }
}

final auditLoggerProvider = Provider<AuditLogger>((ref) {
  return OutboxAuditLogger(
    enqueue: (type, payload) =>
        ref.read(outboxProvider.notifier).enqueue(type, payload),
    actorId: () => ref.read(currentUserProvider)?.id,
  );
});
