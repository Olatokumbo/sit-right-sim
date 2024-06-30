import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sit_right_app/models/postureStats.dart';
import 'package:http/http.dart' as http;

class RecommendationCounter {
  static final RecommendationCounter _instance =
      RecommendationCounter._internal();
  int _counter = 0;
  String lastRecommendation = "";

  factory RecommendationCounter() {
    return _instance;
  }

  RecommendationCounter._internal();

  void incrementCounter() {
    _counter++;
  }

  int getCounter() {
    return _counter;
  }

  void resetCounter() {
    _counter = 0;
  }
}

String generatePrompt(List<PostureStatistics> postures) {
  final buffer = StringBuffer();
  buffer.writeln(
      'I have been sitting in the following postures for these durations:');

  for (var posture in postures) {
    buffer.writeln(
        '${posture.posture} for ${posture.duration.inMinutes} minutes');
  }

  buffer.writeln(
      'Can you provide a brief one-paragraph recommendation (2 sentence max) based on my current sitting posture? Additionally also highlight trends or patterns in my sitting postures');

  return buffer.toString();
}

Future<String> getRecommendations(List<PostureStatistics> postures) async {
  final recommendationCounter = RecommendationCounter();
  recommendationCounter.incrementCounter();

  if (postures.isEmpty) {
    return "";
  }

  if (recommendationCounter.getCounter() < 10) {
    return recommendationCounter.lastRecommendation;
  }

  // final apiKey = dotenv.env["OPENAI_API_KEY"];
  const apiKey = "sk-proj-jp29NPq4niLh0fjS9Yu3T3BlbkFJzRr6AajGQ3dIs5uoDJqo";
  const url =
      'https://api.openai.com/v1/completions'; // example endpoint, adjust as needed

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    'prompt': generatePrompt(postures),
    "model": "gpt-3.5-turbo-instruct",
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
    recommendationCounter.resetCounter();
    final data = jsonDecode(response.body);
    final advise = data['choices'][0]['text'].trim();
    recommendationCounter.lastRecommendation = advise;
    return advise;
  } else {
    return "Cannot generate recommendation";
  }
}
