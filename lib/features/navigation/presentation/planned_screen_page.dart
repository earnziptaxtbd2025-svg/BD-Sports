import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/home_button_if_root.dart';
import '../../../core/widgets/state_view.dart';

/// Placeholder for a screen that is built in a later step. It states which step,
/// who may open it, and shows address ids only when they are well formed.
class PlannedScreenPage extends StatelessWidget {
  const PlannedScreenPage({super.key, required this.spec, required this.params});

  final ScreenSpec spec;
  final Map<String, String> params;

  static const String invalidLinkMessage = 'This link is not valid.';

  @override
  Widget build(BuildContext context) {
    final valid = Screens.paramsAreValid(spec, params);

    return Scaffold(
      appBar: AppBar(
        title: Text(valid ? spec.title : 'Link'),
        leading: homeButtonIfRoot(context),
      ),
      body: valid ? _content(context) : _invalid(context),
    );
  }

  Widget _invalid(BuildContext context) {
    return StateView(
      icon: Icons.link_off,
      title: invalidLinkMessage,
      actionLabel: 'Go to Home',
      onAction: () => context.go(AppRoutes.home),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              spec.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              spec.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Chip(label: Text('Built in Step ${spec.step}')),
            const SizedBox(height: 8),
            Text('Access: ${spec.accessLabel}', style: theme.textTheme.bodySmall),
            for (final name in spec.paramNames)
              Text(
                '${name == 'id' ? 'ID' : name}: ${params[name]}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
