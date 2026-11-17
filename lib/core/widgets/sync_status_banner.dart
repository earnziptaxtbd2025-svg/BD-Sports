import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_strings.dart';
import '../network/connectivity_providers.dart';
import '../sync/outbox.dart';
import '../sync/sync_engine.dart';

/// Thin bar shown above the bottom navigation when the app is offline, syncing,
/// or has changes that need attention. Hidden when everything is fine.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final online = ref.watch(isOnlineProvider);
    final pending = ref.watch(pendingCountProvider);
    final failed = ref.watch(failedCountProvider);
    final syncing = ref.watch(syncEngineProvider.select((state) => state.isSyncing));

    String? message;
    IconData icon = Icons.info_outline;
    Color background = scheme.secondaryContainer;
    Color foreground = scheme.onSecondaryContainer;

    if (!online) {
      icon = Icons.cloud_off_outlined;
      message = pending > 0 ? s.offlineWithPending(pending) : s.offlineNoPending;
    } else if (syncing) {
      icon = Icons.sync;
      message = s.syncing;
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
    } else if (failed > 0) {
      icon = Icons.error_outline;
      message = s.changesFailed(failed);
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (pending > 0) {
      icon = Icons.schedule;
      message = s.changesWaiting(pending);
    }

    if (message == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foreground, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
