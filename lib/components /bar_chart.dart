import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/postureStats.dart';
import 'package:sit_right_app/utils.dart';

class BarChartWidget extends StatelessWidget {
  final List<PostureStatistics> statistics;

  const BarChartWidget(this.statistics, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate maximum duration for scaling
    double maxY = _getMaxY(statistics);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: statistics.isEmpty
            ? const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= statistics.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Text(statistics[index].posture),
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
                  barGroups: _createBarGroups(statistics),
                ),
              ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<PostureStatistics> statistics) {
    return statistics.asMap().entries.map((entry) {
      int index = entry.key;
      PostureStatistics stat = entry.value;
      Color barColor = getColorByPosture(stat.posture);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.endTime.difference(stat.startTime).inSeconds.toDouble(),
            color: barColor,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(List<PostureStatistics> statistics) {
    if (statistics.isEmpty) {
      return 0.0;
    }
    double maxTime = statistics
        .map(
          (stat) =>
              stat.endTime.difference(stat.startTime).inSeconds.toDouble(),
        )
        .reduce((a, b) => a > b ? a : b);
    return maxTime * 1.1; // Adding some space on top of the highest bar
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
