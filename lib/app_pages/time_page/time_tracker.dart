import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/database/local_user.dart';

import '../../database/time_data.dart';
import '../progress_page/daily_banner_page.dart';
import 'time_tracking_page.dart';

class TimeTracker {
  late State<TimeTrackingPage> trackerPage;

  int _passedTime = 0;
  get passedTime => _passedTime;
  double _percent = 0.0;
  get percent => _percent;
  int _goal = 10;
  Timer _timer = Timer(Duration.zero, () {});
  bool click = true;

  TimeTracker(State<TimeTrackingPage> trackingPage) {
    trackerPage = trackingPage;
    _timer.cancel();
  }
  
  Future<void> loadLastStopwatchTime() async {

    final lastTimeUserStoppedTheTime = await LocalUser.loadStopwatchTime();

    // In setState we set the state of the widget with the loaded stopwatch time and the percent of the goal achieved
    
    _passedTime = lastTimeUserStoppedTheTime;
    
    await reloadPercent();
  }

  Future<void> loadCurrentGoal() async {
    int currentWeeklyGoal;
    if (trackerPage.mounted) {
      currentWeeklyGoal = await Provider.of<TimeData>(trackerPage.context, listen: false).loadWeeklyGoal();
    } else {
      currentWeeklyGoal = await LocalUser.loadWeeklyGoal();
    }

    
    _goal = 60 * currentWeeklyGoal ~/ 7;
    
  }

  void saveLastStopwatchTime(int time) async {
    await LocalUser.saveStopwatchTime(time);
  }

  Future<void> reloadPercent() async {
    _percent = await getPercent();
  }

  Future<double> getPercent() async {
    // Calculate the percentage of the goal that has been reached based on the passed time.
    // If the passed time is greater than the goal, set the percentage to 1.0 (or 100%).
    // Otherwise, set the percentage to the ratio of the passed time to the goal.
    await loadCurrentGoal();
    return Duration(seconds: _passedTime).inSeconds.toDouble() > (_goal * 100)
            ? 1
            : Duration(seconds: _passedTime).inSeconds.toDouble() / (_goal * 100);
  }

  Future<void> loadLastDayAppOpened() async {
    String lastDayAppOpened = await LocalUser.lastDayAppWasOpened();
    if (lastDayAppOpened != DateTime.now().day.toString()) {
      resetTimer();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        LocalUser.lastDayOpenedKey,
        DateTime.now()
            .day
            .toString()); // Sets the value of last_opened_day to today.
      if (DateTime.now().day == DateTime.monday) {
        LocalUser.resetRecordedTimeWeekday();
      }
    } 
  }

  void initState() async {
    await loadLastDayAppOpened();
    
    loadLastStopwatchTime();
  }

  void startTimer() {
    if (_timer.isActive) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      _passedTime += 10;
      if (trackerPage.mounted) {
        Provider.of<TimeData>(trackerPage.context, listen: false).updateStopTimerMS(_passedTime);
      }
      final percent = await getPercent();
      _percent = percent;
    });
  }

  void stopTimer() {
    _timer.cancel();
    // Save the current stopwatch time to shared_preferences when stopped
    saveLastStopwatchTime(_passedTime);
    showAchievementPopup();
  }

  void resetTimer() async {
    _passedTime = 0;
    _percent = 0;
    // Reset the saved stopwatch time in shared_preferences
    await LocalUser.resetTimeTracker();
  }

  String get timerText {
    Duration duration = Duration(milliseconds: _passedTime * 10);
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
  }

  void showAchievementPopup() async {
    bool achievementPopupShown = await LocalUser.getTimerAchievementPopupShown();
    if (!achievementPopupShown) {
      // ignore: use_build_context_synchronously
      if (trackerPage.mounted) {
        ProgressBannerBar.show(
          trackerPage.context, 'Congrats! You have just passed an achievement!');
      }
    }
    LocalUser.setTimerAchievementPopupShown(true);
  }

  Widget build(BuildContext context) {
    Provider.of<TimeData>(context, listen: true).weeklyGoal;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Time Tracking',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Pacifico',
            ),
          ),
          const SizedBox(height: 20),
          Consumer<TimeData>(
            builder: (context, myData, child) {
              reloadPercent();
              return FutureBuilder(
                future: reloadPercent(),
                builder: (context, _) {
                return CircularPercentIndicator(
                  radius: 180,
                  lineWidth: 20.0,
                  backgroundWidth: 15,
                  animation: true,
                  animationDuration: 100,
                  animateFromLastPercent: true,
                  percent: _percent,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor:
                      _percent == 1.0 ? Colors.green.shade300 : Colors.blue.shade300,
                  backgroundColor: Colors.white54,
                  center: Container(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          timerText,
                          style: const TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Daily progress: ${(_percent*100).toInt().toString()}%",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          iconSize: 100,
                          onPressed: () {
                            // ignore: invalid_use_of_protected_member
                            trackerPage.setState(() {
                              if (click) {
                                _showConfirmationDialog();
                              } else {
                                click = !click;
                                stopTimer();
                              }
                            });
                          },
                          icon: Icon((click == false) ? Icons.pause_circle_filled :
                          Icons.play_circle_filled, color: Colors.grey.shade50),
                        ),
                      ],
                    )
                  )
                );
              });
            }
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showConfirmation = prefs.getBool('doNotshowConfirmation') ?? false;

    if (showConfirmation) {
      click = !click;
      startTimer();
      return;
    }
    
    // ignore: use_build_context_synchronously
    return showDialog<void>(
      context: trackerPage.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Time Tracker?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to start tracking your time? Once time has been tracked, you cannot remove it.'),
                Text('\nWhen you are finished tracking, press the pause button.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                click = !click;
                startTimer();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continue and do not show this again'),
              onPressed: () {
                click = !click;
                startTimer();
                prefs.setBool('doNotshowConfirmation', true);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}