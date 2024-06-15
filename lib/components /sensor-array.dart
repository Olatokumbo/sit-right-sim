import 'package:flutter/material.dart';

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
    Key? key,
    required this.rows,
    required this.cols,
    required this.sensorValues,
    this.sensorSize = 20.0,
    this.showNumbers = false,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 1, 26, 28),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(widget.sensorSize / 2),
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
            return Container(
              margin: const EdgeInsets.all(2.0),
              width: widget.sensorSize,
              height: widget.sensorSize,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(
                    sensorValue), // Adjust opacity based on sensor value
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
    );
  }
}
