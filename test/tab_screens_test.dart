import 'package:bd_sports/app.dart';
import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:bd_sports/core/widgets/neon_bottom_nav.dart';
import 'package:bd_sports/core/widgets/screen_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The five main tabs in the card look, in both dark and light.
void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  Widget buildApp(SharedPreferences prefs) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        internetReachableProvider.overrideWith((ref) => Stream<bool>.value(true)),
      ],
      child: const BdSportsApp(),
    );
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NeonBottomNav),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final look in <String>['dark', 'light']) {
    group('main tabs in the $look look', () {
      late SharedPreferences prefs;

      setUp(() async {
        prefs = await prefsWith(<String, Object>{
          'language_v1': 'en',
          'theme_mode_v1': look,
        });
      });

      testWidgets('Home shows the banner, quick actions and sections', (tester) async {
        await tester.pumpWidget(buildApp(prefs));
        await tester.pumpAndSettle();

        expect(find.text('Create Your Own Tournament!'), findsOneWidget);
        expect(find.text('Discover Tournaments'), findsOneWidget);
        expect(find.text('Join Tournament'), findsOneWidget);
        expect(find.text('Create Tournament'), findsWidgets);
        expect(find.text('Search tournaments...'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Live Matches'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Trending Tournaments'), findsOneWidget);
        expect(find.text('Live Matches'), findsOneWidget);
      });

      testWidgets('Explore, Create, My Sports and Profile show cards', (tester) async {
        await tester.pumpWidget(buildApp(prefs));
        await tester.pumpAndSettle();

        for (final tab in <String>['Explore', 'Create', 'My Sports']) {
          await openTab(tester, tab);
          expect(find.byType(ScreenTile), findsWidgets, reason: tab);
          expect(tester.takeException(), isNull, reason: tab);
        }

        await openTab(tester, 'Profile');
        expect(find.text('Not signed in'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
        expect(find.byType(ScreenTile), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets('Explore search box opens the search screen', (tester) async {
    final prefs = await prefsWith(<String, Object>{'language_v1': 'en'});
    await tester.pumpWidget(buildApp(prefs));
    await tester.pumpAndSettle();

    await openTab(tester, 'Explore');
    await tester.tap(find.text('Search tournaments...'));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home See All opens the trending screen', (tester) async {
    final prefs = await prefsWith(<String, Object>{'language_v1': 'en'});
    await tester.pumpWidget(buildApp(prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle();

    expect(find.text('Trending tournaments'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bangla texts are shown on Home', (tester) async {
    final prefs = await prefsWith(<String, Object>{'language_v1': 'bn'});
    await tester.pumpWidget(buildApp(prefs));
    await tester.pumpAndSettle();

    expect(find.text('নিজের টুর্নামেন্ট তৈরি করুন!'), findsOneWidget);
    expect(find.text('টুর্নামেন্ট খুঁজুন...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
