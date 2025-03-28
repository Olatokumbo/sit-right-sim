import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';
import 'package:http/http.dart' as http;
import 'package:sit_right_app/utils.dart';

String generatePrompt(List<PostureStatistics> postures) {
  final buffer = StringBuffer();

  var formattedPostures = groupPosture(postures);
  buffer.writeln(
      'I have been sitting in the following postures for these durations:');

  for (var posture in formattedPostures) {
    buffer.writeln('${posture.posture} for ${posture.duration} seconds');
  }

  buffer.writeln(
      'Can you provide a brief one-paragraph recommendation (2 sentence max) based on my current sitting posture? Additionally also highlight trends or patterns in my sitting postures');

  return buffer.toString();
}

class RecommendationService {
  List<PostureStatistics> postures;
  String lastRecommendation = "";

  RecommendationService(this.postures);

  Future<String> getRecommendations() async {
    if (postures.isEmpty) {
      return "";
    }

    final apiKey = dotenv.env["OPENAI_API_KEY"];
    const url = 'https://api.openai.com/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'messages': [
        {"role": "user", "content": generatePrompt(postures)}
      ],
      "model": "gpt-4o",
      "temperature": 1,
      "max_tokens": 256,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['choices'] != null && data['choices'].isNotEmpty) {
        final advise = data['choices'][0]['message']['content']?.trim() ??
            "No recommendation available";
        lastRecommendation = advise;
        return advise;
      }
    }
    return "Cannot generate recommendation";
  }
}
