import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'internet_probe.dart';

/// Whether the internet really works. It checks at start, every 20 seconds, and
/// whenever the phone's network changes. The phone's own network report is only
/// used as a hint to check sooner, never as the answer.
final internetReachableProvider = StreamProvider<bool>((ref) {
  final probe = ref.watch(internetProbeProvider);
  final controller = StreamController<bool>();
  var running = false;
  var disposed = false;

  Future<void> check() async {
    if (running || disposed) {
      return;
    }
    running = true;
    try {
      final online = await probe.check();
      if (!disposed) {
        controller.add(online);
      }
    } finally {
      running = false;
    }
  }

  check();
  final timer = Timer.periodic(const Duration(seconds: 20), (_) => check());

  StreamSubscription<dynamic>? subscription;
  try {
    subscription = Connectivity().onConnectivityChanged.listen(
          (_) => check(),
          onError: (Object _) {},
        );
  } catch (_) {
    // The periodic check still works without the hint.
  }

  ref.onDispose(() {
    disposed = true;
    timer.cancel();
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Developer switch to pretend the phone is offline.
class SimulateOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

final simulateOfflineProvider =
    NotifierProvider<SimulateOfflineNotifier, bool>(SimulateOfflineNotifier.new);

/// The one provider the app should read to know if it is online.
/// Assumes online until the first check finishes, so the app never starts with a
/// false "offline" warning.
final isOnlineProvider = Provider<bool>((ref) {
  if (ref.watch(simulateOfflineProvider)) {
    return false;
  }
  return ref.watch(internetReachableProvider).maybeWhen(
        data: (online) => online,
        orElse: () => true,
      );
});
