import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/current_user_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/router/app_routes.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = context.s;
    final user = ref.watch(currentUserProvider);
    final settings = Screens.forArea(ScreenArea.settings);

    return Scaffold(
      appBar: AppBar(title: Text(s.tabProfile)),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(user?.displayName ?? s.notSignedIn),
            subtitle: Text(
              user == null ? s.signInComingSoon : s.accountRole(user.accountRole),
            ),
            trailing: user == null
                ? TextButton(
                    onPressed: () => context.push(AppRoutes.signIn),
                    child: Text(s.signIn),
                  )
                : null,
          ),
          const Divider(),
          for (final spec in settings)
            ListTile(
              leading: Icon(spec.icon, color: theme.colorScheme.primary),
              title: Text(spec.titleFor(s.language)),
              subtitle: Text(spec.descriptionFor(s.language)),
              trailing: spec.isBuilt
                  ? const Icon(Icons.chevron_right)
                  : Text(s.stepLabel(spec.step), style: theme.textTheme.labelSmall),
              onTap: () => context.push(spec.path),
            ),
          if (Env.devToolsEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Role & Permission tester'),
              subtitle: const Text('Developer tool, removed in the final release.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.devRoles),
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: const Text('Screen map'),
              subtitle: const Text('Developer tool, removed in the final release.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.devScreens),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Public link tester'),
              subtitle: const Text('Developer tool, removed in the final release.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.devLinks),
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Offline sync tester'),
              subtitle: const Text('Developer tool, removed in the final release.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.devSync),
            ),
          ],
        ],
      ),
    );
  }
}
