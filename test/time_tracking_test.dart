import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/database/local_user.dart';
import 'package:urban_escape_application/app_pages/time_page/time_tracker.dart';
import 'package:urban_escape_application/app_pages/time_page/time_tracking_page.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('time tracking', () {
    TimeTrackingPage page;
    late TimeTracker tracker;
    setUp(() {
      page = const TimeTrackingPage();
      tracker = TimeTracker(page.createState());
      WidgetsFlutterBinding.ensureInitialized();
    });

    test('startTimer() should increase _passedTime and _percent, stopTimer() should stop the increase', () async {
      SharedPreferences.setMockInitialValues({LocalUser.weeklyGoalKey: 1});

      // Starting the timer
      tracker.startTimer();

      // Waiting for the timer to complete one iteration and halfway to next for variating time delays
      await Future.delayed(const Duration(milliseconds: 150));

      // Asserting the updated values
      expect(tracker.passedTime, equals(10));
      expect(tracker.percent, equals(0.0125));

      // Stopping the timer
      tracker.stopTimer();

      // Waiting to ensure another iteration would have taken place if the timer was still running
      await Future.delayed(const Duration(milliseconds: 150));

      // Asserting the values don't increase
      expect(tracker.passedTime, equals(10));
      expect(tracker.percent, equals(0.0125));
      expect(await tracker.getPercent(), equals(0.0125)); // Testing future<> getpercent
    });

    test('loadLastDayAppOpened() should not reset timer if it is the same day',
        () async {
      SharedPreferences.setMockInitialValues({
        LocalUser.lastStopwatchTimeKey: 1000,
        LocalUser.lastDayOpenedKey:
            DateTime.now().day.toString()
      });

      await tracker.loadLastStopwatchTime();
      expect(tracker.passedTime, equals(1000));

      await tracker.loadLastDayAppOpened();

      expect(tracker.passedTime, equals(1000));
    });

    test('loadLastDayAppOpened() should reset timer if it is a new day',
        () async {
      SharedPreferences.setMockInitialValues({
        LocalUser.lastStopwatchTimeKey: 1000,
        LocalUser.lastDayOpenedKey:
            DateTime.now().subtract(const Duration(days: 1)).day.toString()
      });

      await tracker.loadLastStopwatchTime();
      expect(tracker.passedTime, equals(1000));

      await tracker.loadLastDayAppOpened();

      expect(tracker.passedTime, equals(0));
    });

    test('resetTimer() resets passedtime and percent as well as localuser', () async {
      SharedPreferences.setMockInitialValues({LocalUser.weeklyGoalKey: 1, LocalUser.lastStopwatchTimeKey: 10});
      
      await tracker.loadLastStopwatchTime();

      expect(tracker.passedTime, equals(10));
      expect(tracker.percent, equals(0.0125));

      tracker.resetTimer();

      expect(tracker.passedTime, equals(0));
      expect(tracker.percent, equals(0.0));
      
      await tracker.loadLastStopwatchTime();
      
      expect(tracker.passedTime, equals(0));
      expect(tracker.percent, equals(0.0));
    });

    test('timerText()', () async {
      SharedPreferences.setMockInitialValues({LocalUser.lastStopwatchTimeKey: 6500});
      
      await tracker.loadLastStopwatchTime();

      expect(tracker.timerText, equals("01:05"));
    });


  });
}
