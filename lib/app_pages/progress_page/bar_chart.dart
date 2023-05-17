import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/local_user.dart';
import '../../database/time_data.dart';

class BarChartContent extends StatefulWidget {
  const BarChartContent({super.key});

  @override
  State<BarChartContent> createState() => _BarChartContentState();
}

class _BarChartContentState extends State<BarChartContent> {

  List<BarChartGroupData> barChartData = [];

  double maxBarHeight = 1.0;
  double dailyGoal = 1.0;

  Future<void> fetchData() async {
    List<BarChartGroupData> data = [];
    dailyGoal = await LocalUser.loadWeeklyGoal() / 7.0;
    if (dailyGoal == 0) {
      dailyGoal = 120 / 7.0;
    }
    maxBarHeight = dailyGoal;
    for (int i = 1; i <= 7; i++) {
      double minutesSpent = (await LocalUser().loadRecordedTimeWeekday(i)) / 6000.0;
      Color color = const Color(0xFF9E9E9E);
      if (minutesSpent > dailyGoal) {
        color = const Color(0xFF51C057);
        if (minutesSpent * 1.1 > maxBarHeight) {
          maxBarHeight = minutesSpent * 1.1;
        }
      }
      data.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: minutesSpent,
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            width: 15,
          ),
        ])
      );
    }
    barChartData = data;
  }

  @override
  Widget build(BuildContext context) {
    Consumer<TimeData> chart =
        Consumer<TimeData>(builder: (context, myData, child) {
          return FutureBuilder(
            future: fetchData(),
            builder: (context, _) {
            return BarChart(
              BarChartData(
                maxY: maxBarHeight,
                barTouchData: BarTouchData(
                  enabled: false
                ),
                barGroups: barChartData,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 1:
                            return const Text('Mon');
                          case 2:
                            return const Text('Tue');
                          case 3:
                            return const Text('Wed');
                          case 4:
                            return const Text('Thu');
                          case 5:
                            return const Text('Fri');
                          case 6:
                            return const Text('Sat');
                          case 7:
                            return const Text('Sun');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text("Minutes"),
                    sideTitles: SideTitles(
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        int digits = 1;
                        if (maxBarHeight >= 10) digits = 0;
                        return SideTitleWidget(
                          space: 2,
                          axisSide: AxisSide.left,
                          child: Text(value.toStringAsFixed(digits)),
                        );
                      },
                      showTitles: true,
                      interval: maxBarHeight / 4,
                    ),
                    drawBehindEverything: false,
                  ),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                ),
                backgroundColor: Colors.black38,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: dailyGoal,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(strokeWidth: 1);
                  },
                  checkToShowHorizontalLine: (value) {
                    if (value != dailyGoal) return false;
                    return true;
                  },
                ),
              ),
            );
          });
    });


    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.45, // set a fixed height for the chart
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView.builder(
        reverse:true,
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height *0.7,
              padding: const EdgeInsets.only(top: 10),
              child: chart);
        },
      ),
    );
  }
}
