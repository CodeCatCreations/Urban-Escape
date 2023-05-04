import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/app_pages/progress_page/goal_storage.dart';


class LocalUser {

  static final LocalUser _singleton = LocalUser._internal();
  factory LocalUser() {
    return _singleton;
  }

  bool hasPinned = false;
  LocalUser._internal();
  static final Set<Marker> savedMarkers = {};
  List<Map<String, dynamic>> markersList = savedMarkers.map((marker) {
    return {
      'markerId': marker.markerId.value,
      'latitude': marker.position.latitude,
      'longitude': marker.position.longitude,
    };
  }).toList();

  final blueIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final List<DateTime> _streakDates = []; // a list to store the dates of the user's streaks

  bool hasGoal = false;
  // a method to add a date to the user's streak
  List<Map<String, dynamic>> getMarkersList(){
    return markersList;
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
    /*GoalStorage goalStorage = GoalStorage();
    Future<int> storedGoal = goalStorage.readGoal();
    storedGoal.then((value) => print('Stored goal: $value'));
    return storedGoal == 30;
  */
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
    /*markersList = savedMarkers.map((marker) {
      return {
        'markerId': marker.markerId.value,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
      };
    }).toList();*/

    String markersJson = json.encode(markersList);
    await prefs.setString('saved_markers', markersJson);
  }

  List<Map<String, dynamic>> getMarkerList(){
    return markersList;
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
    hasGoal = prefs.getBool('has_goal') ?? false;

  }

}
