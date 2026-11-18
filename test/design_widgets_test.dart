import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:bd_sports/core/widgets/app_badge.dart';
import 'package:bd_sports/core/widgets/glass_card.dart';
import 'package:bd_sports/core/widgets/neon_button.dart';
import 'package:bd_sports/core/widgets/neon_tab_bar.dart';
import 'package:bd_sports/core/widgets/neon_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Puts a widget inside the neon theme, the same way the real app does.
Widget host(Widget child) {
  return MaterialApp(
    theme: AppTheme.neonNight(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('NeonButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(NeonButton(label: 'Save', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('disabled button ignores taps', (tester) async {
      await tester.pumpWidget(
        host(const NeonButton(label: 'Save', onPressed: null)),
      );
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('loading button shows spinner and blocks taps', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          NeonButton(label: 'Save', isLoading: true, onPressed: () => taps++),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('shows sub label', (tester) async {
      await tester.pumpWidget(
        host(
          NeonButton(
            label: 'Submit',
            subLabel: 'Before Match Start',
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Before Match Start'), findsOneWidget);
    });

    testWidgets('is at least 48 high', (tester) async {
      await tester.pumpWidget(
        host(NeonButton(label: 'Go', onPressed: () {}, expand: false)),
      );
      expect(
        tester.getSize(find.byType(NeonButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('NeonTabBar', () {
    testWidgets('reports the tapped tab', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        host(
          NeonTabBar(
            tabs: const <NeonTab>[
              NeonTab(label: 'Scorecard'),
              NeonTab(label: 'Stats'),
            ],
            selectedIndex: selected,
            onChanged: (int i) => selected = i,
          ),
        ),
      );
      await tester.tap(find.text('Stats'));
      expect(selected, 1);
    });
  });

  group('AppBadge', () {
    testWidgets('shows its label for every tone', (tester) async {
      for (final AppBadgeTone tone in AppBadgeTone.values) {
        await tester.pumpWidget(host(AppBadge(label: 'X-${tone.name}', tone: tone)));
        expect(find.text('X-${tone.name}'), findsOneWidget);
      }
    });
  });

  group('GlassCard', () {
    testWidgets('shows child and reacts to tap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(GlassCard(onTap: () => taps++, child: const Text('Card'))),
      );
      await tester.tap(find.text('Card'));
      expect(taps, 1);
    });
  });

  group('NeonTextField', () {
    testWidgets('shows label with required star and hint', (tester) async {
      await tester.pumpWidget(
        host(
          const NeonTextField(
            label: 'Tournament Name',
            hint: 'Enter name',
            isRequired: true,
          ),
        ),
      );
      expect(find.textContaining('Tournament Name'), findsOneWidget);
      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('validator error is shown', (tester) async {
      final GlobalKey<FormState> key = GlobalKey<FormState>();
      await tester.pumpWidget(
        host(
          Form(
            key: key,
            child: NeonTextField(
              label: 'Name',
              validator: (String? v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('typing updates the controller', (tester) async {
      final TextEditingController c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(
        host(NeonTextField(label: 'Name', controller: c)),
      );
      await tester.enterText(find.byType(TextFormField), 'Rangpur FC');
      expect(c.text, 'Rangpur FC');
    });
  });
}
