import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../auth/presentation/pages/edit_profile_page.dart';
import 'ai_chat_page.dart';
import 'extended_forecast_page.dart';

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

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
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIChatPage(), // Correctly linked AIChatPage
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
          BottomNavigationBarItem(icon: Icon(FeatherIcons.home), label: 'Home'),
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
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLocationEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  Future<void> _checkLocationServices() async {
    debugPrint('Requesting location permissions...');
    final permission = await Geolocator.requestPermission();
    debugPrint('Location permission status: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied.');
      setState(() {
        _isLocationEnabled = false;
      });
      return;
    }

    debugPrint('Checking if location services are enabled...');
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('Location services enabled: $isEnabled');

    setState(() {
      _isLocationEnabled = isEnabled;
    });

    if (isEnabled) {
      debugPrint('Fetching weather and insights...');
      _fetchWeatherAndInsights();
    } else {
      debugPrint('Prompting user to enable location services...');
      final context = this.context;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Location Services'),
            content: const Text(
              'Location services are required to use this app. Please enable them in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  Future<void> _fetchWeatherAndInsights() async {
    Provider.of<WeatherProvider>(
      context,
      listen: false,
    ).fetchWeatherAndInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarvestHub'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(
                    context,
                  ).openDrawer(); // Open the drawer when the hamburger icon is clicked
                },
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Add functionality for the profile icon here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade400),
              child: const Text(
                'HarvestHub Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Edit Profile Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body:
          _isLocationEnabled
              ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherCard(context),
                    const SizedBox(height: 16),
                    _buildInsightsSection(context),
                  ],
                ),
              )
              : const Center(
                child: Text(
                  'Location services are required to use this app.',
                  textAlign: TextAlign.center,
                ),
              ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final weather = weatherProvider.weatherData;
        if (weather == null) {
          return const Text('Failed to load weather data');
        }

        final current = weather['current'];
        final forecast = weather['forecast'];

        return Card(
          color: Colors.teal.shade50, // Reverted to blue background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Forecast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color:
                        Colors
                            .black, // Darker text color for better readability
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCurrentWeather(context, current),
                const Divider(height: 32, color: Colors.teal),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3-Day Forecast',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87, // Improved text contrast
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExtendedForecastPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'View More',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildForecast(context, forecast),
              ],
            ),
          ),
        );
      },
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
        children:
            forecast.map((day) {
              return Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
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

  Widget _buildInsightsSection(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final insights = weatherProvider.insights;
        if (insights == null) {
          return const Text('Failed to load insights');
        }

        return Card(
          color: Colors.teal.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  insights['farmingTip'] ?? 'No farming tip available',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 32, color: Colors.teal),
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
                  insights['cropRecommendation'] ??
                      'No crop recommendation available',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const AIChatPage();
  }
}

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pest Detection'));
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Community Screen'));
  }
}
