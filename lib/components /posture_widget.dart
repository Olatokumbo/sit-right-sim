import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PostureWidget extends StatelessWidget {
  const PostureWidget({
    super.key,
    required this.predictedPosture,
  });

  final String predictedPosture;

  findPosture(String predictedPosture) {
    switch (predictedPosture) {
      case "Upright":
        return 'upright';
      case "Slouching":
        return "slouching";
      case "Leaning Left":
        return "leftLeaning";
      case "Leaning Right":
        return "rightLeaning";
      case "Leaning Back":
        return "leaningBack";
      default:
        return "empty";
    }
  }

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
            color: Colors.amber,
          ),
        )
      ],
    );
  }
}
