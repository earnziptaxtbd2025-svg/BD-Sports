import 'package:bd_sports/app.dart';
import 'package:bd_sports/core/auth/account_role.dart';
import 'package:bd_sports/core/auth/current_user_provider.dart';
import 'package:bd_sports/core/auth/tournament_role.dart';
import 'package:bd_sports/core/navigation/screen_registry.dart';
import 'package:bd_sports/core/navigation/screens.dart';
import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/router/app_router.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:bd_sports/features/dev_tools/presentation/screen_map_page.dart';
import 'package:bd_sports/features/navigation/presentation/no_access_page.dart';
import 'package:bd_sports/features/navigation/presentation/not_found_page.dart';
import 'package:bd_sports/features/navigation/presentation/planned_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderScope buildApp() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        internetReachableProvider.overrideWith((ref) => Stream<bool>.value(true)),
      ],
      child: const BdSportsApp(),
    );
  }

  Future<ProviderContainer> start(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Future<void> open(WidgetTester tester, ProviderContainer c, String path) async {
    c.read(appRouterProvider).go(path);
    await tester.pumpAndSettle();
  }

  testWidgets('signed-out visitors are sent to sign in', (tester) async {
    final c = await start(tester);
    await open(tester, c, '/create/tournament');
    expect(find.text('Sign-in is built in Step 1.1.'), findsOneWidget);
  });

  testWidgets('a member opens the create tournament screen', (tester) async {
    final c = await start(tester);
    c.read(currentUserProvider.notifier).signInAs(AccountRole.member);
    await open(tester, c, '/create/tournament');
    expect(find.text('Create a tournament'), findsWidgets);
    expect(find.byType(PlannedScreenPage), findsOneWidget);
  });

  testWidgets('organizer tools open only for the organizer of that tournament', (tester) async {
    final c = await start(tester);
    final user = c.read(currentUserProvider.notifier);
    user.signInAs(AccountRole.member);

    await open(tester, c, '/t/abcd2345/manage');
    expect(find.text(NoAccessPage.message), findsOneWidget);

    user.toggleTournamentRole('abcd2345', TournamentRole.organizer);
    await open(tester, c, '/t/abcd2345/manage');
    expect(find.byType(PlannedScreenPage), findsOneWidget);

    await open(tester, c, '/t/efgh6789/manage');
    expect(find.text(NoAccessPage.message), findsOneWidget);
  });

  testWidgets('a suspended account cannot open signed-in screens', (tester) async {
    final c = await start(tester);
    final user = c.read(currentUserProvider.notifier);
    user.signInAs(AccountRole.member);
    user.setSuspended(true);
    await open(tester, c, '/my-sports/teams');
    expect(find.text(NoAccessPage.message), findsOneWidget);
  });

  testWidgets('admin screens follow the role', (tester) async {
    final c = await start(tester);
    final user = c.read(currentUserProvider.notifier);

    await open(tester, c, '/admin');
    expect(find.text('Sign-in is built in Step 1.1.'), findsOneWidget);

    user.signInAs(AccountRole.moderator);
    await open(tester, c, '/admin');
    expect(find.byType(PlannedScreenPage), findsOneWidget);

    await open(tester, c, '/admin/audit');
    expect(find.text(NoAccessPage.message), findsOneWidget);
  });

  testWidgets('signing out closes a protected screen', (tester) async {
    final c = await start(tester);
    final user = c.read(currentUserProvider.notifier);
    user.signInAs(AccountRole.member);
    await open(tester, c, '/my-sports/teams');
    expect(find.byType(PlannedScreenPage), findsOneWidget);

    user.signOut();
    await tester.pumpAndSettle();
    expect(find.text('Sign-in is built in Step 1.1.'), findsOneWidget);
  });

  testWidgets('an unknown address shows a friendly page', (tester) async {
    final c = await start(tester);
    await open(tester, c, '/no/such/place');
    expect(find.text(NotFoundPage.message), findsOneWidget);
  });

  testWidgets('a hub tile opens its screen', (tester) async {
    await start(tester);
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('Explore')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tournaments'));
    await tester.pumpAndSettle();
    expect(find.byType(PlannedScreenPage), findsOneWidget);
  });

  testWidgets('every screen in the list opens without an error', (tester) async {
    final c = await start(tester);
    c.read(currentUserProvider.notifier).signInAs(AccountRole.superAdmin);

    for (final spec in allScreens) {
      // The no-access screen itself shows the no-access message, by design.
      if (spec.path == '/no-access') {
        continue;
      }
      await open(tester, c, Screens.samplePath(spec));
      expect(find.text(NotFoundPage.message), findsNothing, reason: spec.path);
      expect(find.text(NoAccessPage.message), findsNothing, reason: spec.path);
      expect(tester.takeException(), isNull, reason: spec.path);
    }
  });

  testWidgets('the screen map lists every area', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ScreenMapPage())),
    );
    expect(find.textContaining('${allScreens.length} screens'), findsOneWidget);
    expect(find.textContaining('Main tabs ('), findsOneWidget);
  });
}
