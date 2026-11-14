import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/privacy/privacy_settings.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionTitle('Who can see'),
          _AudienceTile(
            title: 'Phone number',
            value: settings.phone,
            onChanged: (value) => notifier.update(settings.copyWith(phone: value)),
          ),
          _AudienceTile(
            title: 'Age',
            value: settings.age,
            onChanged: (value) => notifier.update(settings.copyWith(age: value)),
          ),
          _AudienceTile(
            title: 'Profile photo',
            value: settings.photo,
            onChanged: (value) => notifier.update(settings.copyWith(photo: value)),
          ),
          const _SectionTitle('Contact'),
          _AudienceTile(
            title: 'Who can message me',
            value: settings.messages,
            onChanged: (value) =>
                notifier.update(settings.copyWith(messages: value)),
          ),
          SwitchListTile(
            title: const Text('People can find me by phone number'),
            value: settings.findableByPhone,
            onChanged: (value) =>
                notifier.update(settings.copyWith(findableByPhone: value)),
          ),
          const _SectionTitle('Players'),
          SwitchListTile(
            title: const Text('Show me in talent search'),
            subtitle: const Text('Clubs and academies can find your profile.'),
            value: settings.showInTalentSearch,
            onChanged: (value) =>
                notifier.update(settings.copyWith(showInTalentSearch: value)),
          ),
          SwitchListTile(
            title: const Text('Show my match statistics'),
            value: settings.showStats,
            onChanged: (value) =>
                notifier.update(settings.copyWith(showStats: value)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'These choices are saved on this phone for now. They will be linked '
              'to your account when sign-in is added.',
              style: theme.textTheme.bodySmall,
            ),
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
              child: Text(audience.label),
            ),
        ],
      ),
    );
  }
}
