import 'package:bd_sports/app.dart';
import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/router/app_router.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    // These tests read English texts, so the language is set to English.
    SharedPreferences.setMockInitialValues(<String, Object>{'language_v1': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        internetReachableProvider.overrideWith((ref) => Stream<bool>.value(true)),
      ],
      child: const BdSportsApp(),
    );
  }

  testWidgets('shows five bottom navigation tabs', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });

  testWidgets('switches to the Explore tab', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Explore'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tournaments'), findsOneWidget);
  });

  testWidgets('a shared tournament link opens the tournament screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(appRouterProvider).go('/t/abcd2345');
    await tester.pumpAndSettle();

    expect(find.textContaining('abcd2345'), findsOneWidget);
  });

  testWidgets('a broken link shows a friendly message', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(appRouterProvider).go('/t/not-valid');
    await tester.pumpAndSettle();

    expect(find.text('This link is not valid.'), findsOneWidget);
  });
}
