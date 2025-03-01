import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';

final postureStatisticsProvider = StateProvider<List<PostureStatistics>>((ref) {
  return [];
});
