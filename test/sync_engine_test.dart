import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/sync/outbox.dart';
import 'package:bd_sports/core/sync/outbox_storage.dart';
import 'package:bd_sports/core/sync/pending_operation.dart';
import 'package:bd_sports/core/sync/sync_engine.dart';
import 'package:bd_sports/core/sync/sync_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHandler implements SyncHandler {
  _FakeHandler(this._answer);

  final SyncResult Function(PendingOperation operation) _answer;
  final List<int> seen = <int>[];

  @override
  Future<SyncResult> handle(PendingOperation operation) async {
    seen.add(operation.payload['n'] as int);
    return _answer(operation);
  }
}

void main() {
  late ProviderContainer container;
  late _FakeHandler handler;

  ProviderContainer build(_FakeHandler fake) {
    final c = ProviderContainer(
      overrides: [
        outboxStorageProvider.overrideWithValue(InMemoryOutboxStorage()),
        connectivityStreamProvider.overrideWith((ref) => Stream<bool>.value(true)),
        syncHandlersProvider.overrideWithValue(<String, SyncHandler>{'t': fake}),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Adds changes while offline, then goes online and waits for the sync.
  Future<void> addOfflineThenSync(List<int> numbers) async {
    final engine = container.read(syncEngineProvider.notifier);
    await container.read(outboxProvider.future);
    container.read(simulateOfflineProvider.notifier).set(true);

    final box = container.read(outboxProvider.notifier);
    for (final n in numbers) {
      await box.enqueue('t', <String, dynamic>{'n': n});
    }

    container.read(simulateOfflineProvider.notifier).set(false);
    await engine.syncNow();
  }

  test('sends everything in order and empties the queue', () async {
    handler = _FakeHandler((_) => const SyncSuccess());
    container = build(handler);

    await addOfflineThenSync([1, 2, 3]);

    expect(handler.seen, [1, 2, 3]);
    expect(container.read(outboxProvider).value, isEmpty);
    expect(container.read(syncEngineProvider).lastSyncedAt, isNotNull);
  });

  test('does nothing while offline', () async {
    handler = _FakeHandler((_) => const SyncSuccess());
    container = build(handler);

    await container.read(outboxProvider.future);
    container.read(simulateOfflineProvider.notifier).set(true);
    await container
        .read(outboxProvider.notifier)
        .enqueue('t', <String, dynamic>{'n': 1});
    await container.read(syncEngineProvider.notifier).syncNow();

    expect(handler.seen, isEmpty);
    expect(container.read(pendingCountProvider), 1);
  });

  test('a temporary failure keeps the change and stops the queue', () async {
    handler = _FakeHandler(
      (op) => op.payload['n'] == 2
          ? const SyncRetry('server busy')
          : const SyncSuccess(),
    );
    container = build(handler);

    await addOfflineThenSync([1, 2, 3]);

    final left = container.read(outboxProvider).value!;
    expect(left.map((op) => op.payload['n']).toList(), [2, 3]);
    expect(left.first.attempts, 1);
    expect(left.last.attempts, 0);
    expect(handler.seen, [1, 2]);
  });

  test('a refused change is marked failed and the rest continue', () async {
    handler = _FakeHandler(
      (op) => op.payload['n'] == 1
          ? const SyncRejected('invalid')
          : const SyncSuccess(),
    );
    container = build(handler);

    await addOfflineThenSync([1, 2]);

    final left = container.read(outboxProvider).value!;
    expect(left.length, 1);
    expect(left.single.status, OperationStatus.failed);
    expect(left.single.lastError, 'invalid');
    expect(handler.seen, [1, 2]);
  });
}
