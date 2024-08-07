import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorDataProvider =
    StateProvider<Map<String, List<List<double>>>>((ref) {
  return {
    "backrest": List.generate(5, (index) => List.filled(5, 0.0)),
    "seat": List.generate(5, (index) => List.filled(5, 0.0)),
  };
});
