import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/progress_page/achievement.dart';
import 'package:urban_escape_application/database/local_user.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final Achievement goalAchievement = Achievement(
      title: "Goal-oriented",
      description: "Set a goal",
      maxLevel: 1,
      icon: const Icon(Icons.flag, color: Colors.green));

  final Achievement timeTrackerAchievement = Achievement(
      title: "Time-Tracker",
      description:
          "To complete this achievement: \n\nGo to the stopwatch: Start the stopwatch and pause it",
      maxLevel: 1,
      icon: const Icon(Icons.timer_rounded, color: Colors.green));
  final Achievement saveAMarkerAchievement = Achievement(
      title: "Save-A-Marker",
      description:
          "To complete this achievement: \n\nGo to maps: Create a marker, hold the marker and drag it to your favourite spot. Click on the marker and get it a new name and make sure to save it!",
      maxLevel: 1,
      icon: const Icon(Icons.map_rounded, color: Colors.green));

  final LocalUser localUser = LocalUser();

  @override
  Widget build(BuildContext context) {
    if (LocalUser.goalAchievementPopUpHasBeenShown) {
      goalAchievement.incrementLevel();
    }
    if (LocalUser.timerAchievementPopupShown) {
      timeTrackerAchievement.incrementLevel();
    }
    if (LocalUser.saveAMarkerAchievementPopupShown) {
      saveAMarkerAchievement.incrementLevel();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: ListView(
          // Add padding to the list view
          padding: const EdgeInsets.all(16.0),
          children: [
            goalAchievement,
            timeTrackerAchievement,
            saveAMarkerAchievement,
          ],
        ),
      ),
    );
  }
}
