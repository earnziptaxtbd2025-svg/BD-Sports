import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/create/presentation/create_page.dart';
import '../../features/dev_tools/presentation/public_link_tester_page.dart';
import '../../features/dev_tools/presentation/role_tester_page.dart';
import '../../features/dev_tools/presentation/screen_map_page.dart';
import '../../features/dev_tools/presentation/sync_tester_page.dart';
import '../../features/explore/presentation/explore_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/my_sports/presentation/my_sports_page.dart';
import '../../features/navigation/presentation/no_access_page.dart';
import '../../features/navigation/presentation/not_found_page.dart';
import '../../features/navigation/presentation/planned_screen_page.dart';
import '../../features/profile/presentation/language_settings_page.dart';
import '../../features/profile/presentation/privacy_settings_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../auth/app_user.dart';
import '../auth/current_user_provider.dart';
import '../config/env.dart';
import '../navigation/route_guard.dart';
import '../navigation/screen_registry.dart';
import 'app_routes.dart';

/// Tells the router to check access again when the signed-in person changes, so a
/// screen closes when someone signs out or loses a role.
class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Screens that have their own hand-written route. Every other screen in
/// `allScreens` gets a route (with its access check) generated below.
const Set<String> _handWrittenPaths = <String>{
  AppRoutes.home,
  AppRoutes.explore,
  AppRoutes.create,
  AppRoutes.mySports,
  AppRoutes.profile,
  AppRoutes.privacy,
  AppRoutes.language,
  AppRoutes.signIn,
  AppRoutes.noAccess,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen<AppUser?>(currentUserProvider, (previous, next) => refresh.refresh());
  ref.onDispose(refresh.dispose);

  final generatedRoutes = <RouteBase>[
    for (final spec in allScreens)
      if (!_handWrittenPaths.contains(spec.path))
        GoRoute(
          path: spec.path,
          redirect: (context, state) => screenGuard(
            spec: spec,
            user: ref.read(currentUserProvider),
            params: state.pathParameters,
            location: state.uri.toString(),
          ),
          builder: (context, state) =>
              PlannedScreenPage(spec: spec, params: state.pathParameters),
        ),
  ];

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.create,
                builder: (context, state) => const CreatePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mySports,
                builder: (context, state) => const MySportsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) =>
            SignInPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.noAccess,
        builder: (context, state) => const NoAccessPage(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacySettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageSettingsPage(),
      ),
      ...generatedRoutes,
      if (Env.devToolsEnabled) ...[
        GoRoute(
          path: AppRoutes.devRoles,
          builder: (context, state) => const RoleTesterPage(),
        ),
        GoRoute(
          path: AppRoutes.devSync,
          builder: (context, state) => const SyncTesterPage(),
        ),
        GoRoute(
          path: AppRoutes.devLinks,
          builder: (context, state) => const PublicLinkTesterPage(),
        ),
        GoRoute(
          path: AppRoutes.devScreens,
          builder: (context, state) => const ScreenMapPage(),
        ),
      ],
    ],
  );
});
