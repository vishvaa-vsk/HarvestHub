import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/startup_performance.dart';

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
  bool _isLoading = false; // Start as false to prevent immediate loading
  bool _insightsLoading = false; // Track insights loading separately
  String _lang = 'en';
  bool _initialized = false; // Track initialization state

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
  bool get isInsightsLoading => _insightsLoading;
  String get lang => _lang;
  bool get isInitialized => _initialized;

  /// Initialize the provider when first accessed (lazy initialization)
  void _ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      // Initialization can be done here if needed
    }
  }

  void setLanguage(String langCode) {
    _ensureInitialized();
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
    _ensureInitialized();
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
    _ensureInitialized();
    if (_weatherData != null && _insights != null) return;
    StartupPerformance.markStart('WeatherProvider.fetchWeatherAndInsights');
    _isLoading = true;
    notifyListeners();
    try {
      StartupPerformance.markStart('WeatherProvider.locationCheck');
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
      StartupPerformance.markEnd('WeatherProvider.locationCheck');

      StartupPerformance.markStart('WeatherProvider.getPosition');
      final position = await Geolocator.getCurrentPosition();
      StartupPerformance.markEnd('WeatherProvider.getPosition');

      StartupPerformance.markStart('WeatherProvider.fetchWeatherData');
      // First, fetch weather data immediately (fast operation)
      _weatherData = await _weatherService.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
        lang: _lang,
      );
      StartupPerformance.markEnd('WeatherProvider.fetchWeatherData');

      // Update UI with weather data immediately
      _isLoading = false;
      notifyListeners();

      // Defer heavy AI insights to background to avoid blocking startup
      _fetchInsightsInBackground();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      StartupPerformance.markEnd('WeatherProvider.fetchWeatherAndInsights');
    }
  }

  /// Fetch AI insights in background without blocking startup
  void _fetchInsightsInBackground() {
    // Set insights loading state
    _insightsLoading = true;
    notifyListeners();

    // Use Future.microtask to ensure this runs after UI is updated
    Future.microtask(() async {
      try {
        StartupPerformance.markStart('WeatherProvider.fetchInsights');
        final current = _weatherData?['current'];
        if (current != null) {
          final geminiService = GeminiService();
          _insights = await geminiService.getAgriculturalInsights(
            temperature: (current['temperature'] as num).toDouble(),
            humidity: (current['humidity'] as num).toDouble(),
            rainfall: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
            windSpeed: (current['windSpeed'] as num).toDouble(),
            condition: current['condition'],
            lang: _lang,
          );
        }
        StartupPerformance.markEnd('WeatherProvider.fetchInsights');
      } catch (e) {
        // Handle insights error gracefully - app should still work without insights
        debugPrint('Error fetching insights: $e');
        _insights = {
          'farmingTip': 'Insights temporarily unavailable',
          'cropRecommendation': 'Please try again later',
        };
        StartupPerformance.markEnd('WeatherProvider.fetchInsights');
      } finally {
        // Clear insights loading state and notify listeners
        _insightsLoading = false;
        notifyListeners();
      }
    });
  }

  // Optimized fetchMonthlyForecast to support pagination and reduce loading times
  Future<void> fetchMonthlyForecast({int monthOffset = 0}) async {
    _ensureInitialized();
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
    // Check if we already have this data cached in provider
    if (_futureWeather != null &&
        _futureWeather!.isNotEmpty &&
        _futureWeather!.length >= days) {
      // We already have enough data, just return
      notifyListeners();
      return;
    }

    // Don't show loading for progressive updates (3->7->14->30 days)
    final isProgressive = _futureWeather != null && _futureWeather!.isNotEmpty;

    if (!isProgressive) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Fetch extended forecast data using optimized method
      final newForecastData = await _weatherService.getExtendedForecast(
        location,
        days,
      );

      // Progressive loading: Only update if we got more data
      if (newForecastData.isNotEmpty &&
          (isProgressive == false ||
              newForecastData.length > (_futureWeather?.length ?? 0))) {
        _futureWeather = newForecastData;

        // Clear cache since we have new forecast data
        _clearRecommendationCache();

        // Notify listeners for any data update
        notifyListeners();
      }
    } catch (e) {
      // Don't let errors block the UI for progressive loads
      if (!isProgressive) {
        rethrow;
      }
    } finally {
      if (!isProgressive) {
        _isLoading = false;
        notifyListeners();
      }
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
