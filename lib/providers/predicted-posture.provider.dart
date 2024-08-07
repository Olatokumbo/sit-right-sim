import 'package:flutter_riverpod/flutter_riverpod.dart';

final predictedPostureProvider = StateProvider<String>((ref) {
  return "No Posture Detected";
});
