import 'package:flutter_riverpod/flutter_riverpod.dart';

final hausdorffDistanceProvider = StateProvider<Map<String, double>>((ref) {
  return {
    "backrest": 0,
    "seat": 0,
  };
});
