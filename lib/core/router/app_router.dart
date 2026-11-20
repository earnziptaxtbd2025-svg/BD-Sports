import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/verify_code_page.dart';
import '../../features/auth/presentation/welcome_page.dart';
import '../../features/create/presentation/create_page.dart';
import '../../features/dev_tools/presentation/design_gallery_page.dart';
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
import '../../features/profile/presentation/appearance_settings_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
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
  AppRoutes.appearance,
  AppRoutes.signIn,
  AppRoutes.verify,
  AppRoutes.welcome,
  AppRoutes.editProfile,
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

  // Access rules of the screens that have their own route below.
  final welcomeSpec = allScreens.firstWhere((spec) => spec.id == 'auth.welcome');
  final editProfileSpec = allScreens.firstWhere((spec) => spec.id == 'settings.edit');

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    // A person who signed in but has not given a name yet is sent to finish the
    // profile first. Sign-in screens and developer tools stay open.
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      if (user == null || user.hasProfile || user.isSuspended) {
        return null;
      }
      final path = state.uri.path;
      final open = path == AppRoutes.welcome ||
          path == AppRoutes.noAccess ||
          path.startsWith(AppRoutes.signIn) ||
          path.startsWith('/dev');
      if (open) {
        return null;
      }
      return '${AppRoutes.welcome}?from=${Uri.encodeComponent(state.uri.toString())}';
    },
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
        path: AppRoutes.verify,
        builder: (context, state) => VerifyCodePage(
          phone: state.uri.queryParameters['phone'],
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        redirect: (context, state) => screenGuard(
          spec: welcomeSpec,
          user: ref.read(currentUserProvider),
          params: state.pathParameters,
          location: state.uri.toString(),
        ),
        builder: (context, state) =>
            WelcomePage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        redirect: (context, state) => screenGuard(
          spec: editProfileSpec,
          user: ref.read(currentUserProvider),
          params: state.pathParameters,
          location: state.uri.toString(),
        ),
        builder: (context, state) => const EditProfilePage(),
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
      GoRoute(
        path: AppRoutes.appearance,
        builder: (context, state) => const AppearanceSettingsPage(),
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
        GoRoute(
          path: AppRoutes.devDesign,
          builder: (context, state) => const DesignGalleryPage(),
        ),
      ],
    ],
  );
});
