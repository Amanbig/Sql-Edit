// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sql_edit/main.dart';

void main() {
  testWidgets('SQL Editor Home Screen Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that we're on the home screen
    expect(find.text('Welcome to SQL Editor'), findsOneWidget);
    expect(
      find.text('A powerful database editor for mobile and desktop'),
      findsOneWidget,
    );

    // Verify that the "Start Editing" button is present
    expect(find.text('Start Editing'), findsOneWidget);

    // Verify that feature cards are present
    expect(find.text('SQL Editor'), findsAtLeastNWidgets(1));
    expect(find.text('Query History'), findsOneWidget);
    expect(find.text('Result Viewer'), findsOneWidget);
    expect(find.text('Export Data'), findsOneWidget);
  });

  testWidgets('Navigation to SQL Editor Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Find and tap the "Start Editing" button
    await tester.tap(find.text('Start Editing'));
    await tester.pumpAndSettle();

    // Verify that we've navigated to the SQL Editor screen
    expect(find.text('No Database'), findsOneWidget);
    expect(find.text('Execute Query'), findsOneWidget);
    expect(find.text('Query Results'), findsOneWidget);
    expect(find.text('Query History'), findsOneWidget);
  });

  testWidgets('Navigation to Settings Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Find and tap the settings icon
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify that we've navigated to the Settings screen
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Database'), findsOneWidget);
  });

  testWidgets('Theme Toggle Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Navigate to settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Find and tap the Light theme radio button
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    // Verify that the theme has changed (this is a basic check)
    expect(find.text('Light'), findsOneWidget);
  });
}
