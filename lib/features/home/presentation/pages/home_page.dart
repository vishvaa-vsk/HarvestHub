import 'package:flutter/material.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/weather_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarvestHub'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherCard(context),
            const SizedBox(height: 16),
            _buildCropAdviceCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    final weatherService = WeatherService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather Forecast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Icon(Icons.cloud_outlined, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: weatherService.getWeatherData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Text('No weather data available');
                }

                final weather = snapshot.data!;
                final current = weather['current'];
                final agricultural = weather['agricultural'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeather(context, current),
                    const Divider(height: 32),
                    _buildAgriculturalMetrics(context, agricultural),
                    const Divider(height: 32),
                    Text(
                      '3-Day Forecast',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildForecast(context, weather['forecast']),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(
    BuildContext context,
    Map<String, dynamic> current,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${current['temperature']}°C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              current['condition'],
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Humidity: ${current['humidity']}%'),
            Text('Wind: ${current['windSpeed']} km/h'),
          ],
        ),
      ],
    );
  }

  Widget _buildAgriculturalMetrics(
    BuildContext context,
    Map<String, dynamic> agricultural,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agricultural Metrics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricItem(
              'Soil Moisture',
              '${agricultural['soilMoisture']}%',
            ),
            _buildMetricItem(
              'Evaporation',
              '${agricultural['evaporation']} mm',
            ),
            _buildMetricItem('UV Index', agricultural['uvIndex'].toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, List<dynamic> forecast) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          forecast.map((day) {
            final date = DateTime.parse(day['date']).day;
            return Column(
              children: [
                Text('Day $date'),
                const SizedBox(height: 4),
                Text('${day['temperature']['max']}°'),
                Text('${day['temperature']['min']}°'),
                const SizedBox(height: 4),
                Text('${day['rainChance']}%'),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildCropAdviceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop Advisor', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final advice = await GeminiService.getCropAdvice(
                  weather: 'Sunny, 25°C',
                  soilType: 'Loamy',
                );
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Crop Advice'),
                          content: Text(advice),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: const Text('Get Crop Advice'),
            ),
          ],
        ),
      ),
    );
  }
}
