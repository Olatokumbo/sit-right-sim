import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums.dart';
import '../services/simulation.service.dart';

final simulationSpeedProvider = StateProvider<double>((ref) => 1.0);
final simulationStatusProvider =
    StateProvider<SimulationStatus>((ref) => SimulationStatus.idle);
final simulationPlanProvider = StateProvider<List<PosturePeriod>>((ref) => []);
final simulationPositionProvider = StateProvider<int>((ref) => 0);
final simulationElapsedTimeProvider =
    StateProvider<Duration>((ref) => Duration.zero);
final simulationTotalDurationProvider = StateProvider<Duration>((ref) {
  final plan = ref.watch(simulationPlanProvider);
  return plan.fold(Duration.zero, (total, period) => total + period.duration);
});
final simulationCurrentPostureProvider = StateProvider<String>((ref) {
  final plan = ref.watch(simulationPlanProvider);
  final position = ref.watch(simulationPositionProvider);

  if (plan.isEmpty) {
    return "upright"; // Default posture
  }

  if (position < plan.length) {
    return plan[position].posture;
  } else {
    return plan.last.posture;
  }
});

// Create a provider for the SimulationService to ensure we have a single instance
final simulationServiceProvider = Provider<SimulationService>((ref) {
  // Create a service with a dummy ref first - we'll set the real ref when used
  final service = SimulationService();
  ref.onDispose(() => service.dispose());
  return service;
});
