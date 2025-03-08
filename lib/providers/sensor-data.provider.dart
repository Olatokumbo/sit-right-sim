import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/postures/empty_posture.dart';

final sensorDataProvider =
    StateProvider<Map<String, List<List<double>>>>((ref) {
  List<List<double>> backrest = empty[0]["backrest"]!;
  List<List<double>> seat = empty[0]["seat"]!;

  return {"backrest": backrest, "seat": seat};
});
