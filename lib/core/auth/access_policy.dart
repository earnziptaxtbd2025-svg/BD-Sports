import 'app_user.dart';
import 'permission.dart';
import 'role_permissions.dart';

/// The single place that answers "may this person do this?".
///
/// Important: this only decides what the app shows. Real enforcement must also
/// happen on the server (database row level security), which is added when the
/// backend is connected.
class AccessPolicy {
  const AccessPolicy._();

  static bool can(
    AppUser? user,
    Permission permission, {
    String? tournamentId,
  }) {
    if (user == null || user.isSuspended) {
      return false;
    }

    final accountGrants =
        accountRolePermissions[user.accountRole] ?? const <Permission>{};
    if (accountGrants.contains(permission)) {
      return true;
    }

    if (tournamentId != null) {
      for (final role in user.rolesIn(tournamentId)) {
        final grants =
            tournamentRolePermissions[role] ?? const <Permission>{};
        if (grants.contains(permission)) {
          return true;
        }
      }
    }

    return false;
  }
}
