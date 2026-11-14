import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/shared_preferences_provider.dart';

class CachedValue {
  const CachedValue({required this.json, required this.savedAt});

  final Object? json;
  final DateTime savedAt;

  bool isOlderThan(Duration maxAge) =>
      DateTime.now().toUtc().difference(savedAt) > maxAge;
}

/// Saves the last data fetched from the server so screens can show it offline.
///
/// Pattern for every list or detail screen: show the cached copy immediately, then
/// refresh from the server when online and write the new copy back.
class JsonCache {
  JsonCache(this._prefs);

  static const String _prefix = 'cache:';

  final SharedPreferences _prefs;

  CachedValue? read(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(decoded['savedAt'] as String? ?? '');
      if (savedAt == null) {
        return null;
      }
      return CachedValue(json: decoded['data'], savedAt: savedAt.toUtc());
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, Object? json) {
    final encoded = jsonEncode(<String, dynamic>{
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'data': json,
    });
    return _prefs.setString('$_prefix$key', encoded);
  }

  Future<void> remove(String key) => _prefs.remove('$_prefix$key');

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

final jsonCacheProvider = Provider<JsonCache>(
  (ref) => JsonCache(ref.watch(sharedPreferencesProvider)),
);
