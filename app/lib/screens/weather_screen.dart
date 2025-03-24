import 'package:flutter/material.dart';
import 'package:harvesthub/models/weather_model.dart';
import 'package:harvesthub/gemini_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Weather _weather;
  String _weatherAdvice = "Loading AI farming recommendations...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    // In a real app, fetch this from a weather API
    // For this example, we'll use mock data
    _weather = Weather.mock();
    
    // Get AI-powered farming advice for this weather
    await _getWeatherAdvice();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getWeatherAdvice() async {
    try {
      final geminiService = GeminiService(
        Secrets.geminiApiKey,
      );
      
      final weatherData = {
        'temperature': _weather.temperature,
        'humidity': _weather.humidity,
        'windSpeed': _weather.windSpeed,
        'rainfall': _weather.rainfall,
        'description': _weather.description,
      };
      
      final advice = await geminiService.getWeatherAdvice(weatherData);
      
      setState(() {
        _weatherAdvice = advice;
      });
    } catch (e) {
      setState(() {
        _weatherAdvice = "Could not load AI recommendations. Please try again later.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Insights'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildWeatherCard(),
                  _buildAdviceCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weather.location,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Updated: ${_formatDateTime(_weather.timestamp)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Icon(
                  _getWeatherIcon(_weather.description),
                  size: 64,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Feels like: ${_weather.feelsLike.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Min: ${_weather.tempMin.toStringAsFixed(1)}°C | Max: ${_weather.tempMax.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _weather.description,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.water_drop, '${_weather.humidity}%', 'Humidity'),
                _buildWeatherDetail(Icons.air, '${_weather.windSpeed} km/h', 'Wind'),
                _buildWeatherDetail(Icons.umbrella, '${_weather.rainfall} mm', 'Rain'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Farming Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _weatherAdvice,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('cloud')) {
      return Icons.cloud;
    } else if (description.contains('rain')) {
      return Icons.water_drop;
    } else if (description.contains('sun') || description.contains('clear')) {
      return Icons.wb_sunny;
    } else if (description.contains('storm') || description.contains('thunder')) {
      return Icons.thunderstorm;
    } else if (description.contains('snow')) {
      return Icons.ac_unit;
    } else if (description.contains('fog') || description.contains('haze')) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud_queue;
    }
  }
}

// This would normally be imported from main.dart
class Secrets {
  static String geminiApiKey = '';
}