import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_role.dart';
import 'app_user.dart';
import 'auth_repository.dart';
import 'division.dart';
import 'sports_role.dart';
import 'user_store.dart';

/// Real sign-in with the Supabase server: a code is sent by SMS and checked by the
/// server. The SMS provider is set up in the Supabase dashboard (see docs/AUTH.md).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, this._store);

  final SupabaseClient _client;
  final UserStore _store;

  @override
  AppUser? restoreUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return _store.loadProfile(user.id) ??
        AppUser(id: user.id, displayName: '', phone: _phoneOf(user));
  }

  @override
  Future<void> requestCode(String phone) async {
    await _guard(
      () => _client.auth.signInWithOtp(phone: phone),
      verifying: false,
    );
  }

  @override
  Future<AuthOutcome> verifyCode(String phone, String code) async {
    final response = await _guard(
      () => _client.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      ),
      verifying: true,
    );

    final authUser = response.user ?? _client.auth.currentUser;
    if (authUser == null) {
      throw const AppAuthException(AuthFailure.unknown);
    }

    final local = _store.loadProfile(authUser.id);
    final row = await _fetchProfileRow(authUser.id);
    final user = _merge(authUser.id, phone, row, local);

    return AuthOutcome(user: user, isNewUser: !user.hasProfile);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  /// The profile row on the server, or null if there is none yet (or the table is
  /// not created yet).
  Future<Map<String, dynamic>?> _fetchProfileRow(String id) async {
    try {
      return await _client
          .from('profiles')
          .select('display_name, division, sports_role, account_role, is_suspended')
          .eq('id', id)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// The server profile wins. If the server has no name yet, a profile saved on this
  /// phone (for example while offline) is used.
  static AppUser _merge(
    String id,
    String phone,
    Map<String, dynamic>? row,
    AppUser? local,
  ) {
    final base = (local ?? AppUser(id: id, displayName: '')).copyWith(phone: phone);
    if (row == null) {
      return base;
    }

    final name = row['display_name'];
    if (name is! String || name.trim().isEmpty) {
      return base;
    }

    return AppUser(
      id: id,
      displayName: name,
      phone: phone,
      division: Division.fromCode(row['division'] as String?),
      sportsRole: SportsRole.fromCode(row['sports_role'] as String?),
      accountRole: _accountRoleFromDb(row['account_role'] as String?),
      isSuspended: row['is_suspended'] == true,
    );
  }

  static AccountRole _accountRoleFromDb(String? value) {
    switch (value) {
      case 'moderator':
        return AccountRole.moderator;
      case 'super_admin':
        return AccountRole.superAdmin;
      default:
        return AccountRole.member;
    }
  }

  static String? _phoneOf(User user) {
    final phone = user.phone;
    if (phone == null || phone.isEmpty) {
      return null;
    }
    return phone.startsWith('+') ? phone : '+$phone';
  }

  Future<T> _guard<T>(Future<T> Function() action, {required bool verifying}) async {
    try {
      return await action();
    } catch (error) {
      throw failureFrom(error, verifying: verifying);
    }
  }

  /// Turns any error into the matching [AppAuthException]. Public for tests.
  static AppAuthException failureFrom(Object error, {required bool verifying}) {
    if (error is AppAuthException) {
      return error;
    }

    final text = error.toString().toLowerCase();
    final status = error is AuthException ? error.statusCode : null;

    if (status == '429' || text.contains('rate limit') || text.contains('too many')) {
      return const AppAuthException(AuthFailure.tooManyRequests);
    }
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network') ||
        text.contains('connection') ||
        text.contains('timeout')) {
      return const AppAuthException(AuthFailure.offline);
    }
    if (verifying) {
      if (text.contains('expired') && !text.contains('invalid')) {
        return const AppAuthException(AuthFailure.expiredCode);
      }
      if (text.contains('invalid') || text.contains('token') || status == '403') {
        return const AppAuthException(AuthFailure.wrongCode);
      }
    } else if (text.contains('phone') && text.contains('invalid')) {
      return const AppAuthException(AuthFailure.invalidPhone);
    }
    return const AppAuthException(AuthFailure.unknown);
  }
}
