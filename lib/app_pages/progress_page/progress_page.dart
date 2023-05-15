import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:urban_escape_application/database/time_data.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';
import '../../database/local_user.dart';
import 'achievement_page.dart';
import 'bar_chart.dart';
import 'chart_container.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  int seconds = 102;
  int _goal = 0;
  double _percent = 0.0;
  int animateDuration = 1000;
  //ändringar
  bool shouldShowAchievementPopup = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadWeeklyGoal();

    LocalUser.getGoalAchievementPopupShown().then((shown) {
      if (shown) {
        setState(() {
          LocalUser.goalAchievementPopUpHasBeenShown = true;
        });
      }
    });

    LocalUser.getTimerAchievementPopupShown().then((shown) {
      if (shown) {
        setState(() {
          LocalUser.timerAchievementPopupShown = true;
        });
      }
    });

    LocalUser.getSoundAchievementPopupShown().then((shown) {
      if (shown) {
        setState(() {
          LocalUser.soundsAchievementPopupShown = true;
        });
      }
    });
  }

  void loadWeeklyGoal() async {
    final goal =
        await Provider.of<TimeData>(context, listen: false).loadWeeklyGoal();
    setState(() {
      _goal = goal;
    });
  }

  void _saveNewWeeklyGoal(int newGoal) {
    if (newGoal != _goal) {
      shouldShowAchievementPopup = true;
    }
    setState(() {
      Provider.of<TimeData>(context, listen: false).saveNewWeeklyGoal(newGoal);
      _goal = newGoal;
    });
  }

  Future<void> setPercent() async {
    _percent = seconds / (_goal * 60);
    if (_percent > 1.0) _percent = 1.0;
  }

  Future<void> getWeeklyProgress() async {
    int totalTimeMS = 0;
    for (int i = 1; i <= 7; i++) {
      totalTimeMS += await LocalUser().loadRecordedTimeWeekday(i);
    }
    seconds = totalTimeMS ~/ 100;
  }

  void showAchievementPopup(BuildContext context) async {
    bool achievementPopupShown = await LocalUser.getGoalAchievementPopupShown();
    if (!achievementPopupShown && shouldShowAchievementPopup) {
      // ignore: use_build_context_synchronously
      ProgressBannerBar.show(
          context, 'Congrats! You have just passed an achievement!');
    }
    LocalUser.setGoalAchievementPopupShown(true);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController =
        TextEditingController(text: _goal.toString());
    final PageController pageController = PageController();

    return PageView(
      scrollDirection: Axis.vertical,
      controller: pageController,
      children: [
        // First page
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.white],
              ),
            ),
            child: ListView(
              children: [
               Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: const Color.fromARGB(255, 209, 209, 209),
                  ),
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.flag, size: 35, color: Colors.black,),
                            label: const Text(
                              'Set Goal',
                              textScaleFactor: 1.2,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Stack(
                                        children: <Widget>[
                                          Positioned(
                                            right: -40.0,
                                            top: -40.0,
                                            child: InkResponse(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const CircleAvatar(
                                                backgroundColor: Colors.red,
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                          ),
                                          Form(
                                            key: _formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Set your weekly goal.'),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    controller:
                                                        textEditingController,
                                                    validator: (value) {
                                                      if ((value != null ||
                                                              value!.isEmpty) &&
                                                          int.tryParse(value) !=
                                                              null) {
                                                        if (int.parse(value) <
                                                            1)
                                                          return 'Goal must be more than 0 minutes!';
                                                        return null;
                                                      }
                                                      return 'Requires a number without digits.';
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ElevatedButton(
                                                    child: const Text("Submit"),
                                                    onPressed: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        _formKey.currentState!
                                                            .save();
                                                        _saveNewWeeklyGoal(
                                                            int.parse(
                                                                textEditingController
                                                                    .text));
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                      showAchievementPopup(
                                                          context);
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                          ),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.emoji_events,
                                size: 35,
                                color: Color.fromARGB(255, 226, 171, 7),
                              ),
                              onPressed: () {
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Center(
                        child: Text(
                          'Weekly Progress',
                          textScaleFactor: 1.4,
                        ),
                      ),
                      Consumer<TimeData>(builder: (context, myData, child) {
                        return FutureBuilder(
                            future: setPercent(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: LinearPercentIndicator(
                                  width:
                                      MediaQuery.of(context).size.width - 50.0,
                                  animation: true,
                                  animationDuration: animateDuration,
                                  animateFromLastPercent: true,
                                  lineHeight: 25.0,
                                  percent: _percent,
                                  center: Text(
                                      '${(_percent * 100).toStringAsFixed(0)}%',
                                      textScaleFactor: 1.2),
                                  progressColor: Colors.green,
                                ),
                              );
                            });
                      }),
                      Center(
                        child: Consumer<TimeData>(
                            builder: (context, myData, child) {
                          return FutureBuilder(
                            future: getWeeklyProgress(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Text(
                                '${seconds ~/ 60} / $_goal minutes',
                                textScaleFactor: 1.2,
                              );
                            },
                          );
                        }),
                      ),
                      const ChartContainer(
                        title: 'Daily goal',
                        color: Color.fromARGB(255, 41, 128, 38),
                        chart: BarChartContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Second page
        const AchievementPage(),
      ],
    );
  }
}

class ActivityData {
  final String day;
  final int minutes;

  const ActivityData(this.day, this.minutes);
}
