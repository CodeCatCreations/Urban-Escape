import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_pages/map_pages/map_page.dart';

void main() {
  testWidgets('MapPage should render within a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapPage(),
      ),
    );
    expect(find.byType(MapPage), findsOneWidget);

  });

}

