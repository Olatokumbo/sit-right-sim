import 'package:sit_right_app/models/sitting-quality.model.dart';
import 'package:sit_right_app/utils.dart';

class SittingQualityService {
  double overallQuality = 100;
  List<SittingQuality> data = [];

  // Define a threshold duration in seconds
  final double durationThreshold = 300; // 5 minutes threshold

  void calculate(String posture, DateTime start, DateTime end) {
    double postureScore = getScoreByPosture(posture);
    double normalPostureScore = getScoreByPosture("Upright");

    double deviationValue = (postureScore - normalPostureScore).abs();
    double duration = end.difference(start).inSeconds.toDouble();

    // Base decay rate
    double decayRate = 0.05;
    double qualityDecay = decayRate * duration;

    // Adjust the quality impact based on posture and duration
    double qualityScoreImpact;
    if (deviationValue == 0.0) {
      if (duration >= durationThreshold) {
        // Decay for prolonged good posture
        qualityScoreImpact = -decayRate * (duration - durationThreshold);
      } else {
        // Reward good posture, no decay yet
        qualityScoreImpact = 0.5 * duration - qualityDecay;
      }
    } else {
      // Larger impact for non-upright postures
      qualityScoreImpact = -deviationValue * duration - qualityDecay;
    }

    // Apply the quality score impact
    overallQuality += qualityScoreImpact;

    // Ensure overallQuality remains within bounds [0, 100]
    overallQuality = overallQuality.clamp(0, 100);

    // Log the quality change at the current time
    data.add(SittingQuality(overallQuality, DateTime.now()));
  }
}
