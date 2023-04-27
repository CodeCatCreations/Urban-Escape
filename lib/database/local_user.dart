import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/app_pages/progress_page/goal_storage.dart';


class LocalUser {
  final List<DateTime> _streakDates = []; // a list to store the dates of the user's streaks

  // a method to add a date to the user's streak
  void addStreakDate(DateTime date) {
    _streakDates.add(date);
  }
  // a method to get the user's current streak
  int getCurrentStreak() {
    int streak = 0;
    DateTime today = DateTime.now();
    while (_streakDates.contains(today.subtract(Duration(days: streak)))) {
      streak++;
    }
    return streak;
  }

  Future<bool> goalAdded() async {
    GoalStorage goalStorage = GoalStorage();
    if (await goalStorage.readGoal() == 0){
      return false;
    }
    return true;
  }



  // a method to save the user's streak data to local storage
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dates = _streakDates.map((date) => date.toIso8601String()).toList();
    await prefs.setStringList('streak_dates', dates);
  }

  // a method to load the user's streak data from local storage
  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dates = prefs.getStringList('streak_dates') ?? [];
    _streakDates.clear();
    _streakDates.addAll(dates.map((date) => DateTime.parse(date)));
  }
}
