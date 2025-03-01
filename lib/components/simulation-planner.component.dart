import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/services/simulation.service.dart';
import '../providers/simulation.provider.dart';

class SimulationPlannerDialog extends ConsumerStatefulWidget {
  final Function(List<PosturePeriod>) onSave;

  const SimulationPlannerDialog({super.key, required this.onSave});

  @override
  ConsumerState<SimulationPlannerDialog> createState() =>
      _SimulationPlannerDialogState();
}

class _SimulationPlannerDialogState
    extends ConsumerState<SimulationPlannerDialog> {
  List<PosturePeriod> _periods = [];
  String _selectedPosture = 'upright';
  int _minutes = 1;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    // Load the existing plan after the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPlan();
    });
  }

  // Load the existing plan from the provider
  void _loadExistingPlan() {
    final existingPlan = ref.read(simulationPlanProvider);
    if (existingPlan.isNotEmpty) {
      setState(() {
        _periods =
            List.from(existingPlan); // Create a copy of the existing plan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Simulation Planner",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    return ListTile(
                      title: Text(
                          '${_formatPostureName(period.posture)} - ${_formatDuration(period.duration)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _periods.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPeriodForm(),
            const SizedBox(height: 16),
            _buildTotalDuration(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _periods.isEmpty
                      ? null
                      : () {
                          widget.onSave(_periods);
                          Navigator.of(context).pop();
                        },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Period',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Posture'),
              value: _selectedPosture,
              items: const [
                DropdownMenuItem(value: 'upright', child: Text('Upright')),
                DropdownMenuItem(value: 'slouching', child: Text('Slouching')),
                DropdownMenuItem(
                    value: 'leftLeaning', child: Text('Leaning Left')),
                DropdownMenuItem(
                    value: 'rightLeaning', child: Text('Leaning Right')),
                DropdownMenuItem(
                    value: 'backLeaning', child: Text('Leaning Back')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPosture = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                    initialValue: _minutes.toString(),
                    onChanged: (value) {
                      setState(() {
                        _minutes = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Seconds'),
                    keyboardType: TextInputType.number,
                    initialValue: _seconds.toString(),
                    onChanged: (value) {
                      setState(() {
                        _seconds = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Period'),
                onPressed: () {
                  final duration =
                      Duration(minutes: _minutes, seconds: _seconds);
                  if (duration > Duration.zero) {
                    setState(() {
                      _periods.add(PosturePeriod(
                        posture: _selectedPosture,
                        duration: duration,
                      ));
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDuration() {
    final totalDuration = _periods.fold(
      Duration.zero,
      (total, period) => total + period.duration,
    );

    return Text(
      'Total Duration: ${_formatDuration(totalDuration)}',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes min $seconds sec';
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
