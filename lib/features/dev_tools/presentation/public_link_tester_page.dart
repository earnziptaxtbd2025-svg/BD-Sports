import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/public_links/public_links.dart';
import '../../../core/public_links/short_id.dart';

/// Developer tool: build sample links and check how pasted links are read.
class PublicLinkTesterPage extends ConsumerStatefulWidget {
  const PublicLinkTesterPage({super.key});

  @override
  ConsumerState<PublicLinkTesterPage> createState() =>
      _PublicLinkTesterPageState();
}

class _PublicLinkTesterPageState extends ConsumerState<PublicLinkTesterPage> {
  final TextEditingController _controller = TextEditingController();
  late String _sampleId = ShortId.generate();
  PublicLink? _parsed;
  bool _checked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _describe(PublicLink link) {
    final kind = switch (link) {
      TournamentLink() => 'Tournament',
      MatchLink() => 'Match',
      TeamLink() => 'Team',
    };
    return '$kind link, id ${link.id}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final links = ref.watch(publicLinksProvider);

    final samples = <String>[
      links.tournament(_sampleId, title: 'Pirgachha Premier 2026') ??
          PublicLinks.tournamentPath(_sampleId, title: 'Pirgachha Premier 2026'),
      links.match(_sampleId) ?? PublicLinks.matchPath(_sampleId),
      links.team(_sampleId) ?? PublicLinks.teamPath(_sampleId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Public link tester')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(links.isConfigured ? Icons.public : Icons.public_off),
              title: Text(
                links.isConfigured ? links.baseUrl : 'Web address not set yet',
              ),
              subtitle: Text(
                links.isConfigured
                    ? 'Links below are full web addresses.'
                    : 'Showing paths only. Set the repository variable '
                        'PUBLIC_BASE_URL to get full links.',
              ),
              isThreeLine: !links.isConfigured,
            ),
          ),
          const SizedBox(height: 16),
          Text('Sample links', style: theme.textTheme.titleMedium),
          for (final sample in samples)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(sample, style: const TextStyle(fontSize: 14)),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => Clipboard.setData(ClipboardData(text: sample)),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('New sample id'),
              onPressed: () => setState(() => _sampleId = ShortId.generate()),
            ),
          ),
          const Divider(height: 32),
          Text('Check a link', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste a link or a path like /t/k7m2xq9d',
            ),
            onChanged: (_) => setState(() => _checked = false),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => setState(() {
              _parsed = links.parseText(_controller.text);
              _checked = true;
            }),
            child: const Text('Check'),
          ),
          if (_checked) ...[
            const SizedBox(height: 16),
            if (_parsed == null)
              Text(
                'Not one of our links.',
                style: TextStyle(color: theme.colorScheme.error),
              )
            else ...[
              Text(_describe(_parsed!)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open inside the app'),
                onPressed: () => context.push(PublicLinks.pathFor(_parsed!)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
