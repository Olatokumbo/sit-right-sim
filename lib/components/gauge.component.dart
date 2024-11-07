import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauge extends StatelessWidget {
  final String title;
  final double value;
  const Gauge({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    showAxisLine: false,
                    showTicks: false,
                    startAngle: 180,
                    endAngle: 360,
                    maximum: 1,
                    canScaleToFit: true,
                    showLastLabel: true,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                          value: value,
                          needleLength: 0.7,
                          knobStyle: const KnobStyle())
                    ],
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0,
                          endValue: 18,
                          sizeUnit: GaugeSizeUnit.factor,
                          startWidth: 0,
                          endWidth: 0.05, //originally 0.1
                          color: const Color(0xFFA8AAE2)),
                      GaugeRange(
                          startValue: 20,
                          endValue: 38,
                          startWidth: 0.1,
                          sizeUnit: GaugeSizeUnit.factor,
                          endWidth: 0.15,
                          color: const Color.fromRGBO(168, 170, 226, 1)),
                      GaugeRange(
                          startValue: 40,
                          endValue: 58,
                          startWidth: 0.15,
                          sizeUnit: GaugeSizeUnit.factor,
                          endWidth: 0.2,
                          color: const Color(0xFF7B7DC7)),
                      GaugeRange(
                          startValue: 60,
                          endValue: 80,
                          startWidth: 0.2,
                          sizeUnit: GaugeSizeUnit.factor,
                          endWidth: 0.25,
                          color: const Color.fromRGBO(73, 76, 162, 1)),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
