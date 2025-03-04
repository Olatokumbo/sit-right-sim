import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/components/card.component.dart';
import 'package:sit_right_app/components/charts/sitting-pattern.chart.dart';
import 'package:sit_right_app/components/charts/sitting-statistics.chart.dart';
import 'package:sit_right_app/components/posture-demo.dart';
import 'package:sit_right_app/components/posture-indicator.dart';
import 'package:sit_right_app/components/charts/sitting-quality.chart.dart';
import 'package:sit_right_app/components/simulation-control.component.dart';
// import 'package:sit_right_app/components/timer.component.dart';
import 'package:sit_right_app/providers/ai-recommendation.provider.dart';
import 'package:sit_right_app/providers/hausdorff-distance.provider.dart';
import 'package:sit_right_app/providers/loading.provider.dart';
import 'package:sit_right_app/providers/predicted-posture.provider.dart';
import 'package:sit_right_app/providers/sensor-data.provider.dart';
import 'package:sit_right_app/providers/sensor-size.provider.dart';
import 'package:sit_right_app/providers/simulated-posture.provider.dart';
import 'package:sit_right_app/services/data-augmentation.service.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';
import 'package:sit_right_app/services/weighted-hausdorff-distance.service.dart';
import 'package:sit_right_app/services/posture.service.dart';
import 'package:sit_right_app/services/posture-prediction.service.dart';
import 'package:sit_right_app/services/recommendation.service.dart';
// import 'package:sit_right_app/services/simulation.service.dart';
import 'package:sit_right_app/services/sitting-quality.service.dart';
import 'package:sit_right_app/utils.dart';
// import "components/dropdown.component.dart";
import 'components/gauge.component.dart';
import 'components/sensor-array.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/simulation.provider.dart';

// Services
final postureService = PostureService();
final dataAugmentationService = DataAugmentationService();
final posturePredictionService = PosturePredictionService();
final sittingQualityService = SittingQualityService();
final weightedHausdorffDistanceService = WeightedHausdorffDistanceService();

