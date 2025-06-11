import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/providers/weather_provider.dart';

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
      setState(() {
        _isLoading = true;
      });

      // Fetch AI-generated insights using GeminiService
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );
      final currentWeather = weatherProvider.weatherData?['current'];

      if (currentWeather == null) {
        throw Exception('Failed to fetch current weather data');
      }

      final geminiService = GeminiService();
      final insights = await geminiService.getAgriculturalInsights(
        temperature: (currentWeather['temperature'] as num).toDouble(),
        humidity: (currentWeather['humidity'] as num).toDouble(),
        rainfall: (currentWeather['precipitation'] as num?)?.toDouble() ?? 0.0,
        windSpeed: (currentWeather['windSpeed'] as num).toDouble(),
        condition: currentWeather['condition'],
      );

      // Ensure only relevant content is displayed in each section
      setState(() {
        _farmingTip =
            insights['farmingTip']?.trim() ?? 'No farming tip available';
        _cropRecommendation =
            insights['cropRecommendation']?.trim() ??
            'No crop recommendation available';
      });
    } catch (e) {
      setState(() {
        _farmingTip = 'Error fetching insights: $e';
        _cropRecommendation = 'Error fetching insights: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.farmingTip),
      ), // fallback to farmingTip as section title
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
                          children: [
                            const Icon(Icons.eco, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              loc.farmingTip,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _farmingTip ?? loc.noFarmingTip,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.grass, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              loc.recommendedCrop,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cropRecommendation ?? loc.noCropRecommendation,
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
