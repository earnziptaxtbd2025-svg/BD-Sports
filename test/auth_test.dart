import 'dart:typed_data';

import 'package:bd_sports/core/auth/app_user.dart';
import 'package:bd_sports/core/auth/auth_providers.dart';
import 'package:bd_sports/core/auth/auth_repository.dart';
import 'package:bd_sports/core/auth/current_user_provider.dart';
import 'package:bd_sports/core/auth/division.dart';
import 'package:bd_sports/core/auth/preview_auth_repository.dart';
import 'package:bd_sports/core/auth/sports_role.dart';
import 'package:bd_sports/core/auth/supabase_auth_repository.dart';
import 'package:bd_sports/core/auth/user_store.dart';
import 'package:bd_sports/core/l10n/app_language.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const phone = '01712345678';
  const phoneNormalized = '+8801712345678';

  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
  });

  Matcher failsWith(AuthFailure failure) => throwsA(
        isA<AppAuthException>().having((e) => e.failure, 'failure', failure),
      );

  group('saved profile data', () {
    test('a profile survives being saved and read back', () {
      const user = AppUser(
        id: 'u1',
        displayName: 'Rakib Islam',
        phone: phoneNormalized,
        division: Division.rangpur,
        sportsRole: SportsRole.organizer,
      );
      final back = AppUser.fromJson(user.toJson());
      expect(back, isNotNull);
      expect(back!.id, 'u1');
      expect(back.displayName, 'Rakib Islam');
      expect(back.phone, phoneNormalized);
      expect(back.division, Division.rangpur);
      expect(back.sportsRole, SportsRole.organizer);
    });

    test('damaged data gives null, not an error', () {
      expect(AppUser.fromJson('text'), isNull);
      expect(AppUser.fromJson(<String, Object?>{'id': '', 'name': 'x'}), isNull);
      expect(AppUser.fromJson(<String, Object?>{'id': 'a'}), isNull);
    });

    test('hasProfile needs a name', () {
      expect(const AppUser(id: 'a', displayName: '').hasProfile, isFalse);
      expect(const AppUser(id: 'a', displayName: '  ').hasProfile, isFalse);
      expect(const AppUser(id: 'a', displayName: 'Ali').hasProfile, isTrue);
    });

    test('unknown saved values fall back safely', () {
      expect(SportsRole.fromCode('nonsense'), SportsRole.fan);
      expect(SportsRole.fromCode(null), SportsRole.fan);
      expect(Division.fromCode('nowhere'), isNull);
      expect(Division.fromCode('sylhet'), Division.sylhet);
    });

    test('every division has an English and a Bangla name', () {
      for (final division in Division.values) {
        expect(division.labelFor(AppLanguage.english), isNotEmpty);
        expect(division.labelFor(AppLanguage.bangla), isNotEmpty);
        expect(
          division.labelFor(AppLanguage.bangla),
          isNot(division.labelFor(AppLanguage.english)),
        );
      }
    });

    test('copyWith can clear the division', () {
      const user = AppUser(id: 'a', displayName: 'A', division: Division.dhaka);
      expect(user.copyWith(clearDivision: true).division, isNull);
      expect(user.copyWith(displayName: 'B').division, Division.dhaka);
    });
  });

  group('preview sign-in', () {
    late UserStore store;
    late PreviewAuthRepository repository;

    setUp(() {
      store = UserStore(prefs);
      repository = PreviewAuthRepository(store);
    });

    test('nobody is signed in at first', () {
      expect(repository.restoreUser(), isNull);
    });

    test('a wrong code is refused', () async {
      await expectLater(
        repository.verifyCode(phoneNormalized, '000000'),
        failsWith(AuthFailure.wrongCode),
      );
      expect(store.sessionUserId, isNull);
    });

    test('the preview code signs in a new person who needs a profile', () async {
      final outcome = await repository.verifyCode(
        phoneNormalized,
        PreviewAuthRepository.previewCode,
      );
      expect(outcome.isNewUser, isTrue);
      expect(outcome.user.phone, phoneNormalized);
      expect(repository.restoreUser()?.id, outcome.user.id);
    });

    test('a person with a saved profile is not new', () async {
      final first = await repository.verifyCode(phoneNormalized, '123456');
      await store.saveProfile(first.user.copyWith(displayName: 'Rakib'));
      await repository.signOut();
      expect(repository.restoreUser(), isNull);

      final again = await repository.verifyCode(phoneNormalized, '123456');
      expect(again.isNewUser, isFalse);
      expect(again.user.displayName, 'Rakib');
    });

    test('two phone numbers are two different people', () async {
      final a = await repository.verifyCode('+8801712345678', '123456');
      final b = await repository.verifyCode('+8801812345678', '123456');
      expect(a.user.id, isNot(b.user.id));
    });
  });

  group('AuthController', () {
    test('a bad phone number is refused before anything is sent', () async {
      final controller = container.read(authControllerProvider);
      await expectLater(controller.sendCode('12345'), failsWith(AuthFailure.invalidPhone));
      await expectLater(
        controller.verify('12345', '123456'),
        failsWith(AuthFailure.invalidPhone),
      );
    });

    test('Bangla digits in the phone number work', () async {
      final controller = container.read(authControllerProvider);
      await controller.sendCode('০১৭১২৩৪৫৬৭৮');
    });

    test('only 3 codes can be asked for in 10 minutes', () async {
      final controller = container.read(authControllerProvider);
      await controller.sendCode(phone);
      await controller.sendCode(phone);
      await controller.sendCode(phone);
      await expectLater(controller.sendCode(phone), failsWith(AuthFailure.tooManyRequests));
    });

    test('only 5 code checks are allowed in 10 minutes', () async {
      final controller = container.read(authControllerProvider);
      for (var i = 0; i < 5; i++) {
        await expectLater(
          controller.verify(phone, '000000'),
          failsWith(AuthFailure.wrongCode),
        );
      }
      await expectLater(
        controller.verify(phone, '123456'),
        failsWith(AuthFailure.tooManyRequests),
      );
      expect(container.read(currentUserProvider), isNull);
    });

    test('a right code signs the person in, and sign out clears it', () async {
      final controller = container.read(authControllerProvider);
      final outcome = await controller.verify(phone, '১২৩৪৫৬');
      expect(outcome.isNewUser, isTrue);
      expect(container.read(currentUserProvider)?.phone, phoneNormalized);

      await controller.signOut();
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(authRepositoryProvider).restoreUser(), isNull);
    });
  });

  group('ProfileController', () {
    Future<void> signIn() async {
      await container.read(authControllerProvider).verify(phone, '123456');
    }

    test('saving does nothing when nobody is signed in', () async {
      await container.read(profileControllerProvider).save(
            name: 'Ali',
            division: null,
            role: SportsRole.fan,
          );
      expect(container.read(currentUserProvider), isNull);
    });

    test('the profile is saved on the phone and in the signed-in user', () async {
      await signIn();
      await container.read(profileControllerProvider).save(
            name: '  Rakib   Islam ',
            division: Division.rangpur,
            role: SportsRole.player,
          );

      final user = container.read(currentUserProvider)!;
      expect(user.displayName, 'Rakib Islam');
      expect(user.division, Division.rangpur);
      expect(user.sportsRole, SportsRole.player);
      expect(user.hasProfile, isTrue);

      final saved = container.read(userStoreProvider).loadProfile(user.id)!;
      expect(saved.displayName, 'Rakib Islam');
      expect(saved.sportsRole, SportsRole.player);
    });

    test('the profile choice never changes the account role', () async {
      await signIn();
      await container.read(profileControllerProvider).save(
            name: 'Ali',
            division: null,
            role: SportsRole.organizer,
          );
      final user = container.read(currentUserProvider)!;
      expect(user.accountRole.name, 'member');
      expect(user.tournamentRoles, isEmpty);
    });

    test('the division can be cleared', () async {
      await signIn();
      final controller = container.read(profileControllerProvider);
      await controller.save(name: 'Ali', division: Division.dhaka, role: SportsRole.fan);
      await controller.save(name: 'Ali', division: null, role: SportsRole.fan);
      expect(container.read(currentUserProvider)!.division, isNull);
    });

    test('a photo is kept on the phone and can be removed', () async {
      await signIn();
      final controller = container.read(profileControllerProvider);
      final bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

      await controller.save(
        name: 'Ali',
        division: null,
        role: SportsRole.fan,
        photo: bytes,
        photoChanged: true,
      );
      expect(container.read(profilePhotoProvider), bytes);

      await controller.save(
        name: 'Ali',
        division: null,
        role: SportsRole.fan,
        photo: null,
        photoChanged: true,
      );
      expect(container.read(profilePhotoProvider), isNull);
    });

    test('a photo is left alone when it was not changed', () async {
      await signIn();
      final controller = container.read(profileControllerProvider);
      final bytes = Uint8List.fromList(<int>[9, 9]);
      await controller.save(
        name: 'Ali',
        division: null,
        role: SportsRole.fan,
        photo: bytes,
        photoChanged: true,
      );
      await controller.save(name: 'Ali B', division: null, role: SportsRole.fan);
      expect(container.read(profilePhotoProvider), bytes);
    });
  });

  group('server error kinds', () {
    AuthFailure kind(String message, {required bool verifying}) =>
        SupabaseAuthRepository.failureFrom(Exception(message), verifying: verifying)
            .failure;

    test('too many requests', () {
      expect(kind('429 rate limit reached', verifying: false), AuthFailure.tooManyRequests);
      expect(kind('Too many requests', verifying: true), AuthFailure.tooManyRequests);
    });

    test('no internet', () {
      expect(kind('SocketException: Failed host lookup', verifying: true), AuthFailure.offline);
      expect(kind('Network is unreachable', verifying: false), AuthFailure.offline);
    });

    test('wrong or expired code', () {
      expect(kind('Token has expired or is invalid', verifying: true), AuthFailure.wrongCode);
      expect(kind('OTP has expired', verifying: true), AuthFailure.expiredCode);
    });

    test('anything else is unknown', () {
      expect(kind('something strange', verifying: true), AuthFailure.unknown);
      expect(kind('something strange', verifying: false), AuthFailure.unknown);
    });
  });
}
