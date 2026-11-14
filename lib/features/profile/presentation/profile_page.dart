import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/current_user_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/router/app_routes.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(user?.displayName ?? 'Not signed in'),
            subtitle: Text(
              user == null
                  ? 'Sign-in is built in Step 1.1.'
                  : user.accountRole.label,
            ),
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
          ],
        ],
      ),
    );
  }
}
