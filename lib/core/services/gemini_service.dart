import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

class GeminiService {
  Future<Map<String, String>> getAgriculturalInsights({
    required double temperature,
    required double humidity,
    required double rainfall,
    required double windSpeed,
    required String condition,
  }) async {
    try {
      // Load service account credentials
      final serviceAccountJson = await rootBundle.loadString(
        'lib/core/services/gemini_service_account.json',
      );
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        serviceAccountJson,
      );

      // Authenticate with Google Cloud
      final client = await clientViaServiceAccount(serviceAccountCredentials, [
        'https://www.googleapis.com/auth/generative-language',
      ]);

      // Prepare the prompt
      final prompt = '''
        You are an AI-powered agricultural assistant. Based on the given weather conditions, provide a daily farming tip and crop recommendation.

        Weather Data:
        - Temperature: $temperature°C
        - Humidity: $humidity%
        - Rainfall: ${rainfall}mm
        - Wind Speed: $windSpeed km/h
        - Condition: $condition
      ''';

      print('Calling Generative Language API with prompt: $prompt');

      // Call the Generative Language API using REST
      final response = await client.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': {'text': prompt},
          'temperature': 0.7,
          'candidateCount': 1,
        }),
      );

      print('Generative Language API Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch AI insights: ${response.body}');
      }

      final data = json.decode(response.body);
      final farmingTip =
          data['candidates']?[0]['output'] ?? 'No farming tip available';
      final cropRecommendation = 'Crop recommendation logic can be added here';

      return {
        'farmingTip': farmingTip,
        'cropRecommendation': cropRecommendation,
      };
    } catch (e) {
      print('Error calling Generative Language API: $e');
      return {
        'farmingTip': 'Error fetching farming tip',
        'cropRecommendation': 'Error fetching crop recommendation',
      };
    }
  }
}
