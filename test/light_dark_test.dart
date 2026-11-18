import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:bd_sports/core/theme/app_palette.dart';
import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:bd_sports/core/theme/theme_mode_provider.dart';
import 'package:bd_sports/core/widgets/app_badge.dart';
import 'package:bd_sports/core/widgets/glass_card.dart';
import 'package:bd_sports/core/widgets/neon_bottom_nav.dart';
import 'package:bd_sports/core/widgets/neon_button.dart';
import 'package:bd_sports/core/widgets/neon_stepper.dart';
import 'package:bd_sports/core/widgets/neon_tab_bar.dart';
import 'package:bd_sports/core/widgets/neon_text_field.dart';
import 'package:bd_sports/core/widgets/score_header.dart';
import 'package:bd_sports/core/widgets/stat_bar.dart';
import 'package:bd_sports/features/dev_tools/presentation/design_gallery_page.dart';
import 'package:bd_sports/features/profile/presentation/appearance_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget hostIn(ThemeData theme, Widget child) =>
    MaterialApp(theme: theme, home: Scaffold(body: SingleChildScrollView(child: child)));

/// Colour of the first text with [text] in the widget tree.
Color? textColor(WidgetTester tester, String text) {
  final Text widget = tester.widget<Text>(find.text(text).first);
  return widget.style?.color ?? DefaultTextStyle.of(tester.element(find.text(text).first)).style.color;
}

void main() {
  final Map<String, ThemeData> looks = <String, ThemeData>{
    'dark': AppTheme.neonNight(),
    'light': AppTheme.neonDay(),
  };

  for (final MapEntry<String, ThemeData> look in looks.entries) {
    group('widgets in the ${look.key} look', () {
      testWidgets('all widgets build without an error', (tester) async {
        tester.view.physicalSize = const Size(900, 3000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          hostIn(
            look.value,
            Column(
              children: <Widget>[
                NeonButton(label: 'Green', onPressed: () {}),
                NeonButton(
                  label: 'Quiet',
                  style: NeonButtonStyle.outline,
                  onPressed: () {},
                ),
                NeonTabBar(
                  tabs: const <NeonTab>[NeonTab(label: 'A'), NeonTab(label: 'B')],
                  selectedIndex: 0,
                  onChanged: (_) {},
                ),
                Wrap(
                  children: <Widget>[
                    for (final AppBadgeTone tone in AppBadgeTone.values)
                      AppBadge(label: 'Badge', tone: tone),
                  ],
                ),
                const NeonTextField(label: 'Name', hint: 'Type', isRequired: true),
                const NeonStepper(labels: <String>['One', 'Two', 'Three'], currentStep: 1),
                const GlassCard(child: Text('Card')),
                const ScoreHeader(homeName: 'A', awayName: 'B', score: '1 - 0'),
                const StatBar(label: 'Shots', homeValue: 5, awayValue: 3),
                NeonBottomNav(
                  items: const <NeonNavItem>[
                    NeonNavItem(label: 'Home', icon: Icons.home),
                    NeonNavItem(label: 'Create', icon: Icons.add),
                  ],
                  selectedIndex: 0,
                  centerIndex: 1,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('text field label follows the look', (tester) async {
        await tester.pumpWidget(
          hostIn(look.value, const NeonTextField(label: 'Tournament Name')),
        );
        final AppPalette p = look.value.extension<AppPalette>()!;
        expect(textColor(tester, 'Tournament Name'), p.textPrimary);
      });

      testWidgets('quiet button text follows the look', (tester) async {
        await tester.pumpWidget(
          hostIn(
            look.value,
            NeonButton(
              label: 'Cancel',
              style: NeonButtonStyle.outline,
              onPressed: () {},
            ),
          ),
        );
        final AppPalette p = look.value.extension<AppPalette>()!;
        expect(textColor(tester, 'Cancel'), p.textPrimary);
      });

      testWidgets('the design gallery builds', (tester) async {
        tester.view.physicalSize = const Size(900, 9000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(theme: look.value, home: const DesignGalleryPage()),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        // Remove the page so the blinking LIVE dot stops before the test ends.
        await tester.pumpWidget(const SizedBox.shrink());
      });
    });
  }

  test('dark and light text colours are different', () {
    expect(AppPalette.dark.textPrimary, isNot(AppPalette.light.textPrimary));
  });

  group('theme choice', () {
    test('an unknown or empty saved value gives dark', () {
      expect(ThemeModeNotifier.fromCode(null), ThemeMode.dark);
      expect(ThemeModeNotifier.fromCode('nonsense'), ThemeMode.dark);
    });

    test('saved values are read back', () {
      expect(ThemeModeNotifier.fromCode('light'), ThemeMode.light);
      expect(ThemeModeNotifier.fromCode('system'), ThemeMode.system);
      expect(ThemeModeNotifier.fromCode('dark'), ThemeMode.dark);
    });

    test('the choice is saved on the phone', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProviderContainer c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);

      expect(c.read(themeModeProvider), ThemeMode.dark);
      await c.read(themeModeProvider.notifier).set(ThemeMode.light);
      expect(c.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode_v1'), 'light');
    });

    testWidgets('the appearance screen changes the choice', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{'language_v1': 'en'});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProviderContainer c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: AppearanceSettingsPage()),
        ),
      );
      await tester.pump();
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);

      await tester.tap(find.text('Light'));
      await tester.pump();
      expect(c.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode_v1'), 'light');
    });
  });
}
