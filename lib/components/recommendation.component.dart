import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/enums.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';
import 'package:sit_right_app/providers/ai-recommendation.provider.dart';
import 'package:sit_right_app/providers/simulation.provider.dart';
import '../services/recommendation.service.dart';

class AIRecommendation extends ConsumerStatefulWidget {
  const AIRecommendation({super.key, required this.postureStats});

  final List<PostureStatistics> postureStats;

  @override
  ConsumerState<AIRecommendation> createState() => _AIRecommendationState();
}

class _AIRecommendationState extends ConsumerState<AIRecommendation> {
  late RecommendationService recommendationService;

  String recommendation = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    recommendationService = RecommendationService(widget.postureStats);
    _startFetchingRecommendations();
  }

  void _startFetchingRecommendations() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final status = ref.read(simulationStatusProvider);

      if (status == SimulationStatus.running) {
        String result = await recommendationService.getRecommendations();
        setState(() {
          recommendation = result;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(recommendation);
  }
}