Future<void> main() async {
  await dotenv.load(fileName: "env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sit Right Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  DateTime startTime = DateTime.now();

  List<PostureStatistics> postureStatistics = [];
  late RecommendationService recommendationService =
      RecommendationService(postureStatistics);

  Future<void> setPosture(String value) async {
    final sensorSize = ref.read(sensorSizeProvider);

    Map<String, List<List<double>>> postureData =
        postureService.get(value, sensorSize);

    List<List<double>> backrest = postureData["backrest"]!;
    List<List<double>> seat = postureData["seat"]!;

    ref.read(sensorDataProvider.notifier).state = {
      "backrest": backrest,
      "seat": seat
    };
    ref.read(loadingProvider.notifier).state = true;

    String posture = await posturePredictionService
        .fetchPrediction(ref.read(sensorDataProvider));

    String recommendation = await recommendationService.getRecommendations();
    sittingQualityService.calculate(posture, startTime, DateTime.now());

    setState(() {
      if (ref.read(predictedPostureProvider.notifier).state !=
          "No Posture Detected") {
        postureStatistics.add(PostureStatistics(
            ref.read(predictedPostureProvider),
            getScoreByPosture(posture),
            startTime,
            DateTime.now()));
      }
    });

    startTime = DateTime.now();
    ref.read(predictedPostureProvider.notifier).state = posture;
    ref.read(simulatedPostureProvider.notifier).state = value;
    ref.read(aiRecommendationProvider.notifier).state = recommendation;
    ref.read(loadingProvider.notifier).state = false;

    ref.read(hausdorffDistanceProvider.notifier).state =
        await weightedHausdorffDistanceService.calculate(
            backrest, seat, sensorSize, postureService);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the SimulationService from the provider
      final simulationService = ref.read(simulationServiceProvider);

      // Set the ref and posture change callback
      simulationService.setRef(ref);
      simulationService.setPostureChangeCallback(setPosture);

      setPosture(ref.read(simulatedPostureProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorData = ref.watch(sensorDataProvider);
    final sensorSize = ref.watch(sensorSizeProvider);
    final predictedPosture = ref.watch(predictedPostureProvider);
    // final simulatedPosture = ref.watch(simulatedPostureProvider);
    final aiRecommendation = ref.watch(aiRecommendationProvider);
    final hausdorffDistance = ref.watch(hausdorffDistanceProvider);
    final loading = ref.watch(loadingProvider);
    final double scoreSum = getScoreByPosture(predictedPosture).abs() +
        (hausdorffDistance["backrest"]?.toDouble() ?? 0.0) +
        (hausdorffDistance["seat"]?.toDouble() ?? 0.0);

    // Avoid division by zero or invalid values
    final postureScore = (scoreSum > 0)
        ? (100 / scoreSum).toInt()
        : 100; // Default to 100 if the scoreSum is 0 or less

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: const Color(0xFF032022),
          title: const Text('SitRight Dashboard'),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardComponent(
                    title: "Visual Representation",
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                SensorArray(
                                  rows: sensorSize,
                                  cols: sensorSize,
                                  sensorSize: 190 / sensorSize,
                                  sensorValues: sensorData["backrest"] ?? [],
                                  flipHorizontal: true,
                                ),
                                const SizedBox(height: 10),
                                SensorArray(
                                  rows: sensorSize,
                                  cols: sensorSize,
                                  sensorSize: 190 / sensorSize,
                                  sensorValues: sensorData["seat"] ?? [],
                                  flipHorizontal: true,
                                ),
                              ],
                            ),
                            PostureDemo(
                              predictedPosture: predictedPosture,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              SimulationControlPanel(
                                onPostureChange: setPosture,
                              ),
                              // const Divider(),
                              // const Text("Manual Control:",
                              //     style:
                              //         TextStyle(fontWeight: FontWeight.bold)),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     DropdownWidget(
                              //       items: const {
                              //         "Upright": "upright",
                              //         "Slouching": "slouching",
                              //         "Leaning Left": "leftLeaning",
                              //         "Leaning Right": "rightLeaning",
                              //         "Leaning Back": "backLeaning"
                              //       },
                              //       onValueChanged: (String value) async {
                              //         setPosture(value);
                              //       },
                              //     ),
                              //     IconButton(
                              //         onPressed: () async {
                              //           await setPosture(simulatedPosture);
                              //         },
                              //         icon: const Icon(Icons.refresh))
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                        // const Expanded(
                        //   flex: 1,
                        //   child: CardComponent(
                        //     title: "Timer",
                        //     child: TimerComponent(),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(15),
                      child: DefaultTabController(
                        length: 3,
                        child: Scaffold(
                          backgroundColor:
                              const Color.fromRGBO(237, 217, 246, 0.702),
                          appBar: AppBar(
                            toolbarHeight: 0,
                            bottom: const TabBar(
                              tabs: [
                                Tab(
                                    icon:
                                        Icon(Icons.stacked_line_chart_rounded)),
                                Tab(icon: Icon(Icons.bar_chart_sharp)),
                                Tab(icon: Icon(Icons.recommend)),
                              ],
                            ),
                          ),
                          body: TabBarView(
                            children: [
                              Column(
                                children: [
                                  CardComponent(
                                    title: "Sitting Pattern",
                                    child: SittingPatternChart(
                                      data: postureStatistics,
                                      indicatorLineColor: Colors.blueGrey,
                                      averageLineColor: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                              // 2nd Tab
                              Column(
                                children: [
                                  CardComponent(
                                    title: "Sitting Quality",
                                    child: SittingQualityChart(
                                        data: sittingQualityService.data,
                                        startTime: DateTime.now()),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CardComponent(
                                          title: "Statistics",
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SittingStatisticsChart(
                                                  postureStatistics),
                                            ],
                                          ),
                                        ),
                                        CardComponent(
                                          title: "Predicted Posture",
                                          child: PostureIndicator(
                                            predictedPosture: predictedPosture,
                                          ),
                                        ),
                                        CardComponent(
                                            title: "AI Recommendation",
                                            child: Text(aiRecommendation))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // 3rd Tab
                              Column(
                                children: [
                                  CardComponent(
                                    title:
                                        "Hausdorff Distance with Procrustes Analysis",
                                    child: Row(
                                      children: [
                                        Gauge(
                                          title:
                                              "Backrest: ${hausdorffDistance["backrest"]}",
                                          value: hausdorffDistance["backrest"]
                                                  ?.toDouble() ??
                                              0,
                                        ),
                                        Gauge(
                                            title:
                                                "Seat: ${hausdorffDistance["seat"]}",
                                            value: hausdorffDistance["seat"]
                                                    ?.toDouble() ??
                                                0)
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CardComponent(
                                          title: "Posture Score (%)",
                                          child: loading
                                              ? const Text("Loading...")
                                              : Text(
                                                  style: const TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  "$postureScore/100",
                                                ),
                                        ),
                                        const CardComponent(
                                          title: "",
                                        ),
                                        const CardComponent(
                                          title: "",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
