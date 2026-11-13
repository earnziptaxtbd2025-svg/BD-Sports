import 'package:bd_sports/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows five bottom navigation tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BdSportsApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });

  testWidgets('switches to the Explore tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BdSportsApp()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Explore'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Step 1.6'), findsOneWidget);
  });
}
