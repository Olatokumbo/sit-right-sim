import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/postureStats.dart';
import 'package:sit_right_app/utils.dart';

class BarChartWidget extends StatelessWidget {
  final List<PostureStatistics> statistics;

  const BarChartWidget(this.statistics, {super.key});

  @override
  Widget build(BuildContext context) {
    double maxY = _getMaxY(statistics);

    return Column(children: [
      Expanded(
        flex: 1,
        child: Card(
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
                      minY: -0.5,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              DateTime startTime = DateTime.now().subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute));
                              DateTime time = startTime.add(Duration(minutes: value.toInt()));
                              return Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Text(
                                  _formatTime(time),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                            interval: 60, // Display time labels every hour
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  "${(value / 1000000).toStringAsFixed(0)} sec",
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
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          "Upright",
          "Leaning Back",
          "Leaning Left",
          "Leaning Right",
          "Slouching"
        ].map((posture) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                Container(
                    width: 20, height: 20, color: getColorByPosture(posture)),
                const SizedBox(
                    width: 10), // Add some space between the box and the text
                Text(posture),
              ],
            ),
          );
        }).toList(),
      )
    ]);
  }

  List<BarChartGroupData> _createBarGroups(List<PostureStatistics> statistics) {
    DateTime startTime = DateTime.now().subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute)); // Start at midnight

    // Aggregate data
    Map<String, Map<int, double>> aggregatedData = {};
    for (var stat in statistics) {
      int startMinute = stat.startTime.difference(startTime).inMinutes;
      int endMinute = stat.endTime.difference(startTime).inMinutes;
      String posture = stat.posture;

      if (!aggregatedData.containsKey(posture)) {
        aggregatedData[posture] = {};
      }

      for (int minute = startMinute; minute <= endMinute; minute++) {
        aggregatedData[posture]![minute] = (aggregatedData[posture]![minute] ?? 0) + 1;
      }
    }

    // Create bar groups from aggregated data
    List<BarChartGroupData> barGroups = [];
    aggregatedData.forEach((posture, data) {
      data.forEach((minute, duration) {
        barGroups.add(
          BarChartGroupData(
            x: minute,
            barRods: [
              BarChartRodData(
                toY: duration,
                color: getColorByPosture(posture),
                width: 16,
              ),
            ],
          ),
        );
      });
    });

    return barGroups;
  }

  double _getMaxY(List<PostureStatistics> statistics) {
    if (statistics.isEmpty) {
      return 0.0;
    }
    double maxTime = statistics
        .map(
          (stat) => stat.endTime.difference(stat.startTime).inMicroseconds.toDouble(),
        )
        .reduce((a, b) => a > b ? a : b);
    return maxTime * 1.1;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}