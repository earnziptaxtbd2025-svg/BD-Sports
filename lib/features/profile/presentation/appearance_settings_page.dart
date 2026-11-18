import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/theme_mode_provider.dart';

/// Choose dark, light, or the same as the phone. The choice is saved and applies at once.
class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = context.s;
    final current = ref.watch(themeModeProvider);

    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.dark, s.appearanceDark, Icons.dark_mode_outlined),
      (ThemeMode.light, s.appearanceLight, Icons.light_mode_outlined),
      (ThemeMode.system, s.appearanceSystem, Icons.phone_android),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.appearanceTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(s.appearanceIntro, style: theme.textTheme.bodyMedium),
          ),
          for (final (mode, label, icon) in options)
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              selected: mode == current,
              trailing: mode == current
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () => ref.read(themeModeProvider.notifier).set(mode),
            ),
        ],
      ),
    );
  }
}
