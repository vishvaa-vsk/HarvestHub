import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-preview-0409',
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text == null) {
        return "No response.";
      }
      return text;
    } catch (e) {
      return "Error: $e";
    }
  }
}
