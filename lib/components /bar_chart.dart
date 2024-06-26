import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/postureStats.dart';

class BarChartWidget extends StatelessWidget {
  final List<PostureStatistics> statistics;

  const BarChartWidget(this.statistics, {super.key});

  @override
  Widget build(BuildContext context) {
    final nonZeroStatistics =
        statistics.where((stat) => stat.duration.inSeconds > 0).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nonZeroStatistics.isEmpty
            ? const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(nonZeroStatistics),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= nonZeroStatistics.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Text(nonZeroStatistics[index].posture),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _createBarGroups(nonZeroStatistics),
                ),
              ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(
      List<PostureStatistics> nonZeroStatistics) {
    return nonZeroStatistics.asMap().entries.map((entry) {
      int index = entry.key;
      PostureStatistics stat = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.duration.inSeconds.toDouble(),
            // colors: [Colors.blue],
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(List<PostureStatistics> nonZeroStatistics) {
    if (nonZeroStatistics.isEmpty) {
      return 0.0;
    }
    double maxDuration = nonZeroStatistics
        .map((stat) => stat.duration.inSeconds.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return maxDuration * 1.1; // Adding some space on top of the highest bar
  }
}
