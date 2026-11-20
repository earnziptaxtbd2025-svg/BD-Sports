import 'app_user.dart';
import 'auth_repository.dart';
import 'user_store.dart';

/// Sign-in used while no Supabase keys are set (preview mode). No SMS is sent: the
/// code is always [previewCode]. Everything is kept on the phone only.
///
/// This lets the whole sign-in and profile flow be tried before the server exists.
/// It is never used when Supabase keys are present.
class PreviewAuthRepository implements AuthRepository {
  PreviewAuthRepository(this._store);

  /// The code that works in preview mode.
  static const String previewCode = '123456';

  final UserStore _store;

  @override
  AppUser? restoreUser() {
    final id = _store.sessionUserId;
    if (id == null) {
      return null;
    }
    return _store.loadProfile(id) ?? AppUser(id: id, displayName: '');
  }

  @override
  Future<void> requestCode(String phone) async {}

  @override
  Future<AuthOutcome> verifyCode(String phone, String code) async {
    if (code != previewCode) {
      throw const AppAuthException(AuthFailure.wrongCode);
    }

    final id = 'preview-${phone.replaceAll(RegExp(r'\D'), '')}';
    final saved = _store.loadProfile(id);
    final user = (saved ?? AppUser(id: id, displayName: '')).copyWith(phone: phone);

    await _store.setSession(id);
    return AuthOutcome(user: user, isNewUser: !user.hasProfile);
  }

  @override
  Future<void> signOut() => _store.clearSession();
}
