import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sit_right_app/components%20/pie_chart.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    List<TimeStampedSensorValues> sensorData = [
      TimeStampedSensorValues(
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        sensorValues: List.generate(
          10,
          (i) => List.generate(10, (j) => (i + j) / 20.0),
        ),
      ),
      TimeStampedSensorValues(
        timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
        sensorValues: List.generate(
          10,
          (i) => List.generate(10, (j) => (i + j) / 30.0),
        ),
      ),
      TimeStampedSensorValues(
        timestamp: DateTime.now(),
        sensorValues: List.generate(
          10,
          (i) => List.generate(10, (j) => (i + j) / 40.0),
        ),
      ),
    ];

    print(sensorData[0].timestamp);
    print(sensorData[1].timestamp);

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
                Column(
                  children: [
                    SensorArray(
                      rows: 10,
                      cols: 10,
                      sensorSize: 25.0,
                      sensorData: sensorData,
                    ),
                    const SizedBox(height: 10),
                    SensorArray(
                      rows: 10,
                      cols: 10,
                      sensorSize: 25.0,
                      sensorData: sensorData,
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
