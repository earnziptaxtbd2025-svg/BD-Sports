import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/privacy/privacy_settings.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = context.s;
    final settings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(s.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionTitle(s.privacyWhoCanSee),
          _AudienceTile(
            title: s.privacyPhone,
            value: settings.phone,
            onChanged: (value) => notifier.update(settings.copyWith(phone: value)),
          ),
          _AudienceTile(
            title: s.privacyAge,
            value: settings.age,
            onChanged: (value) => notifier.update(settings.copyWith(age: value)),
          ),
          _AudienceTile(
            title: s.privacyPhoto,
            value: settings.photo,
            onChanged: (value) => notifier.update(settings.copyWith(photo: value)),
          ),
          _SectionTitle(s.privacyContact),
          _AudienceTile(
            title: s.privacyWhoCanMessage,
            value: settings.messages,
            onChanged: (value) =>
                notifier.update(settings.copyWith(messages: value)),
          ),
          SwitchListTile(
            title: Text(s.privacyFindByPhone),
            value: settings.findableByPhone,
            onChanged: (value) =>
                notifier.update(settings.copyWith(findableByPhone: value)),
          ),
          _SectionTitle(s.privacyPlayers),
          SwitchListTile(
            title: Text(s.privacyTalentSearch),
            subtitle: Text(s.privacyTalentSearchHint),
            value: settings.showInTalentSearch,
            onChanged: (value) =>
                notifier.update(settings.copyWith(showInTalentSearch: value)),
          ),
          SwitchListTile(
            title: Text(s.privacyShowStats),
            value: settings.showStats,
            onChanged: (value) =>
                notifier.update(settings.copyWith(showStats: value)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(s.privacyFooter, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _AudienceTile extends StatelessWidget {
  const _AudienceTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final Audience value;
  final ValueChanged<Audience> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return ListTile(
      title: Text(title),
      trailing: DropdownButton<Audience>(
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        items: [
          for (final audience in Audience.values)
            DropdownMenuItem<Audience>(
              value: audience,
              child: Text(s.audience(audience)),
            ),
        ],
      ),
    );
  }
}
