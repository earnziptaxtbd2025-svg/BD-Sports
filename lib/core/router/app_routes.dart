/// Paths of screens that are written by hand. Every other screen path comes from
/// `lib/core/navigation/screen_registry.dart`.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String explore = '/explore';
  static const String create = '/create';
  static const String mySports = '/my-sports';
  static const String profile = '/profile';
  static const String privacy = '/privacy';
  static const String signIn = '/sign-in';
  static const String noAccess = '/no-access';

  /// Developer tools (only registered when DEV_TOOLS is on).
  static const String devRoles = '/dev/roles';
  static const String devSync = '/dev/sync';
  static const String devLinks = '/dev/links';
  static const String devScreens = '/dev/screens';
}
