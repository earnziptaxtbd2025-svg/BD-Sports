import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/pending_operation.dart';
import '../../../core/sync/sync_handler.dart';

/// How the pretend server answers in the sync tester.
enum FakeServerMode {
  working('Working'),
  temporaryError('Temporary error'),
  rejectsAll('Rejects changes');

  const FakeServerMode(this.label);

  final String label;
}

class FakeServerModeNotifier extends Notifier<FakeServerMode> {
  @override
  FakeServerMode build() => FakeServerMode.working;

  void set(FakeServerMode mode) {
    state = mode;
  }
}

final fakeServerModeProvider =
    NotifierProvider<FakeServerModeNotifier, FakeServerMode>(
  FakeServerModeNotifier.new,
);

/// Pretend server used by the developer sync tester. Replaced by real handlers
/// (match score events, registrations, and so on) when the backend is connected.
class DemoSyncHandler implements SyncHandler {
  DemoSyncHandler(this._currentMode);

  static const String type = 'demo.score_draft';

  final FakeServerMode Function() _currentMode;

  @override
  Future<SyncResult> handle(PendingOperation operation) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    switch (_currentMode()) {
      case FakeServerMode.working:
        return const SyncSuccess();
      case FakeServerMode.temporaryError:
        return const SyncRetry('Server is busy (simulated)');
      case FakeServerMode.rejectsAll:
        return const SyncRejected('Server refused this change (simulated)');
    }
  }
}
