import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/database/local_user.dart';
import 'package:urban_escape_application/database/time_data.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('TimeData', () {
    late TimeData data = TimeData();

    setUp(() {
      data = TimeData();
    });

    test('Test', () {
      expect(data.weeklyGoal, 120);
    });

    test('Test saveNewWeeklyGoal and loadWeeklyGoal', () async {
      // Setting inital value for weekly goal
      SharedPreferences.setMockInitialValues({
        LocalUser.weeklyGoalKey: 120,
      });
      //Checking that the loaded weekly goal is correct
      final result = await data.loadWeeklyGoal();
      expect(result, equals(120));

      const newlySetGoal = 240;
      //Saving the new goal with TimeData
      data.saveNewWeeklyGoal(newlySetGoal);
      //Loading the weeklyGoal with TimeData
      final loadedWeeklyGoal = await data.loadWeeklyGoal();
      expect(loadedWeeklyGoal, newlySetGoal);
    });

    test(
        'Controlling that the updateStopTimeMS changes LocalUser saveStopwatchTime',
        () async {
      SharedPreferences.setMockInitialValues({
        LocalUser.lastStopwatchTimeKey: 0,
      });

      final defaultResult = await LocalUser.loadStopwatchTime();
      expect(defaultResult, equals(0));

      const newSetTime = 6000;
      //By using updateStopTimeMS, it should update LocalUser.saveStopWatchTime
      data.updateStopTimerMS(newSetTime);
      //Let's load LocalUser.loadStopWatchTime to see if it has updated the time
      final newlyLoadedTime = await LocalUser.loadStopwatchTime();
      expect(newlyLoadedTime, newSetTime);
    });

  });
}
