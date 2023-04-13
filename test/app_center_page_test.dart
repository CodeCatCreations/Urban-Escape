import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_front_page/app_center_page.dart';

void main() {
  group('AppCenterPage Widget Tests', () {
    // Creating a test case to check if AppCenterPage widget contains a Center widget
    testWidgets('AppCenterPage Widget renders correctly', (WidgetTester tester) async {
       // Rendering the AppCenterPage widget using the MaterialApp widget
      await tester.pumpWidget(const MaterialApp(home: AppCenterPage()));
      expect(find.text('This is the app center page.'), findsOneWidget);
    });
  // Expecting to find one Center widget in the widget tree
    testWidgets('AppCenterPage Widget contains a Center widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppCenterPage()));
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
