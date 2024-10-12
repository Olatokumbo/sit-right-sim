import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          child: SvgPicture.asset(
            "./assets/${findPosture(predictedPosture)}.svg",
            height: 170,
            colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
          ),
        )
      ],
    );
  }
}
