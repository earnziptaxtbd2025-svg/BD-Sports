import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_role.dart';
import 'app_user.dart';
import 'tournament_role.dart';

/// Holds the signed-in user. Real sign-in is built in Step 1.1; until then the
/// developer tools screen drives this state so roles can be tested.
class CurrentUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void signInAs(AccountRole role) {
    final previous = state;
    state = AppUser(
      id: 'dev-user',
      displayName: 'Dev user',
      accountRole: role,
      tournamentRoles:
          previous?.tournamentRoles ?? const <String, Set<TournamentRole>>{},
      isSuspended: previous?.isSuspended ?? false,
    );
  }

  void signOut() {
    state = null;
  }

  void setSuspended(bool value) {
    final user = state;
    if (user == null) {
      return;
    }
    state = user.copyWith(isSuspended: value);
  }

  void toggleTournamentRole(String tournamentId, TournamentRole role) {
    final user = state;
    if (user == null) {
      return;
    }

    final updated = Map<String, Set<TournamentRole>>.from(user.tournamentRoles);
    final roles = Set<TournamentRole>.from(
      updated[tournamentId] ?? const <TournamentRole>{},
    );

    if (!roles.remove(role)) {
      roles.add(role);
    }

    if (roles.isEmpty) {
      updated.remove(tournamentId);
    } else {
      updated[tournamentId] = roles;
    }

    state = user.copyWith(tournamentRoles: updated);
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);
