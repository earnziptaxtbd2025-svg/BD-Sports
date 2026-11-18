import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:bd_sports/core/widgets/app_logo.dart';
import 'package:bd_sports/core/widgets/stadium_background.dart';
import 'package:bd_sports/features/dev_tools/presentation/design_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) =>
    MaterialApp(theme: AppTheme.neonNight(), home: child);

void main() {
  group('missing images never break the app', () {
    testWidgets('StadiumBackground shows its child', (tester) async {
      await tester.pumpWidget(
        host(const Scaffold(body: StadiumBackground(child: Text('Hello')))),
      );
      await tester.pump();
      expect(find.text('Hello'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppLogo draws a fallback and shows the name', (tester) async {
      await tester.pumpWidget(
        host(const Scaffold(body: Center(child: AppLogo(showName: true)))),
      );
      await tester.pump();
      expect(find.text('Bangladesh'), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DesignGalleryPage', () {
    testWidgets('shows every design widget without an error', (tester) async {
      tester.view.physicalSize = const Size(900, 9000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(const DesignGalleryPage()));
      await tester.pump();

      for (final String title in <String>[
        'Colours',
        'Buttons',
        'Tabs',
        'Badges',
        'Input fields',
        'Stepper',
        'Statistics',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text('Rangpur FC'), findsOneWidget);
      expect(find.text('180/5'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Remove the page so the blinking LIVE dot stops before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('stepper Next and Back buttons move the step', (tester) async {
      tester.view.physicalSize = const Size(900, 9000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(const DesignGalleryPage()));
      await tester.pump();

      // Start: step 3 (index 2) is current, so two ticks.
      expect(find.byIcon(Icons.check), findsNWidgets(3));
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsNWidgets(4));
      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsNWidgets(3));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
