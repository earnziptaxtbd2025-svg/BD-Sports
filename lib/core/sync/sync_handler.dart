import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pending_operation.dart';

/// What happened when one queued change was sent.
sealed class SyncResult {
  const SyncResult();
}

/// The server accepted the change.
final class SyncSuccess extends SyncResult {
  const SyncSuccess();
}

/// A temporary problem (no internet, server busy). Try again later.
final class SyncRetry extends SyncResult {
  const SyncRetry(this.reason);

  final String reason;
}

/// The server refused the change for good. Retrying will not help.
final class SyncRejected extends SyncResult {
  const SyncRejected(this.reason);

  final String reason;
}

/// Sends one type of queued change to the server. Each feature writes its own.
///
/// The server must treat [PendingOperation.id] as an idempotency key, so a change
/// that is sent twice is applied only once.
abstract interface class SyncHandler {
  Future<SyncResult> handle(PendingOperation operation);
}

/// Operation type to handler. Filled in main() with the real handlers.
final syncHandlersProvider = Provider<Map<String, SyncHandler>>(
  (ref) => const <String, SyncHandler>{},
);
