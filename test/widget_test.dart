// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectu/main.dart';

void main() {
  testWidgets('ConnectU app loads with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ConnectUApp());

    // Verify that the app loads and displays the login screen with expected widgets.
    expect(find.text('ConnectU'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
  
  testWidgets('Login button validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ConnectUApp());

    // Tap login button without entering credentials
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}
