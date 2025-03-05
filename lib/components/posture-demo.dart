import 'package:flutter/material.dart';
import 'package:sit_right_app/utils.dart';

class PostureDemo extends StatelessWidget {
  const PostureDemo({super.key, required this.predictedPosture});

  final String predictedPosture;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            "./assets/demo-${findPosture(predictedPosture)}.png",
            height: 400,
          ),
        )
      ],
    );
  }
}
