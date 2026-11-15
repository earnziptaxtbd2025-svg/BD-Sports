import 'package:bd_sports/core/auth/permission.dart';
import 'package:bd_sports/core/navigation/screen_registry.dart';
import 'package:bd_sports/core/navigation/screen_spec.dart';
import 'package:bd_sports/core/navigation/screens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('screen list', () {
    test('every screen has a unique id and a unique path', () {
      expect(allScreens.map((s) => s.id).toSet().length, allScreens.length);
      expect(allScreens.map((s) => s.path).toSet().length, allScreens.length);
    });

    test('paths are well formed', () {
      for (final spec in allScreens) {
        expect(RegExp(r'^/[a-z0-9\-/:A-Za-z]*$').hasMatch(spec.path), isTrue, reason: spec.path);
        expect(spec.path.endsWith('/') && spec.path != '/', isFalse, reason: spec.path);
      }
    });

    test('steps look like 1.3 or 1B.1', () {
      for (final spec in allScreens) {
        expect(RegExp(r'^\d+B?\.\d+$').hasMatch(spec.step), isTrue, reason: spec.id);
      }
    });

    test('permission screens name a permission', () {
      for (final spec in allScreens) {
        if (spec.access == ScreenAccess.permission) {
          expect(spec.permission, isNotNull, reason: spec.id);
        }
      }
    });

    test('tournament permissions only appear on screens with a tournament id', () {
      for (final spec in allScreens) {
        if (spec.permission?.scope == PermissionScope.tournament) {
          expect(spec.path.contains(':id'), isTrue, reason: spec.id);
        }
      }
    });

    test('screens listed in a tab hub need no address parameters', () {
      for (final spec in allScreens.where((s) => s.hub != null)) {
        expect(spec.paramNames, isEmpty, reason: spec.id);
      }
    });

    test('every tab hub has screens', () {
      for (final hub in HubTab.values) {
        expect(Screens.forHub(hub), isNotEmpty, reason: hub.name);
      }
    });

    test('the five tabs are built', () {
      for (final id in ['tab.home', 'tab.explore', 'tab.create', 'tab.mySports', 'tab.profile']) {
        expect(Screens.byId(id)!.isBuilt, isTrue, reason: id);
      }
    });

    test('the tournament, match and team link paths exist', () {
      expect(allScreens.any((s) => s.path == '/t/:id'), isTrue);
      expect(allScreens.any((s) => s.path == '/m/:id'), isTrue);
      expect(allScreens.any((s) => s.path == '/team/:id'), isTrue);
    });
  });

  group('addresses', () {
    test('sample paths fill every parameter', () {
      for (final spec in allScreens) {
        final path = Screens.samplePath(spec);
        expect(path.contains(':'), isFalse, reason: spec.id);
      }
      expect(
        Screens.samplePath(Screens.byId('system.report')!),
        '/report/tournament/abcd2345',
      );
    });

    test('well-formed ids pass and broken ones fail', () {
      final spec = Screens.byId('tournament.detail')!;
      expect(Screens.paramsAreValid(spec, {'id': 'abcd2345'}), isTrue);
      expect(Screens.paramsAreValid(spec, {'id': 'nope'}), isFalse);
      expect(Screens.paramsAreValid(spec, {'id': '<script>'}), isFalse);
      expect(Screens.paramsAreValid(spec, <String, String>{}), isFalse);
    });

    test('a report needs a known type and a valid id', () {
      final spec = Screens.byId('system.report')!;
      expect(Screens.paramsAreValid(spec, {'type': 'post', 'id': 'abcd2345'}), isTrue);
      expect(Screens.paramsAreValid(spec, {'type': 'hack', 'id': 'abcd2345'}), isFalse);
    });

    test('a screen with two ids checks both', () {
      final spec = Screens.byId('match.score')!;
      expect(Screens.paramsAreValid(spec, {'id': 'abcd2345', 'matchId': 'efgh6789'}), isTrue);
      expect(Screens.paramsAreValid(spec, {'id': 'abcd2345', 'matchId': 'x'}), isFalse);
    });
  });
}
