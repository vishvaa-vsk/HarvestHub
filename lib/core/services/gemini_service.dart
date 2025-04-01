import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  Future<Map<String, String>> getAgriculturalInsights({
    required double temperature,
    required double humidity,
    required double rainfall,
    required double windSpeed,
    required String condition,
  }) async {
    try {
      // Initialize the GenerativeModel client
      final model = GenerativeModel(
        model: 'models/gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );

      // Prepare the prompt
      final content = [
        Content.text('''
        You are an AI-powered agricultural assistant. Based on the given weather conditions, provide a daily farming tip and crop recommendation.

        Weather Data:
        - Temperature: $temperature°C
        - Humidity: $humidity%
        - Rainfall: ${rainfall}mm
        - Wind Speed: $windSpeed km/h
        - Condition: $condition
      '''),
      ];

      print('Calling Generative Language API with prompt: $content');

      // Call the Generative Language API using the client
      final response = await model.generateContent(content);

      print('Generative Language API Response: ${response.text}');

      final farmingTip =
          response.text?.split('Crop Recommendation:').first.trim() ??
          'No farming tip available';
      final cropRecommendation =
          response.text?.split('Crop Recommendation:').last.trim() ??
          'No crop recommendation available';

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
