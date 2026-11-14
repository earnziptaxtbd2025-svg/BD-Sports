import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_providers.dart';
import 'outbox.dart';
import 'pending_operation.dart';
import 'sync_handler.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastSyncedAt,
    this.lastError,
  });

  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? lastError;

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

/// Sends the outbox to the server whenever it can.
///
/// Rules:
/// - Changes are sent in the order they were made.
/// - A temporary failure stops the run and waits (back-off), so order is kept.
/// - A permanent refusal marks that one change as failed and moves on.
/// - It runs when the app starts, when the internet comes back, when a new change
///   is added, every 30 seconds, and when the user taps "Sync now".
class SyncEngine extends Notifier<SyncState> {
  Timer? _timer;
  Future<void>? _current;
  bool _rerun = false;
  bool _forceNext = false;
  bool _disposed = false;
  bool _syncedAny = false;
  String? _runError;

  @override
  SyncState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });

    ref.listen<bool>(isOnlineProvider, (previous, next) {
      if (next && previous != true) {
        syncNow();
      }
    });

    ref.listen<AsyncValue<List<PendingOperation>>>(outboxProvider, (
      previous,
      next,
    ) {
      final before = previous?.value?.length ?? 0;
      final after = next.value?.length ?? 0;
      if (after > before) {
        syncNow();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 30), (_) => syncNow());
    Future<void>.microtask(syncNow);

    return const SyncState();
  }

  /// Starts a sync, or joins the one that is already running.
  Future<void> syncNow({bool force = false}) {
    final running = _current;
    if (running != null) {
      _rerun = true;
      if (force) {
        _forceNext = true;
      }
      return running;
    }

    final run = _run(force: force).whenComplete(() {
      _current = null;
    });
    _current = run;
    return run;
  }

  Future<void> _run({required bool force}) async {
    if (_disposed || !ref.read(isOnlineProvider)) {
      return;
    }

    _syncedAny = false;
    _runError = null;
    var forceThisPass = force;
    var started = false;

    try {
      do {
        _rerun = false;
        final operations = await _snapshot();
        final hasWork = operations.any(
          (op) => op.status == OperationStatus.pending,
        );
        if (_disposed || !hasWork) {
          break;
        }

        started = true;
        _setState(state.copyWith(isSyncing: true));
        await _drain(force: forceThisPass || _forceNext);
        _forceNext = false;
        forceThisPass = false;
      } while (_rerun && !_disposed);
    } catch (error) {
      _runError = error.toString();
    }

    if (!started) {
      return;
    }

    _setState(
      SyncState(
        isSyncing: false,
        lastSyncedAt: _syncedAny ? DateTime.now() : state.lastSyncedAt,
        lastError: _runError,
      ),
    );
  }

  Future<void> _drain({required bool force}) async {
    final handlers = ref.read(syncHandlersProvider);
    final outbox = ref.read(outboxProvider.notifier);
    final snapshot = List<PendingOperation>.of(await _snapshot());

    for (final op in snapshot) {
      if (_disposed || !ref.read(isOnlineProvider)) {
        return;
      }
      if (op.status == OperationStatus.failed) {
        continue;
      }

      final due = op.nextAttemptAt;
      if (!force && due != null && due.isAfter(DateTime.now().toUtc())) {
        // The oldest change is still waiting. Keep the order and stop here.
        return;
      }

      final handler = handlers[op.type];
      if (handler == null) {
        continue;
      }

      SyncResult result;
      try {
        result = await handler.handle(op);
      } catch (error) {
        result = SyncRetry(error.toString());
      }
      if (_disposed) {
        return;
      }

      if (result is SyncSuccess) {
        await outbox.remove(op.id);
        _syncedAny = true;
      } else if (result is SyncRetry) {
        await outbox.markRetry(op.id, result.reason);
        _runError = result.reason;
        return;
      } else if (result is SyncRejected) {
        await outbox.markFailed(op.id, result.reason);
        _runError = result.reason;
      }
    }
  }

  Future<List<PendingOperation>> _snapshot() async {
    return ref.read(outboxProvider).value ??
        await ref.read(outboxProvider.future);
  }

  void _setState(SyncState value) {
    if (!_disposed) {
      state = value;
    }
  }
}

final syncEngineProvider = NotifierProvider<SyncEngine, SyncState>(
  SyncEngine.new,
);
