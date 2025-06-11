import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'google_translate_api.dart';

/// A service class for interacting with the Weather API.
///
/// This class fetches current weather data, 3-day forecasts, and monthly
/// forecasts. It also provides methods for fetching future weather data
/// and extended forecasts.
class WeatherService {
  static const String _weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  final String? _weatherApiKey = dotenv.env['WEATHER_API_KEY'];
  final String? _googleTranslateApiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];

  // Performance cache for repeated requests
  static final Map<String, Map<String, dynamic>> _forecastCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 15); // 15 minute cache

  // Helper to map locale to supported weatherapi lang
  String _getWeatherApiLang(String langCode) {
    switch (langCode) {
      case 'ta':
        return 'ta';
      case 'te':
        return 'te';
      case 'hi':
        return 'hi';
      default:
        return 'en';
    }
  }

  Future<Map<String, dynamic>> getWeatherData({
    double? latitude,
    double? longitude,
    String lang = 'en',
  }) async {
    try {
      // Use provided latitude and longitude or fetch current location
      if (latitude == null || longitude == null) {
        Position position = await _getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      }
      final apiLang = _getWeatherApiLang(lang);
      // Fetch current weather data
      final currentWeatherResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/current.json?key=$_weatherApiKey&q=$latitude,$longitude&lang=$apiLang',
        ),
      );
      if (currentWeatherResponse.statusCode != 200) {
        throw Exception('Failed to load current weather data');
      }
      final currentWeather = json.decode(currentWeatherResponse.body);
      // Fetch 5-day forecast data (including today) to ensure we get 3 future days
      final forecastResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=$latitude,$longitude&days=5&lang=$apiLang',
        ),
      );
      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to load forecast data');
      }
      final forecastData = json.decode(forecastResponse.body);
      final List<dynamic> forecastList =
          forecastData['forecast']['forecastday'];
      final List<Map<String, dynamic>> forecast = await Future.wait(
        forecastList.map((day) async {
          final condition = day['day']['condition']['text'];
          String translatedCondition = condition;
          if (lang == 'ml' && _googleTranslateApiKey != null) {
            final translator = GoogleTranslateApi(_googleTranslateApiKey);
            translatedCondition = await translator.translate(condition, 'ml');
          }
          return {
            'date': day['date'],
            'temperature': {
              'min': day['day']['mintemp_c'],
              'max': day['day']['maxtemp_c'],
            },
            'condition': translatedCondition,
            'rainChance': day['day']['daily_chance_of_rain'],
          };
        }).toList(),
      );
      final currentCondition = currentWeather['current']['condition']['text'];
      String translatedCurrentCondition = currentCondition;
      if (lang == 'ml' && _googleTranslateApiKey != null) {
        final translator = GoogleTranslateApi(_googleTranslateApiKey);
        translatedCurrentCondition = await translator.translate(
          currentCondition,
          'ml',
        );
      }
      final current = {
        'temperature': currentWeather['current']['temp_c'] ?? 0,
        'humidity': currentWeather['current']['humidity'] ?? 0,
        'condition': translatedCurrentCondition,
        'windSpeed': currentWeather['current']['wind_kph'] ?? 0,
        'wind_dir': currentWeather['current']['wind_dir'] ?? 'Unknown',
        'feelslike_c': currentWeather['current']['feelslike_c'] ?? 0,
        'pressure_mb': currentWeather['current']['pressure_mb'] ?? 0,
        'vis_km': currentWeather['current']['vis_km'] ?? 0,
        'uv': currentWeather['current']['uv'] ?? 0,
        'cloud': currentWeather['current']['cloud'] ?? 0,
      };
      return {
        'current': current,
        'forecast': forecast,
        'agricultural': {
          'uvIndex': currentWeather['current']['uv'],
          'precipitation': currentWeather['current']['precip_mm'],
        },
      };
    } catch (e) {
      return {
        'current': {
          'temperature': 0,
          'humidity': 0,
          'condition': 'Unknown',
          'windSpeed': 0,
        },
        'forecast': [],
        'agricultural': {'uvIndex': 0, 'precipitation': 0},
      }; // Return default values in case of error
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable them to fetch weather data.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permissions are denied. Please grant permissions.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Map<String, dynamic>>> getMonthlyForecast({
    int? year,
    int? month,
  }) async {
    try {
      // Use current year and month if not provided
      final now = DateTime.now();
      year ??= now.year;
      month ??= now.month;

      // Construct the query for the specified year and month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final response = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=auto:ip&dt=${startDate.toIso8601String()}&end_dt=${endDate.toIso8601String()}',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load monthly forecast data');
      }

      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['forecast']['forecastday'];

      return forecastList.map((day) {
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
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFutureWeather(
    String location,
    String date,
  ) async {
    try {
      // Fetch future weather data from WeatherAPI
      final response = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/future.json?key=$_weatherApiKey&q=$location&dt=$date',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load future weather data');
      }

      final data = json.decode(response.body);
      final forecast = data['forecast']['forecastday'];

      return forecast.map<Map<String, dynamic>>((day) {
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
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getExtendedForecast(
    String location,
    int days,
  ) async {
    try {
      // Check cache first for performance
      final cacheKey = '${location}_$days';
      if (_forecastCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          final cachedData = _forecastCache[cacheKey]!;
          return List<Map<String, dynamic>>.from(cachedData['data']);
        }
      }

      // Get current location if "auto" is passed
      String locationQuery =
          location.toLowerCase() == "auto"
              ? await _getLocationQuery()
              : location;

      // Ensure days is within API limits (1-30)
      int forecastDays = days.clamp(1, 30);

      List<Map<String, dynamic>> extendedForecast =
          []; // ULTRA-OPTIMIZED: Minimize API calls for speed
      if (forecastDays <= 3) {
        // Fastest path: Single API call for 3 days or less - ULTRA FAST
        final response = await http
            .get(
              Uri.parse(
                '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=$locationQuery&days=$forecastDays',
              ),
            )
            .timeout(
              const Duration(seconds: 3),
            ); // ULTRA FAST timeout for 3-day

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final forecast = data['forecast']['forecastday'];

          extendedForecast =
              forecast.map<Map<String, dynamic>>((day) {
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
        }
      } else if (forecastDays <= 14) {
        // Single API call for 14 days or less
        final response = await http
            .get(
              Uri.parse(
                '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=$locationQuery&days=$forecastDays',
              ),
            )
            .timeout(const Duration(seconds: 8)); // Reasonable timeout

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final forecast = data['forecast']['forecastday'];

          extendedForecast =
              forecast.map<Map<String, dynamic>>((day) {
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
        }
      } else {
        // For 15-30 days: Use more aggressive parallel processing

        // Get first 14 days in one call
        final response14Future = http
            .get(
              Uri.parse(
                '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=$locationQuery&days=14',
              ),
            )
            .timeout(
              const Duration(seconds: 8),
            ); // Prepare parallel future day requests immediately
        List<Future<Map<String, dynamic>?>> futureDayRequests = [];
        for (int i = 14; i < forecastDays; i++) {
          final date = DateTime.now().add(Duration(days: i));
          final formattedDate =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          futureDayRequests.add(
            _fetchSingleFutureDayOptimized(locationQuery, formattedDate),
          );
        }

        // Execute all requests in parallel
        final results = await Future.wait([
          response14Future,
          ...futureDayRequests,
        ]);

        // Process 14-day response
        final response14 = results[0] as http.Response;
        if (response14.statusCode == 200) {
          final data14 = json.decode(response14.body);
          final forecast14 = data14['forecast']['forecastday'];

          extendedForecast.addAll(
            forecast14.map<Map<String, dynamic>>((day) {
              return {
                'date': day['date'],
                'temperature': {
                  'min': day['day']['mintemp_c'],
                  'max': day['day']['maxtemp_c'],
                },
                'condition': day['day']['condition']['text'],
                'rainChance': day['day']['daily_chance_of_rain'],
              };
            }),
          );
        }

        // Process future day results
        for (int i = 1; i < results.length; i++) {
          final dayData = results[i] as Map<String, dynamic>?;
          if (dayData != null) {
            extendedForecast.add(dayData);
          }
        }
      }

      // Sort by date to ensure correct order
      extendedForecast.sort((a, b) => a['date'].compareTo(b['date']));

      // Cache the results for future requests
      _forecastCache[cacheKey] = {'data': extendedForecast};
      _cacheTimestamps[cacheKey] = DateTime.now();

      return extendedForecast;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _fetchSingleFutureDayOptimized(
    String locationQuery,
    String formattedDate,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_weatherApiBaseUrl/future.json?key=$_weatherApiKey&q=$locationQuery&dt=$formattedDate',
            ),
          )
          .timeout(const Duration(seconds: 8)); // Optimized timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecast = data['forecast']['forecastday'];

        if (forecast.isNotEmpty) {
          final day = forecast[0];
          return {
            'date': day['date'],
            'temperature': {
              'min': day['day']['mintemp_c'],
              'max': day['day']['maxtemp_c'],
            },
            'condition': day['day']['condition']['text'],
            'rainChance': day['day']['daily_chance_of_rain'],
          };
        }
      }
    } catch (e) {
      // Continue with other requests even if one fails
      debugPrint('Failed to fetch weather for $formattedDate: $e');
    }
    return null;
  }

  // Helper method to get location query string
  Future<String> _getLocationQuery() async {
    try {
      Position position = await _getCurrentLocation();
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return 'auto:ip'; // Fallback to IP-based location
    }
  }
}
