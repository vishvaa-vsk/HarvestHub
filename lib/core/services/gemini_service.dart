import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A service class for interacting with the Gemini API.
///
/// This class generates prompts and sends them to the Gemini API to fetch
/// agricultural insights and crop recommendations. It also parses the
/// responses to extract relevant information.
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

      // Call the Generative Language API using the client
      final content = [
        Content.text('''
        You are an AI-powered agricultural assistant. Based on the given weather conditions, provide a crisp farming tip and a crop recommendation.

        Weather Data:
        - Temperature: $temperature°C
        - Humidity: $humidity%
        - Rainfall: ${rainfall}mm
        - Wind Speed: $windSpeed km/h
        - Condition: $condition

        Response Format:
        Farming Tip: <Provide only the farming tip here>
        Recommended Crop: <Provide only the recommended crop advice in few lines (not more than 4 lines) here>
        '''),
      ];

      final response = await model.generateContent(content);

      // Extract and format the response
      final responseText = response.text ?? '';
      final farmingTipMatch = RegExp(
        r'Farming Tip:\s*(.*?)\s*Recommended Crop:',
        dotAll: true,
      ).firstMatch(responseText);
      final cropRecommendationMatch = RegExp(
        r'Recommended Crop:\s*(.*)',
        dotAll: true,
      ).firstMatch(responseText);

      final farmingTip =
          farmingTipMatch?.group(1)?.trim() ?? 'No farming tip available';
      final cropRecommendation =
          cropRecommendationMatch?.group(1)?.trim() ??
          'No crop recommendation available';

      return {
        'farmingTip': farmingTip,
        'cropRecommendation': cropRecommendation,
      };
    } catch (e) {
      return {
        'farmingTip': 'Error fetching farming tip',
        'cropRecommendation': 'Error fetching crop recommendation',
      };
    }
  }

  Future<String> getCropRecommendation(
    List<Map<String, dynamic>> monthlyForecast,
  ) async {
    try {
      // Prepare the prompt for Gemini API
      final prompt = '''
        You are an AI-powered agricultural assistant. Based on the given monthly weather forecast, recommend the best crop for planting in a detailed manner.

        Monthly Weather Data:
        ${monthlyForecast.map((day) => '- Date: ${day['date']}, Max Temp: ${day['temperature']['max']}°C, Min Temp: ${day['temperature']['min']}°C, Condition: ${day['condition']}, Rain Chance: ${day['rainChance']}%').join('\n')}
      ''';

      final client = GenerativeModel(
        model: 'models/gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );

      final content = [Content.text(prompt)];
      final response = await client.generateContent(content);

      // Preserve and format the response
      return response.candidates.first.text?.trim() ??
          'No recommendation available';
    } catch (e) {
      return 'Error fetching crop recommendation';
    }
  }
}
