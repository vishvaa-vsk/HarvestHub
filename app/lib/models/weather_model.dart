class Weather {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;
  final double rainfall;
  final String location;
  final DateTime timestamp;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.rainfall,
    required this.location,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final wind = json['wind'];
    
    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'],
      description: weather['description'],
      icon: weather['icon'],
      windSpeed: (wind['speed'] as num).toDouble(),
      rainfall: json['rain'] != null ? (json['rain']['1h'] as num).toDouble() : 0.0,
      location: json['name'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  // Create a mock weather instance for testing
  factory Weather.mock() {
    return Weather(
      temperature: 25.4,
      feelsLike: 26.0,
      tempMin: 23.1,
      tempMax: 27.8,
      humidity: 65,
      description: 'Partly cloudy',
      icon: '04d',
      windSpeed: 3.5,
      rainfall: 0.0,
      location: 'Sample Farm',
      timestamp: DateTime.now(),
    );
  }
}