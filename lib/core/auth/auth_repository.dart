import 'app_user.dart';

/// Why signing in did not work. Each one is shown to the person as a message in the
/// current language.
enum AuthFailure {
  invalidPhone,
  tooManyRequests,
  wrongCode,
  expiredCode,
  offline,
  unknown,
}

/// Thrown by the sign-in steps. (Named differently from Supabase's own
/// `AuthException` so the two are never mixed up.)
class AppAuthException implements Exception {
  const AppAuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AppAuthException(${failure.name})';
}

/// A correct code was entered.
class AuthOutcome {
  const AuthOutcome({required this.user, required this.isNewUser});

  /// The person. [AppUser.displayName] is empty for a new person.
  final AppUser user;

  /// true when the person must still set up a profile.
  final bool isNewUser;
}

/// Signs people in with a mobile number and a code sent by SMS.
///
/// Two versions exist: one for the real server (Supabase) and one for preview mode,
/// used while no Supabase keys are set. See `auth_providers.dart`.
abstract interface class AuthRepository {
  /// The person signed in from an earlier visit, or null.
  AppUser? restoreUser();

  /// Sends a code. [phone] is already in the form +8801XXXXXXXXX.
  Future<void> requestCode(String phone);

  /// Checks the code. Throws [AppAuthException] when it is wrong or expired.
  Future<AuthOutcome> verifyCode(String phone, String code);

  Future<void> signOut();
}
