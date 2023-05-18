import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';
import 'dart:async';
import 'package:urban_escape_application/database/local_user.dart';

import '../../database/time_data.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> {
  int _passedTime = 0;
  double _percent = 0.0;
  int _goal = 10;
  Timer _timer = Timer(Duration.zero, () {});
  bool click = true;
  
  Future<void> loadLastStopwatchTime() async {

    final lastTimeUserStoppedTheTime = await LocalUser.loadStopwatchTime();

    // In setState we set the state of the widget with the loaded stopwatch time and the percent of the goal achieved
    setState(() {
      _passedTime = lastTimeUserStoppedTheTime;
    
      reloadPercent();
    });
  }

  Future<void> loadCurrentGoal() async {
    final currentWeeklyGoal = await Provider.of<TimeData>(context, listen: false).loadWeeklyGoal();

    
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

  void loadLastDayAppOpened() async {
    String lastDayAppOpened = await LocalUser.lastDayAppWasOpened();
    if (lastDayAppOpened != DateTime.now().day.toString()) {
      if (DateTime.now().day == DateTime.monday) {
        LocalUser.resetRecordedTimeWeekday();
      }
    } 
  }

  @override
  void initState() {
    super.initState();
    loadLastDayAppOpened();
    
    loadLastStopwatchTime();
  }

  void startTimer() {
    if (_timer.isActive) return;
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      double percent = await getPercent();
      setState(() {
        _passedTime += 2;
        _percent = percent;
      });
      Provider.of<TimeData>(context, listen: false).updateStopTimerMS(_passedTime);
    });
  }

  void stopTimer(BuildContext context) {
    _timer.cancel();
    // Save the current stopwatch time to shared_preferences when stopped
    saveLastStopwatchTime(_passedTime);
    showAchievementPopup(context);
  }

  void resetTimer() {
    setState(() {
      _passedTime = 0;
      _percent = 0;
    });
    // Reset the saved stopwatch time in shared_preferences
  }

  String get timerText {
    Duration duration = Duration(milliseconds: _passedTime * 10);
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
  }

  void showAchievementPopup(BuildContext context) async {
    bool achievementPopupShown = await LocalUser.getTimerAchievementPopupShown();
    if (!achievementPopupShown) {
      // ignore: use_build_context_synchronously
      ProgressBannerBar.show(
          context, 'Congrats! You have just passed an achievement!');
    }
    LocalUser.setTimerAchievementPopupShown(true);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TimeData>(context, listen: true).weeklyGoal;
    return Container(
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
                  animationDuration: 10,
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
                          "Daily progress: " + (_percent*100).toInt().toString()+"%",
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          iconSize: 100,
                          onPressed: () {
                            setState(() {
                              if (click) {
                                _showMyDialog();
                              } else {
                                click = !click;
                                stopTimer(context);
                              }
                              //click = !click;
                              //(click == false) ? startTimer() : stopTimer(context);
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
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ElevatedButton(
                child: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    click = true;
                  });
                  resetTimer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
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
        ],
      );
    },
  );
}
}
          
