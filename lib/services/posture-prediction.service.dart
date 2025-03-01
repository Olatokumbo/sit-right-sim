import 'dart:convert';
import 'package:http/http.dart' as http;

class PosturePredictionService {
  final String url = "https://main-qtrb3tnorq-uc.a.run.app";

  Future<String> fetchPrediction(Map<String, List<List<double>>> values) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'posture_backrest': values["backrest"],
          'posture_seat': values["seat"]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<double> prediction = List<double>.from(data["prediction"][0]);
        int predictedClassIndex =
            prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

        switch (predictedClassIndex) {
          case 0:
            return "Upright";
          case 1:
            return "Slouching";
          case 2:
            return "Leaning Left";
          case 3:
            return "Leaning Right";
          case 4:
            return "Leaning Back";
          default:
            return "Unknown";
        }
      } else {
        throw Exception(
            "Failed to fetch prediction. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch prediction: $e");
    }
  }
}
