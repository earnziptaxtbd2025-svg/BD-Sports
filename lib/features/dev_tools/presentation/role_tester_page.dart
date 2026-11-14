import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/access_policy.dart';
import '../../../core/auth/account_role.dart';
import '../../../core/auth/current_user_provider.dart';
import '../../../core/auth/permission.dart';
import '../../../core/auth/tournament_role.dart';

/// Developer tool: switch roles and see exactly what each role may do.
class RoleTesterPage extends ConsumerWidget {
  const RoleTesterPage({super.key});

  static const String sampleTournamentId = 'sample-tournament';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final notifier = ref.read(currentUserProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Role & Permission tester')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Account role', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Signed out'),
                selected: user == null,
                onSelected: (_) => notifier.signOut(),
              ),
              for (final role in AccountRole.values)
                ChoiceChip(
                  label: Text(role.label),
                  selected: user?.accountRole == role,
                  onSelected: (_) => notifier.signInAs(role),
                ),
            ],
          ),
          if (user != null) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Account suspended'),
              value: user.isSuspended,
              onChanged: notifier.setSuspended,
            ),
            const SizedBox(height: 8),
            Text(
              'Roles in the sample tournament',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final role in TournamentRole.values)
                  FilterChip(
                    label: Text(role.label),
                    selected: user.rolesIn(sampleTournamentId).contains(role),
                    onSelected: (_) =>
                        notifier.toggleTournamentRole(sampleTournamentId, role),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text('What this person can do', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final permission in Permission.values)
            _PermissionTile(
              permission: permission,
              allowed: AccessPolicy.can(
                user,
                permission,
                tournamentId: sampleTournamentId,
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.permission, required this.allowed});

  final Permission permission;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        allowed ? Icons.check_circle : Icons.cancel_outlined,
        color: allowed ? scheme.primary : scheme.outline,
      ),
      title: Text(permission.label),
      subtitle: Text(permission.scope.name),
    );
  }
}
