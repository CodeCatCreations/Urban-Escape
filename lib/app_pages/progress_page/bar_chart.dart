import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/progress_page/chart_container.dart';

class BarChartContent extends StatelessWidget {

  final List<BarChartGroupData> barChartGroupData = [
  BarChartGroupData(x: 1, barRods: [
    BarChartRodData(toY: 10, color: Color(0xFF9E9E9E)),
  ]),
   BarChartGroupData(x: 2, barRods: [
    BarChartRodData(toY: 8.5, color: Color(0xFF9E9E9E)),
  ]),
   BarChartGroupData(x: 3, barRods: [
    BarChartRodData(toY: 12.6, color: Color(0xFF26DD2F)),
  ]),
   BarChartGroupData(x: 4, barRods: [
    BarChartRodData(toY: 11.4, color: Color(0xFF26DD2F)),
  ]),
   BarChartGroupData(x: 5, barRods: [
    BarChartRodData(toY: 7.5, color: Color(0xFF9E9E9E)),
  ]),
  BarChartGroupData(x: 6, barRods: [
    BarChartRodData(toY: 14, color: Color(0xFF26DD2F)),
  ]),
   BarChartGroupData(x: 7, barRods: [
    BarChartRodData(toY: 12.2, color: Color(0xFF26DD2F), borderRadius: const BorderRadius.vertical(top: Radius.circular(2)), width: 20),
  ]),
];

  BarChartContent({super.key});

  
  
  @override
  Widget build (BuildContext context) {
    BarChart chart = BarChart(
      BarChartData(
        barGroups: barChartGroupData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                switch (value.toInt()) {
                  case 1:
                    return const Text('Mon');
                  case 2:
                    return const Text('Tues');
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
          leftTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        backgroundColor: const Color.fromARGB(255, 37, 109, 37),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(strokeWidth: 1);
          },
        ),
      ),
    );

    /*
    return Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: chart
          ),
        ); */

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45, // set a fixed height for the chart
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: barChartGroupData.length,
        itemBuilder: (context, index) {
          return Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.only(top: 10),
              child: chart
            ),
          );
        }
      )
    );
  } 
}