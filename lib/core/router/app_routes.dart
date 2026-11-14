/// Central place for route paths.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String explore = '/explore';
  static const String create = '/create';
  static const String mySports = '/my-sports';
  static const String profile = '/profile';

  /// Developer tools (only registered when DEV_TOOLS is on).
  static const String devRoles = '/dev/roles';
  static const String devSync = '/dev/sync';
}
