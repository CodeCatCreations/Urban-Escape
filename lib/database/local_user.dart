import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LocalUser {

  static final LocalUser _singleton = LocalUser._internal();

  factory LocalUser() {
    return _singleton;
  }

  bool hasPinned = false;
  LocalUser._internal();

  static Set<Marker> savedMarkers = {};
  // We declare the variable to be static so that it belongs to the class and not to any instance of it.
  static const lastStopwatchTimeKey = 'last_stopwatch_time';
  static const weeklyGoalKey = 'weekly_goal';


  final blueIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final List<DateTime> _streakDates = []; // a list to store the dates of the user's streaks.... Varför inte STATIC?????

  // This function loads the last saved stopwatch time from shared preferences.
  // It returns a Future<int>, which means that it will be completed with an integer value in the future.
  // We mark it as async because it makes use of the SharedPreferences plugin, which is asynchronous.
  static Future<int> loadStopwatchTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastStopwatchTimeKey) ?? 0; // Return the saved time, or 0 if it's not present.
  }

  bool hasGoal = false;

  static Future<void> saveStopwatchTime(int timeInMS) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastStopwatchTimeKey, timeInMS); //Save the current stopwatch time to shared preferences.
    await prefs.setInt("time_spent_day_${DateTime.now().weekday}", timeInMS);
  }

  Future<int> loadRecordedTimeWeekday(int weekDay) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("time_spent_day_$weekDay") ?? 0; // Return the recorded time for the specified weekday, or 0 if there is none.
  }

  static Future<void> resetRecordedTimeWeekday() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 7; i++) {
      await prefs.setInt("time_spent_day_$i", 0); // Sets the recorded time for all days of the week to 0.
    }
  }

  static Future<String> lastDayAppWasOpened() async {
    final prefs = await SharedPreferences.getInstance();
    String s = prefs.getString('last_opened_day') ?? ''; // Saves the last day the app was opened in a temporary string s.
    await prefs.setString('last_opened_day', DateTime.now().day.toString()); // Sets the value of last_opened_day to today.
    return s; // Return the day the app was opened last, or '' if it has not been opened before.
  }

  /// This function loads the current weekly goal from shared preferences
  static Future<int> loadWeeklyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(weeklyGoalKey) ?? 0; // Return the current goal, or 0 if it's not present.
  }

  static Future<void> saveWeeklyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(weeklyGoalKey, goal); //Save the new weekly goal to shared preferences.
  }

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

  void setGoal(){
    hasGoal = true;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('has_goal', hasGoal);
    });
  }

  bool goalAdded() {
  return hasGoal;
  }

  // a method to save the user's streak data to local storage
  Future <void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveDates(prefs);
    saveMarkers(prefs);

    hasPinned = true;
    prefs.setBool('has_goal', hasGoal);
  }

  bool getPinStatus(){
    return hasPinned;
  }

  void saveDates(SharedPreferences prefs) async {
    List<String> dates = _streakDates.map((date) => date.toIso8601String()).toList();
    await prefs.setStringList('streak_dates', dates);
  }

  void saveMarkers(SharedPreferences prefs) async {
    List<Map<String, dynamic>> markersList = savedMarkers.map((marker) {
      return {
        'markerId': marker.markerId.value,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'infoWindowTitle' : marker.infoWindow.title
      };
    }).toList();

    String markersJson = json.encode(markersList);
    await prefs.setString('saved_markers', markersJson);
  }

  // a method to load the user's streak data from local storage
  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loadDates(prefs);
    loadMarkers(prefs);
  }

  void loadDates(SharedPreferences prefs) {
    List<String> dates = prefs.getStringList('streak_dates') ?? [];
    _streakDates.clear();
    _streakDates.addAll(dates.map((date) => DateTime.parse(date)));
  }

  void loadMarkers(SharedPreferences prefs) {
    String markersJson = prefs.getString('saved_markers') ?? '[]';
    List<Map<String, dynamic>> markersList = List<Map<String, dynamic>>.from(json.decode(markersJson));
    savedMarkers.clear();
    for (Map<String, dynamic> markerData in markersList) {
      Marker marker = Marker(
        markerId: MarkerId(markerData['markerId']),
        position: LatLng(markerData['latitude'], markerData['longitude']),
        draggable: false,
        icon: blueIcon,
        infoWindow: InfoWindow( // Create the info window with the saved title
          title: markerData['infoWindowTitle']
        ),
      );
      savedMarkers.add(marker);
    }

    hasGoal = prefs.getBool('has_goal') ?? false;

  }

static bool goalAchievementPopUpHasBeenShown = false;

static Future<void> setGoalAchievementPopupShown(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    goalAchievementPopUpHasBeenShown = true;
    await prefs.setBool('goal_pop_up_shown', value);
  }

 static Future<bool> getGoalAchievementPopupShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('goal_pop_up_shown') ?? false;
  }

static bool timerAchievementPopupShown = false;

static Future<void> setTimerAchievementPopupShown(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  timerAchievementPopupShown = true;
  await prefs.setBool('timer_pop_up_shown', value);
}

static Future<bool> getTimerAchievementPopupShown() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('timer_pop_up_shown') ?? false;
}

static bool saveAMarkerAchievementPopupShown = false;

static Future<void> setSaveAMarkerAchievementPopupShown(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  saveAMarkerAchievementPopupShown = true;
  await prefs.setBool('save_marker_pop_up_shown', value);
}

static Future<bool> getSaveAMarkerAchievementPopupShown() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('save_marker_pop_up_shown') ?? false;
}




/*
  bool getSetTimeAchievementStatus() {}

  bool getSaveMarkerAchievementStatus() {}
  */
}
