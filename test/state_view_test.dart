import 'package:bd_sports/core/widgets/state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('loading shows a progress indicator', (tester) async {
    await tester.pumpWidget(_wrap(const StateView.loading(message: 'Please wait')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Please wait'), findsOneWidget);
  });

  testWidgets('empty shows title, message and a working action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(StateView.empty(
      title: 'No tournaments yet',
      message: 'Create the first one.',
      actionLabel: 'Create',
      onAction: () => taps++,
    )));
    expect(find.text('No tournaments yet'), findsOneWidget);
    expect(find.text('Create the first one.'), findsOneWidget);

    await tester.tap(find.text('Create'));
    expect(taps, 1);
  });

  testWidgets('error offers a retry only when given one', (tester) async {
    await tester.pumpWidget(_wrap(const StateView.error()));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    var retries = 0;
    await tester.pumpWidget(_wrap(StateView.error(onRetry: () => retries++)));
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('offline explains that saved data is shown', (tester) async {
    await tester.pumpWidget(_wrap(const StateView.offline()));
    expect(find.text('You are offline'), findsOneWidget);
    expect(find.textContaining('saved information'), findsOneWidget);
  });
}
