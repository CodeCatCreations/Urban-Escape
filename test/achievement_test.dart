import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_escape_application/app_pages/progress_page/achievement.dart';

void main() {
  group('Achievement', () {

    test('Test incrementLevel', () {
      final Achievement goalAchievement = Achievement(
          title: "Goal-Setter",
          description:
              "To complete this achievement: \n\nGo to the Progress Page: Click on the 'Set Goal' and set a goal!",
          maxLevel: 1,
          icon: const Icon(Icons.flag, color: Colors.green));
      // Initial level should be 0
      expect(goalAchievement.level, 0);

      // Incrementing level for the first time
      goalAchievement.incrementLevel();
      expect(goalAchievement.level, 1);
      expect(goalAchievement.passed, true);
      expect(goalAchievement.percent, 0);
      expect(goalAchievement.icon.color, Colors.amber);

      // Incrementing level beyond the maxLevel should have no effect
      goalAchievement.incrementLevel();
      expect(goalAchievement.level, 1);
      expect(goalAchievement.passed, true);
      expect(goalAchievement.percent, 0);
      expect(goalAchievement.icon.color, Colors.amber);

      // Changing the description
      goalAchievement.changeDescription('New Description');
      expect(goalAchievement.description, 'New Description');
    });

    test('Test setIconColor', () {
    final Achievement timeTrackerAchievement = Achievement(
        title: "Time-Tracker",
        description:
            "To complete this achievement: \n\nGo to the stopwatch: Start the stopwatch and pause it. Make sure to see your progress in the progress page as well!",
        maxLevel: 1,
        icon: const Icon(Icons.timer_rounded, color: Colors.green));

      // Initial passed state should be false
      expect(timeTrackerAchievement.passed, false);

      // After calling setIconColor, the icon color should be updated to amber
      timeTrackerAchievement.passed = true;
      timeTrackerAchievement.setIconColor();
      expect(timeTrackerAchievement.icon.color, Colors.amber);
    });
  });
}
