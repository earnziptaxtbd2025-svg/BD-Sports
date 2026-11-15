import '../public_links/short_id.dart';
import 'screen_registry.dart';
import 'screen_spec.dart';

/// Lookups over the screen list.
class Screens {
  const Screens._();

  static ScreenSpec? byId(String id) {
    for (final spec in allScreens) {
      if (spec.id == id) {
        return spec;
      }
    }
    return null;
  }

  static List<ScreenSpec> forHub(HubTab hub) =>
      allScreens.where((spec) => spec.hub == hub).toList();

  static List<ScreenSpec> forArea(ScreenArea area) =>
      allScreens.where((spec) => spec.area == area).toList();

  /// A real-looking path for a screen, used by the developer screen map and tests.
  static String samplePath(ScreenSpec spec, {String id = 'abcd2345'}) {
    return spec.path.replaceAllMapped(RegExp(r':(\w+)'), (match) {
      switch (match.group(1)) {
        case 'type':
          return 'tournament';
        default:
          return id;
      }
    });
  }

  /// Types a report can be about.
  static const Set<String> reportTypes = <String>{
    'tournament',
    'user',
    'post',
    'match',
  };

  /// Checks every `:parameter` of a screen. Ids must be well-formed short ids, so
  /// text from an address is never shown or used unless it is safe.
  static bool paramsAreValid(ScreenSpec spec, Map<String, String> params) {
    for (final name in spec.paramNames) {
      final value = params[name];
      if (value == null) {
        return false;
      }
      if (name == 'type') {
        if (!reportTypes.contains(value)) {
          return false;
        }
      } else if (!ShortId.isValid(value)) {
        return false;
      }
    }
    return true;
  }
}
