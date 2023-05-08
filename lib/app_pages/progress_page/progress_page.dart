import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:urban_escape_application/database/time_data.dart';

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
  int minutes = 102;
  int _goal = 120;
  int animateDuration = 1000;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadWeeklyGoal();
  }

  void loadWeeklyGoal() async {

    _goal = await Provider.of<TimeData>(context, listen:false).loadWeeklyGoal();
  }

  void _saveNewWeeklyGoal(int newGoal) {

    setState(() {
      Provider.of<TimeData>(context, listen:false).saveNewWeeklyGoal(newGoal);
      _goal = newGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    double percent = minutes / _goal;
    if (percent > 1.0) percent = 1.0;
    final TextEditingController textEditingController = TextEditingController(text: _goal.toString());
    final PageController pageController = PageController();

    return PageView(
      scrollDirection: Axis.vertical,
      controller: pageController,
      children: [
        // First page
        Scaffold(
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 209, 209, 209),
                ),
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.flag, size: 35),
                          label: const Text(
                            'Set Goals', textScaleFactor: 1.2,
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
                                              child: Text('Set your weekly goal.'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: textEditingController,
                                                validator: (value) {
                                                  if ((value != null || value!.isEmpty) && int.tryParse(value) != null) {
                                                    if (int.parse(value) < 1) return 'Goal must be more than 0 minutes!';
                                                    return null;
                                                  } return 'Requires a number without digits.';
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                child: const Text("Submit"),
                                                onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    _formKey.currentState!.save();
                                                    _saveNewWeeklyGoal(int.parse(textEditingController.text));
                                                    Navigator.of(context).pop();
                                                  }
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
                            icon: const Icon(Icons.emoji_events, size: 35, color: Color.fromARGB(255, 226, 171, 7), ),
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
                        'Weekly Progress', textScaleFactor: 1.4,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 50.0,
                        animation: true,
                        animationDuration: animateDuration,
                        animateFromLastPercent: true,
                        lineHeight: 25.0,
                        percent: percent,
                        center: Text('${(percent * 100).toStringAsFixed(0)}%', textScaleFactor: 1.2),
                        progressColor: Colors.green,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$minutes / $_goal minutes', textScaleFactor: 1.2,
                      ),
                    ),
                    ChartContainer(
                      title: 'Daily goal',
                      color: const Color.fromARGB(255, 41, 128, 38),
                      chart: BarChartContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Second page
        AchievementPage(),
      ],
    ); 
  }
}

class ActivityData {
  final String day;
  final int minutes;

  const ActivityData(this.day, this.minutes);
}