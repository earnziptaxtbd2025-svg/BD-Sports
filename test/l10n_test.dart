import 'package:bd_sports/core/widgets/neon_bottom_nav.dart';
import 'package:bd_sports/app.dart';
import 'package:bd_sports/core/auth/account_role.dart';
import 'package:bd_sports/core/auth/permission.dart';
import 'package:bd_sports/core/l10n/app_language.dart';
import 'package:bd_sports/core/l10n/language_provider.dart';
import 'package:bd_sports/core/l10n/strings_bn.dart';
import 'package:bd_sports/core/l10n/strings_en.dart';
import 'package:bd_sports/core/navigation/screen_registry.dart';
import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/privacy/privacy_settings.dart';
import 'package:bd_sports/core/router/app_router.dart';
import 'package:bd_sports/core/security/validation_issue.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RegExp _banglaLetters = RegExp(r'[\u0980-\u09FF]');

void main() {
  const en = EnglishStrings();
  const bn = BanglaStrings();

  group('both languages are complete', () {
    test('every plain text exists in both and uses the right script', () {
      expect(en.debugAllTexts.length, bn.debugAllTexts.length);
      for (var i = 0; i < en.debugAllTexts.length; i++) {
        final english = en.debugAllTexts[i];
        final bangla = bn.debugAllTexts[i];
        expect(english.trim(), isNotEmpty, reason: 'English text #$i');
        expect(bangla.trim(), isNotEmpty, reason: 'Bangla text #$i');
        expect(_banglaLetters.hasMatch(english), isFalse, reason: english);
        expect(_banglaLetters.hasMatch(bangla), isTrue, reason: bangla);
      }
    });

    test('every permission, role, audience and validation message is translated', () {
      for (final value in Permission.values) {
        expect(en.permission(value).trim(), isNotEmpty, reason: value.name);
        expect(_banglaLetters.hasMatch(bn.permission(value)), isTrue, reason: value.name);
      }
      for (final value in AccountRole.values) {
        expect(_banglaLetters.hasMatch(bn.accountRole(value)), isTrue, reason: value.name);
        expect(en.accountRole(value).trim(), isNotEmpty);
      }
      for (final value in Audience.values) {
        expect(_banglaLetters.hasMatch(bn.audience(value)), isTrue, reason: value.name);
        expect(en.audience(value).trim(), isNotEmpty);
      }
      for (final value in ValidationIssue.values) {
        expect(_banglaLetters.hasMatch(bn.validation(value)), isTrue, reason: value.name);
        expect(en.validation(value).trim(), isNotEmpty);
      }
    });

    test('every screen has a Bangla title and description', () {
      for (final spec in allScreens) {
        expect(_banglaLetters.hasMatch(spec.titleBn), isTrue, reason: spec.id);
        expect(_banglaLetters.hasMatch(spec.descriptionBn), isTrue, reason: spec.id);
        expect(spec.titleFor(AppLanguage.english), spec.title);
        expect(spec.titleFor(AppLanguage.bangla), spec.titleBn);
        expect(spec.descriptionFor(AppLanguage.english), spec.description);
        expect(spec.descriptionFor(AppLanguage.bangla), spec.descriptionBn);
      }
    });
  });

  group('texts with numbers', () {
    test('steps', () {
      expect(en.stepLabel('1.3'), 'Step 1.3');
      expect(bn.stepLabel('1.3'), 'ধাপ ১.৩');
      expect(bn.builtInStep('1B.4'), 'ধাপ ১B.৪-এ তৈরি হবে');
    });

    test('offline bar counts', () {
      expect(en.offlineWithPending(3), contains('3 change(s)'));
      expect(bn.offlineWithPending(3), contains('৩টি'));
      expect(bn.changesWaiting(12), contains('১২টি'));
      expect(bn.changesFailed(1), contains('১টি'));
    });
  });

  group('language choice', () {
    test('Bangla is the default', () {
      expect(AppLanguage.defaultLanguage, AppLanguage.bangla);
      expect(AppLanguage.fromCode(null), AppLanguage.bangla);
      expect(AppLanguage.fromCode('xx'), AppLanguage.bangla);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
    });

    test('the saved choice is read and a bad value falls back to Bangla', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'language_v1': 'en'});
      var prefs = await SharedPreferences.getInstance();
      var container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      expect(container.read(languageProvider), AppLanguage.english);

      SharedPreferences.setMockInitialValues(<String, Object>{'language_v1': 'garbage'});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      expect(container.read(languageProvider), AppLanguage.bangla);
    });

    test('a new choice is saved on the phone', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).set(AppLanguage.english);
      expect(prefs.getString('language_v1'), 'en');
      expect(container.read(languageProvider), AppLanguage.english);
    });
  });

  group('the app in two languages', () {
    late SharedPreferences prefs;

    setUp(() async {
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

    testWidgets('starts in Bangla', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('হোম'), findsWidgets);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('the language screen switches the whole app at once', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      final router = container.read(appRouterProvider);

      router.go('/profile/language');
      await tester.pumpAndSettle();
      expect(find.text('বাংলা'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Choose the language of the app.'), findsOneWidget);

      router.go('/home');
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(NeonBottomNav), matching: find.text('Home')),
        findsOneWidget,
      );
      expect(prefs.getString('language_v1'), 'en');

      router.go('/profile/language');
      await tester.pumpAndSettle();
      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();
      expect(find.text('অ্যাপের ভাষা বেছে নিন।'), findsOneWidget);
    });

    testWidgets('screen titles follow the language', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

      container.read(appRouterProvider).go('/team/abcd2345');
      await tester.pumpAndSettle();
      expect(find.text('দল'), findsWidgets);

      await container.read(languageProvider.notifier).set(AppLanguage.english);
      await tester.pumpAndSettle();
      expect(find.text('Team'), findsWidgets);
    });
  });
}
