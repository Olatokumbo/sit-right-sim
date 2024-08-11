import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';
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
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              DateTime startTime = DateTime.now()
                                  .subtract(const Duration(hours: 2));
                              DateTime time = startTime
                                  .add(Duration(minutes: value.toInt()));
                              return Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Text(
                                  _formatTime(time),
                                  style: const TextStyle(fontSize: 10),
                                ),
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
                                  (value / 1000000).toStringAsFixed(0),
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
    DateTime startTime = DateTime.now().subtract(const Duration(hours: 2));

    return statistics.map((stat) {
      int x = stat.startTime.difference(startTime).inMinutes;
      Color barColor = getColorByPosture(stat.posture);

      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: stat.endTime
                .difference(stat.startTime)
                .inMicroseconds
                .toDouble(),
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
              stat.endTime.difference(stat.startTime).inMicroseconds.toDouble(),
        )
        .reduce((a, b) => a > b ? a : b);
    return maxTime * 1.1;
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
