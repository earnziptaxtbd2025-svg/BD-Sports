import 'account_role.dart';
import 'permission.dart';
import 'tournament_role.dart';

const Set<Permission> _memberPermissions = {
  Permission.createTournament,
  Permission.registerTeam,
  Permission.createPost,
  Permission.reportContent,
  Permission.editOwnProfile,
};

/// What each account role may do, anywhere in the app.
final Map<AccountRole, Set<Permission>> accountRolePermissions = {
  AccountRole.member: _memberPermissions,
  AccountRole.moderator: {
    ..._memberPermissions,
    Permission.approveTournament,
    Permission.verifyOrganizer,
    Permission.moderateContent,
    Permission.viewAnalytics,
  },
  AccountRole.superAdmin: Permission.values.toSet(),
};

/// What each tournament role may do, only inside that tournament.
const Map<TournamentRole, Set<Permission>> tournamentRolePermissions = {
  TournamentRole.organizer: {
    Permission.editTournament,
    Permission.manageRegistrations,
    Permission.manageFixtures,
    Permission.enterScore,
    Permission.manageSquad,
    Permission.sendAnnouncement,
    Permission.viewFinance,
    Permission.manageFinance,
    Permission.resolveProtest,
    Permission.disqualifyTeam,
    Permission.assignScorer,
  },
  TournamentRole.scorer: {
    Permission.enterScore,
  },
  TournamentRole.teamManager: {
    Permission.manageSquad,
  },
};
