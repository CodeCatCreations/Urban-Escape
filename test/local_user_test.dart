import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/database/local_user.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalUser tests', () {
    LocalUser localUser = LocalUser();
    MockSharedPreferences mockSharedPreferences = MockSharedPreferences();


    test('Test loadStopwatchTime()', () async {
      when(mockSharedPreferences.getInt(LocalUser.lastStopwatchTimeKey))
          .thenReturn(100);
      SharedPreferences.setMockInitialValues({
        LocalUser.lastStopwatchTimeKey: 100,
        LocalUser.weeklyGoalKey: 10,
      });      final result = await LocalUser.loadStopwatchTime();
      expect(result, equals(100));
    });

    test('Test getCurrentStreak() without streaks', () {
      expect(localUser.getCurrentStreak(), equals(0));
    });
  });
}