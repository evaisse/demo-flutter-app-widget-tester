// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_test/main.dart';

void main() {
  testWidgets('Go to the next 2 pages and get back home', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify that our widget contains a title & counter starts at 0.
    expect(find.byKey(Key('title')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.byKey(Key('nextPage')), findsOneWidget);

    await tester.tap(find.byKey(Key('nextPage')));
    await tester.pumpAndSettle();

    expect(find.text('Other page'), findsOneWidget);

    await tester.tap(find.byKey(Key('nextPage')));
    await tester.pumpAndSettle();

    expect(find.text('page B'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
  });
}
