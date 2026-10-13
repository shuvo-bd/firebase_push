// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_push/app.dart';

void main() {
  testWidgets('offline preview supports adding a task', (tester) async {
    await tester.pumpWidget(const TaskManagerApp(firebaseEnabled: false));
    expect(find.text('Make room for\nwhat matters.'), findsOneWidget);

    await tester.ensureVisible(find.text('Open offline preview'));
    await tester.tap(find.text('Open offline preview'));
    await tester.pumpAndSettle();
    expect(find.text('Your day, in focus.'), findsOneWidget);
    expect(find.text('Prepare weekly plan'), findsOneWidget);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Call the studio');
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Call the studio'), findsOneWidget);
  });
}
