import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/weather_provider.dart';

class ExtendedForecastPage extends StatefulWidget {
  const ExtendedForecastPage({super.key});

  @override
  State<ExtendedForecastPage> createState() => _ExtendedForecastPageState();
}

class _ExtendedForecastPageState extends State<ExtendedForecastPage> {
  DateTime currentMonth = DateTime.now();
  String? _cachedRecommendation;
  bool _isLoadingRecommendation = false;
  @override
  void initState() {
    super.initState();
    // Immediate UI rendering with ultra-fast progressive loading
    _initializeDataAsync();
  }

  void _initializeDataAsync() {
    // Priority: Show SOMETHING useful within 2-3 seconds
    Future.microtask(() async {
      if (!mounted) return;

      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );

      // STEP 1: Get minimal essential data IMMEDIATELY (3 days max)
      if (weatherProvider.futureWeather == null ||
          weatherProvider.futureWeather!.isEmpty) {
        // Ultra-fast: Get only 3 days first (fastest possible load)
        await weatherProvider.fetchExtendedForecast('auto', 3);

        // STEP 2: Quick expansion to 7 days (still very fast)
        Future.delayed(const Duration(milliseconds: 100), () async {
          if (mounted) {
            await weatherProvider.fetchExtendedForecast('auto', 7);
          }
        });

        // STEP 3: Medium expansion to 14 days
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (mounted) {
            await weatherProvider.fetchExtendedForecast('auto', 14);
          }
        });

        // STEP 4: Full 30 days in background (user can already interact)
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (mounted) {
            await weatherProvider.fetchExtendedForecast('auto', 30);
          }
        });
      }

      // Load crop recommendation much later in background (non-essential)
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _loadCropRecommendation();
        }
      });
    });
  }

  Future<void> _loadCropRecommendation() async {
    if (mounted && !_isLoadingRecommendation) {
      setState(() {
        _isLoadingRecommendation = true;
      });

      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );

      // Use background processing to avoid blocking UI
      Future.microtask(() async {
        try {
          final recommendation =
              await weatherProvider.getExtendedForecastCropRecommendation();
          if (mounted) {
            setState(() {
              _cachedRecommendation = recommendation;
              _isLoadingRecommendation = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _cachedRecommendation = null;
              _isLoadingRecommendation = false;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppConstants.lightGray,
      appBar: AppBar(
        title: Text(
          loc.thirtyDayForecast,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          // Reload recommendation when weather data changes
          if (weatherProvider.futureWeather != null &&
              weatherProvider.futureWeather!.isNotEmpty &&
              !_isLoadingRecommendation &&
              _cachedRecommendation == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCropRecommendation();
            });
          }

          // FAST SKELETON: Show immediately even if loading
          final forecastData = weatherProvider.futureWeather ?? [];

          // Show skeleton only if we have absolutely no data
          if (weatherProvider.isLoading && forecastData.isEmpty) {
            return _buildFastSkeletonLoader(loc);
          }

          // Show content even with minimal data (3 days minimum)
          if (forecastData.isEmpty) {
            return Center(
              child: Text(
                loc.failedToLoadWeather,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather forecast header (like in old design)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    _getDateRangeText(loc),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ), // Calendar section (matching old UI exactly)
                _buildOldStyleCalendar(context, forecastData, loc),

                const SizedBox(height: 16), // Reduced from 24 to 16
                // Recommended Crop Section (enhanced design)
                _buildRecommendedCropSection(context, loc, weatherProvider),

                const SizedBox(height: 16), // Reduced from 20 to 16
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDateRangeText(AppLocalizations loc) {
    final now = DateTime.now();
    final startDate = now;
    final endDate = now.add(
      const Duration(days: 29),
    ); // 30 days total (including today)
    return loc.weatherForecastCalendar(
      DateFormat('MMM d').format(startDate),
      DateFormat('MMM d').format(endDate),
    );
  }

  String _getLocalizedMonthYear(DateTime date, AppLocalizations loc) {
    final monthNames = [
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
    final monthName = monthNames[date.month - 1];
    return '$monthName ${date.year}';
  }

  Widget _buildOldStyleCalendar(
    BuildContext context,
    List<Map<String, dynamic>> forecastData,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation header (like old design)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black54),
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  _getLocalizedMonthYear(currentMonth, loc),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.black54),
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ), // Day headers (simple like old design)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                _buildDayHeader(loc.sunday),
                _buildDayHeader(loc.monday),
                _buildDayHeader(loc.tuesday),
                _buildDayHeader(loc.wednesday),
                _buildDayHeader(loc.thursday),
                _buildDayHeader(loc.friday),
                _buildDayHeader(loc.saturday),
              ],
            ),
          ),
          // Calendar grid (exactly like old design)
          _buildCalendarGrid(forecastData),

          // Remove excess space for better layout
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<Map<String, dynamic>> forecastData) {
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final weeks = <Widget>[];
    final today = DateTime.now();

    // Calculate the minimum number of weeks needed
    final totalCells = firstWeekday + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();

    for (int week = 0; week < weeksNeeded; week++) {
      final days = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final dayNumber = week * 7 + day - firstWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          // Empty cell for days outside current month
          days.add(const Expanded(child: SizedBox(height: 60)));
        } else {
          final date = DateTime(
            currentMonth.year,
            currentMonth.month,
            dayNumber,
          );
          final weatherData = _getWeatherForDate(forecastData, date);
          days.add(_buildCalendarDayCell(date, weatherData, today));
        }
      }

      weeks.add(Row(children: days));
    }

    return Column(children: weeks);
  }

  Map<String, dynamic>? _getWeatherForDate(
    List<Map<String, dynamic>> forecastData,
    DateTime date,
  ) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    try {
      return forecastData.firstWhere(
        (weather) => weather['date'] == dateString,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildCalendarDayCell(
    DateTime date,
    Map<String, dynamic>? weatherData,
    DateTime today,
  ) {
    final hasWeather = weatherData != null && weatherData.isNotEmpty;
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    // Check if date is in the past or future for weather data availability
    final now = DateTime.now();
    final todayDateOnly = DateTime(now.year, now.month, now.day);
    final thirtyDaysFromToday = todayDateOnly.add(const Duration(days: 29));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final isPast = dateOnly.isBefore(todayDateOnly);
    final isWithin30Days = !isPast && !dateOnly.isAfter(thirtyDaysFromToday);
    final isCurrentMonth =
        date.month == currentMonth.month && date.year == currentMonth.year;
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black87;

    // Color coding based on weather data availability
    if (!isCurrentMonth) {
      // Dates outside current month
      backgroundColor = AppConstants.lightGray;
      textColor = Colors.grey.shade300;
    } else if (!hasWeather || !isWithin30Days) {
      // Past dates OR future dates without weather data (not in 30-day forecast) - grey them out
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade400;
    } else if (hasWeather &&
        isWithin30Days &&
        weatherData['rainChance'] != null) {
      // Dates with weather data (part of 30-day forecast) - color by rain chance
      final rainChance = weatherData['rainChance'] as int;
      if (rainChance >= 80) {
        backgroundColor =
            AppConstants.lightBlue; // Light blue for high rain chance
      } else if (rainChance >= 60) {
        backgroundColor =
            AppConstants.lightGreenBg; // Light green for medium rain
      } else if (rainChance > 0) {
        backgroundColor = const Color(0xFFFFF3E0); // Light orange for low rain
      } else {
        backgroundColor = Colors.white; // White for no rain
      }
    }

    // Today's highlight
    if (isToday) {
      borderColor = AppConstants.materialGreen;
      textColor = AppConstants.materialGreen;
    }

    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isToday ? borderColor : Colors.grey.shade200,
            width: isToday ? 2.0 : 0.5,
          ),
          boxShadow:
              isToday
                  ? [
                    BoxShadow(
                      color: AppConstants.materialGreen.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Day number
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),

              // Temperature (show for dates with weather data)
              if (isWithin30Days &&
                  hasWeather &&
                  weatherData['temperature'] != null)
                Text(
                  '${(weatherData['temperature']['max'] ?? weatherData['temperature']['min'] ?? 0).toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              else
                const SizedBox(height: 9),

              // Rain percentage (show for dates with weather data)
              if (isWithin30Days &&
                  hasWeather &&
                  weatherData['rainChance'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 0.5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        weatherData['rainChance'] > 0
                            ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '${weatherData['rainChance']}%',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                      color:
                          weatherData['rainChance'] > 0
                              ? const Color(0xFF2196F3)
                              : Colors.black54,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCropSection(
    BuildContext context,
    AppLocalizations loc,
    WeatherProvider weatherProvider,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  color: AppConstants.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.recommendedCrop,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      loc.basedOn30DayForecast,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Use cached recommendation instead of FutureBuilder
          _isLoadingRecommendation
              ? Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.analyzingForecast,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
              : _cachedRecommendation == null || _cachedRecommendation!.isEmpty
              ? Text(
                loc.noCropRecommendation,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              )
              : Text(
                _cachedRecommendation!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFastSkeletonLoader(AppLocalizations loc) {
    // Ultra-lightweight skeleton that renders in under 100ms
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Simple calendar skeleton - just boxes
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Month header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 18,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Simple grid of boxes (5 rows x 7 columns)
                ...List.generate(
                  5,
                  (week) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Row(
                      children: List.generate(
                        7,
                        (day) => Expanded(
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Simple recommendation skeleton
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Text skeleton lines
                ...List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
