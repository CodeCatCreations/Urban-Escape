import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_front_page/app_screen.dart';
import 'package:urban_escape_application/main.dart';

void main() {
  /*
  testWidgets('App title is correct', (WidgetTester tester) async {
    await tester.pumpWidget(const UrbanEscape());
    expect(find.text('Urban Escape'), findsOneWidget);
  });
  */

  // Test whether the app has a primary color of blue
  testWidgets('App has a primary color of blue', (WidgetTester tester) async {
  // Pump the widget tree with the UrbanEscape app
    await tester.pumpWidget(const UrbanEscape());
  // Get the theme of the MaterialApp widget and check if its primary color is blue
    final theme = Theme.of(tester.element(find.byType(MaterialApp)));
    expect(theme.primaryColor, equals(Colors.blue));
  });
  // Test whether the home screen of the app is the AppScreen widget
  testWidgets('App screen is the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const UrbanEscape());
  // Check if there is one and only one AppScreen widget in the widget tree
    expect(find.byType(AppScreen), findsOneWidget);
  });
}
