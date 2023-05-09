import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/sounds_page.dart';
import 'package:flutter_test/flutter_test.dart';

// test

void main() {

  testWidgets('SoundsPage builds SoundWidgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(),
          child: SoundsPage(),
        ),
      ),
    );

    expect(find.byType(SoundsPage), findsOneWidget);
    expect(find.byType(SoundWidget), findsNWidgets(4));
    expect(find.byType(Image), findsNWidgets(4));
    expect(find.byType(VolumeSlider), findsNWidgets(4));
  });

  testWidgets('Test play and stop first sound', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsPage(),
      ),
    );

    // Find the first SoundWidget
    final soundWidgetFinder = find.byType(SoundWidget).first;

    // Tap the SoundWidget
    await tester.tap(soundWidgetFinder);
    await tester.pump();

    // Check if the SoundWidget is activated
    final activatedImageFinder = find.descendant(
      of: soundWidgetFinder,
      matching: find.byType(Image),
    );
    expect(
      activatedImageFinder,
      findsOneWidget,
      reason: 'Activated image not found',
    );

    // Find the volume slider and set the value to 0.7
    final volumeSliderFinder = find.descendant(
      of: soundWidgetFinder,
      matching: find.byType(VolumeSlider),
    );
    await tester.drag(volumeSliderFinder, const Offset(100, 0));
    await tester.pump();

    // Tap the SoundWidget again to stop the sound
    await tester.tap(soundWidgetFinder);
    await tester.pump();

    // Check if the SoundWidget is deactivated
    final deactivatedImageFinder = find.descendant(
      of: soundWidgetFinder,
      matching: find.byType(Image),
    );
    expect(
      deactivatedImageFinder,
      findsOneWidget,
      reason: 'Deactivated image not found',
    );
  });

}
