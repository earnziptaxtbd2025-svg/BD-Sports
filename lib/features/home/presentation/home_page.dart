import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/providers/backend_provider.dart';
import '../../../core/router/app_routes.dart';

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
    final s = context.s;
    final configured = ref.watch(backendConfiguredProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Env.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: s.languageTitle,
            onPressed: () => context.push(AppRoutes.language),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.welcome, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(s.homeIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(s.quickLinks, style: theme.textTheme.titleMedium),
          for (final id in shortcutIds)
            if (Screens.byId(id) case final spec?)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(spec.icon, color: theme.colorScheme.primary),
                title: Text(spec.titleFor(s.language)),
                subtitle: Text(spec.descriptionFor(s.language)),
                onTap: () => context.push(spec.path),
              ),
          // Developer information, hidden in production builds.
          if (Env.devToolsEnabled) ...[
            const SizedBox(height: 16),
            _BackendStatusCard(configured: configured),
          ],
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
