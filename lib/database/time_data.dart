import 'package:flutter/material.dart';

import 'local_user.dart';

class TimeData extends ChangeNotifier {
  int _currentGoal = 120;
  int _stopTimerMS = 0;

  int get weeklyGoal => _currentGoal;
  int get stopTimerMS => _stopTimerMS;

  void saveNewWeeklyGoal(int newGoal) async {
    _currentGoal = newGoal;
    await LocalUser.saveWeeklyGoal(newGoal);
    notifyListeners();
  }

  Future<int> loadWeeklyGoal() async {
    final currentGoal = await LocalUser.loadWeeklyGoal();
    
    if (currentGoal == 0) {
      saveNewWeeklyGoal(_currentGoal);
    } else {
      _currentGoal = currentGoal;
    }
    return _currentGoal;
  }

  void updateStopTimerMS(int newTime) async {
    _stopTimerMS = newTime;
    await LocalUser.saveStopwatchTime(newTime);
    notifyListeners();
  }
}