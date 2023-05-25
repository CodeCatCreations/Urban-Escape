import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';

import '../../database/local_user.dart';
import '../../database/time_data.dart';

class BarChartContent extends StatefulWidget {
  const BarChartContent({super.key});

  @override
  State<BarChartContent> createState() => _BarChartContentState();
}

class _BarChartContentState extends State<BarChartContent> {

  static const int secondsUntilDisplayedAsMinutes = 240;

  List<BarChartGroupData> barChartData = [];

  double maxBarHeight = 1.0;
  double dailyGoal = 1.0;
  bool showAsMinutes = false;

  Future<void> fetchData(BuildContext context) async {
    List<BarChartGroupData> data = [];
    dailyGoal = await LocalUser.loadWeeklyGoal() / 7.0;
    if (dailyGoal == 0) {
      dailyGoal = 120 / 7.0;
    }
    dailyGoal *= 60;
    maxBarHeight = dailyGoal;
    for (int i = 1; i <= 7; i++) {
      double timeSpent = (await LocalUser().loadRecordedTimeWeekday(i)) / 100;
      Color color = const Color(0xFF9E9E9E);
      if (timeSpent > dailyGoal) {
        color = const Color(0xFF51C057);
        showAchievementPopup(context);
        if (timeSpent * 1.1 > maxBarHeight) {
          maxBarHeight = timeSpent * 1.1;
        }
      }
      data.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: timeSpent,
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            width: 15,
          ),
        ])
      );
    }
    if (maxBarHeight >= secondsUntilDisplayedAsMinutes) {
      showAsMinutes = true;
    } else {
      showAsMinutes = false;
    }
    barChartData = data;
  }

  void showAchievementPopup(BuildContext context) async {
    bool achievementPopupShown = await LocalUser.getGoalReacherAchievementPopupShown();
    if (!achievementPopupShown) {
      // ignore: use_build_context_synchronously
      ProgressBannerBar.show(
          context, 'Congrats! You have just passed an achievement!');
    }
    LocalUser.setGoalReacherAchievementPopupShown(true);
  }

  @override
  Widget build(BuildContext context) {
    Consumer<TimeData> chart =
        Consumer<TimeData>(builder: (context, myData, child) {
          return FutureBuilder(
            future: fetchData(context),
            builder: (context, _) {
            return BarChart(
              BarChartData(
                maxY: maxBarHeight,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black,
                    tooltipPadding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      int time = barChartData[groupIndex].barRods[rodIndex].toY.floor();
                      String text = "";
                      if (time >= 60) {
                        text = "${(time ~/ 60).toStringAsFixed(0)} minutes ";
                      }
                      text += "${(time % 60).toStringAsFixed(0)} seconds";
                      return BarTooltipItem(text, TextStyle(
                        color: Colors.white,
                      ));
                    },
                  ),
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
                    axisNameWidget: Text(showAsMinutes ? "Minutes" : "Seconds"),
                    sideTitles: SideTitles(
                      reservedSize: 26,
                      getTitlesWidget: (value, _) {
                        if (showAsMinutes) {
                          value /= 60;
                        }
                        return SideTitleWidget(
                          space: 2,
                          axisSide: AxisSide.left,
                          child: Text(value.toStringAsFixed(0)),
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
      width: MediaQuery.of(context).size.width * 0.9,
      child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height *0.7,
          padding: const EdgeInsets.fromLTRB(0, 10, 36, 0),
          child: chart
      ),
    );
  }
}
