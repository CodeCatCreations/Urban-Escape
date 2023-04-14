import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);
  
  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  int minutes = 102;
  int goal = 120;
  int animateDuration = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flag),
                      onPressed: () {
                        setState(() {
                          goal += 1;
                          animateDuration = 0;
                        });
                      },
                    ),
                    const Text(
                      'Set Goals',
                    ),
                  ],
                ),
                
                const Center(
                  child: Text(
                    'Weekly Progress',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 50.0,
                    animation: true,
                    animationDuration: animateDuration,
                    lineHeight: 20.0,
                    percent: minutes / goal,
                    center: Text((minutes * 100 ~/ goal).toString() + '%'),
                    progressColor: Colors.green,
                  ),
                ),
                Center(
                  child: Text(
                    '$minutes / $goal minutes',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityData {
  final String day;
  final int minutes;

  const ActivityData(this.day, this.minutes);
}