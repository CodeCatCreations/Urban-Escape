import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_front_page/app_screen.dart';
import 'package:urban_escape_application/app_pages/map_pages/map_page.dart';
import 'package:urban_escape_application/app_pages/sounds_page.dart';
import 'package:urban_escape_application/app_pages/time_page/time_tracking.dart';
import 'package:urban_escape_application/app_pages/progress_page/progress_page.dart';

// Todo: pixel overflow from progress page to pass these tests
void main() {
  group('AppScreen Widget Tests', () {
    testWidgets('AppScreen Widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppScreen()));
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Sounds'), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('AppScreen Widget navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppScreen()));

      // Tap on the Map page icon
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      expect(find.byType(MapPage), findsOneWidget);

      // Tap on the Sounds page icon
      await tester.tap(find.byIcon(Icons.music_note));
      await tester.pumpAndSettle();
      expect(find.byType(SoundsPage), findsOneWidget);

      // Tap on the Social page icon
      await tester.tap(find.byIcon(Icons.people));
      //PumpAndSettle riggers a rebuild of the widget tree and waits for all animations to complete
      await tester.pumpAndSettle(); 
      expect(find.byType(TimeTrackingPage), findsOneWidget);

      // Tap on the Progress page icon
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();
      //Makes sure that only ProgressPage is the only widget present
      expect(find.byType(ProgressPage), findsOneWidget);
    });
  });
}
