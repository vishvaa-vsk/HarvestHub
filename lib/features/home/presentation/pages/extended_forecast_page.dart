import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/weather_provider.dart';

class ExtendedForecastPage extends StatefulWidget {
  const ExtendedForecastPage({super.key});

  @override
  State<ExtendedForecastPage> createState() => _ExtendedForecastPageState();
}

class _ExtendedForecastPageState extends State<ExtendedForecastPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch forecast data only once
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );
      if (weatherProvider.futureWeather == null ||
          weatherProvider.futureWeather!.isEmpty) {
        weatherProvider.fetchExtendedForecast(
          'auto',
          30,
        ); // Provide location and days
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('30-Day Weather Forecast')),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading &&
              (weatherProvider.futureWeather == null ||
                  weatherProvider.futureWeather!.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          final forecastData = weatherProvider.futureWeather;
          if (forecastData == null || forecastData.isEmpty) {
            return const Center(child: Text('No forecast data available'));
          }

          return Column(
            children: [
              Expanded(
                child: CalendarWidget(
                  forecastData: forecastData,
                  allowMonthNavigation: true, // Enable month navigation
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
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
                            Icon(Icons.grass, color: Colors.green),
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
                          weatherProvider.insights?['cropRecommendation'] ??
                              'No crop recommendation available',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> forecastData;
  final bool allowMonthNavigation;

  const CalendarWidget({super.key, 
    required this.forecastData,
    this.allowMonthNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today; // Start from today
    final endDate = today.add(
      const Duration(days: 29),
    ); // Ensure 30 days are included

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Weather Forecast: ${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Month navigation
          if (allowMonthNavigation)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: null, // Disable going back before current month
                ),
                Text(
                  DateFormat('MMMM yyyy').format(today),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: null, // Disable going forward
                ),
              ],
            ),
          // Day of week headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(
                  width: 30,
                  child: Text('Sun', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Mon', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Tue', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Wed', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Thu', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Fri', textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 30,
                  child: Text('Sat', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Custom calendar grid - using Expanded with a SingleChildScrollView to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: _buildCalendarGrid(
                context,
                today,
                forecastData,
                startDate,
                endDate,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    DateTime focusedDate,
    List<Map<String, dynamic>> weatherData,
    DateTime startDate,
    DateTime endDate,
  ) {
    final daysInMonth =
        DateTime(focusedDate.year, focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final firstWeekdayOfMonth =
        firstDayOfMonth.weekday % 7; // 0-based weekday (0 = Sunday)

    // Calculate number of weeks needed
    final int weeksNeeded = ((daysInMonth + firstWeekdayOfMonth) / 7).ceil();

    // Adjust the calendar grid to include all days in the range
    final days = List.generate(weeksNeeded * 7, (index) {
      final dayOffset = index - firstWeekdayOfMonth;
      final day = DateTime(focusedDate.year, focusedDate.month, 1 + dayOffset);

      // Check if this day is within the forecast range
      final isInForecastRange =
          day.isAfter(startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(endDate.add(const Duration(days: 1)));

      // Check if this day belongs to the current month
      final isCurrentMonth = day.month == focusedDate.month;

      if (isInForecastRange) {
        // Find weather data for this day
        final weather = weatherData.firstWhere(
          (entry) => entry['date'] == DateFormat('yyyy-MM-dd').format(day),
          orElse: () => {},
        );

        if (weather.isNotEmpty) {
          return _buildDayCell(day, weather, isCurrentMonth);
        }
      }

      // Return a placeholder for days outside the forecast range or current month
      return _buildEmptyCell();
    });

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7, // 7 days per week
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 0.75, // Make cells taller than they are wide
      children: days,
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Map<String, dynamic> weather,
    bool isCurrentMonth,
  ) {
    final hasWeather = weather.isNotEmpty;
    final isToday =
        day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday ? Colors.blue : Colors.grey.withOpacity(0.3),
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isCurrentMonth ? null : Colors.grey.withOpacity(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCurrentMonth ? Colors.black : Colors.grey,
              ),
            ),
            if (hasWeather) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '${weather['temperature']['max']}°C',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrentMonth ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '${weather['rainChance']}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentMonth ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.withOpacity(0.05),
      ),
    );
  }
}
