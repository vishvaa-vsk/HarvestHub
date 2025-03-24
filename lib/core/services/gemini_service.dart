import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  static Future<String> getCropAdvice({
    required String weather,
    required String soilType,
    String? additionalContext,
  }) async {
    if (dotenv.env['GEMINI_API_KEY']?.isEmpty ?? true) {
      throw Exception('Gemini API key not configured');
    }

    final prompt = '''
      Based on the following conditions:
      Weather: $weather
      Soil Type: $soilType
      ${additionalContext ?? ''}
      
      Provide farming advice including:
      1. Suitable crops to plant
      2. Best practices for cultivation
      3. Potential challenges and solutions
      
      Keep the response concise and practical.
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? 'Unable to generate advice at the moment.';
  }
}