import 'package:sit_right_app/models/sitting-quality.model.dart';
import 'package:sit_right_app/utils.dart';

class SittingQualityService {
  double quality = 1;
  String? currentPosture;
  DateTime? postureStartTime;
  List<SittingQuality> data = [];
  final double durationThreshold = 10; // 5 minutes threshold

  void calculate(String posture, DateTime start, DateTime end) {
    if (currentPosture == null || currentPosture != posture) {
      currentPosture = posture;
      postureStartTime = DateTime.now();
    }
    double postureScore = getScoreByPosture(posture);
    double normalPostureScore = getScoreByPosture("Upright");

    double deviationValue = (postureScore - normalPostureScore).abs();
    double duration = end.difference(postureStartTime!).inSeconds.toDouble();
    double constant = 10;
    double slope = deviationValue == 0.0 ? 1 : 0;

    var beta = (constant * deviationValue + slope);

    var qqQuality = 1 / (1 + deviationValue + beta * duration);

    quality = qqQuality;

    // Log the quality change at the current time
    data.add(SittingQuality(quality, DateTime.now()));
  }
}
