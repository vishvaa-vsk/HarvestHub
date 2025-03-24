import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _baseUrl =
      'https://earthengine.googleapis.com/v1/projects';
  final String? _apiKey = dotenv.env['GOOGLE_CLOUD_API_KEY'];

  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      // Get current location
      Position position = await _getCurrentLocation();

      // Get weather data from Google Cloud
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/${dotenv.env['GOOGLE_CLOUD_PROJECT_ID']}/assets/weather'
          '?location=${position.latitude},${position.longitude}'
          '&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Return mock data for testing until API is properly configured
      return _getMockWeatherData();
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

  // Mock data for testing
  Map<String, dynamic> _getMockWeatherData() {
    return {
      "current": {
        "temperature": 28,
        "humidity": 65,
        "condition": "Partly cloudy",
        "windSpeed": 12,
        "rainfall": 0,
      },
      "forecast": [
        {
          "date": DateTime.now().add(const Duration(days: 1)).toString(),
          "temperature": {"min": 22, "max": 30},
          "condition": "Sunny",
          "rainChance": 10,
        },
        {
          "date": DateTime.now().add(const Duration(days: 2)).toString(),
          "temperature": {"min": 23, "max": 31},
          "condition": "Cloudy",
          "rainChance": 30,
        },
        {
          "date": DateTime.now().add(const Duration(days: 3)).toString(),
          "temperature": {"min": 21, "max": 29},
          "condition": "Light rain",
          "rainChance": 60,
        },
      ],
      "agricultural": {"soilMoisture": 75, "evaporation": 4.5, "uvIndex": 6},
    };
  }
}
