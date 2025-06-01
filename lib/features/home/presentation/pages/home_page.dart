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
import 'profile_page.dart'; // Added import for ProfilePage

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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0), // Added margin for floating effect
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0), // Rounded edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green.shade700,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FeatherIcons.home),
                activeIcon: Icon(FeatherIcons.home, color: Colors.green),
                label: loc.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(FeatherIcons.messageCircle),
                activeIcon: Icon(
                  FeatherIcons.messageCircle,
                  color: Colors.green,
                ),
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
        ),
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.appTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              loc.yourFarmingCompanion,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white70),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Used GlobalKey to open the drawer
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white70,
              size: 32,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
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

        return Card(
          color: Colors.teal.shade50,
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
                  loc.weatherForecast,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
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
                          const SizedBox(height: 8),
                          Text(
                            loc.humidity(current['humidity']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            loc.visibility(current['vis_km']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            loc.feelsLike(current['feelslike_c']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            loc.wind(current['windSpeed'], current['wind_dir']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            loc.pressure(current['pressure_mb']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            loc.uvIndex(current['uv']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            loc.cloudCover(current['cloud']),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, color: Colors.teal),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loc.threeDayForecast,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ExtendedForecastPage(),
                            ),
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            loc.viewMore,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current['temperature']}°C',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    current['condition'],
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Feels Like: ${current['feelslike_c']}°C',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Wind: ${current['windSpeed']} km/h (${current['wind_dir']})',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Pressure: ${current['pressure_mb']} mb',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Humidity: ${current['humidity']}%',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Visibility: ${current['vis_km']} km',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'UV: ${current['uv']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Precip: ${current['precip_mm']} mm',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, List<dynamic> forecast) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            forecast.map<Widget>((day) {
              return Container(
                width: 140,
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day['temperature']['max']}°C / ${day['temperature']['min']}°C',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day['rainChance']}% Rain',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
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
        final loc = AppLocalizations.of(context)!;
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
                  insights['farmingTip'] ?? 'No farming tip available',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 32, color: Colors.teal),
                Row(
                  children: [
                    const Icon(Icons.grass, color: Colors.brown),
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
