// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kanbankit/app.dart';

void main() {
  testWidgets('KanbanKit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KanbanKitApp());

    // Verify that the app loads with the board page
    expect(find.text('KanbanKit'), findsOneWidget);
    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Verify that the floating action button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
