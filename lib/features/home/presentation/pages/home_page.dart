import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import 'package:harvesthub/main.dart';
import 'package:flutter/services.dart';

import '../../../../core/providers/weather_provider.dart';
import '../../../auth/presentation/pages/edit_profile_page.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../auth/presentation/pages/phone_auth_page.dart';
import 'ai_chat_page.dart';
import 'extended_forecast_page.dart';
import 'help_support_page.dart';
import 'about_page.dart';
import '../../../../screens/community_feed.dart';
import 'package:harvesthub/screens/pest_detect_screen.dart';

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
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
    const PestDetectionScreen(),
    CommunityFeedPage(), // Use the new Community Feed
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Ensure consistent system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Also set the system UI after the frame is built to ensure it sticks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    });

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildModernBottomNavigationBar(localizations),
    );
  }

  Widget _buildModernBottomNavigationBar(AppLocalizations localizations) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_filled,
                label: localizations.home,
                index: 0,
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.smart_toy_rounded,
                label: localizations.harvestBot,
                index: 1,
                isSelected: false, // Never selected since it navigates away
              ),
              _buildNavItem(
                icon: Icons.pest_control_rounded,
                label: localizations.pestDetection,
                index: 2,
                isSelected: _currentIndex == 1, // Adjusted index
              ),
              _buildNavItem(
                icon: Icons.people_alt_rounded,
                label: localizations.community,
                index: 3,
                isSelected: _currentIndex == 2, // Adjusted index
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Set system UI overlay style for consistent navigation bar on tab switch
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );

        // Handle HarvestBot navigation separately
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatPage()),
          );
        } else {
          // Adjust index for other screens since we removed AIChatPage from _screens
          int adjustedIndex = index;
          if (index > 1) {
            adjustedIndex = index - 1;
          }

          setState(() {
            _currentIndex = adjustedIndex;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF16A34A) : Colors.grey.shade500,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color:
                  isSelected ? const Color(0xFF16A34A) : Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  @override
  void dispose() {
    // Cancel any ongoing operations or listeners here if needed
    super.dispose();
  }

  Future<void> _checkLocationServices() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLocationEnabled = false;
        });
      }
      return;
    }

    final isEnabled = await Geolocator.isLocationServiceEnabled();

    if (mounted) {
      setState(() {
        _isLocationEnabled = isEnabled;
      });
    }

    if (isEnabled) {
      _fetchWeatherAndInsights();
    } else if (mounted) {
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
    if (mounted) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeatherAndInsights();
    }
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
          loc.appTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF16A34A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black54),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FutureBuilder<String>(
              future: AvatarUtils.getAvatarWithFallback(
                userId:
                    FirebaseAuth.instance.currentUser?.phoneNumber ?? 'guest',
              ),
              builder: (context, avatarSnapshot) {
                final avatarUrl =
                    avatarSnapshot.data ??
                    'https://avatar.iran.liara.run/public/1';

                return GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF16A34A),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 40,
                            height: 40,
                            color: const Color(0xFFF0F0F0),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildModernDrawer(context, loc),
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
                  colors: [Color(0xff20c25e), Color(0xff12ab64)],
                  stops: [0.25, 0.75],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.currentWeather,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${current['temperature']}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              current['condition'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(current['condition']),
                        color: Colors.white.withOpacity(0.7),
                        size: 80,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.feelsLike(current['feelslike_c']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              loc.humidity(current['humidity']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              loc.cloudCover(current['cloud']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
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
                              loc.pressure(current['pressure_mb']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              loc.wind(
                                current['windSpeed'],
                                current['wind_dir'],
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              loc.uvIndex(current['uv']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.end,
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
                Expanded(
                  child: Text(
                    loc.upcomingForecast,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExtendedForecastPage(),
                      ),
                    );
                  },
                  child: Text(
                    loc.viewAll,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
    final loc = AppLocalizations.of(context)!;
    final today = DateTime.now();

    // Filter out today's data and show only future dates
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final futureForecasts =
        forecast.where((day) {
          try {
            final forecastDate = DateTime.parse(day['date']);
            final forecastDateOnly = DateTime(
              forecastDate.year,
              forecastDate.month,
              forecastDate.day,
            );
            return forecastDateOnly.isAfter(todayDateOnly);
          } catch (e) {
            return false;
          }
        }).toList();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            futureForecasts.length > 3
                ? 3
                : futureForecasts.length, // Limit to 3 future days max
        itemBuilder: (context, index) {
          final day = futureForecasts[index];
          String dayName;

          try {
            final forecastDate = DateTime.parse(day['date']);
            final forecastDateOnly = DateTime(
              forecastDate.year,
              forecastDate.month,
              forecastDate.day,
            );
            final tomorrow = DateTime(today.year, today.month, today.day + 1);
            final tomorrowDateOnly = DateTime(
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
            );

            if (forecastDateOnly.isAtSameMomentAs(tomorrowDateOnly)) {
              dayName = loc.tomorrow;
            } else {
              // Get the month name and day
              final monthNumber = forecastDate.month;
              final dayNumber = forecastDate.day;
              final monthNames = [
                '',
                loc.january,
                loc.february,
                loc.march,
                loc.april,
                loc.may,
                loc.june,
                loc.july,
                loc.august,
                loc.september,
                loc.october,
                loc.november,
                loc.december,
              ];
              final monthName =
                  monthNumber <= 12 ? monthNames[monthNumber] : 'January';
              dayName = '$monthName ${dayNumber.toString().padLeft(2, '0')}';
            }
          } catch (e) {
            dayName = day['date'];
          }

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${day['temperature']['max']}°C',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        day['rainChance'] > 50
                            ? Icons.water_drop
                            : Icons.wb_sunny,
                        size: 14,
                        color:
                            day['rainChance'] > 50
                                ? Colors.blue
                                : Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${day['rainChance']}% ${loc.rain}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    '${loc.minTemperature} ${day['temperature']['min']}°C',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final insights = weatherProvider.insights;
        if (insights == null) {
          return Text(loc.failedToLoadInsights);
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
                          color: const Color(0xFF16A34A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: const Color(0xFF16A34A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.farmingTip,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insights['farmingTip'] ?? loc.noFarmingTip,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
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
                          color: const Color(0xFF16A34A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.eco,
                          color: const Color(0xFF16A34A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.recommendedCrop,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insights['cropRecommendation'] ?? loc.noCropRecommendation,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
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

  // Helper function to get weather icon based on condition
  IconData _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      return Icons.wb_sunny;
    } else if (conditionLower.contains('rain') ||
        conditionLower.contains('shower')) {
      return Icons.water_drop;
    } else if (conditionLower.contains('storm') ||
        conditionLower.contains('thunder')) {
      return Icons.thunderstorm;
    } else if (conditionLower.contains('snow') ||
        conditionLower.contains('blizzard')) {
      return Icons.ac_unit;
    } else if (conditionLower.contains('fog') ||
        conditionLower.contains('mist')) {
      return Icons.foggy;
    } else if (conditionLower.contains('wind')) {
      return Icons.air;
    } else if (conditionLower.contains('cloud') ||
        conditionLower.contains('overcast') ||
        conditionLower.contains('partly')) {
      return Icons.cloud;
    } else {
      return Icons.wb_cloudy; // Default icon
    }
  }

  Widget _buildModernDrawer(BuildContext context, AppLocalizations loc) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Profile Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
                          .get(),
                  builder: (context, snapshot) {
                    String userName = 'Guest User';
                    String userPhone = '';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      userName = userData['name'] ?? 'User';
                      userPhone = userData['phoneNumber'] ?? '';
                    }

                    // Use user's phone number as the seed for consistent avatar
                    final userId =
                        FirebaseAuth.instance.currentUser?.phoneNumber ??
                        'guest';

                    return Column(
                      children: [
                        // Avatar with green border matching reference
                        FutureBuilder<String>(
                          future: AvatarUtils.getAvatarWithFallback(
                            userId: userId,
                          ),
                          builder: (context, avatarSnapshot) {
                            final avatarUrl =
                                avatarSnapshot.data ??
                                'https://avatar.iran.liara.run/public/1';

                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF16A34A),
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  avatarUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: const Color(0xFFF0F0F0),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF16A34A),
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: const Color(0xFFF0F0F0),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Online indicator (green dot)
                        Transform.translate(
                          offset: const Offset(25, -25),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // User Name
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F1F1F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (userPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            userPhone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: const Color(0xFFF0F0F0),
              ),

              // Dark Mode Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.darkMode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    Switch(
                      value: false,
                      onChanged: (value) {
                        // TODO: Implement dark mode logic
                      },
                      activeColor: const Color(0xFF16A34A),
                      inactiveThumbColor: const Color(0xFFE5E5E5),
                      inactiveTrackColor: const Color(0xFFF5F5F5),
                    ),
                  ],
                ),
              ),

              // Separator after Dark Mode
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: const Color(0xFFF0F0F0),
              ), // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildSimpleDrawerItem(
                        icon: Icons.settings_outlined,
                        title: loc.editProfileSettings,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _buildSimpleDrawerItem(
                        icon: Icons.language_outlined,
                        title: loc.changeLanguage,
                        onTap: () async {
                          Navigator.pop(context);
                          await _showLanguageSelector(context, loc);
                        },
                      ),

                      _buildSimpleDrawerItem(
                        icon: Icons.help_outline,
                        title: loc.helpSupport,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportPage(),
                            ),
                          );
                        },
                      ),
                      _buildSimpleDrawerItem(
                        icon: Icons.info_outline,
                        title: loc.about,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Separator line before logout
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: const Color(0xFFF0F0F0),
                      ),

                      _buildSimpleDrawerItem(
                        icon: Icons.logout,
                        title: loc.logout,
                        textColor: const Color(0xFFEF4444),
                        iconColor: const Color(0xFFEF4444),
                        onTap: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhoneAuthPage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            debugPrint('Error during logout: $e');
                          }
                        },
                      ),
                      const SizedBox(height: 24), // Extra bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor ?? textColor ?? const Color(0xFF6B7280),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? const Color(0xFF1F1F1F),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageSelector(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    final languages = [
      {'code': 'en', 'label': loc.english, 'icon': Icons.language},
      {'code': 'hi', 'label': loc.hindi, 'icon': Icons.translate},
      {'code': 'ta', 'label': loc.tamil, 'icon': Icons.g_translate},
      {'code': 'te', 'label': loc.telugu, 'icon': Icons.g_translate},
      {'code': 'ml', 'label': loc.malayalam, 'icon': Icons.g_translate},
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final green = const Color(0xFF16A34A);
        final greyTile = const Color(0xFFF3F3F3);
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    loc.appTitle,
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
                          () => Navigator.pop(context, lang['code'] as String),
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
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            systemNavigationBarColor: Color(0xFFF6F8F7),
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
        final provider = Provider.of<WeatherProvider>(context, listen: false);
        await provider.fetchWeatherAndInsights();
      }
    }
  }
}

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure consistent system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return const PestDetectScreen();
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure consistent system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return CommunityFeedPage();
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
