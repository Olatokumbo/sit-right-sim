import 'package:flutter/material.dart';
import 'color-scalebar.component.dart';

class SensorArray extends StatefulWidget {
  final int rows;
  final int cols;
  final double sensorSize;
  final bool showNumbers;
  final List<List<double>> sensorValues;
  final bool flipHorizontal;

  const SensorArray({
    super.key,
    required this.rows,
    required this.cols,
    required this.sensorValues,
    this.sensorSize = 20.0,
    this.showNumbers = false,
    this.flipHorizontal = false,
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
    // Clamp value to the range of 0 to 255
    value = value.clamp(0, 255);

    // Normalize the value to a range of 0.0 to 1.0
    double normalizedValue = value / 255.0;

    if (normalizedValue < 0.5) {
      // Interpolate between blue and yellow
      return Color.lerp(Colors.blue, Colors.yellow, normalizedValue * 25)!;
    } else {
      // Interpolate between yellow and red
      return Color.lerp(
          Colors.yellow, Colors.red, (normalizedValue - 0.5) * 25)!;
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
              height: widget.cols * widget.sensorSize + (widget.cols - 1) * 1.2,
            ),
            widget.flipHorizontal
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(1.0, 1.0, 1.0),
                    child: _buildSensorGrid(),
                  )
                : _buildSensorGrid(),
          ]),
    );
  }

  Widget _buildSensorGrid() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(widget.sensorSize / 1.5),
      constraints: BoxConstraints(
        maxWidth: widget.cols * widget.sensorSize +
            (widget.cols - 1) * 1, // 2 is the margin
        maxHeight: widget.rows * widget.sensorSize +
            (widget.rows - 1) * 1, // 2 is the margin
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
          int col = widget.flipHorizontal
              ? (widget.cols - 1) -
                  (index % widget.cols) // Reverse column order
              : index % widget.cols;
          double sensorValue = widget.sensorValues[row][col];
          sensorValue = sensorValue > 255.0 ? 255.0 : sensorValue;
          return Container(
            margin: const EdgeInsets.all(1.0),
            width: widget.sensorSize,
            height: widget.sensorSize,
            decoration: BoxDecoration(
              color: _getColorFromValue(sensorValue),
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
    );
  }
}
