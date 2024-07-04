import 'package:flutter/material.dart';

import 'color_scale_bar.dart';

class TimeStampedSensorValues {
  final DateTime timestamp;
  final List<List<double>> sensorValues;

  TimeStampedSensorValues({
    required this.timestamp,
    required this.sensorValues,
  });
}

class SensorArray extends StatefulWidget {
  final int rows;
  final int cols;
  final double sensorSize;
  final bool showNumbers;
  final List<List<double>> sensorValues;

  const SensorArray({
    super.key,
    required this.rows,
    required this.cols,
    required this.sensorValues,
    this.sensorSize = 20.0,
    this.showNumbers = false,
  });

  @override
  _SensorArrayState createState() => _SensorArrayState();
}

class _SensorArrayState extends State<SensorArray> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getColorFromValue(double value) {
    value = value.clamp(0.0, 1.0); // Ensure value is between 0 and 1
    if (value < 0.5) {
      // Interpolate between blue and yellow
      return Color.lerp(Colors.blue, Colors.yellow, value * 2)!;
    } else {
      // Interpolate between yellow and red
      return Color.lerp(Colors.yellow, Colors.red, (value - 0.5) * 2)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorScaleBar(
            height: widget.cols * widget.sensorSize + (widget.cols - 1) * 2,
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 1, 26, 28),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(widget.sensorSize / 1.5),
            constraints: BoxConstraints(
              maxWidth: widget.cols * widget.sensorSize +
                  (widget.cols - 1) * 2, // 2 is the margin
              maxHeight: widget.rows * widget.sensorSize +
                  (widget.rows - 1) * 2, // 2 is the margin
            ),
            child: GridView.builder(
              itemCount: widget.rows * widget.cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.cols,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ widget.cols;
                int col = index % widget.cols;
                double sensorValue = widget.sensorValues[row][col];
                sensorValue = sensorValue > 1.0 ? 1.0 : sensorValue;
                return Container(
                  margin: const EdgeInsets.all(1.0),
                  width: widget.sensorSize,
                  height: widget.sensorSize,
                  decoration: BoxDecoration(
                    color: _getColorFromValue(
                        sensorValue), // Use color based on sensor value
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: widget.showNumbers
                        ? Text(
                            '$row,$col\n${sensorValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: widget.sensorSize / 3,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
