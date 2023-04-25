import 'package:flutter/material.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievement page'),
      ),
      body: Center(
        child: Text('This is the achievement page'),
      ),
    );
  }
}