import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalUser {
  static final LocalUser _singleton = LocalUser._internal();

  factory LocalUser() {
    return _singleton;
  }

  LocalUser._internal();

  static Set<Marker> savedMarkers = {};
  // We declare the variable to be static so that it belongs to the class and not to any instance of it.
  static const lastStopwatchTimeKey = 'last_stopwatch_time';
  static const timeSpentInDayKey = "time_spent_day_weekday";
  static const weeklyGoalKey = 'weekly_goal';

  final blueIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  // This function loads the last saved stopwatch time from shared preferences.
  // It returns a Future<int>, which means that it will be completed with an integer value in the future.
  // We mark it as async because it makes use of the SharedPreferences plugin, which is asynchronous.
  static Future<int> loadStopwatchTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastStopwatchTimeKey) ??
        0; // Return the saved time, or 0 if it's not present.
  }

  static Future<void> saveStopwatchTime(int timeInMS) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastStopwatchTimeKey,
        timeInMS); //Save the current stopwatch time to shared preferences.
    await prefs.setInt("time_spent_day_${DateTime.now().weekday}", timeInMS);
  }

  Future<int> loadRecordedTimeWeekday(int weekDay) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("time_spent_day_$weekDay") ??
        0; // Return the recorded time for the specified weekday, or 0 if there is none.
  }

  static Future<void> resetRecordedTimeWeekday() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 7; i++) {
      await prefs.setInt("time_spent_day_$i",
          0); // Sets the recorded time for all days of the week to 0.
    }
  }

  static Future<void> resetTimeTracker() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastStopwatchTimeKey, 0);
  }

  static Future<String> lastDayAppWasOpened() async {
    final prefs = await SharedPreferences.getInstance();
    String s = prefs.getString('last_opened_day') ??
        ''; // Saves the last day the app was opened in a temporary string s.
    await prefs.setString(
        'last_opened_day',
        DateTime.now()
            .day
            .toString()); // Sets the value of last_opened_day to today.
    return s; // Return the day the app was opened last, or '' if it has not been opened before.
  }

  /// This function loads the current weekly goal from shared preferences
  static Future<int> loadWeeklyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(weeklyGoalKey) ??
        0; // Return the current goal, or 0 if it's not present.
  }

  static Future<void> saveWeeklyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        weeklyGoalKey, goal); //Save the new weekly goal to shared preferences.
  }

  // a method to save the user's streak data to local storage
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveMarkers(prefs);
  }

  void saveMarkers(SharedPreferences prefs) async {
    List<Map<String, dynamic>> markersList = savedMarkers.map((marker) {
      return {
        'markerId': marker.markerId.value,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'infoWindowTitle': marker.infoWindow.title
      };
    }).toList();

    String markersJson = json.encode(markersList);
    await prefs.setString('saved_markers', markersJson);
  }

  // a method to load the user's streak data from local storage
  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loadMarkers(prefs);
  }

  void loadMarkers(SharedPreferences prefs) {
    String markersJson = prefs.getString('saved_markers') ?? '[]';
    List<Map<String, dynamic>> markersList =
        List<Map<String, dynamic>>.from(json.decode(markersJson));
    savedMarkers.clear();
    for (Map<String, dynamic> markerData in markersList) {
      Marker marker = Marker(
        markerId: MarkerId(markerData['markerId']),
        position: LatLng(markerData['latitude'], markerData['longitude']),
        draggable: false,
        icon: blueIcon,
        infoWindow: InfoWindow(
            // Create the info window with the saved title
            title: markerData['infoWindowTitle']),
      );
      savedMarkers.add(marker);
    }
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

  static bool soundsAchievementPopupShown = false;

  static Future<void> setSoundsAchievementPopupShown(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    soundsAchievementPopupShown = true;
    await prefs.setBool('sound_pop_up_shown', value);
  }

  static Future<bool> getSoundAchievementPopupShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_pop_up_shown') ?? false;
  }

  static bool goalReacherAchievementPopupShown = false;

  static Future<void> setGoalReacherAchievementPopupShown(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    goalReacherAchievementPopupShown = true;
    await prefs.setBool('goal_reacher_pop_up_shown', value);
  }

  static Future<bool> getGoalReacherAchievementPopupShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('goal_reacher_pop_up_shown') ?? false;
  }

}
