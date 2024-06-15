import 'dart:convert';
import 'package:http/http.dart' as http;

class PosturePredictionService {
  final String url = "https://predict-qtrb3tnorq-uc.a.run.app";

  Future<String> fetchPrediction(List<double> value) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'features': value}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        switch (data["prediction"][0] as int) {
          case 4:
            return "Upright";
          case 3:
            return "Slouching";
          case 1:
            return "Left Leaning";
          case 2:
            return "Right Leaning";
          case 0:
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
