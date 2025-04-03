import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';
import 'package:intl/intl.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  Map<String, String>? _insights;
  List<Map<String, dynamic>>? _monthlyForecast;
  List<Map<String, dynamic>>? _futureWeather;
  bool _isLoading = true;

  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, String>? get insights => _insights;
  List<Map<String, dynamic>>? get monthlyForecast => _monthlyForecast;
  List<Map<String, dynamic>>? get futureWeather => _futureWeather;
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

  Future<void> fetchMonthlyForecast() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch monthly weather data from WeatherAPI
      final forecastResponse = await _weatherService.getMonthlyForecast();
      _monthlyForecast = forecastResponse;
    } catch (e) {
      print('Error fetching monthly forecast: $e');
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
    } catch (e) {
      print('Error fetching future weather: $e');
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
    } catch (e) {
      print('Error fetching future weather range: $e');
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
    } catch (e) {
      print('Error fetching extended forecast: $e');
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
      final geminiService = GeminiService();
      final recommendation = await geminiService.getCropRecommendation(
        forecastData,
      );
      return recommendation;
    } catch (e) {
      print('Error fetching crop recommendation: $e');
      return null;
    }
  }
}
