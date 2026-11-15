import '../auth/access_policy.dart';
import '../auth/app_user.dart';
import '../auth/permission.dart';
import '../router/app_routes.dart';
import 'screen_spec.dart';

/// Decides if a screen may open. Returns where to send the person instead, or null
/// if the screen may open.
///
/// This only guards what the app shows. The server must enforce the same rules.
String? screenGuard({
  required ScreenSpec spec,
  required AppUser? user,
  required Map<String, String> params,
  required String location,
}) {
  if (spec.access == ScreenAccess.public) {
    return null;
  }

  if (user == null) {
    return '${AppRoutes.signIn}?from=${Uri.encodeComponent(location)}';
  }

  if (user.isSuspended) {
    return AppRoutes.noAccess;
  }

  if (spec.access == ScreenAccess.signedIn) {
    return null;
  }

  final permission = spec.permission!;
  final allowed = AccessPolicy.can(
    user,
    permission,
    tournamentId: permission.scope == PermissionScope.tournament
        ? params['id']
        : null,
  );
  return allowed ? null : AppRoutes.noAccess;
}

/// Reads the `from` value of the sign-in address. Accepts only a plain path inside
/// the app, so a crafted link can never send the person to another website.
String? safeReturnPath(String? from) {
  if (from == null || from.isEmpty || from.length > 200) {
    return null;
  }
  if (!from.startsWith('/') || from.startsWith('//') || from.contains('\\')) {
    return null;
  }
  if (from.contains('://') || from.contains('\n') || from.contains('\r')) {
    return null;
  }
  if (from == AppRoutes.signIn ||
      from.startsWith('${AppRoutes.signIn}/') ||
      from.startsWith('${AppRoutes.signIn}?')) {
    return null;
  }
  return from;
}
