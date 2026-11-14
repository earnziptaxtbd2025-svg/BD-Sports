import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _hasNetwork(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

/// Real network state from the phone.
///
/// Note: this tells whether the phone is connected to a network, not whether the
/// internet works. The sync engine also treats failed requests as "retry later".
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _hasNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasNetwork);
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
final isOnlineProvider = Provider<bool>((ref) {
  if (ref.watch(simulateOfflineProvider)) {
    return false;
  }
  return ref.watch(connectivityStreamProvider).maybeWhen(
        data: (online) => online,
        orElse: () => true,
      );
});
