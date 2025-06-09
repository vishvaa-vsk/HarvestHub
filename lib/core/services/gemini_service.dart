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
    String lang = 'en',
  }) async {
    try {
      // Initialize the GenerativeModel client
      final model = GenerativeModel(
        model: 'models/gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );
      String langInstruction = '';
      switch (lang) {
        case 'ta':
          langInstruction = 'Respond in Tamil.';
          break;
        case 'te':
          langInstruction = 'Respond in Telugu.';
          break;
        case 'hi':
          langInstruction = 'Respond in Hindi.';
          break;
        case 'ml':
          langInstruction = 'Respond in Malayalam.';
          break;
        default:
          langInstruction = 'Respond in English.';
      }
      // Call the Generative Language API using the client
      final content = [
        Content.text('''
        $langInstruction
        You are an AI-powered agricultural assistant. Based on the current weather conditions, provide immediate farming advice and crop recommendations suitable for today's conditions.

        Current Weather Data:
        - Temperature: $temperature°C
        - Humidity: $humidity%
        - Rainfall: ${rainfall}mm
        - Wind Speed: $windSpeed km/h
        - Condition: $condition

        Provide recommendations that are:
        - Suitable for immediate action based on current weather
        - Focused on short-term farming activities (today/this week)
        - Appropriate for the current seasonal conditions

        Response Format:
        Farming Tip: <Provide only the farming tip based on current weather conditions>
        Recommended Crop: <Provide crop recommendations suitable for current weather and immediate planting decisions (not more than 4 lines)>
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
    List<Map<String, dynamic>> monthlyForecast, {
    String lang = 'en',
  }) async {
    try {
      // Determine the forecast period for more specific recommendations
      final forecastDays = monthlyForecast.length;
      final forecastPeriod =
          forecastDays >= 30
              ? '30-day extended forecast'
              : forecastDays >= 14
              ? '2-week forecast'
              : 'weekly forecast';

      // Add language instruction based on the lang parameter
      String langInstruction = '';
      switch (lang) {
        case 'ta':
          langInstruction = 'Respond in Tamil.';
          break;
        case 'te':
          langInstruction = 'Respond in Telugu.';
          break;
        case 'hi':
          langInstruction = 'Respond in Hindi.';
          break;
        case 'ml':
          langInstruction = 'Respond in Malayalam.';
          break;
        default:
          langInstruction = 'Respond in English.';
      }

      // Prepare the prompt for Gemini API
      final prompt = '''
        $langInstruction
        You are an AI-powered agricultural assistant. Based on the given $forecastPeriod weather data, recommend the best crop for planting.
        
        Consider the following factors:
        - Temperature patterns and ranges throughout the forecast period
        - Rainfall distribution and frequency
        - Seasonal weather trends
        - Crop growth cycles that align with the forecast period
        - Regional agricultural practices
        
        Provide a comprehensive recommendation that includes:
        1. Primary crop recommendation with reasoning
        2. Alternative crop options
        3. Planting timeline suggestions
        4. Key weather-related considerations

        Weather Forecast Data ($forecastDays days):
        ${monthlyForecast.map((day) => '- Date: ${day['date']}, Max Temp: ${day['temperature']['max']}°C, Min Temp: ${day['temperature']['min']}°C, Condition: ${day['condition']}, Rain Chance: ${day['rainChance']}%').join('\n')}
        
        Please provide a detailed but concise recommendation (maximum 4 sentences).
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
