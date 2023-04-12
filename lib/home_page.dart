import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60.0, right: 10.0, left: 10.0, bottom: 10.0),
            padding: const EdgeInsets.all(20.0),
            color: Colors.grey,
            width: double.infinity,
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Weekly Progress',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 90.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: 0.2,
                    center: const Text("20.0%"),
                    progressColor: Colors.green,
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
