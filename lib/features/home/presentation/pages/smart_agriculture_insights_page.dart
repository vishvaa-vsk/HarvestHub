import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/services/gemini_service.dart';

class SmartAgricultureInsightsPage extends StatefulWidget {
  const SmartAgricultureInsightsPage({super.key});

  @override
  State<SmartAgricultureInsightsPage> createState() =>
      _SmartAgricultureInsightsPageState();
}

class _SmartAgricultureInsightsPageState
    extends State<SmartAgricultureInsightsPage> {
  bool _isLoading = true;
  String? _farmingTip;
  String? _cropRecommendation;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    try {
      // Fetch weather data from WeatherAPI
      final weatherResponse = await http.get(
        Uri.parse(
          'https://api.weatherapi.com/v1/current.json?key=${dotenv.env['WEATHER_API_KEY']}&q=London',
        ),
      );
      print('WeatherAPI Response: ${weatherResponse.body}');

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to fetch weather data');
      }

      final weatherData = json.decode(weatherResponse.body);
      final temperature = weatherData['current']['temp_c'];
      final humidity = weatherData['current']['humidity'];
      final rainfall = weatherData['current']['precip_mm'];
      final windSpeed = weatherData['current']['wind_kph'];
      final condition = weatherData['current']['condition']['text'];

      // Fetch AI-generated insights using GeminiService
      final geminiService = GeminiService();
      final insights = await geminiService.getAgriculturalInsights(
        temperature: temperature,
        humidity: humidity,
        rainfall: rainfall,
        windSpeed: windSpeed,
        condition: condition,
      );

      setState(() {
        _farmingTip = insights['farmingTip'];
        _cropRecommendation = insights['cropRecommendation'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _farmingTip = 'Error fetching insights: $e';
        _cropRecommendation = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Agricultural Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.eco, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Farming Tip',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _farmingTip ?? 'No tip available',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: const [
                            Icon(Icons.grass, color: Colors.brown),
                            SizedBox(width: 8),
                            Text(
                              'Recommended Crop',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cropRecommendation ?? 'No recommendation available',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
