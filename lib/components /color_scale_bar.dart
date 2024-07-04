import 'package:flutter/material.dart';

class ColorScaleBar extends StatelessWidget {
  final double width;
  final double height;

  const ColorScaleBar({
    Key? key,
    this.width = 25.0,
    this.height = 200.0,
  }) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0', style: TextStyle(color: Colors.grey)),
              SizedBox(height: height / 3),
              const Text('0.5', style: TextStyle(color: Colors.grey)),
              SizedBox(height: height / 3),
              const Text('1', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(100, (index) {
                double value = index / 99;
                return Expanded(
                  child: Container(
                    color: _getColorFromValue(value),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
