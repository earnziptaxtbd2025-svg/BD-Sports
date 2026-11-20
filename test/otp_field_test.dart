import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:bd_sports/core/widgets/neon_dropdown_field.dart';
import 'package:bd_sports/core/widgets/otp_field.dart';
import 'package:bd_sports/core/widgets/role_option_card.dart';
import 'package:bd_sports/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(
      theme: AppTheme.neonNight(),
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('OtpField', () {
    testWidgets('keeps only digits', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(OtpField(controller: controller)));

      await tester.enterText(find.byType(TextField), 'ab12c');
      expect(controller.text, '12');
    });

    testWidgets('Bangla digits become 0-9', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(OtpField(controller: controller)));

      await tester.enterText(find.byType(TextField), '১২৩');
      expect(controller.text, '123');
    });

    testWidgets('stops at the length', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(OtpField(controller: controller, length: 4)));

      await tester.enterText(find.byType(TextField), '123456');
      expect(controller.text, '1234');
    });

    testWidgets('runs onCompleted once when the last digit is typed', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final done = <String>[];
      await tester.pumpWidget(
        host(OtpField(controller: controller, onCompleted: done.add)),
      );

      await tester.enterText(find.byType(TextField), '12345');
      expect(done, isEmpty);
      await tester.enterText(find.byType(TextField), '123456');
      expect(done, <String>['123456']);

      // Typing the same full code again, without clearing, does not repeat it.
      await tester.enterText(find.byType(TextField), '123456');
      expect(done, hasLength(1));

      // After the person clears it and types again, it runs again.
      await tester.enterText(find.byType(TextField), '');
      await tester.enterText(find.byType(TextField), '654321');
      expect(done, <String>['123456', '654321']);
    });

    testWidgets('shows the typed digits in boxes', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(OtpField(controller: controller)));

      await tester.enterText(find.byType(TextField), '42');
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('NeonDropdownField', () {
    testWidgets('shows the hint, opens a list and returns the choice', (tester) async {
      String? chosen = 'none-yet';
      await tester.pumpWidget(
        host(
          NeonDropdownField<String>(
            label: 'Division',
            hint: 'Choose',
            items: const [('d', 'Dhaka'), ('s', 'Sylhet')],
            onChanged: (value) => chosen = value,
          ),
        ),
      );

      expect(find.text('Choose'), findsOneWidget);
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      expect(find.text('Sylhet'), findsOneWidget);

      await tester.tap(find.text('Sylhet'));
      await tester.pumpAndSettle();
      expect(chosen, 's');
    });

    testWidgets('shows the chosen text and can clear the choice', (tester) async {
      String? chosen = 'd';
      await tester.pumpWidget(
        host(
          NeonDropdownField<String>(
            label: 'Division',
            value: 'd',
            clearLabel: 'Not set',
            items: const [('d', 'Dhaka'), ('s', 'Sylhet')],
            onChanged: (value) => chosen = value,
          ),
        ),
      );

      expect(find.text('Dhaka'), findsOneWidget);
      await tester.tap(find.text('Dhaka'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not set'));
      await tester.pumpAndSettle();
      expect(chosen, isNull);
    });

    testWidgets('closing the list without choosing changes nothing', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host(
          NeonDropdownField<String>(
            label: 'Division',
            hint: 'Choose',
            items: const [('d', 'Dhaka')],
            onChanged: (_) => calls++,
          ),
        ),
      );

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5)); // outside the list
      await tester.pumpAndSettle();
      expect(calls, 0);
    });
  });

  group('RoleOptionCard', () {
    testWidgets('reports taps and shows a tick when chosen', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          RoleOptionCard(
            icon: Icons.groups_outlined,
            title: 'Fan',
            body: 'Follow',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.text('Fan'));
      expect(taps, 1);
    });

    testWidgets('has no tick when not chosen', (tester) async {
      await tester.pumpWidget(
        host(
          RoleOptionCard(
            icon: Icons.groups_outlined,
            title: 'Fan',
            body: 'Follow',
            selected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });

  group('UserAvatar', () {
    test('first letter of the name', () {
      expect(UserAvatar.initial('rakib'), 'R');
      expect(UserAvatar.initial('  সাকিব'), 'স');
      expect(UserAvatar.initial(''), '');
    });

    testWidgets('shows the letter, or an icon when there is no name', (tester) async {
      await tester.pumpWidget(host(const UserAvatar(name: 'Rakib')));
      expect(find.text('R'), findsOneWidget);

      await tester.pumpWidget(host(const UserAvatar()));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
