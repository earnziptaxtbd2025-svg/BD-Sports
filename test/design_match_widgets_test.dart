import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:bd_sports/core/widgets/live_badge.dart';
import 'package:bd_sports/core/widgets/neon_bottom_nav.dart';
import 'package:bd_sports/core/widgets/neon_stepper.dart';
import 'package:bd_sports/core/widgets/score_header.dart';
import 'package:bd_sports/core/widgets/stat_bar.dart';
import 'package:bd_sports/core/widgets/team_crest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool bottom = false}) {
  return MaterialApp(
    theme: AppTheme.neonNight(),
    home: Scaffold(
      body: bottom ? const SizedBox.shrink() : Center(child: child),
      bottomNavigationBar: bottom ? child : null,
    ),
  );
}

void main() {
  group('TeamCrest.initials', () {
    test('two words give two letters', () {
      expect(TeamCrest.initials('Rangpur FC'), 'RF');
    });
    test('one word gives one letter', () {
      expect(TeamCrest.initials('Rangpur'), 'R');
    });
    test('empty name gives a question mark', () {
      expect(TeamCrest.initials('   '), '?');
    });
    test('Bangla name works', () {
      expect(TeamCrest.initials('রংপুর এফসি').isNotEmpty, isTrue);
    });
  });

  group('LiveBadge', () {
    testWidgets('shows its label', (tester) async {
      await tester.pumpWidget(host(const LiveBadge(label: 'LIVE')));
      expect(find.text('LIVE'), findsOneWidget);
      // Remove the widget so the blinking animation is stopped before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('ScoreHeader', () {
    testWidgets('shows teams, score and status', (tester) async {
      await tester.pumpWidget(
        host(
          const ScoreHeader(
            homeName: 'Rangpur FC',
            awayName: 'Lalmonirhat United',
            score: '1 - 0',
            status: '1st Half 63:24',
            competition: 'Football Championship 2026',
          ),
        ),
      );
      expect(find.text('Rangpur FC'), findsOneWidget);
      expect(find.text('Lalmonirhat United'), findsOneWidget);
      expect(find.text('1 - 0'), findsOneWidget);
      expect(find.text('1st Half 63:24'), findsOneWidget);
      expect(find.text('Football Championship 2026'), findsOneWidget);
    });

    testWidgets('live match shows the live badge', (tester) async {
      await tester.pumpWidget(
        host(
          const ScoreHeader(
            homeName: 'A',
            awayName: 'B',
            score: '0 - 0',
            isLive: true,
          ),
        ),
      );
      expect(find.byType(LiveBadge), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('long cricket score does not overflow', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: ScoreHeader(
              homeName: 'Rangpur Royals',
              awayName: 'Lalmonirhat United',
              score: '180/5',
              status: '(20.0 Over)',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('StatBar', () {
    test('flexes follow the values', () {
      final (int h, int a) = StatBar.flexes(58, 42);
      expect(h, 580);
      expect(a, 420);
    });
    test('both zero gives an even split', () {
      expect(StatBar.flexes(0, 0), (1, 1));
    });
    test('one side zero keeps a thin part', () {
      final (int h, int a) = StatBar.flexes(5, 0);
      expect(h, 1000);
      expect(a, 1);
    });
    test('negative value counts as zero', () {
      final (int h, int a) = StatBar.flexes(-3, 4);
      expect(h, 1);
      expect(a, 1000);
    });

    testWidgets('shows label and both numbers with suffix', (tester) async {
      await tester.pumpWidget(
        host(
          const StatBar(
            label: 'Possession',
            homeValue: 58,
            awayValue: 42,
            suffix: '%',
          ),
        ),
      );
      expect(find.text('Possession'), findsOneWidget);
      expect(find.text('58%'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
    });
  });

  group('NeonStepper', () {
    testWidgets('shows all step labels', (tester) async {
      await tester.pumpWidget(
        host(
          const NeonStepper(
            labels: <String>['Info', 'Rules', 'Prize', 'Location', 'Preview'],
            currentStep: 2,
          ),
        ),
      );
      for (final String l in <String>['Info', 'Rules', 'Prize', 'Location', 'Preview']) {
        expect(find.text(l), findsOneWidget);
      }
      // Steps 1 and 2 are done: two ticks. Step 3 is current: number 3 is shown.
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('out of range step is kept inside', (tester) async {
      await tester.pumpWidget(
        host(
          const NeonStepper(labels: <String>['A', 'B'], currentStep: 99),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('NeonBottomNav', () {
    const List<NeonNavItem> items = <NeonNavItem>[
      NeonNavItem(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
      NeonNavItem(label: 'Explore', icon: Icons.search),
      NeonNavItem(label: 'Create', icon: Icons.add),
      NeonNavItem(label: 'My Sports', icon: Icons.emoji_events_outlined),
      NeonNavItem(label: 'Profile', icon: Icons.person_outline),
    ];

    testWidgets('shows every label', (tester) async {
      await tester.pumpWidget(
        host(
          NeonBottomNav(
            items: items,
            selectedIndex: 0,
            centerIndex: 2,
            onChanged: (_) {},
          ),
          bottom: true,
        ),
      );
      for (final NeonNavItem i in items) {
        expect(find.text(i.label), findsOneWidget);
      }
    });

    testWidgets('reports the tapped item, also the raised one', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        host(
          NeonBottomNav(
            items: items,
            selectedIndex: selected,
            centerIndex: 2,
            onChanged: (int i) => selected = i,
          ),
          bottom: true,
        ),
      );
      await tester.tap(find.text('Profile'));
      expect(selected, 4);
      await tester.tap(find.byIcon(Icons.add));
      expect(selected, 2);
    });

    testWidgets('selected item uses its selected icon', (tester) async {
      await tester.pumpWidget(
        host(
          NeonBottomNav(items: items, selectedIndex: 0, onChanged: (_) {}),
          bottom: true,
        ),
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
    });
  });
}
