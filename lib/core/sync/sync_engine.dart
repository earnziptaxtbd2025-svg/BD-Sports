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
/// - A temporary failure stops the pass and waits (back-off), so order is kept.
/// - A permanent refusal marks that one change as failed and moves on.
/// - It runs when the app starts, when the internet comes back, when a new change
///   is added, every 30 seconds, and when the user taps "Sync now".
///
/// A request to sync is never lost: if one arrives while a pass is running (or just
/// finishing), another pass runs straight after it.
class SyncEngine extends Notifier<SyncState> {
  Timer? _timer;
  Future<void>? _current;
  bool _rerun = false;
  bool _forceNext = false;
  bool _disposed = false;
  bool _syncedAny = false;
  String? _passError;

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

  /// Asks for a sync. If one is already running, it will run once more after the
  /// current pass, and the returned future completes when everything is done.
  Future<void> syncNow({bool force = false}) {
    if (force) {
      _forceNext = true;
    }
    _rerun = true;
    return _current ??= _runPasses();
  }

  Future<void> _runPasses() async {
    // Let syncNow() store this future before any work starts.
    await null;
    try {
      while (_rerun && !_disposed) {
        _rerun = false;
        await _pass();
      }
    } finally {
      // Cleared in the same step as the last check, so a request can never fall
      // between "no more passes" and "ready for a new run".
      _current = null;
    }
  }

  Future<void> _pass() async {
    if (_disposed || !ref.read(isOnlineProvider)) {
      return;
    }

    final operations = await _snapshot();
    if (_disposed ||
        !operations.any((op) => op.status == OperationStatus.pending)) {
      return;
    }

    _syncedAny = false;
    _passError = null;
    _setState(state.copyWith(isSyncing: true));

    try {
      await _drain(force: _forceNext);
    } catch (error) {
      _passError = error.toString();
    }
    _forceNext = false;

    _setState(
      SyncState(
        isSyncing: false,
        lastSyncedAt: _syncedAny ? DateTime.now() : state.lastSyncedAt,
        lastError: _passError,
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
        _passError = result.reason;
        return;
      } else if (result is SyncRejected) {
        await outbox.markFailed(op.id, result.reason);
        _passError = result.reason;
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
