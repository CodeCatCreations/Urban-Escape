import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_pages/settings_page.dart';

void main() {
  testWidgets('SettingsPage Widget renders correctly', (WidgetTester tester) async {
    // Build the widget tree.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify that the title is displayed.
    expect(find.text('Settings'), findsOneWidget);

    // Verify that the back button is displayed.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Verify that the content text is displayed.
    expect(find.text('This is the settings page'), findsOneWidget);
  });

  testWidgets('SettingsPage Widget pops navigation when back button is pressed', (WidgetTester tester) async {
    // Build the widget tree.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Tap the back button.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify that the page has been popped.
    expect(find.byType(SettingsPage), findsNothing);
  });
}
