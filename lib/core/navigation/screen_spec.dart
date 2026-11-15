import 'package:flutter/material.dart';

import '../auth/permission.dart';

/// Who may open a screen.
enum ScreenAccess {
  /// Anyone, even without signing in.
  public,

  /// Any signed-in person.
  signedIn,

  /// Signed in and holding a specific [Permission].
  permission,
}

enum ScreenStatus {
  /// A real screen exists.
  built,

  /// Opens a placeholder that says which step builds it.
  planned,
}

/// Tabs that show a list of screens (a "hub").
enum HubTab { explore, create, mySports }

/// Groups screens in the docs and in the developer screen map.
enum ScreenArea {
  tabs('Main tabs'),
  auth('Sign in'),
  discover('Discover'),
  create('Create'),
  mySports('My Sports'),
  tournament('Tournament'),
  manage('Organizer tools'),
  match('Match'),
  team('Team'),
  player('Player'),
  club('Club'),
  coach('Coach'),
  referee('Referee'),
  ground('Ground'),
  organizer('Organizer'),
  community('Community'),
  settings('Settings and help'),
  system('System'),
  admin('Admin');

  const ScreenArea(this.label);

  final String label;
}

/// One screen of the app. The full list lives in `screen_registry.dart`
/// (generated from `tool/screens_data.py`).
class ScreenSpec {
  const ScreenSpec({
    required this.id,
    required this.title,
    required this.path,
    required this.area,
    required this.icon,
    required this.step,
    required this.description,
    this.access = ScreenAccess.public,
    this.permission,
    this.hub,
    this.status = ScreenStatus.planned,
  }) : assert(
          access != ScreenAccess.permission || permission != null,
          'A permission screen needs a permission',
        );

  final String id;
  final String title;

  /// go_router path, for example `/t/:id/manage`.
  final String path;
  final ScreenArea area;
  final IconData icon;

  /// Roadmap step that builds the real screen, for example `1.3` or `1B.1`.
  final String step;
  final String description;
  final ScreenAccess access;
  final Permission? permission;
  final HubTab? hub;
  final ScreenStatus status;

  /// Names of the `:parameters` in [path].
  List<String> get paramNames =>
      RegExp(r':(\w+)').allMatches(path).map((m) => m.group(1)!).toList();

  bool get isBuilt => status == ScreenStatus.built;

  /// Tournament permissions are checked against the `:id` in the path.
  bool get isTournamentScoped =>
      permission != null && permission!.scope == PermissionScope.tournament;

  String get accessLabel {
    switch (access) {
      case ScreenAccess.public:
        return 'Anyone';
      case ScreenAccess.signedIn:
        return 'Signed in';
      case ScreenAccess.permission:
        return permission!.label;
    }
  }
}
