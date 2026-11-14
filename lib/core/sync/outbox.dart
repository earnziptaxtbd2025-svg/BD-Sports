import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'outbox_storage.dart';
import 'pending_operation.dart';
import 'retry_policy.dart';

/// The queue of changes waiting to be sent to the server.
///
/// Every write the user makes while offline goes in here first. It is saved on the
/// phone after every change, so nothing is lost if the app closes.
class OutboxNotifier extends AsyncNotifier<List<PendingOperation>> {
  final Random _random = Random.secure();
  Future<void> _tail = Future<void>.value();

  @override
  Future<List<PendingOperation>> build() => ref.read(outboxStorageProvider).load();

  /// Adds a change to the end of the queue.
  Future<PendingOperation> enqueue(String type, Map<String, dynamic> payload) async {
    late PendingOperation created;
    await _mutate((current) {
      created = PendingOperation(
        id: _newId(),
        type: type,
        payload: payload,
        createdAt: DateTime.now().toUtc(),
      );
      return <PendingOperation>[...current, created];
    });
    return created;
  }

  Future<void> remove(String id) {
    return _mutate(
      (current) => current.where((op) => op.id != id).toList(),
    );
  }

  /// The attempt failed for a temporary reason. Try again later.
  Future<void> markRetry(String id, String reason) {
    return _mutate((current) {
      return current.map((op) {
        if (op.id != id) {
          return op;
        }
        final attempts = op.attempts + 1;
        return op.copyWith(
          attempts: attempts,
          lastError: reason,
          nextAttemptAt: DateTime.now().toUtc().add(retryDelay(attempts)),
        );
      }).toList();
    });
  }

  /// The server refused this change for good (for example, invalid data).
  Future<void> markFailed(String id, String reason) {
    return _mutate((current) {
      return current.map((op) {
        if (op.id != id) {
          return op;
        }
        return op.copyWith(
          attempts: op.attempts + 1,
          status: OperationStatus.failed,
          lastError: reason,
          clearNextAttempt: true,
        );
      }).toList();
    });
  }

  /// Puts every failed change back in the queue.
  Future<void> retryFailed() {
    return _mutate((current) {
      return current.map((op) {
        if (op.status != OperationStatus.failed) {
          return op;
        }
        return op.copyWith(
          status: OperationStatus.pending,
          clearError: true,
          clearNextAttempt: true,
        );
      }).toList();
    });
  }

  Future<void> clear() => _mutate((_) => <PendingOperation>[]);

  /// Runs read-modify-write steps one at a time so two changes never overwrite
  /// each other.
  Future<void> _mutate(
    List<PendingOperation> Function(List<PendingOperation> current) change,
  ) {
    final run = _tail.then((_) async {
      final storage = ref.read(outboxStorageProvider);
      final current = state.value ?? await storage.load();
      final next = change(current);
      await storage.save(next);
      state = AsyncData<List<PendingOperation>>(next);
    });
    _tail = run.then((_) {}, onError: (Object _) {});
    return run;
  }

  String _newId() {
    final time = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(1 << 31);
    return '$time-$salt';
  }
}

final outboxProvider =
    AsyncNotifierProvider<OutboxNotifier, List<PendingOperation>>(
  OutboxNotifier.new,
);

/// Changes still waiting to be sent.
final pendingCountProvider = Provider<int>((ref) {
  final items = ref.watch(outboxProvider).value ?? const <PendingOperation>[];
  return items.where((op) => op.status == OperationStatus.pending).length;
});

/// Changes the server refused.
final failedCountProvider = Provider<int>((ref) {
  final items = ref.watch(outboxProvider).value ?? const <PendingOperation>[];
  return items.where((op) => op.status == OperationStatus.failed).length;
});
