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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );
      if (weatherProvider.futureWeather == null ||
          weatherProvider.futureWeather!.isEmpty) {
        weatherProvider.fetchExtendedForecast('auto', 30);
      }
      _loadCropRecommendation();
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

          if (weatherProvider.isLoading &&
              (weatherProvider.futureWeather == null ||
                  weatherProvider.futureWeather!.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.materialGreen,
                ),
              ),
            );
          }

          final forecastData = weatherProvider.futureWeather;
          if (forecastData == null || forecastData.isEmpty) {
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

                const SizedBox(height: 16),

                // Calendar section (matching old UI exactly)
                _buildOldStyleCalendar(context, forecastData, loc),

                const SizedBox(height: 24),

                // Recommended Crop Section (enhanced design)
                _buildRecommendedCropSection(context, loc, weatherProvider),

                const SizedBox(height: 20),
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
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation header (like old design)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),

          // Day headers (simple like old design)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
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

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
    int lastDayNumber = 0;

    for (int week = 0; week < 6; week++) {
      final days = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final dayNumber = week * 7 + day - firstWeekday + 1;
        lastDayNumber = dayNumber;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          days.add(const SizedBox(height: 65)); // Fixed height like old design
        } else {
          final date = DateTime(
            currentMonth.year,
            currentMonth.month,
            dayNumber,
          );
          final weatherData = _getWeatherForDate(forecastData, date);
          days.add(_buildOldStyleDayCell(dayNumber, date, weatherData, today));
        }
      }

      weeks.add(Row(children: days));
      if (weeks.length >= 5 && lastDayNumber >= daysInMonth) break;
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

  Widget _buildOldStyleDayCell(
    int dayNumber,
    DateTime date,
    Map<String, dynamic>? weatherData,
    DateTime today,
  ) {
    final hasWeather = weatherData != null && weatherData.isNotEmpty;
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    // Check if date is in the past (before today) or beyond 30 days from today
    final now = DateTime.now();
    final todayDateOnly = DateTime(now.year, now.month, now.day);
    final thirtyDaysFromToday = todayDateOnly.add(
      const Duration(days: 29),
    ); // 30 days total including today
    final dateOnly = DateTime(date.year, date.month, date.day);

    final isPast = dateOnly.isBefore(todayDateOnly);
    final isBeyond30Days = dateOnly.isAfter(thirtyDaysFromToday);
    final isWithin30Days = !isPast && !isBeyond30Days;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black87;

    // If date is in past, make it grey
    if (isPast) {
      backgroundColor = AppConstants.lightGray;
      textColor = Colors.grey.shade400;
    } else if (isBeyond30Days) {
      // Dates beyond 30 days - show them as inactive
      backgroundColor = AppConstants.offWhite;
      textColor = Colors.grey.shade300;
    } else if (isWithin30Days) {
      // Color coding for dates within 30-day forecast period
      if (hasWeather && weatherData['rainChance'] != null) {
        final rainChance = weatherData['rainChance'] as int;
        if (rainChance >= 80) {
          backgroundColor = AppConstants.lightBlue; // Light blue for 80%+
        } else if (rainChance >= 60) {
          backgroundColor = AppConstants.lightGreenBg; // Light green for 60-79%
        } else if (rainChance > 0) {
          backgroundColor = const Color(
            0xFFFFF3E0,
          ); // Light orange for any rain
        } else {
          backgroundColor = Colors.white; // White for 0%
        }
      }
    }

    // Today's highlight (green border for current date)
    if (isToday) {
      borderColor = AppConstants.materialGreen;
      textColor = AppConstants.materialGreen;
    }

    return Expanded(
      child: Container(
        height: 65, // Fixed height like old design
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isToday ? borderColor : Colors.grey.shade300,
            width: isToday ? 2.0 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Day number
              Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ), // Temperature (show for dates within 30-day forecast period with weather data)
              if (isWithin30Days &&
                  hasWeather &&
                  weatherData['temperature'] != null)
                Text(
                  '${(weatherData['temperature']['max'] ?? weatherData['temperature']['min'] ?? 0).toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                )
              else
                const SizedBox(height: 13), // Maintain spacing
              // Rain percentage (show for dates within 30-day forecast period with weather data)
              if (isWithin30Days &&
                  hasWeather &&
                  weatherData['rainChance'] != null)
                Text(
                  '${weatherData['rainChance']}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color:
                        weatherData['rainChance'] > 0
                            ? const Color(0xFF2196F3) // Blue for rain
                            : Colors.black54, // Gray for no rain
                  ),
                )
              else
                const SizedBox(height: 12), // Maintain spacing
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
                  color: AppConstants.primaryGreen.withOpacity(0.1),
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
              // Add refresh button
              IconButton(
                onPressed:
                    _isLoadingRecommendation
                        ? null
                        : () {
                          setState(() {
                            _cachedRecommendation = null;
                          });
                          _loadCropRecommendation();
                        },
                icon: Icon(
                  Icons.refresh,
                  color:
                      _isLoadingRecommendation
                          ? Colors.grey
                          : AppConstants.primaryGreen,
                  size: 20,
                ),
                tooltip: 'Refresh recommendation',
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
}
