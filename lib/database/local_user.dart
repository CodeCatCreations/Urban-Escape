import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/app_pages/progress_page/goal_storage.dart';


class LocalUser {

  static final LocalUser _singleton = LocalUser._internal();
  factory LocalUser() {
    return _singleton;
  }

  LocalUser._internal();


  static final Set<Marker> savedMarkers = {};


  final blueIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
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
  Future <void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    saveDates(prefs);
    saveMarkers(prefs);

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
      };
    }).toList();

    String markersJson = json.encode(markersList);
    await prefs.setString('saved_markers', markersJson);
  }



  // a method to load the user's streak data from local storage
  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dates = prefs.getStringList('streak_dates') ?? [];
    _streakDates.clear();
    _streakDates.addAll(dates.map((date) => DateTime.parse(date)));

    String markersJson = prefs.getString('saved_markers') ?? '[]';
    List<Map<String, dynamic>> markersList = List<Map<String, dynamic>>.from(json.decode(markersJson));
    savedMarkers.clear();
    for (Map<String, dynamic> markerData in markersList) {
      Marker marker = Marker(
        markerId: MarkerId(markerData['markerId']),
        position: LatLng(markerData['latitude'], markerData['longitude']),
        draggable: false,
        icon: blueIcon,
      );
      savedMarkers.add(marker);
    }

  }

}
