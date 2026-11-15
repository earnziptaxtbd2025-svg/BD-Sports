import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/screen_registry.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';

/// Developer tool: every screen of the app, with its access rule and status.
/// Tap a screen to open it with a sample id, to check navigation and access.
class ScreenMapPage extends StatelessWidget {
  const ScreenMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final built = allScreens.where((s) => s.isBuilt).length;
    final planned = allScreens.length - built;

    return Scaffold(
      appBar: AppBar(title: const Text('Screen map')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${allScreens.length} screens: $built built, $planned planned.\n'
              'Sign in as different roles in the Role tester to see access rules change.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final area in ScreenArea.values)
            _AreaSection(area: area, screens: Screens.forArea(area)),
        ],
      ),
    );
  }
}

class _AreaSection extends StatelessWidget {
  const _AreaSection({required this.area, required this.screens});

  final ScreenArea area;
  final List<ScreenSpec> screens;

  @override
  Widget build(BuildContext context) {
    if (screens.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: Text('${area.label} (${screens.length})'),
      children: [
        for (final spec in screens)
          ListTile(
            dense: true,
            leading: Icon(spec.icon),
            title: Text(spec.title),
            subtitle: Text('${spec.path}   |   ${spec.accessLabel}'),
            trailing: Text(spec.isBuilt ? 'Built' : 'Step ${spec.step}'),
            onTap: () => context.push(Screens.samplePath(spec)),
          ),
      ],
    );
  }
}
