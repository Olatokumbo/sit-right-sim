import 'dart:math';
import 'package:sit_right_app/postures/back_leaning_posture.dart';
import 'package:sit_right_app/postures/left_leaning_posture.dart';
import 'package:sit_right_app/postures/right_leaning_posture.dart';
import 'package:sit_right_app/postures/slouching_posture.dart';
import 'package:sit_right_app/postures/upright_posture.dart';

class PostureService {
  Map<String, List<List<double>>> get(String posture, int gridSize) {
    int randomNumber = Random().nextInt(99);
    switch (posture) {
      case "upright":
        return upright[randomNumber];
      case "slouching":
        return slouching[randomNumber];
      case "leftLeaning":
        return left_leaning[randomNumber];
      case "rightLeaning":
        return right_leaning[randomNumber];
      case "backLeaning":
        return back_leaning[randomNumber];
      default:
        return {"backrest": [], "seat": []};
    }
  }
}
