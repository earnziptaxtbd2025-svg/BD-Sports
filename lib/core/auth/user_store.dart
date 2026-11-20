import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/shared_preferences_provider.dart';
import 'app_user.dart';

/// Saves the signed-in person and their profile on the phone, so the app opens
/// signed in and the profile can be edited without internet.
class UserStore {
  UserStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _sessionKey = 'session_user_v1';

  static String _profileKey(String id) => 'profile_v1_$id';
  static String _photoKey(String id) => 'photo_v1_$id';

  /// Largest profile photo kept on the phone (the picker already shrinks photos).
  static const int maxPhotoBytes = 600 * 1024;

  String? get sessionUserId => _prefs.getString(_sessionKey);

  Future<void> setSession(String id) => _prefs.setString(_sessionKey, id);

  Future<void> clearSession() => _prefs.remove(_sessionKey);

  /// The saved profile of [id], or null if none or damaged.
  AppUser? loadProfile(String id) {
    final raw = _prefs.getString(_profileKey(id));
    if (raw == null) {
      return null;
    }
    try {
      return AppUser.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(AppUser user) {
    return _prefs.setString(_profileKey(user.id), jsonEncode(user.toJson()));
  }

  Uint8List? loadPhoto(String id) {
    final raw = _prefs.getString(_photoKey(id));
    if (raw == null) {
      return null;
    }
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePhoto(String id, Uint8List bytes) {
    return _prefs.setString(_photoKey(id), base64Encode(bytes));
  }

  Future<void> removePhoto(String id) => _prefs.remove(_photoKey(id));
}

final userStoreProvider = Provider<UserStore>(
  (ref) => UserStore(ref.watch(sharedPreferencesProvider)),
);
