import 'package:bd_sports/core/auth/access_policy.dart';
import 'package:bd_sports/core/auth/account_role.dart';
import 'package:bd_sports/core/auth/app_user.dart';
import 'package:bd_sports/core/auth/permission.dart';
import 'package:bd_sports/core/auth/tournament_role.dart';
import 'package:flutter_test/flutter_test.dart';

AppUser _user({
  AccountRole role = AccountRole.member,
  Map<String, Set<TournamentRole>> tournamentRoles =
      const <String, Set<TournamentRole>>{},
  bool suspended = false,
}) {
  return AppUser(
    id: 'u1',
    displayName: 'Test',
    accountRole: role,
    tournamentRoles: tournamentRoles,
    isSuspended: suspended,
  );
}

void main() {
  group('AccessPolicy', () {
    test('signed-out visitors cannot do anything', () {
      for (final permission in Permission.values) {
        expect(AccessPolicy.can(null, permission), isFalse);
      }
    });

    test('a member can create a tournament but not approve one', () {
      final user = _user();
      expect(AccessPolicy.can(user, Permission.createTournament), isTrue);
      expect(AccessPolicy.can(user, Permission.approveTournament), isFalse);
    });

    test('a scorer can enter score only in their own tournament', () {
      final user = _user(
        tournamentRoles: {
          't1': {TournamentRole.scorer},
        },
      );
      expect(
        AccessPolicy.can(user, Permission.enterScore, tournamentId: 't1'),
        isTrue,
      );
      expect(
        AccessPolicy.can(user, Permission.enterScore, tournamentId: 't2'),
        isFalse,
      );
      expect(
        AccessPolicy.can(user, Permission.manageFixtures, tournamentId: 't1'),
        isFalse,
      );
    });

    test('an organizer manages fixtures only in their own tournament', () {
      final user = _user(
        tournamentRoles: {
          't1': {TournamentRole.organizer},
        },
      );
      expect(
        AccessPolicy.can(user, Permission.manageFixtures, tournamentId: 't1'),
        isTrue,
      );
      expect(
        AccessPolicy.can(user, Permission.manageFixtures, tournamentId: 't2'),
        isFalse,
      );
      expect(AccessPolicy.can(user, Permission.manageFixtures), isFalse);
    });

    test('a moderator can moderate but not manage admins', () {
      final user = _user(role: AccountRole.moderator);
      expect(AccessPolicy.can(user, Permission.moderateContent), isTrue);
      expect(AccessPolicy.can(user, Permission.manageAdmins), isFalse);
    });

    test('a super admin can do everything', () {
      final user = _user(role: AccountRole.superAdmin);
      for (final permission in Permission.values) {
        expect(AccessPolicy.can(user, permission), isTrue);
      }
    });

    test('a suspended account is denied everything', () {
      final user = _user(
        role: AccountRole.superAdmin,
        suspended: true,
      );
      for (final permission in Permission.values) {
        expect(AccessPolicy.can(user, permission), isFalse);
      }
    });
  });
}
