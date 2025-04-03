import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  Map<String, dynamic>? get weatherData => _weatherData;
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
}
