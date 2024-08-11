import 'package:sit_right_app/models/sitting-quality.model.dart';
import 'package:sit_right_app/utils.dart';

class SittingQualityService {
  double overallQuality = 100;
  List<SittingQuality> data = [];

  void calculate(String posture, DateTime start, DateTime end) {
    double postureScore = getScoreByPosture(posture);
    double normalPostureScore = getScoreByPosture("Upright");

    double deviationValue = (postureScore - normalPostureScore).abs();
    double duration = end.difference(start).inSeconds.toDouble();

    double qualityScoreImpact = deviationValue * duration;

    if (deviationValue == 0.0) {
      overallQuality += 0.5 * duration; // Small increase for good posture
    } else {
      overallQuality -= qualityScoreImpact;
    }

    // Ensure overallQuality remains within bounds [0, 100]
    overallQuality = overallQuality.clamp(0, 100);

    print("<>?<> $overallQuality");

    data.add(SittingQuality(overallQuality, DateTime.now()));

    // print(overallQuality);
  }
}
