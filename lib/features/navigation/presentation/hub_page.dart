import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';

/// A tab that lists the screens of one area (Explore, Create, My Sports).
/// Each row opens its screen. Locked rows ask the person to sign in first.
class HubPage extends StatelessWidget {
  const HubPage({
    super.key,
    required this.title,
    required this.hub,
    required this.intro,
  });

  final String title;
  final HubTab hub;
  final String intro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final items = Screens.forHub(hub);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(intro, style: theme.textTheme.bodyMedium),
          ),
          for (final spec in items)
            ListTile(
              leading: Icon(spec.icon, color: theme.colorScheme.primary),
              title: Text(spec.titleFor(s.language)),
              subtitle: Text(spec.descriptionFor(s.language)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (spec.access != ScreenAccess.public)
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  if (!spec.isBuilt) ...[
                    const SizedBox(width: 6),
                    Text(s.stepLabel(spec.step), style: theme.textTheme.labelSmall),
                  ],
                ],
              ),
              onTap: () => context.push(spec.path),
            ),
        ],
      ),
    );
  }
}
