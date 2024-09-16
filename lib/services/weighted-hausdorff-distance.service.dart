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

  List<Point> extractPointsFromMatrix(List<List<double>> matrix) {
    List<Point> points = [];
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        double pressureValue = matrix[i][j];
        if (pressureValue > 0) {
          points.add(Point(i.toDouble(), j.toDouble(), weight: pressureValue));
        }
      }
    }
    return points;
  }

  Map<String, double> calculate(List<List<double>> backrest,
      List<List<double>> seat, int gridSize, PostureService postureService) {
    Map<String, List<List<double>>> uprightPosture =
        postureService.get("upright", gridSize);

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

    // Round the distances to 2 decimal places
    backrestDistance = double.parse(backrestDistance.toStringAsFixed(3));
    seatDistance = double.parse(seatDistance.toStringAsFixed(3));

    return {"backrest": backrestDistance, "seat": seatDistance};
  }
}
