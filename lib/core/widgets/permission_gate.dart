import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_policy.dart';
import '../auth/current_user_provider.dart';
import '../auth/permission.dart';

/// Shows [child] only when the current user holds [permission].
///
/// For tournament permissions, pass the [tournamentId] the screen belongs to.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.tournamentId,
    this.fallback = const SizedBox.shrink(),
  });

  final Permission permission;
  final String? tournamentId;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allowed = AccessPolicy.can(
      user,
      permission,
      tournamentId: tournamentId,
    );
    return allowed ? child : fallback;
  }
}
