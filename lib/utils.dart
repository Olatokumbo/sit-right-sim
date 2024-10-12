import 'package:flutter/material.dart';
import 'models/posture-statistics.model.dart';
import 'models/posture-chart.model.dart';

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

String findPosture(String predictedPosture) {
  switch (predictedPosture) {
    case "Upright":
      return 'upright';
    case "Slouching":
      return "slouching";
    case "Leaning Left":
      return "leftLeaning";
    case "Leaning Right":
      return "rightLeaning";
    case "Leaning Back":
      return "backLeaning";
    default:
      return "empty";
  }
}

double getScoreByPosture(String posture) {
  double spinalLoad = 0.0;
  double muscleActivity = 0.0;
  double ergonomicRisk = 0.0;

  switch (posture) {
    case "Upright":
      spinalLoad = 1.0; // Low spinal load in an upright posture
      muscleActivity = 1.0; // Minimal muscle activity needed
      ergonomicRisk = 1.0; // Low ergonomic risk
      break;
    case "Slouching":
      spinalLoad = 2.5; // Higher spinal load due to poor posture
      muscleActivity = 3.0; // Increased muscle activity to maintain balance
      ergonomicRisk = 3.5; // High ergonomic risk
      break;
    case "Leaning Left":
      spinalLoad = 3.0; // Asymmetric load on the spine
      muscleActivity = 2.5; // Moderate muscle activity
      ergonomicRisk = 2.5; // Moderate ergonomic risk
      break;
    case "Leaning Right":
      spinalLoad = -3.0; // Similar to Leaning Left
      muscleActivity = -2.5; // Similar muscle activity
      ergonomicRisk = -2.5; // Similar ergonomic risk
      break;
    case "Leaning Back":
      spinalLoad = 2.0; // Lower spinal load than slouching but still not ideal
      muscleActivity = 2.0; // Moderate muscle activity
      ergonomicRisk = 2.0; // Moderate ergonomic risk
      break;
    default:
      return 0; // Default score for undefined postures
  }

  // Calculate the weighted posture score
  double postureScore =
      (0.4 * spinalLoad) + (0.3 * muscleActivity) + (0.3 * ergonomicRisk);

  return postureScore;
}
