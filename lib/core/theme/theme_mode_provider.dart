import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/shared_preferences_provider.dart';

/// Dark, light, or follow the phone. Saved on the phone. Dark is the default because
/// it is the approved design.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode_v1';

  @override
  ThemeMode build() {
    final String? saved = ref.read(sharedPreferencesProvider).getString(_key);
    return fromCode(saved);
  }

  /// Reads a saved code. Anything unknown gives dark.
  static ThemeMode fromCode(String? code) {
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == code) {
        return mode;
      }
    }
    return ThemeMode.dark;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
