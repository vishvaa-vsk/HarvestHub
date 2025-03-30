import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../../../core/services/weather_service.dart';

class HarvestHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIChatScreen(),
    const PestDetectionScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.green.shade400,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.cloud),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.messageCircle),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.alertTriangle),
            label: 'Pest Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.users),
            label: 'Community',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 1; // Navigate to AI Chat
          });
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildWeatherCard(context)),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Toggle Weekly/Extended Forecast'),
            ),
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
                final forecast = weather['forecast'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeather(context, current),
                    const Divider(height: 32),
                    Text(
                      '3-Day Forecast',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildForecast(context, forecast),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                Text('Feels Like: ${current['feelslike_c']}°C'),
                Text(
                  'Wind: ${current['windSpeed']} km/h (${current['wind_dir']})',
                ),
                Text('Pressure: ${current['pressure_mb']} mb'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Humidity: ${current['humidity']}%'),
                Text('Visibility: ${current['vis_km']} km'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('UV Index: ${current['uv']}'),
                Text('Cloud Cover: ${current['cloud']}%'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, List<dynamic> forecast) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: forecast.map((day) {
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  day['date'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${day['temperature']['max']}°C / ${day['temperature']['min']}°C',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text('${day['rainChance']}% Rain'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('AI Chat Screen'));
  }
}

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pest Detection Screen'));
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Community Screen'));
  }
}
