import 'package:sit_right_app/services/posture.service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Point {
  final double x;
  final double y;
  final double weight;

  Point(this.x, this.y, {this.weight = 1.0});
}

class WeightedHausdorffDistanceService {
  final String url = "https://hausdorff-distance-qtrb3tnorq-uc.a.run.app";

  Future<Map<String, double>> calculate(
      List<List<double>> backrest,
      List<List<double>> seat,
      int gridSize,
      PostureService postureService) async {
    Map<String, List<List<double>>> uprightPosture =
        postureService.get("upright", gridSize);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'upright_backrest': uprightPosture["backrest"],
          'upright_seat': uprightPosture["seat"],
          'posture_backrest': backrest,
          'posture_seat': seat
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "backrest": data["hausdorff_backrest_with_procrustes"],
          "seat": data["hausdorff_seat_with_procrustes"]
        };
      } else {
        throw Exception(
            "Failed to fetch prediction. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }
}
