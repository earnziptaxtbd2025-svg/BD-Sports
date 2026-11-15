import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/providers/backend_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// Screens offered as quick links on Home.
  static const List<String> shortcutIds = <String>[
    'discover.search',
    'discover.map',
    'discover.calendar',
    'system.notifications',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final configured = ref.watch(backendConfiguredProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Env.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Tournaments near you will appear here (Step 1.5).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Quick links', style: theme.textTheme.titleMedium),
          for (final id in shortcutIds)
            if (Screens.byId(id) case final spec?)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(spec.icon, color: theme.colorScheme.primary),
                title: Text(spec.title),
                subtitle: Text(spec.description),
                onTap: () => context.push(spec.path),
              ),
          const SizedBox(height: 16),
          _BackendStatusCard(configured: configured),
        ],
      ),
    );
  }
}

class _BackendStatusCard extends StatelessWidget {
  const _BackendStatusCard({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          configured ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
        ),
        title: const Text('Backend'),
        subtitle: Text(
          configured
              ? 'Supabase keys found.'
              : 'Supabase keys not set yet. The app runs in offline preview.',
        ),
      ),
    );
  }
}
