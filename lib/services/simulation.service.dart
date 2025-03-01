import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums.dart';
import '../providers/simulation.provider.dart';

// Define a class to represent a posture period in the simulation
class PosturePeriod {
  final String posture;
  final Duration duration;

  PosturePeriod({required this.posture, required this.duration});
}

// Simulation Service class
class SimulationService {
  Timer? _timer;
  Timer? _postureTimer;
  DateTime? _simulationStartTime;
  // ignore: unused_field
  DateTime? _pauseTime;
  Duration _accumulatedTime = Duration.zero;
  Function(String)? _onPostureChange;

  // Use a late variable for the ref so it can be set after construction
  late WidgetRef _ref;

  // Constructor without ref parameter
  SimulationService();

  // Method to set the ref after construction
  void setRef(WidgetRef ref) {
    _ref = ref;
  }

  // Set the callback function for posture changes
  void setPostureChangeCallback(Function(String) callback) {
    _onPostureChange = callback;
  }

  // Create a simulation plan
  void createSimulationPlan(List<PosturePeriod> plan) {
    _ref.read(simulationPlanProvider.notifier).state = plan;
    _ref.read(simulationPositionProvider.notifier).state = 0;
    _ref.read(simulationElapsedTimeProvider.notifier).state = Duration.zero;
    _accumulatedTime = Duration.zero;
  }

  // Start the simulation
  void startSimulation() {
    if (_ref.read(simulationStatusProvider) == SimulationStatus.running) {
      return;
    }

    final plan = _ref.read(simulationPlanProvider);
    if (plan.isEmpty) {
      return;
    }

    if (_ref.read(simulationStatusProvider) == SimulationStatus.paused) {
      // Resume the simulation - start fresh from current accumulated time
      _simulationStartTime = DateTime.now();
      _ref.read(simulationStatusProvider.notifier).state =
          SimulationStatus.running;

      // Continue with the current posture
      final position = _ref.read(simulationPositionProvider);

      if (position < plan.length) {
        final elapsedTime = _ref.read(simulationElapsedTimeProvider);
        final currentPeriod = plan[position];

        // Calculate remaining time for current posture
        var postureTotalTime = Duration.zero;
        for (int i = 0; i < position; i++) {
          postureTotalTime += plan[i].duration;
        }

        final postureElapsedTime = elapsedTime - postureTotalTime;
        final remainingTime = currentPeriod.duration - postureElapsedTime;

        if (remainingTime > Duration.zero) {
          _scheduleNextPosture(remainingTime);
        } else {
          // Move to the next posture immediately
          _advanceToNextPosture();
        }
      }
    } else {
      // Start a new simulation
      _accumulatedTime = Duration.zero;
      _startNewSimulation(plan);
    }

    // Start or restart the timer to update elapsed time every second
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsedTime();
    });
  }

  // Helper method to start a new simulation
  void _startNewSimulation(List<PosturePeriod> plan) {
    _simulationStartTime = DateTime.now();
    _ref.read(simulationStatusProvider.notifier).state =
        SimulationStatus.running;
    _ref.read(simulationPositionProvider.notifier).state = 0;
    _ref.read(simulationElapsedTimeProvider.notifier).state = Duration.zero;
    _accumulatedTime = Duration.zero;

    // Trigger the first posture
    if (plan.isNotEmpty) {
      _triggerPostureChange(plan[0].posture);

      // Schedule next posture change
      _scheduleNextPosture(plan[0].duration);
    }
  }

  // Pause the simulation
  void pauseSimulation() {
    if (_ref.read(simulationStatusProvider) != SimulationStatus.running) {
      return;
    }

    _pauseTime = DateTime.now();
    _ref.read(simulationStatusProvider.notifier).state =
        SimulationStatus.paused;

    // Cancel timers but keep track of elapsed time
    _timer?.cancel();
    _postureTimer?.cancel();

    // Store current elapsed time
    if (_simulationStartTime != null) {
      final currentElapsed = _ref.read(simulationElapsedTimeProvider);
      _accumulatedTime = currentElapsed;
    }
  }

  // Stop the simulation
  void stopSimulation() {
    _timer?.cancel();
    _postureTimer?.cancel();
    _ref.read(simulationStatusProvider.notifier).state = SimulationStatus.idle;
    _ref.read(simulationPositionProvider.notifier).state = 0;
    _ref.read(simulationElapsedTimeProvider.notifier).state = Duration.zero;
    _accumulatedTime = Duration.zero;
    _simulationStartTime = null;
    _pauseTime = null;
  }

  // Update elapsed time
  void _updateElapsedTime() {
    if (_ref.read(simulationStatusProvider) != SimulationStatus.running ||
        _simulationStartTime == null) {
      return;
    }

    final now = DateTime.now();
    final elapsedSinceStart = now.difference(_simulationStartTime!);
    final totalElapsed = _accumulatedTime + elapsedSinceStart;

    _ref.read(simulationElapsedTimeProvider.notifier).state = totalElapsed;

    final totalDuration = _ref.read(simulationTotalDurationProvider);
    if (totalElapsed >= totalDuration) {
      _completeSimulation();
    }
  }

  // Schedule the next posture change
  void _scheduleNextPosture(Duration duration) {
    _postureTimer?.cancel();
    _postureTimer = Timer(duration, _advanceToNextPosture);
  }

  // Advance to the next posture
  void _advanceToNextPosture() {
    final plan = _ref.read(simulationPlanProvider);
    final currentPosition = _ref.read(simulationPositionProvider);

    if (currentPosition + 1 < plan.length) {
      final nextPosition = currentPosition + 1;
      final nextPosture = plan[nextPosition].posture;

      _ref.read(simulationPositionProvider.notifier).state = nextPosition;
      _triggerPostureChange(nextPosture);

      _scheduleNextPosture(plan[nextPosition].duration);
    } else {
      _completeSimulation();
    }
  }

  // Trigger posture change callback
  void _triggerPostureChange(String posture) {
    if (_onPostureChange != null) {
      _onPostureChange!(posture);
    }
  }

  // Complete the simulation
  void _completeSimulation() {
    _timer?.cancel();
    _postureTimer?.cancel();
    _ref.read(simulationStatusProvider.notifier).state =
        SimulationStatus.completed;
  }

  // Clean up resources
  void dispose() {
    _timer?.cancel();
    _postureTimer?.cancel();
  }
}
