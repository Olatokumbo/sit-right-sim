import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sit_right_app/components%20/pie_chart.dart';
import 'package:sit_right_app/data_augmentation.service.dart';
import 'package:sit_right_app/posture.service.dart';
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

  PostureService postureService = PostureService();
  DataAugmentationService dataAugmentationService = DataAugmentationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
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
                  onValueChanged: (value) {
                    setState(() {
                      var postureData = postureService.get(value);

                      var backrest = dataAugmentationService
                          .generateAugmentedDataForPosture(
                              postureData["backrest"]!);
                      var seat = dataAugmentationService
                          .generateAugmentedDataForPosture(
                              postureData["backrest"]!);

                      data = {"backrest": backrest, "seat": seat};

                      // data = postureData;
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
        ),
        const Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [Text("k;nokno")],
                    )),
                Expanded(
                    child: Row(
                  children: [
                    Expanded(child: PieChartWidget()),
                    Expanded(child: PieChartWidget())
                  ],
                )),
              ],
            ))
      ],
    ));
  }
}
