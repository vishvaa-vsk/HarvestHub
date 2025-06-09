import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';
import 'package:geolocator/geolocator.dart';

/// A provider class for managing weather data and agricultural insights.
///
/// This class fetches weather data from the Weather API and agricultural
/// insights from the GeminiService. It also manages the loading state and
/// provides methods for fetching monthly forecasts and extended weather data.
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  Map<String, String>? _insights;
  List<Map<String, dynamic>>? _monthlyForecast;
  List<Map<String, dynamic>>? _futureWeather;
  bool _isLoading = true;
  String _lang = 'en';

  // Crop recommendation caching
  String? _cachedExtendedForecastRecommendation;
  String? _cachedGeneralRecommendation;
  String? _cachedForecastDataHash;
  String? _cachedRecommendationLang;
  DateTime? _cacheTimestamp;
  static const Duration _cacheExpiration = Duration(
    hours: 6,
  ); // Cache for 6 hours

  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, String>? get insights => _insights;
  List<Map<String, dynamic>>? get monthlyForecast => _monthlyForecast;
  List<Map<String, dynamic>>? get futureWeather => _futureWeather;
  bool get isLoading => _isLoading;
  String get lang => _lang;
  void setLanguage(String langCode) {
    _lang = langCode;
    _weatherData = null;
    _insights = null;
    // Clear cache when language changes
    _clearRecommendationCache();
    notifyListeners();
  }

  /// Clear all cached recommendations
  void _clearRecommendationCache() {
    _cachedExtendedForecastRecommendation = null;
    _cachedGeneralRecommendation = null;
    _cachedForecastDataHash = null;
    _cachedRecommendationLang = null;
    _cacheTimestamp = null;
  }

  /// Generate a hash for forecast data to use as cache key
  String _generateForecastHash(List<Map<String, dynamic>> forecastData) {
    final dataString = forecastData
        .map(
          (day) =>
              '${day['date']}_${day['temperature']}_${day['condition']}_${day['rainChance']}',
        )
        .join('|');
    return dataString.hashCode.toString();
  }

  /// Check if cache is valid
  bool _isCacheValid(String? forecastHash, String lang) {
    if (_cacheTimestamp == null ||
        _cachedForecastDataHash != forecastHash ||
        _cachedRecommendationLang != lang) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_cacheTimestamp!).abs() < _cacheExpiration;
  }

  Future<void> fetchWeatherData() async {
    if (_weatherData != null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _weatherData = await _weatherService.getWeatherData(lang: _lang);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherAndInsights() async {
    if (_weatherData != null && _insights != null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        throw Exception('Location services are disabled.');
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied.');
        }
      }
      final position = await Geolocator.getCurrentPosition();
      final weatherFuture = _weatherService.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
        lang: _lang,
      );
      final insightsFuture = weatherFuture.then<Map<String, String>>((
        weatherData,
      ) {
        final current = weatherData['current'];
        if (current != null) {
          final geminiService = GeminiService();
          return geminiService.getAgriculturalInsights(
            temperature: (current['temperature'] as num).toDouble(),
            humidity: (current['humidity'] as num).toDouble(),
            rainfall: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
            windSpeed: (current['windSpeed'] as num).toDouble(),
            condition: current['condition'],
            lang: _lang,
          );
        }
        return Future.value({});
      });
      final results = await Future.wait([weatherFuture, insightsFuture]);
      _weatherData = results[0] as Map<String, dynamic>?;
      _insights = results[1] as Map<String, String>?;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optimized fetchMonthlyForecast to support pagination and reduce loading times
  Future<void> fetchMonthlyForecast({int monthOffset = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calculate the target month and year based on the offset
      final now = DateTime.now();
      final targetDate = DateTime(now.year, now.month + monthOffset);

      // Fetch monthly weather data for the target month
      final forecastResponse = await _weatherService.getMonthlyForecast(
        year: targetDate.year,
        month: targetDate.month,
      );
      _monthlyForecast = forecastResponse;
      // Clear cache since we have new forecast data
      _clearRecommendationCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFutureWeather(String location, String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch future weather data from WeatherAPI
      _futureWeather = await _weatherService.getFutureWeather(location, date);
      // Clear cache since we have new forecast data
      _clearRecommendationCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFutureWeatherRange(String location, String endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch weather data for the range in a single API request
      final response = await _weatherService.getFutureWeather(
        location,
        endDate,
      );
      _futureWeather =
          response.map((day) {
            return {
              'date': day['date'],
              'temperature': {
                'min': day['day']['mintemp_c'],
                'max': day['day']['maxtemp_c'],
              },
              'condition': day['day']['condition']['text'],
              'rainChance': day['day']['daily_chance_of_rain'],
            };
          }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExtendedForecast(String location, int days) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch extended forecast data using the new method
      _futureWeather = await _weatherService.getExtendedForecast(
        location,
        days,
      );
      // Clear cache since we have new forecast data
      _clearRecommendationCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getCropRecommendation() async {
    // Use _futureWeather (extended forecast) when available, fall back to _monthlyForecast
    List<Map<String, dynamic>>? forecastData =
        _futureWeather ?? _monthlyForecast;

    if (forecastData == null || forecastData.isEmpty) return null;

    try {
      // Generate hash for caching
      final forecastHash = _generateForecastHash(forecastData);

      // Check if we have a valid cached recommendation
      if (_isCacheValid(forecastHash, _lang) &&
          _cachedGeneralRecommendation != null) {
        return _cachedGeneralRecommendation;
      }

      final geminiService = GeminiService();
      final recommendation = await geminiService.getCropRecommendation(
        forecastData,
        lang: _lang,
      );

      // Cache the recommendation
      _cachedGeneralRecommendation = recommendation;
      _cachedForecastDataHash = forecastHash;
      _cachedRecommendationLang = _lang;
      _cacheTimestamp = DateTime.now();

      return recommendation;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getExtendedForecastCropRecommendation() async {
    // Specifically use 30-day extended forecast data only
    if (_futureWeather == null || _futureWeather!.isEmpty) return null;

    try {
      // Generate hash for caching
      final forecastHash = _generateForecastHash(_futureWeather!);

      // Check if we have a valid cached recommendation
      if (_isCacheValid(forecastHash, _lang) &&
          _cachedExtendedForecastRecommendation != null) {
        return _cachedExtendedForecastRecommendation;
      }

      final geminiService = GeminiService();
      final recommendation = await geminiService.getCropRecommendation(
        _futureWeather!,
        lang: _lang,
      );

      // Cache the recommendation
      _cachedExtendedForecastRecommendation = recommendation;
      _cachedForecastDataHash = forecastHash;
      _cachedRecommendationLang = _lang;
      _cacheTimestamp = DateTime.now();

      return recommendation;
    } catch (e) {
      return null;
    }
  }
}
