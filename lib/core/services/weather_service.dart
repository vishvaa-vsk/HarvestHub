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
      print(
        'Location fetched: Latitude=${position.latitude}, Longitude=${position.longitude}',
      );

      // Fetch current weather data from WeatherAPI
      final currentWeatherResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/current.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}',
        ),
      );
      print(
        'WeatherAPI Current Weather Response: ${currentWeatherResponse.statusCode}',
      );
      print('Response Body: ${currentWeatherResponse.body}');

      if (currentWeatherResponse.statusCode != 200) {
        throw Exception('Failed to load current weather data');
      }

      final currentWeather = json.decode(currentWeatherResponse.body);

      // Fetch 3-day forecast data from WeatherAPI
      final forecastResponse = await http.get(
        Uri.parse(
          '$_weatherApiBaseUrl/forecast.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}&days=3',
        ),
      );
      print('WeatherAPI Forecast Response: ${forecastResponse.statusCode}');
      print('Response Body: ${forecastResponse.body}');

      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to load forecast data');
      }

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

      return {
        'current': {
          'temperature': currentWeather['current']['temp_c'],
          'humidity': currentWeather['current']['humidity'],
          'condition': currentWeather['current']['condition']['text'],
          'windSpeed': currentWeather['current']['wind_kph'],
        },
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
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
