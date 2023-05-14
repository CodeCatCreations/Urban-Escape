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
  
  final Achievement soundsAchievement = Achievement(
      title: "Wave-Listener",
      description:
          "To complete this achievement: \n\nGo to the sounds page and turn on the waves sound",
      maxLevel: 1,
      icon: const Icon(Icons.waves_rounded, color: Colors.green));

  final LocalUser localUser = LocalUser();

  @override
  Widget build(BuildContext context) {
 
    if (LocalUser.goalAchievementPopUpHasBeenShown) {
      goalAchievement.incrementLevel();
    }
    if (LocalUser.timerAchievementPopupShown) {
      timeTrackerAchievement.incrementLevel();
    }
    if (LocalUser.soundsAchievementPopupShown) {
      soundsAchievement.incrementLevel();
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
            soundsAchievement,
          ],
        ),
      ),
    );
  }
}
