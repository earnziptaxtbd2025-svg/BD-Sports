import 'package:bd_sports/core/privacy/privacy_settings.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('defaults', () {
    test('phone number is hidden by default', () {
      expect(PrivacySettings.defaults().phone, Audience.nobody);
      expect(PrivacySettings.defaults().findableByPhone, isFalse);
    });

    test('under-18 players get stricter defaults', () {
      final minor = PrivacySettings.defaults(isMinor: true);
      expect(minor.age, Audience.nobody);
      expect(minor.messages, Audience.nobody);
      expect(minor.photo, Audience.teammates);
      expect(minor.showInTalentSearch, isFalse);
    });
  });

  group('who can view', () {
    test('owner always can', () {
      expect(PrivacySettings.canView(Audience.nobody, ViewerRelation.owner), isTrue);
    });

    test('everyone, teammates and nobody', () {
      expect(PrivacySettings.canView(Audience.everyone, ViewerRelation.other), isTrue);
      expect(PrivacySettings.canView(Audience.teammates, ViewerRelation.teammate), isTrue);
      expect(PrivacySettings.canView(Audience.teammates, ViewerRelation.other), isFalse);
      expect(PrivacySettings.canView(Audience.nobody, ViewerRelation.teammate), isFalse);
    });
  });

  group('saving', () {
    test('round trips through JSON', () {
      final settings = PrivacySettings.defaults().copyWith(
        phone: Audience.teammates,
        showStats: false,
      );
      final copy = PrivacySettings.fromJson(settings.toJson());
      expect(copy.phone, Audience.teammates);
      expect(copy.showStats, isFalse);
    });

    test('unknown or missing values fall back to the most private choice', () {
      final settings = PrivacySettings.fromJson(<String, dynamic>{'phone': 'hacked'});
      expect(settings.phone, Audience.nobody);
      expect(settings.findableByPhone, isFalse);
      expect(settings.showInTalentSearch, isFalse);
    });

    test('choices are kept after restarting', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();

      final first = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(first.dispose);
      final current = first.read(privacySettingsProvider);
      await first
          .read(privacySettingsProvider.notifier)
          .update(current.copyWith(phone: Audience.everyone));

      final second = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(second.dispose);
      expect(second.read(privacySettingsProvider).phone, Audience.everyone);
    });
  });
}
