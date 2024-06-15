import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sit_right_app/components%20/card.dart';
import 'package:sit_right_app/components%20/pie_chart.dart';
import 'package:sit_right_app/data_augmentation.service.dart';
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
  String posture = "Unknown";

  PostureService postureService = PostureService();
  DataAugmentationService dataAugmentationService = DataAugmentationService();
  PosturePredictionService posturePredictionService =
      PosturePredictionService();

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
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownWidget(
                          list: const [
                            "upright",
                            "slouching",
                            "leftLeaning",
                            "rightLeaning",
                            "leaningBack"
                          ],
                          onValueChanged: (value) async {
                            setState(() {
                              var postureData = postureService.get(value);
                              var backrest = dataAugmentationService
                                  .generateAugmentedDataForPosture(
                                      postureData["backrest"]!);
                              var seat = dataAugmentationService
                                  .generateAugmentedDataForPosture(
                                      postureData["seat"]!);

                              data = {"backrest": backrest, "seat": seat};
                            });

                            List<double> flattenedList = [
                              ...data["backrest"]
                                      ?.expand((innerList) => innerList) ??
                                  [],
                              ...data["seat"]
                                      ?.expand((innerList) => innerList) ??
                                  [],
                            ];

                            var response = await posturePredictionService
                                .fetchPrediction(flattenedList);

                            setState(() {
                              posture = response;
                            });
                          },
                        ),
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
                  const CardComponent(
                    title: "Controls",
                    // child: Text("Hello World"),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      children: [CardComponent(title: "Sitting Pattern")],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const CardComponent(
                            title: "Statistics", child: PieChartWidget()),
                        CardComponent(
                          title: "Realtime Posture",
                          child: Text(
                            posture,
                            style: const TextStyle(
                                fontSize: 50, fontWeight: FontWeight.w800),
                          ),
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
