import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_front_page/app_center_page.dart';

void main() {
  testWidgets('AppCenterPage should have a Center widget as its direct child', (WidgetTester tester) async {
    // Wrap the MaterialApp with a MediaQuery widget
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
          home: AppCenterPage(),
        ),
      ),
    );

    // Verify that the direct child of the Scaffold is a Center widget
    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets('AppCenterPage should have a Text widget as a child of Center', (WidgetTester tester) async {
    // Wrap the MaterialApp with a MediaQuery widget
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
          home: AppCenterPage(),
        ),
      ),
    );

    // Find the Center widget
    final centerWidget = find.byType(Center).evaluate().first.widget as Center;

    // Verify that the child of the Center widget is a Text widget
    expect(centerWidget.child, isA<Text>());
  });
}

