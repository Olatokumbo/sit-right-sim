import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit_right_app/components%20/bar_chart.dart';
import 'package:sit_right_app/components%20/card.dart';
import 'package:sit_right_app/components%20/line_chart_widget.dart';
import 'package:sit_right_app/components%20/pie_chart.dart';
import 'package:sit_right_app/components%20/posture_widget.dart';
import 'package:sit_right_app/components%20/timer.dart';
import 'package:sit_right_app/providers/ai-recommendation.provider.dart';
import 'package:sit_right_app/providers/loading.provider.dart';
import 'package:sit_right_app/providers/predicted-posture.provider.dart';
import 'package:sit_right_app/providers/sensor-data.provider.dart';
import 'package:sit_right_app/providers/sensor-size.provider.dart';
import 'package:sit_right_app/providers/simulated-posture.provider.dart';
import 'package:sit_right_app/services/data-augmentation.service.dart';
import 'package:sit_right_app/models/postureStats.dart';
import 'package:sit_right_app/services/posture.service.dart';
import 'package:sit_right_app/services/posture-prediction.service.dart';
import 'package:sit_right_app/services/recommendation.service.dart';
import "components /dropdown_widget.dart";
import 'components /sensor-array.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Services
final postureService = PostureService();
final dataAugmentationService = DataAugmentationService();
final posturePredictionService = PosturePredictionService();

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

  double getValueByPosture(String posture) {
    switch (posture) {
      case "Upright":
        return 1.0;
      case "Slouching":
        return 2.0;
      case "Leaning Left":
        return 3.0;
      case "Leaning Right":
        return 4.0;
      case "Leaning Back":
        return 5.0;
      default:
        return 0.0;
    }
  }

  Future<void> setPosture(String value) async {
    final sensorSize = ref.read(sensorSizeProvider);
    var postureData = postureService.get(value, sensorSize);
    var backrest = dataAugmentationService
        .generateAugmentedDataForPosture(postureData["backrest"]!);
    var seat = dataAugmentationService
        .generateAugmentedDataForPosture(postureData["seat"]!);

    ref.read(sensorDataProvider.notifier).state = {
      "backrest": backrest,
      "seat": seat
    };
    ref.read(loadingProvider.notifier).state = true;

    var posture = await posturePredictionService
        .fetchPrediction(ref.read(sensorDataProvider));

    var recommendation = await recommendationService.getRecommendations();

    setState(() {
      if (ref.read(predictedPostureProvider.notifier).state !=
          "No Posture Detected") {
        postureStatistics.add(PostureStatistics(
            ref.read(predictedPostureProvider),
            getValueByPosture(posture),
            startTime,
            DateTime.now()));
      }
    });

    startTime = DateTime.now();
    ref.read(predictedPostureProvider.notifier).state = posture;
    ref.read(simulatedPostureProvider.notifier).state = value;
    ref.read(aiRecommendationProvider.notifier).state = recommendation;
    ref.read(loadingProvider.notifier).state = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPosture(ref.read(simulatedPostureProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorData = ref.watch(sensorDataProvider);
    final sensorSize = ref.watch(sensorSizeProvider);
    final predictedPosture = ref.watch(predictedPostureProvider);
    final simulatedPosture = ref.watch(simulatedPostureProvider);
    final aiRecommendation = ref.watch(aiRecommendationProvider);
    final loading = ref.watch(loadingProvider);

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
                    title: "Sensor Array",
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SensorArray(
                              rows: sensorSize,
                              cols: sensorSize,
                              sensorSize: 190 / sensorSize,
                              sensorValues: sensorData["backrest"] ?? [],
                            ),
                            const SizedBox(height: 10),
                            SensorArray(
                              rows: sensorSize,
                              cols: sensorSize,
                              sensorSize: 190 / sensorSize,
                              sensorValues: sensorData["seat"] ?? [],
                            ),
                            DropdownWidget(
                              items: const {
                                "5x5": "5",
                                "10x10": "10",
                                "15x15": "15",
                                "20x20": "20",
                                "25x25": "25",
                                "32x32": "32"
                              },
                              onValueChanged: (value) async {
                                ref.read(sensorSizeProvider.notifier).state =
                                    int.parse(value);
                                await setPosture(simulatedPosture);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CardComponent(
                          title: "Simulated Posture",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownWidget(
                                items: const {
                                  "Upright": "upright",
                                  "Slouching": "slouching",
                                  "Leaning Left": "leftLeaning",
                                  "Leaning Right": "rightLeaning",
                                  "Leaning Back": "backLeaning"
                                },
                                onValueChanged: (String value) async {
                                  setPosture(value);
                                },
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await setPosture(simulatedPosture);
                                  },
                                  icon: const Icon(Icons.refresh))
                            ],
                          ),
                        ),
                        const CardComponent(
                          title: "Timer",
                          child: TimerComponent(),
                        ),
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
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(15),
                      child: DefaultTabController(
                        length: 3,
                        child: Scaffold(
                          backgroundColor: Color.fromRGBO(237, 217, 246, 0.702),
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
                              Row(
                                children: [
                                  CardComponent(
                                    title: "Sitting Pattern",
                                    child: LineChartWidget(
                                      data: postureStatistics,
                                      indicatorLineColor: Colors.blueGrey,
                                      averageLineColor: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  CardComponent(
                                    title: "Sitting Pattern",
                                    child: BarChartWidget(
                                      postureStatistics,
                                    ),
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
                                              StatisticsPieChart(
                                                  postureStatistics),
                                            ],
                                          ),
                                        ),
                                        CardComponent(
                                          title: "Predicted Posture",
                                          child: loading
                                              ? const Text("Loading...")
                                              : PostureWidget(
                                                  predictedPosture:
                                                      predictedPosture),
                                        ),
                                        CardComponent(
                                            title: "AI Recommendation",
                                            child: Text(aiRecommendation))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.warning),
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
