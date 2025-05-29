import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleTranslateApi {
  final String apiKey;
  GoogleTranslateApi(this.apiKey);

  static final Map<String, String> _cache = {};

  Future<String> translate(
    String text,
    String targetLang, {
    String sourceLang = 'en',
  }) async {
    final cacheKey = '$sourceLang|$targetLang|$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    final url = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'source': sourceLang,
        'target': targetLang,
        'format': 'text',
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translated =
          data['data']['translations'][0]['translatedText'] as String;
      _cache[cacheKey] = translated;
      return translated;
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
