import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  final String? _weatherApiKey = dotenv.env['WEATHER_API_KEY'];

  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      // Get current location
      Position position = await _getCurrentLocation();

      // Fetch current weather data from WeatherAPI
      final currentWeatherResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/current.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}',
        ),
      );

      if (currentWeatherResponse.statusCode != 200) {
        throw Exception('Failed to load current weather data');
      }

      print('Current Weather Response: ${currentWeatherResponse.body}');
      final currentWeather = json.decode(currentWeatherResponse.body);

      // Fetch 3-day forecast data from WeatherAPI
      final forecastResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}&days=3',
        ),
      );

      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to load forecast data');
      }

      print('Forecast Weather Response: ${forecastResponse.body}');
      final forecastData = json.decode(forecastResponse.body);

      // Parse forecast into 3-day chunks
      final List<dynamic> forecastList =
          forecastData['forecast']['forecastday'];
      final List<Map<String, dynamic>> forecast =
          forecastList.map((day) {
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

      // Parse current weather and agricultural metrics
      final current = {
        'temperature': currentWeather['current']['temp_c'] ?? 0,
        'humidity': currentWeather['current']['humidity'] ?? 0,
        'condition':
            currentWeather['current']['condition']['text'] ?? 'Unknown',
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
      print('Error fetching weather data: $e');
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

  Future<List<Map<String, dynamic>>> getMonthlyForecast() async {
    try {
      // Fetch 30-day forecast data from WeatherAPI
      final response = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=auto:ip&days=30',
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
      print('Error fetching monthly forecast: $e');
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

      print(
        'Fetching future weather data from: $_weatherApiBaseUrl/future.json?key=$_weatherApiKey&q=$location&dt=$date',
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

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
      print('Error fetching future weather data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getExtendedForecast(
    String location,
    int days,
  ) async {
    try {
      // Get current location if "auto" is passed
      String locationQuery =
          location.toLowerCase() == "auto"
              ? await _getLocationQuery()
              : location;

      // Ensure days is within API limits (1-30)
      int forecastDays = days.clamp(1, 30);

      List<Map<String, dynamic>> extendedForecast = [];

      for (int i = 0; i < forecastDays; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final formattedDate =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        if (i < 14) {
          // Use forecast.json for dates within the next 14 days
          final response = await http.get(
            Uri.parse(
              '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=$locationQuery&days=${i + 1}',
            ),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to load forecast data');
          }

          final data = json.decode(response.body);
          final forecast = data['forecast']['forecastday'];

          extendedForecast.addAll(
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
            }),
          );
        } else {
          // Use future.json for dates beyond 14 days
          final response = await http.get(
            Uri.parse(
              '$_weatherApiBaseUrl/future.json?key=$_weatherApiKey&q=$locationQuery&dt=$formattedDate',
            ),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to load future weather data');
          }

          final data = json.decode(response.body);
          final forecast = data['forecast']['forecastday'];

          extendedForecast.addAll(
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
            }),
          );
        }
      }

      return extendedForecast;
    } catch (e) {
      print('Error fetching future weather data: $e');
      rethrow;
    }
  }

  // Helper method to get location query string
  Future<String> _getLocationQuery() async {
    try {
      Position position = await _getCurrentLocation();
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      print('Error getting location, falling back to IP: $e');
      return 'auto:ip'; // Fallback to IP-based location
    }
  }
}
