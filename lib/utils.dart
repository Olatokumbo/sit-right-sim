import 'package:flutter/material.dart';
import 'models/postureStats.dart';
import 'models/posture_chart.dart';

Color getColorByPosture(String posture) {
  // List of postures and their corresponding colors
  List<String> postureList = [
    "Upright",
    "Slouching",
    "Leaning Left",
    "Leaning Right",
    "Leaning Back"
  ];

  // Index of the posture in the list
  int index = postureList.indexOf(posture);

  if (index != -1) {
    // Use modulo operation to wrap around the index if it exceeds the list length
    return Colors.primaries[index % Colors.primaries.length];
  } else {
    // Default color if posture is not found
    return Colors.grey; // Or any other default color you prefer
  }
}

List<PostureChart> groupPosture(List<PostureStatistics> data) {
  Map<String, int> groupedMap = {};

  for (var item in data) {
    String posture = item.posture;
    DateTime startTime = item.startTime;
    DateTime endTime = item.endTime;

    // Calculate the duration in seconds
    int durationInSeconds = endTime.difference(startTime).inSeconds;

    if (groupedMap.containsKey(posture)) {
      groupedMap[posture] = groupedMap[posture]! + durationInSeconds;
    } else {
      groupedMap[posture] = durationInSeconds;
    }
  }

  // Convert the groupedMap back to a list of PostureChart objects
  List<PostureChart> groupedList = groupedMap.entries
      .map((entry) => PostureChart(entry.key, entry.value))
      .toList();

  return groupedList;
}
