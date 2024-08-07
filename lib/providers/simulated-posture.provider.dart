import 'package:flutter_riverpod/flutter_riverpod.dart';

final simulatedPostureProvider = StateProvider<String>((ref) {
  return 'upright';
});
