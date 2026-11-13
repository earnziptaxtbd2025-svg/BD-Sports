import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/backend_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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
          const SizedBox(height: 24),
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
