import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added import for FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import for Firestore
import 'package:harvesthub/l10n/app_localizations.dart';
import 'package:harvesthub/main.dart'; // Import the file where the GlobalKey is defined
import 'package:flutter/services.dart';

import '../../../../core/providers/weather_provider.dart';
import '../../../auth/presentation/pages/edit_profile_page.dart';
import '../../../auth/presentation/pages/phone_auth_page.dart'; // Added import for PhoneAuthPage
import 'ai_chat_page.dart';
import 'extended_forecast_page.dart';
import '../../../../screens/community_feed.dart';
import 'package:harvesthub/screens/pest_detect_screen.dart';

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
    const AIChatPage(),
    const PestDetectionScreen(),
    CommunityFeedPage(), // Use the new Community Feed
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.home),
            activeIcon: Icon(FeatherIcons.home, color: Colors.green),
            label: loc.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.messageCircle),
            activeIcon: Icon(FeatherIcons.messageCircle, color: Colors.green),
            label: loc.harvestBot,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pest_control),
            activeIcon: Icon(Icons.pest_control, color: Colors.green),
            label: loc.pestDetection,
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.users),
            activeIcon: Icon(FeatherIcons.users, color: Colors.green),
            label: loc.community,
          ),
        ],
      ),
    );
  }
}

/// The home page of the HarvestHub application.
///
/// This page displays weather data, agricultural insights, and navigation
/// options. It also includes a drawer for accessing profile settings and
/// changing the app's language.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Added GlobalKey

  bool _isLocationEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  Future<void> _checkLocationServices() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationEnabled = false;
      });
      return;
    }

    final isEnabled = await Geolocator.isLocationServiceEnabled();

    setState(() {
      _isLocationEnabled = isEnabled;
    });

    if (isEnabled) {
      _fetchWeatherAndInsights();
    } else {
      final context = this.context;
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(loc.enableLocationServices),
            content: Text(loc.locationServicesRequired),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openLocationSettings();
                },
                child: Text(loc.openSettings),
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'HarvestHub',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black54),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              // Notification functionality can be added here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data!.exists) {
                    return const Text(
                      'Error loading user data',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    );
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade700,
                              Colors.green.shade400,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData['phoneNumber'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: Text(loc.editProfileSettings),
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
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text(loc.changeLanguage),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                final languages = [
                  {'code': 'en', 'label': loc.english, 'icon': Icons.language},
                  {'code': 'hi', 'label': loc.hindi, 'icon': Icons.translate},
                  {'code': 'ta', 'label': loc.tamil, 'icon': Icons.g_translate},
                  {
                    'code': 'te',
                    'label': loc.telugu,
                    'icon': Icons.g_translate,
                  },
                  {
                    'code': 'ml',
                    'label': loc.malayalam,
                    'icon': Icons.g_translate,
                  },
                ];
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    final theme = Theme.of(context);
                    final green = Colors.green.shade700;
                    final greyTile = const Color(0xFFF3F3F3);
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'HarvestHub',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 3, top: 2),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              loc.selectLanguage,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 2.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final lang in languages)
                                _LanguageTileModal(
                                  label: lang['label'] as String,
                                  icon: lang['icon'] as IconData,
                                  onTap:
                                      () => Navigator.pop(
                                        context,
                                        lang['code'] as String,
                                      ),
                                  accent: green,
                                  grey: greyTile,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
                if (selected != null) {
                  final rootState = harvestHubAppKey.currentState;
                  if (rootState != null) {
                    await rootState.setLocale(selected);
                    // Reset system navigation bar color after locale change
                    SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                        systemNavigationBarColor: Color(0xFFF6F8F7),
                        systemNavigationBarIconBrightness: Brightness.dark,
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.dark,
                      ),
                    );
                    // Fetch new weather and insights in the new language
                    final provider = Provider.of<WeatherProvider>(
                      context,
                      listen: false,
                    );
                    await provider.fetchWeatherAndInsights();
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(loc.logout),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut(); // Sign out the user
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const PhoneAuthPage(), // Redirect to PhoneAuthPage
                    ),
                    (route) => false, // Remove all previous routes
                  );
                } catch (e) {
                  debugPrint('Error during logout: $e');
                }
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
              : Center(
                child: Text(
                  loc.locationServicesRequired,
                  textAlign: TextAlign.center,
                ),
              ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final weather = weatherProvider.weatherData;
        if (weather == null) {
          return Center(child: Text(loc.failedToLoadWeather));
        }

        final current = weather['current'];
        final forecast = weather['forecast'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weather Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Weather',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud,
                          color: Colors.white.withOpacity(0.8),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${current['temperature']}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    current['condition'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feels Like: ${current['feelslike_c']}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Humidity: ${current['humidity']}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Wind: ${current['windSpeed']} km/h (${current['wind_dir']})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              'UV Index: ${current['uv']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming Forecast Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExtendedForecastPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All >',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildForecast(context, forecast),
          ],
        );
      },
    );
  }

  Widget _buildForecast(BuildContext context, List<dynamic> forecast) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length > 3 ? 3 : forecast.length,
        itemBuilder: (context, index) {
          final day = forecast[index];
          String dayName;

          if (index == 0) {
            dayName = 'Tomorrow';
          } else {
            // Parse the date string and format it
            try {
              final parts = day['date'].split(' ');
              if (parts.length >= 2) {
                dayName = '${parts[0]} ${parts[1]}';
              } else {
                dayName = day['date'];
              }
            } catch (e) {
              dayName = day['date'];
            }
          }

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Text(
                  '${day['temperature']['max']}°C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      day['rainChance'] > 50
                          ? Icons.water_drop
                          : Icons.wb_sunny,
                      size: 16,
                      color:
                          day['rainChance'] > 50 ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      day['rainChance'] > 50
                          ? '${day['rainChance']}% Rain'
                          : '${day['rainChance']}% Rain',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Min: ${day['temperature']['min']}°C',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
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

        return Column(
          children: [
            // Farming Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Farming Tip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    insights['farmingTip'] ?? 'No farming tip available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recommended Crop Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.eco,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recommended Crop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    insights['cropRecommendation'] ??
                        'No crop recommendation available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return const PestDetectScreen();
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Community Screen'));
  }
}

class _LanguageTileModal extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
  final Color grey;
  const _LanguageTileModal({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.accent,
    required this.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: grey,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
