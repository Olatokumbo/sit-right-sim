// simulation-control.component.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/components/card.component.dart';
import 'package:sit_right_app/services/simulation.service.dart';
import '../enums.dart';
import '../providers/simulation.provider.dart';
import 'simulation-planner.component.dart';

class SimulationControlPanel extends ConsumerWidget {
  final Function(String) onPostureChange;

  const SimulationControlPanel({Key? key, required this.onPostureChange})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(simulationStatusProvider);
    final plan = ref.watch(simulationPlanProvider);
    final position = ref.watch(simulationPositionProvider);
    final elapsedTime = ref.watch(simulationElapsedTimeProvider);
    final totalDuration = ref.watch(simulationTotalDurationProvider);
    final simulationService = ref.watch(simulationServiceProvider);
    simulationService.setRef(ref);
    simulationService.setPostureChangeCallback(onPostureChange);

    return CardComponent(
      title: "Simulation Control",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressIndicator(elapsedTime, totalDuration),
          const SizedBox(height: 10),
          _buildCurrentStatus(plan, position, status),
          const SizedBox(height: 10),
          _buildControlButtons(context, ref, simulationService, status),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Duration elapsed, Duration total) {
    final progress = total.inMilliseconds > 0
        ? elapsed.inMilliseconds / total.inMilliseconds
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(elapsed)),
            Text(_formatDuration(total)),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStatus(
      List<PosturePeriod> plan, int position, SimulationStatus status) {
    if (plan.isEmpty) {
      return const Text("No simulation plan defined");
    }

    String statusText;
    switch (status) {
      case SimulationStatus.idle:
        statusText = "Ready";
        break;
      case SimulationStatus.running:
        statusText = "Running";
        break;
      case SimulationStatus.paused:
        statusText = "Paused";
        break;
      case SimulationStatus.completed:
        statusText = "Completed";
        break;
    }

    final currentPosture =
        position < plan.length ? plan[position].posture : "None";
    final nextPosture =
        position + 1 < plan.length ? plan[position + 1].posture : "None";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Status: $statusText",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text("Current Posture: ${_formatPostureName(currentPosture)}"),
        Text("Next Posture: ${_formatPostureName(nextPosture)}"),
      ],
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    WidgetRef ref,
    SimulationService simulationService,
    SimulationStatus status,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text("Plan"),
          onPressed: () => _showPlannerDialog(context, ref, simulationService),
        ),
        ElevatedButton.icon(
          icon: Icon(status == SimulationStatus.running
              ? Icons.pause
              : Icons.play_arrow),
          label: Text(status == SimulationStatus.running ? "Pause" : "Play"),
          onPressed: status == SimulationStatus.running
              ? () {
                  simulationService.pauseSimulation();
                }
              : (status == SimulationStatus.completed &&
                      ref.read(simulationPlanProvider).isNotEmpty)
                  ? () {
                      simulationService.stopSimulation();
                      simulationService.startSimulation();
                    }
                  : (ref.read(simulationPlanProvider).isNotEmpty)
                      ? () {
                          simulationService.startSimulation();
                        }
                      : null,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.stop),
          label: const Text("Stop"),
          onPressed: (status == SimulationStatus.running ||
                  status == SimulationStatus.paused)
              ? () {
                  simulationService.stopSimulation();
                }
              : null,
        ),
      ],
    );
  }

  void _showPlannerDialog(
    BuildContext context,
    WidgetRef ref,
    SimulationService simulationService,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimulationPlannerDialog(
        onSave: (plan) {
          simulationService.createSimulationPlan(plan);
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPostureName(String posture) {
    switch (posture) {
      case 'upright':
        return 'Upright';
      case 'slouching':
        return 'Slouching';
      case 'leftLeaning':
        return 'Leaning Left';
      case 'rightLeaning':
        return 'Leaning Right';
      case 'backLeaning':
        return 'Leaning Back';
      default:
        return posture;
    }
  }
}
