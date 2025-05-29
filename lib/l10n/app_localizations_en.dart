// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HarvestHub';

  @override
  String get welcomeMessage => 'Welcome to HarvestHub!';

  @override
  String get selectLanguage => 'Select Preferred Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get tamil => 'Tamil';

  @override
  String get telugu => 'Telugu';

  @override
  String get malayalam => 'Malayalam';

  @override
  String get home => 'Home';

  @override
  String get harvestBot => 'HarvestBot';

  @override
  String get pestDetection => 'Pest Detection';

  @override
  String get community => 'Community';

  @override
  String get yourFarmingCompanion => 'Your farming companion';

  @override
  String get editProfileSettings => 'Edit Profile Settings';

  @override
  String get logout => 'Logout';

  @override
  String get errorLoadingUserData => 'Error loading user data';

  @override
  String get weatherForecast => 'Weather Forecast';

  @override
  String feelsLike(Object value) {
    return 'Feels Like: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'Wind: $speed km/h ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'Pressure: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'Humidity: $value%';
  }

  @override
  String visibility(Object value) {
    return 'Visibility: $value km';
  }

  @override
  String uvIndex(Object value) {
    return 'UV Index: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'Cloud Cover: $value%';
  }

  @override
  String get threeDayForecast => '3-Day Forecast';

  @override
  String get viewMore => 'View More';

  @override
  String get failedToLoadWeather => 'Failed to load weather data';

  @override
  String get farmingTip => 'Farming Tip';

  @override
  String get noFarmingTip => 'No farming tip available';

  @override
  String get recommendedCrop => 'Recommended Crop';

  @override
  String get noCropRecommendation => 'No crop recommendation available';

  @override
  String get locationServicesRequired => 'Location services are required to use this app.';

  @override
  String get failedToLoadInsights => 'Failed to load insights';

  @override
  String get sendOTP => 'Send OTP';

  @override
  String get verifyOTP => 'Verify OTP';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterOTP => 'Enter OTP';

  @override
  String get pleaseEnterNameAndPhone => 'Please enter your name and phone number';

  @override
  String get invalidOTP => 'Invalid OTP';

  @override
  String get failedToSendOTP => 'Failed to send OTP. Please try again.';

  @override
  String get failedToSignIn => 'Failed to sign in';

  @override
  String get enableLocationServices => 'Enable Location Services';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';
}
