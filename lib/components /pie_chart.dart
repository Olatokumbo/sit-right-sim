import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/postureStats.dart';

class StatisticsPieChart extends StatelessWidget {
  final List<PostureStatistics> data;

  const StatisticsPieChart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: data.map((postureStats) {
                return PieChartSectionData(
                  color: Colors.primaries[
                      data.indexOf(postureStats) % Colors.primaries.length],
                  value: postureStats.duration.inSeconds.toDouble(),
                  title: postureStats.posture,
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
