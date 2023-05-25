import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  });
}