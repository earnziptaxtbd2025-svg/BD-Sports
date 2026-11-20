import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/backend_provider.dart';
import '../security/input_validators.dart';
import '../security/rate_limiter.dart';
import '../sync/outbox.dart';
import 'auth_repository.dart';
import 'current_user_provider.dart';
import 'division.dart';
import 'preview_auth_repository.dart';
import 'profile_sync_handler.dart';
import 'sports_role.dart';
import 'supabase_auth_repository.dart';
import 'user_store.dart';

/// Real server sign-in when Supabase keys exist, preview sign-in otherwise.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(userStoreProvider);
  if (ref.watch(backendConfiguredProvider)) {
    return SupabaseAuthRepository(Supabase.instance.client, store);
  }
  return PreviewAuthRepository(store);
});

/// The steps of signing in. Holds the limits that stop repeated tries: at most 3
/// codes and 5 code checks in 10 minutes. The server enforces its own limits too,
/// because a changed app can skip these.
class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  final RateLimiter _sendLimiter = RateLimiter(
    maxActions: 3,
    window: const Duration(minutes: 10),
  );
  final RateLimiter _checkLimiter = RateLimiter(
    maxActions: 5,
    window: const Duration(minutes: 10),
  );

  /// Sends a code. [phoneInput] is what the person typed.
  Future<void> sendCode(String phoneInput) async {
    final phone = InputValidators.normalizeBdPhone(phoneInput);
    if (phone == null) {
      throw const AppAuthException(AuthFailure.invalidPhone);
    }
    if (!_sendLimiter.tryAcquire()) {
      throw const AppAuthException(AuthFailure.tooManyRequests);
    }
    await _ref.read(authRepositoryProvider).requestCode(phone);
  }

  /// Checks the code and, if it is right, signs the person in.
  Future<AuthOutcome> verify(String phoneInput, String code) async {
    final phone = InputValidators.normalizeBdPhone(phoneInput);
    if (phone == null) {
      throw const AppAuthException(AuthFailure.invalidPhone);
    }
    if (!_checkLimiter.tryAcquire()) {
      throw const AppAuthException(AuthFailure.tooManyRequests);
    }

    final outcome = await _ref
        .read(authRepositoryProvider)
        .verifyCode(phone, InputValidators.toAsciiDigits(code).trim());
    _ref.read(currentUserProvider.notifier).setUser(outcome.user);
    return outcome;
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    _ref.read(currentUserProvider.notifier).signOut();
  }
}

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

/// The profile photo of the signed-in person, kept on the phone.
final profilePhotoProvider = Provider<Uint8List?>((ref) {
  final id = ref.watch(currentUserProvider.select((user) => user?.id));
  if (id == null) {
    return null;
  }
  return ref.watch(userStoreProvider).loadPhoto(id);
});

/// Saves the profile. It is written on the phone first, so it works without internet.
/// When the server is connected, the change is queued and sent when online.
class ProfileController {
  ProfileController(this._ref);

  final Ref _ref;

  /// Saves name, division, role and (when [photoChanged]) the photo. A null [photo]
  /// with [photoChanged] true removes the photo.
  Future<void> save({
    required String name,
    required Division? division,
    required SportsRole role,
    Uint8List? photo,
    bool photoChanged = false,
  }) async {
    final current = _ref.read(currentUserProvider);
    if (current == null) {
      return;
    }

    final updated = current.copyWith(
      displayName: InputValidators.sanitizeText(name, maxLength: 60),
      division: division,
      clearDivision: division == null,
      sportsRole: role,
    );

    final store = _ref.read(userStoreProvider);
    await store.saveProfile(updated);
    if (photoChanged) {
      if (photo == null) {
        await store.removePhoto(updated.id);
      } else {
        await store.savePhoto(updated.id, photo);
      }
    }

    _ref.read(currentUserProvider.notifier).setUser(updated);
    if (photoChanged) {
      _ref.invalidate(profilePhotoProvider);
    }

    if (!_ref.read(backendConfiguredProvider)) {
      return;
    }

    final outbox = _ref.read(outboxProvider.notifier);
    await outbox.enqueue(ProfileSyncHandler.type, <String, dynamic>{
      'phone': updated.phone,
      'display_name': updated.displayName,
      'division': updated.division?.name,
      'sports_role': updated.sportsRole.name,
    });
    if (photoChanged) {
      await outbox.enqueue(ProfilePhotoSyncHandler.type, <String, dynamic>{
        if (photo == null) 'remove': true else 'base64': _encode(photo),
      });
    }
  }

  static String _encode(Uint8List bytes) => base64Encode(bytes);
}

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(ref),
);
