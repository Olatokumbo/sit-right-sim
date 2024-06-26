import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sit_right_app/components%20/bar_chart.dart';
import 'package:sit_right_app/components%20/card.dart';
import 'package:sit_right_app/components%20/pie_chart.dart';
import 'package:sit_right_app/components%20/posture_widget.dart';
import 'package:sit_right_app/components%20/timer.dart';
import 'package:sit_right_app/data_augmentation.service.dart';
import 'package:sit_right_app/models/postureStats.dart';
import 'package:sit_right_app/posture.service.dart';
import 'package:sit_right_app/posture_prediction.service.dart';
import "components /dropdown_widget.dart";
import 'components /sensor-array.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<TimeStampedSensorValues> generateWavySensorData(
    int rows, int cols, int totalDurationMillis, int intervalMillis) {
  int numDataPoints = totalDurationMillis ~/ intervalMillis;
  List<TimeStampedSensorValues> sensorData = [];
  DateTime startTime = DateTime.now();

  for (int k = 0; k < numDataPoints; k++) {
    DateTime timestamp =
        startTime.add(Duration(milliseconds: k * intervalMillis));
    List<List<double>> sensorValues = List.generate(
      rows,
      (i) => List.generate(
        cols,
        (j) => (0.5 + 0.5 * sin(2 * pi * (i + j + k) / 10)), // Wavy pattern
      ),
    );
    sensorData.add(TimeStampedSensorValues(
        timestamp: timestamp, sensorValues: sensorValues));
  }

  return sensorData;
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, List<List<double>>> data = {
    "backrest": List.generate(10, (index) => List.filled(10, 0.0)),
    "seat": List.generate(10, (index) => List.filled(10, 0.0)),
  };
  String predictedPosture = "No Posture Detected";
  String simulatedPosture = 'upright';

  PostureService postureService = PostureService();
  DataAugmentationService dataAugmentationService = DataAugmentationService();
  PosturePredictionService posturePredictionService =
      PosturePredictionService();
  var startTime = DateTime.now();

  List<PostureStatistics> postureStatistics = [];

  void updateStatistics(String posture, Duration duration) {
    setState(() {
      // Find the index of the existing stat
      int index =
          postureStatistics.indexWhere((stat) => stat.posture == posture);

      if (index == -1) {
        // If not found, add new entry
        postureStatistics.add(PostureStatistics(posture, duration));
      } else {
        // If found, update the existing duration by creating a new instance
        PostureStatistics existingStat = postureStatistics[index];
        PostureStatistics updatedStat = existingStat.copyWith(
          duration: existingStat.duration + duration,
        );
        postureStatistics[index] = updatedStat;
      }
    });
  }

  Future<void> setPosture(value) async {
    if (value == null) {
      return;
    }
    setState(() {
      var postureData = postureService.get(value);
      var backrest = dataAugmentationService
          .generateAugmentedDataForPosture(postureData["backrest"]!);
      var seat = dataAugmentationService
          .generateAugmentedDataForPosture(postureData["seat"]!);

      data = {"backrest": backrest, "seat": seat};
    });

    List<double> flattenedList = [
      ...data["backrest"]?.expand((innerList) => innerList) ?? [],
      ...data["seat"]?.expand((innerList) => innerList) ?? [],
    ];

    var posture = await posturePredictionService.fetchPrediction(flattenedList);

    var duration = DateTime.now().difference(startTime);

    setState(() {
      startTime = DateTime.now();
      updateStatistics(predictedPosture, duration);
      predictedPosture = posture;
      simulatedPosture = value;
    });
  }

  @override
  void initState() {
    super.initState();
    setPosture(simulatedPosture);
  }

  @override
  Widget build(BuildContext context) {
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
                              rows: 10,
                              cols: 10,
                              sensorSize: 25.0,
                              sensorValues: data["backrest"] ?? [],
                            ),
                            const SizedBox(height: 10),
                            SensorArray(
                              rows: 10,
                              cols: 10,
                              sensorSize: 25.0,
                              sensorValues: data["seat"] ?? [],
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
                                  "Leaning Back": "leaningBack"
                                },
                                onValueChanged: (value) async {
                                  setPosture(value);
                                },
                              ),
                              IconButton(
                                  onPressed: () async {
                                    // if (posture != ) {
                                    await setPosture(simulatedPosture);
                                    // }
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
                    child: Row(
                      children: [
                        CardComponent(
                          title: "Sitting Pattern",
                          child: BarChartWidget(postureStatistics),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CardComponent(
                          title: "Statistics",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatisticsPieChart(postureStatistics),
                            ],
                          ),
                        ),
                        CardComponent(
                          title: "Predicted Posture",
                          child:
                              PostureWidget(predictedPosture: predictedPosture),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
