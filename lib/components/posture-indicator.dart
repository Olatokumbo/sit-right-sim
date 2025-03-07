import 'package:flutter/material.dart';
import 'package:sit_right_app/utils.dart';

class PostureIndicator extends StatelessWidget {
  const PostureIndicator({
    super.key,
    required this.predictedPosture,
  });

  final String predictedPosture;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          predictedPosture,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            "./assets/${findPosture(predictedPosture)}.png",
            height: 170,
          ),
        )
      ],
    );
  }
}
