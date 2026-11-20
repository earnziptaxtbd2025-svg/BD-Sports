import 'dart:typed_data';

import 'package:bd_sports/app.dart';
import 'package:bd_sports/core/auth/app_user.dart';
import 'package:bd_sports/core/auth/current_user_provider.dart';
import 'package:bd_sports/core/auth/division.dart';
import 'package:bd_sports/core/auth/initial_user_provider.dart';
import 'package:bd_sports/core/auth/photo_picker.dart';
import 'package:bd_sports/core/auth/sports_role.dart';
import 'package:bd_sports/core/auth/user_store.dart';
import 'package:bd_sports/core/network/connectivity_providers.dart';
import 'package:bd_sports/core/router/app_router.dart';
import 'package:bd_sports/core/storage/shared_preferences_provider.dart';
import 'package:bd_sports/core/widgets/neon_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A photo picker that returns a prepared answer, so no phone gallery is needed.
class _FakePicker implements PhotoPicker {
  _FakePicker(this.result);

  final Uint8List? result;

  @override
  Future<Uint8List?> pickFromGallery() async => result;
}

/// The whole sign-in and profile flow, in the app, with the preview server.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{'language_v1': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> start(
    WidgetTester tester, {
    AppUser? signedIn,
    PhotoPicker? picker,
  }) async {
    // A tall screen, so the whole form is built without scrolling.
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        internetReachableProvider.overrideWith((ref) => Stream<bool>.value(true)),
        initialUserProvider.overrideWithValue(signedIn),
        if (picker != null) photoPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const BdSportsApp()),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> goTo(WidgetTester tester, ProviderContainer c, String path) async {
    c.read(appRouterProvider).go(path);
    await tester.pumpAndSettle();
  }

  Future<void> sendCodeFor(WidgetTester tester, String phone) async {
    await tester.enterText(find.byType(TextFormField), phone);
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('signing in', () {
    testWidgets('a protected screen sends a visitor to sign in', (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/create/tournament');
      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
    });

    testWidgets('an empty or short phone number shows a message', (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/sign-in');

      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Enter a mobile number.'), findsOneWidget);

      await sendCodeFor(tester, '12345');
      expect(find.text('Enter a mobile number.'), findsNothing);
      expect(
        find.text('Enter a valid Bangladesh mobile number, like 01712345678.'),
        findsOneWidget,
      );
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('a new person signs in, sets up a profile and lands on the screen they wanted',
        (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/create/tournament');

      await sendCodeFor(tester, '01712345678');
      expect(find.text('We sent a 6-digit code to +8801712345678.'), findsOneWidget);
      expect(find.textContaining('123456'), findsOneWidget); // preview hint

      await typeCode(tester, '123456');
      expect(find.text('Tell us about you'), findsWidgets);
      expect(c.read(currentUserProvider)?.hasProfile, isFalse);

      await tester.enterText(find.byType(TextFormField), 'Rakib Islam');
      await tapText(tester, 'Organizer');
      await tapText(tester, 'Continue');

      final user = c.read(currentUserProvider)!;
      expect(user.displayName, 'Rakib Islam');
      expect(user.sportsRole, SportsRole.organizer);
      expect(find.text('Create a tournament'), findsWidgets);
    });

    testWidgets('a wrong code shows a message and the person can try again',
        (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/sign-in');
      await sendCodeFor(tester, '01712345678');

      await typeCode(tester, '111111');
      expect(
        find.text('The code is not correct or has expired. Check it or ask for a new code.'),
        findsOneWidget,
      );
      expect(c.read(currentUserProvider), isNull);

      await typeCode(tester, '123456');
      expect(find.text('Tell us about you'), findsWidgets);
    });

    testWidgets('a returning person goes straight to Home', (tester) async {
      // The profile was saved on this phone in an earlier visit.
      await UserStore(prefs).saveProfile(
        const AppUser(
          id: 'preview-8801712345678',
          displayName: 'Old Name',
          phone: '+8801712345678',
        ),
      );

      final c = await start(tester);
      await goTo(tester, c, '/sign-in');
      await sendCodeFor(tester, '01712345678');
      await typeCode(tester, '123456');

      expect(c.read(currentUserProvider)?.displayName, 'Old Name');
      expect(find.text('Create Your Own Tournament!'), findsOneWidget);
    });

    testWidgets('a code that is too short does not sign in', (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/sign-in');
      await sendCodeFor(tester, '01712345678');

      await typeCode(tester, '1234');
      expect(c.read(currentUserProvider), isNull);
      expect(find.text('Tell us about you'), findsNothing);

      // Remove the screen so its countdown timer is stopped before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the verify screen without a number goes back to sign in',
        (tester) async {
      final c = await start(tester);
      await goTo(tester, c, '/sign-in/verify');
      expect(find.text('Welcome back!'), findsOneWidget);
    });
  });

  group('profile', () {
    const person = AppUser(
      id: 'u1',
      displayName: 'Rakib Islam',
      phone: '+8801712345678',
      division: Division.rangpur,
      sportsRole: SportsRole.player,
    );

    testWidgets('someone without a name is sent to finish the profile',
        (tester) async {
      await start(tester, signedIn: const AppUser(id: 'u2', displayName: ''));
      expect(find.text('Tell us about you'), findsWidgets);
    });

    testWidgets('the name is required', (tester) async {
      await start(tester, signedIn: const AppUser(id: 'u2', displayName: ''));
      await tapText(tester, 'Continue');
      expect(find.text('Tell us about you'), findsWidgets);
      expect(find.byType(NeonBottomNav), findsNothing);
    });

    testWidgets('Profile shows the person and signing out works', (tester) async {
      final c = await start(tester, signedIn: person);

      await tester.tap(
        find.descendant(of: find.byType(NeonBottomNav), matching: find.text('Profile')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rakib Islam'), findsOneWidget);
      expect(find.text('+8801712345678'), findsOneWidget);
      expect(find.text('Player'), findsWidgets);
      expect(find.text('Rangpur'), findsWidgets);

      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();
      expect(c.read(currentUserProvider), isNull);
      expect(find.text('Not signed in'), findsOneWidget);
    });

    testWidgets('cancelling sign out keeps the person signed in', (tester) async {
      final c = await start(tester, signedIn: person);
      await tester.tap(
        find.descendant(of: find.byType(NeonBottomNav), matching: find.text('Profile')),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(c.read(currentUserProvider), isNotNull);
    });

    testWidgets('editing the profile saves the new name', (tester) async {
      final c = await start(tester, signedIn: person);
      await goTo(tester, c, '/profile/edit');

      expect(find.text('+8801712345678'), findsOneWidget); // shown, not editable
      await tester.enterText(find.byType(TextFormField), 'Rakib Hasan');
      await tapText(tester, 'Save');

      expect(c.read(currentUserProvider)!.displayName, 'Rakib Hasan');
      expect(
        c.read(userStoreProvider).loadProfile('u1')!.displayName,
        'Rakib Hasan',
      );
    });

    testWidgets('a photo that is too big is refused with a message', (tester) async {
      final c = await start(
        tester,
        signedIn: person,
        picker: _FakePicker(Uint8List(UserStore.maxPhotoBytes + 1)),
      );
      await goTo(tester, c, '/profile/edit');

      await tester.ensureVisible(find.text('Add photo'));
      await tester.tap(find.text('Add photo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Could not use that photo. Try another.'), findsOneWidget);
      expect(find.text('Add photo'), findsOneWidget); // still no photo
    });
  });
}
