import 'package:bd_sports/core/sync/outbox.dart';
import 'package:bd_sports/core/sync/outbox_storage.dart';
import 'package:bd_sports/core/sync/pending_operation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryOutboxStorage storage;
  late ProviderContainer container;

  setUp(() {
    storage = InMemoryOutboxStorage();
    container = ProviderContainer(
      overrides: [outboxStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
  });

  Future<OutboxNotifier> outbox() async {
    await container.read(outboxProvider.future);
    return container.read(outboxProvider.notifier);
  }

  test('keeps changes in the order they were added', () async {
    final box = await outbox();
    await box.enqueue('t', <String, dynamic>{'n': 1});
    await box.enqueue('t', <String, dynamic>{'n': 2});
    await box.enqueue('t', <String, dynamic>{'n': 3});

    final items = container.read(outboxProvider).value!;
    expect(items.map((op) => op.payload['n']).toList(), [1, 2, 3]);
  });

  test('saves every change to storage', () async {
    final box = await outbox();
    await box.enqueue('t', <String, dynamic>{'n': 1});

    final saved = await storage.load();
    expect(saved.length, 1);
    expect(saved.first.type, 't');
  });

  test('a new outbox loads what was saved before', () async {
    final box = await outbox();
    await box.enqueue('t', <String, dynamic>{'n': 1});

    final second = ProviderContainer(
      overrides: [outboxStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(second.dispose);
    final reloaded = await second.read(outboxProvider.future);

    expect(reloaded.length, 1);
    expect(reloaded.first.payload['n'], 1);
  });

  test('markRetry counts the attempt and delays the next one', () async {
    final box = await outbox();
    final op = await box.enqueue('t', <String, dynamic>{});
    await box.markRetry(op.id, 'no internet');

    final updated = container.read(outboxProvider).value!.single;
    expect(updated.attempts, 1);
    expect(updated.status, OperationStatus.pending);
    expect(updated.lastError, 'no internet');
    expect(updated.nextAttemptAt!.isAfter(DateTime.now().toUtc()), isTrue);
  });

  test('markFailed and retryFailed move a change out and back', () async {
    final box = await outbox();
    final op = await box.enqueue('t', <String, dynamic>{});

    await box.markFailed(op.id, 'refused');
    expect(container.read(failedCountProvider), 1);
    expect(container.read(pendingCountProvider), 0);

    await box.retryFailed();
    expect(container.read(failedCountProvider), 0);
    expect(container.read(pendingCountProvider), 1);
  });

  test('remove deletes only that change', () async {
    final box = await outbox();
    final first = await box.enqueue('t', <String, dynamic>{'n': 1});
    await box.enqueue('t', <String, dynamic>{'n': 2});
    await box.remove(first.id);

    final items = container.read(outboxProvider).value!;
    expect(items.length, 1);
    expect(items.single.payload['n'], 2);
  });

  test('a change survives the save and load round trip', () {
    final op = PendingOperation(
      id: 'a',
      type: 't',
      payload: <String, dynamic>{'x': 1},
      createdAt: DateTime.utc(2026, 1, 1),
      attempts: 2,
      status: OperationStatus.failed,
      lastError: 'boom',
      nextAttemptAt: DateTime.utc(2026, 1, 2),
    );

    final copy = PendingOperation.fromJson(op.toJson());
    expect(copy.id, 'a');
    expect(copy.attempts, 2);
    expect(copy.status, OperationStatus.failed);
    expect(copy.lastError, 'boom');
    expect(copy.nextAttemptAt, DateTime.utc(2026, 1, 2));
    expect(copy.payload['x'], 1);
  });
}
