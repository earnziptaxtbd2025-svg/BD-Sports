import 'package:bd_sports/core/auth/account_role.dart';
import 'package:bd_sports/core/auth/app_user.dart';
import 'package:bd_sports/core/auth/tournament_role.dart';
import 'package:bd_sports/core/navigation/route_guard.dart';
import 'package:bd_sports/core/navigation/screens.dart';
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

String? _guard(String id, AppUser? user, {Map<String, String> params = const {}, String location = '/x'}) {
  return screenGuard(
    spec: Screens.byId(id)!,
    user: user,
    params: params,
    location: location,
  );
}

void main() {
  group('screenGuard', () {
    test('public screens open for everyone', () {
      expect(_guard('tournament.detail', null), isNull);
      expect(_guard('tournament.detail', _user()), isNull);
    });

    test('signed-out visitors go to sign in and come back afterwards', () {
      final target = _guard('create.tournament', null, location: '/create/tournament');
      expect(target, '/sign-in?from=%2Fcreate%2Ftournament');
    });

    test('signed-in screens open for any signed-in person', () {
      expect(_guard('mine.teams', _user()), isNull);
    });

    test('a suspended account is sent to no access', () {
      expect(_guard('mine.teams', _user(suspended: true)), '/no-access');
      expect(_guard('create.tournament', _user(suspended: true)), '/no-access');
    });

    test('a member can open create tournament', () {
      expect(_guard('create.tournament', _user()), isNull);
    });

    test('organizer tools need the organizer role in that tournament', () {
      final organizer = _user(tournamentRoles: {
        'abcd2345': {TournamentRole.organizer},
      });
      expect(_guard('manage.home', _user(), params: {'id': 'abcd2345'}), '/no-access');
      expect(_guard('manage.home', organizer, params: {'id': 'abcd2345'}), isNull);
      expect(_guard('manage.home', organizer, params: {'id': 'efgh6789'}), '/no-access');
    });

    test('a scorer can score but cannot manage fixtures', () {
      final scorer = _user(tournamentRoles: {
        'abcd2345': {TournamentRole.scorer},
      });
      expect(_guard('match.score', scorer, params: {'id': 'abcd2345'}), isNull);
      expect(_guard('manage.fixtures', scorer, params: {'id': 'abcd2345'}), '/no-access');
    });

    test('admin screens follow the role matrix', () {
      final moderator = _user(role: AccountRole.moderator);
      expect(_guard('admin.home', moderator), isNull);
      expect(_guard('admin.reports', moderator), isNull);
      expect(_guard('admin.audit', moderator), '/no-access');
      expect(_guard('admin.roles', moderator), '/no-access');
      expect(_guard('admin.home', _user()), '/no-access');

      final superAdmin = _user(role: AccountRole.superAdmin);
      expect(_guard('admin.audit', superAdmin), isNull);
      expect(_guard('admin.roles', superAdmin), isNull);
    });
  });

  group('safeReturnPath', () {
    test('accepts plain in-app paths', () {
      expect(safeReturnPath('/create/tournament'), '/create/tournament');
      expect(safeReturnPath('/t/abcd2345/manage?tab=teams'), '/t/abcd2345/manage?tab=teams');
    });

    test('rejects web addresses and tricks', () {
      for (final bad in [
        null,
        '',
        'https://evil.example',
        '//evil.example',
        '/\\evil.example',
        'javascript:alert(1)',
        '/ok\nHeader: x',
        'create/tournament',
        '/redirect?to=https://evil.example',
      ]) {
        expect(safeReturnPath(bad), isNull, reason: '$bad');
      }
    });

    test('never returns to the sign-in screen itself', () {
      expect(safeReturnPath('/sign-in'), isNull);
      expect(safeReturnPath('/sign-in?from=%2Fhome'), isNull);
      expect(safeReturnPath('/sign-in/verify'), isNull);
    });

    test('rejects very long values', () {
      expect(safeReturnPath('/${'a' * 300}'), isNull);
    });
  });
}
