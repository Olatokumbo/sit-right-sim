import 'dart:math';

import 'package:sit_right_app/services/posture.service.dart';

class Point {
  final double x;
  final double y;
  final double weight;

  Point(this.x, this.y, {this.weight = 1.0});
}

class WeightedHausdorffDistanceService {
  double _euclideanDistance(Point p1, Point p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  double _directedWeightedHausdorffDistance(
      List<Point> setA, List<Point> setB) {
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (var a in setA) {
      double minWeightedDistance = double.infinity;

      for (var b in setB) {
        double distance = _euclideanDistance(a, b);
        double weightedDistance =
            distance * a.weight; // Weight by a's importance

        if (weightedDistance < minWeightedDistance) {
          minWeightedDistance = weightedDistance;
        }
      }

      weightedSum += minWeightedDistance;
      totalWeight += a.weight; // Sum up the weights of set A
    }

    return weightedSum / totalWeight;
  }

  double weightedHausdorffDistance(List<Point> setA, List<Point> setB) {
    return max(
      _directedWeightedHausdorffDistance(setA, setB),
      _directedWeightedHausdorffDistance(setB, setA),
    );
  }

  List<Point> extractPointsFromMatrix(List<List<double>> matrix,
      {double weight = 1.0}) {
    List<Point> points = [];
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        if (matrix[i][j] > 0) {
          points.add(Point(i.toDouble(), j.toDouble(), weight: weight));
        }
      }
    }
    return points;
  }

  void calculate(List<List<double>> backrest, List<List<double>> seat,
      PostureService postureService) {
    var uprightPosture =
        postureService.postures["upright"] as Map<String, List<List<double>>>;

    // Extract points from matrices with a default weight
    List<Point> uprightBackrestPoints =
        extractPointsFromMatrix(uprightPosture["backrest"]!);
    List<Point> uprightSeatPoints =
        extractPointsFromMatrix(uprightPosture["seat"]!);

    List<Point> otherBackrestPoints = extractPointsFromMatrix(backrest);
    List<Point> otherSeatPoints = extractPointsFromMatrix(seat);

    // Calculate Weighted Hausdorff Distance
    double backrestDistance =
        weightedHausdorffDistance(uprightBackrestPoints, otherBackrestPoints);
    double seatDistance =
        weightedHausdorffDistance(uprightSeatPoints, otherSeatPoints);

    print("Weighted Hausdorff distance (backrest): $backrestDistance");
    print("Weighted Hausdorff distance (seat): $seatDistance");
  }
}
