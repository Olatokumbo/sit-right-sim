import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';
import 'package:sit_right_app/utils.dart';

class SittingStatisticsChart extends StatelessWidget {
  final List<PostureStatistics> data;

  const SittingStatisticsChart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: groupPosture(data).map((postureStats) {
                return PieChartSectionData(
                  color: getColorByPosture(postureStats.posture),
                  value: postureStats.duration.toDouble(),
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
