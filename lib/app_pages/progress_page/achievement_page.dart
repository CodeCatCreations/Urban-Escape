import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/progress_page/achievement.dart';
import 'package:urban_escape_application/database/local_user.dart';

class AchievementPage extends StatelessWidget {

  final Achievement goalAchievement = Achievement(title: "Goal-oriented", description: "Set a goal", maxLevel: 1, icon: const Icon(Icons.flag, color: Colors.green));
  final Achievement natureLoverAchievement = Achievement(title: "NatureLover", description: "Place a pin on a park", maxLevel: 5, icon: const Icon(Icons.nature, color: Colors.green));
  final Achievement streakAchievement = Achievement(title: "Streak", description: "Maintain a five-day streak!", maxLevel: 5, icon: const Icon(Icons.star, color: Colors.blue));

  final LocalUser _localUser = LocalUser();

  AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSetGoal = _localUser.goalAdded();
    if (hasSetGoal){
      goalAchievement.incrementLevel();
    }
    if(_localUser.getPinStatus()){
      print("Success");
      natureLoverAchievement.incrementLevel();
    }


    /*if(_localUser.getMarkerList().isNotEmpty){
      log(_localUser.markersList.length);
      natureLoverAchievement.incrementLevel();
      log(_localUser.getMarkerList().length);
    }*/


    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement page'),
      ),
      body: ListView(
        // Add padding to the list view
        padding: const EdgeInsets.all(16.0),
        children: [
        goalAchievement,
          natureLoverAchievement,
          streakAchievement,

        ],
      ),
    );
  }
}