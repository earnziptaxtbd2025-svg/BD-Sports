import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/shared_preferences_provider.dart';
import 'app_language.dart';

/// The language the person chose. Saved on the phone, Bangla by default.
class LanguageNotifier extends Notifier<AppLanguage> {
  static const String _key = 'language_v1';

  @override
  AppLanguage build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return AppLanguage.fromCode(saved);
  }

  Future<void> set(AppLanguage language) async {
    state = language;
    await ref.read(sharedPreferencesProvider).setString(_key, language.code);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);
