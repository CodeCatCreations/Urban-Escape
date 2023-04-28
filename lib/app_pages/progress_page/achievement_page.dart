import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/progress_page/achievement.dart';

class AchievementPage extends StatelessWidget {

  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement page'),
      ),
      body: ListView(
        // Add padding to the list view
        padding: const EdgeInsets.all(16.0),
        children: [
          Achievement(title: "NatureLover", description: "Description of NatureLover achievement", maxLevel: 5, icon: const Icon(Icons.nature, color: Colors.green)),
          Achievement(title: "Goal-oriented", description: "Set a goal to reach level 1", maxLevel: 5, icon: const Icon(Icons.flag, color: Colors.orange)),
          Achievement(title: "Streak", description: "Maintain a five-day streak!", maxLevel: 5, icon: const Icon(Icons.star, color: Colors.blue)),
        ],
      ),
    );
  }
  void _showAchievementDetails(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: const <Widget>[
          ],
        );
      },
    );
  }




}