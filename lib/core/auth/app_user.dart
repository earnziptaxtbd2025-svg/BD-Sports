import 'account_role.dart';
import 'tournament_role.dart';

/// The signed-in person, as far as permissions are concerned.
class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    this.accountRole = AccountRole.member,
    this.tournamentRoles = const <String, Set<TournamentRole>>{},
    this.isSuspended = false,
  });

  final String id;
  final String displayName;
  final AccountRole accountRole;

  /// Tournament id to the roles held in that tournament.
  final Map<String, Set<TournamentRole>> tournamentRoles;

  final bool isSuspended;

  Set<TournamentRole> rolesIn(String tournamentId) =>
      tournamentRoles[tournamentId] ?? const <TournamentRole>{};

  AppUser copyWith({
    AccountRole? accountRole,
    Map<String, Set<TournamentRole>>? tournamentRoles,
    bool? isSuspended,
  }) {
    return AppUser(
      id: id,
      displayName: displayName,
      accountRole: accountRole ?? this.accountRole,
      tournamentRoles: tournamentRoles ?? this.tournamentRoles,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }
}
