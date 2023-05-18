import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/progress_page/achievement.dart';
import 'package:urban_escape_application/database/local_user.dart';

class AchievementPage extends StatefulWidget {
  final PageController pageController;
  const AchievementPage({required this.pageController});

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final Achievement goalAchievement = Achievement(
      title: "Goal-Setter",
      description:
          "To complete this achievement: \n\nGo to the Progress Page: Click on the 'Set Goal' and set a goal!",
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

  final Achievement goalReacherAchievement = Achievement(
      title: "Goal-Reacher",
      description:
          "To complete this achievement: \n\nGo back to the stopwatch and start tracking again, once your daily goal has been reached you will earn this achievement!",
      maxLevel: 1,
      icon: const Icon(Icons.grade_outlined, color: Colors.green));

  final LocalUser localUser = LocalUser();

  @override
  Widget build(BuildContext context) {

    if (LocalUser.goalAchievementPopUpHasBeenShown) {
      goalAchievement.incrementLevel();
      goalAchievement.changeDescription(
          "Congragulations! \n\nYou've earned this achievement because you've set a goal");
    }
    if (LocalUser.timerAchievementPopupShown) {
      timeTrackerAchievement.incrementLevel();
      timeTrackerAchievement.changeDescription(
          "Congragulations! \n\nYou've earned this achievement because you used the stopwatch!");
    }
    if (LocalUser.soundsAchievementPopupShown) {
      soundsAchievement.incrementLevel();
      soundsAchievement.changeDescription(
          "Congragulations! \n\nYou've earned this achievement because you listened to the waves!");
    }
    if (LocalUser.goalReacherAchievementPopupShown) {
      goalReacherAchievement.incrementLevel();
      goalReacherAchievement.changeDescription(
        "Congragulations! \n\nYou've earned this achievement because you reached your daily goal!"
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: kToolbarHeight, // Adjust the height as needed
              color: Colors.blue, // Use your desired color
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: Image.asset(
                      'assets/icons/achievement.png',
                      width: 50,
                      height: 70,
                      color: const Color.fromARGB(255, 226, 171, 7),
                    ),
                    label: const Text(''),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_up_sharp),
                    iconSize: 40,
                    onPressed: () {
                      widget.pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.decelerate,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  goalAchievement,
                  timeTrackerAchievement,
                  soundsAchievement,
                  goalReacherAchievement,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
