import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/language_provider.dart';

/// Choose Bangla or English. The choice is saved on the phone and applies at once.
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = context.s;
    final current = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.languageTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(s.languageIntro, style: theme.textTheme.bodyMedium),
          ),
          for (final language in AppLanguage.values)
            ListTile(
              title: Text(language.nativeName),
              selected: language == current,
              trailing: language == current
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () => ref.read(languageProvider.notifier).set(language),
            ),
        ],
      ),
    );
  }
}
