import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Murojaah Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            barTouchData: BarTouchData(
              enabled: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const style = TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('Sen', style: style);
                        break;
                      case 1:
                        text = const Text('Sel', style: style);
                        break;
                      case 2:
                        text = const Text('Rab', style: style);
                        break;
                      case 3:
                        text = const Text('Kam', style: style);
                        break;
                      case 4:
                        text = const Text('Jum', style: style);
                        break;
                      case 5:
                        text = const Text('Sab', style: style);
                        break;
                      case 6:
                        text = const Text('Min', style: style);
                        break;
                      default:
                        text = const Text('', style: style);
                        break;
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 16.0,
                      child: text,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(toY: 8, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: 14, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 3, barRods: [
                BarChartRodData(toY: 15, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 4, barRods: [
                BarChartRodData(toY: 13, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 5, barRods: [
                BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
              ]),
              BarChartGroupData(x: 6, barRods: [
                BarChartRodData(toY: 16, color: Colors.lightBlueAccent)
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
