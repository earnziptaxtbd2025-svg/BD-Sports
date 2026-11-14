import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connectivity_providers.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/pending_operation.dart';
import '../../../core/sync/sync_engine.dart';
import '../data/demo_sync_handler.dart';

/// Developer tool: test offline saving and automatic sync on a real phone.
class SyncTesterPage extends ConsumerWidget {
  const SyncTesterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final operations =
        ref.watch(outboxProvider).value ?? const <PendingOperation>[];
    final online = ref.watch(isOnlineProvider);
    final simulateOffline = ref.watch(simulateOfflineProvider);
    final serverMode = ref.watch(fakeServerModeProvider);
    final sync = ref.watch(syncEngineProvider);
    final pending = ref.watch(pendingCountProvider);
    final failed = ref.watch(failedCountProvider);

    final outbox = ref.read(outboxProvider.notifier);
    final engine = ref.read(syncEngineProvider.notifier);

    final lastSynced = sync.lastSyncedAt == null
        ? 'Never synced'
        : 'Last synced ${TimeOfDay.fromDateTime(sync.lastSyncedAt!).format(context)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Offline sync tester')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(online ? Icons.wifi : Icons.wifi_off),
              title: Text(online ? 'Online' : 'Offline'),
              subtitle: Text(
                'Waiting: $pending   Failed: $failed\n'
                '${sync.isSyncing ? 'Syncing...' : lastSynced}',
              ),
              isThreeLine: true,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Simulate offline'),
            subtitle: const Text('Or turn on airplane mode to test for real.'),
            value: simulateOffline,
            onChanged: ref.read(simulateOfflineProvider.notifier).set,
          ),
          const SizedBox(height: 8),
          Text('Pretend server', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in FakeServerMode.values)
                ChoiceChip(
                  label: Text(mode.label),
                  selected: serverMode == mode,
                  onSelected: (_) =>
                      ref.read(fakeServerModeProvider.notifier).set(mode),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add score draft'),
                onPressed: () => outbox.enqueue(DemoSyncHandler.type, {
                  'matchId': 'demo-match',
                  'event': 'Goal',
                  'team': operations.length.isEven ? 'Team A' : 'Team B',
                  'at': DateTime.now().toIso8601String(),
                }),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sync now'),
                onPressed: () => engine.syncNow(force: true),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text('Retry failed'),
                onPressed: outbox.retryFailed,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear all'),
                onPressed: outbox.clear,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Queue (${operations.length})', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (operations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Nothing waiting. Add a score draft to test.'),
            ),
          for (final op in operations) _OperationTile(operation: op),
        ],
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.operation});

  final PendingOperation operation;

  String get _statusLabel {
    if (operation.status == OperationStatus.failed) {
      return 'Failed (refused by server)';
    }
    final next = operation.nextAttemptAt;
    if (next != null && next.isAfter(DateTime.now().toUtc())) {
      return 'Waiting to retry';
    }
    return 'Waiting to sync';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final failed = operation.status == OperationStatus.failed;
    final error = operation.lastError;

    return Card(
      child: ListTile(
        leading: Icon(
          failed ? Icons.error_outline : Icons.schedule,
          color: failed ? scheme.error : scheme.primary,
        ),
        title: Text('${operation.payload['event']} - ${operation.payload['team']}'),
        subtitle: Text(
          '$_statusLabel. Attempts: ${operation.attempts}'
          '${error == null ? '' : '\n$error'}',
        ),
      ),
    );
  }
}
