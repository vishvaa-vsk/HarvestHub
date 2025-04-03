import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  Map<String, String>? _insights;
  bool _isLoading = true;

  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, String>? get insights => _insights;
  bool get isLoading => _isLoading;

  Future<void> fetchWeatherData() async {
    if (_weatherData != null) return; // Fetch only once
    _isLoading = true;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeatherData();
    } catch (e) {
      print('Error fetching weather data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherAndInsights() async {
    if (_weatherData != null && _insights != null) return; // Fetch only once
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch weather data
      _weatherData = await _weatherService.getWeatherData();

      // Fetch insights using GeminiService
      final geminiService = GeminiService();
      final current = _weatherData?['current'];
      if (current != null) {
        _insights = await geminiService.getAgriculturalInsights(
          temperature: (current['temperature'] as num).toDouble(),
          humidity: (current['humidity'] as num).toDouble(),
          rainfall: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
          windSpeed: (current['windSpeed'] as num).toDouble(),
          condition: current['condition'],
        );
      }
    } catch (e) {
      print('Error fetching weather or insights: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
