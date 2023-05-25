import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';

void main() {
  testWidgets('Test show method', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    const message = 'Test Message';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ProgressBannerBar.show(context, message);
                },
                child: const Text('Show Banner'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the progress banner
    await tester.tap(find.text('Show Banner'));
    await tester.pumpAndSettle();

    // Verify that the SnackBar is displayed
    expect(find.byType(SnackBar), findsOneWidget);

    // Verify the content of the SnackBar
    final snackBarFinder = find.byType(SnackBar);
    final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
    expect(snackBarWidget.content, isA<Text>());
    expect((snackBarWidget.content as Text).data, message);

    // Verify the properties of the SnackBar
    expect(snackBarWidget.backgroundColor, equals(Colors.green.shade600));
    expect(snackBarWidget.behavior, equals(SnackBarBehavior.floating));
    expect(snackBarWidget.duration, equals(const Duration(seconds: 5)));
    expect(snackBarWidget.elevation, equals(10.0));
    expect(snackBarWidget.shape, isA<RoundedRectangleBorder>());
  });
}
