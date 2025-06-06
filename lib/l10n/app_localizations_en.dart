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
  String get selectLanguage => 'Select Language';

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
  String get thirtyDayForecast => '30-Day Forecast';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'Weather Forecast';
  }

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

  @override
  String get nextContinue => 'CONTINUE';

  @override
  String get proceed => 'PROCEED';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get talkToHarvestBot => 'Talk to HarvestBot';

  @override
  String get createPost => 'Create Post';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get post => 'Post';

  @override
  String get noPostsYet => 'No posts yet.';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get currentWeather => 'Current Weather';

  @override
  String get upcomingForecast => 'Upcoming Forecast';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get minTemperature => 'Min:';

  @override
  String get rain => 'Rain';

  @override
  String get viewAll => 'View All >';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get sunday => 'Sun';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get helpAndSupportTitle => 'Help & Support';

  @override
  String get appFeaturesTitle => 'App Features';

  @override
  String get gettingStartedTitle => 'Getting Started';

  @override
  String get featuresAndUsageTitle => 'Features & Usage';

  @override
  String get contactSupportTitle => 'Contact Support';

  @override
  String get weatherUpdatesFeature => 'Weather Updates';

  @override
  String get weatherUpdatesDesc => 'Get real-time weather information including temperature, humidity, wind speed, and 3-day forecasts to plan your farming activities.';

  @override
  String get aiChatFeature => 'HarvestBot AI Assistant';

  @override
  String get aiChatDesc => 'Chat with our AI-powered farming expert for personalized advice, crop recommendations, and answers to your agricultural questions.';

  @override
  String get pestDetectionFeature => 'Pest Detection';

  @override
  String get pestDetectionDesc => 'Upload photos of your crops to identify potential pest issues and get recommendations for treatment and prevention.';

  @override
  String get communityFeature => 'Farming Community';

  @override
  String get communityDesc => 'Connect with fellow farmers, share experiences, ask questions, and learn from the farming community.';

  @override
  String get multiLanguageFeature => 'Multi-Language Support';

  @override
  String get multiLanguageDesc => 'Use the app in your preferred language with support for English, Hindi, Tamil, Telugu, and Malayalam.';

  @override
  String get profileManagementFeature => 'Profile Management';

  @override
  String get profileManagementDesc => 'Manage your personal information, crop preferences, and location settings for personalized recommendations.';

  @override
  String get gettingStartedStep1 => '1. Set up your profile with your location and crop preferences';

  @override
  String get gettingStartedStep2 => '2. Allow location access for accurate weather updates';

  @override
  String get gettingStartedStep3 => '3. Explore weather forecasts and farming insights on the home screen';

  @override
  String get gettingStartedStep4 => '4. Chat with HarvestBot for personalized farming advice';

  @override
  String get gettingStartedStep5 => '5. Join the community to connect with other farmers';

  @override
  String get weatherUsageTitle => 'Using Weather Features';

  @override
  String get weatherUsageDesc => 'View current weather conditions, 3-day forecasts, and 30-day extended forecasts. Tap \'View All\' to see detailed calendar view.';

  @override
  String get aiChatUsageTitle => 'Using HarvestBot';

  @override
  String get aiChatUsageDesc => 'Ask questions about crops, diseases, fertilizers, or any farming topic. The AI provides context-aware responses based on your conversation.';

  @override
  String get pestDetectionUsageTitle => 'Using Pest Detection';

  @override
  String get pestDetectionUsageDesc => 'Take clear photos of affected plants. The system will analyze and provide identification and treatment recommendations.';

  @override
  String get communityUsageTitle => 'Using Community Features';

  @override
  String get communityUsageDesc => 'Share posts, photos, and experiences. Comment on others\' posts and build connections with fellow farmers.';

  @override
  String get troubleshootingTitle => 'Troubleshooting';

  @override
  String get locationIssues => 'Location Issues';

  @override
  String get locationIssuesDesc => 'Ensure location services are enabled in your device settings for accurate weather data.';

  @override
  String get weatherNotLoading => 'Weather Not Loading';

  @override
  String get weatherNotLoadingDesc => 'Check your internet connection and location permissions. Pull down to refresh the home screen.';

  @override
  String get aiNotResponding => 'AI Not Responding';

  @override
  String get aiNotRespondingDesc => 'Ensure you have a stable internet connection. Try rephrasing your question if the AI doesn\'t understand.';

  @override
  String get contactSupportDesc => 'For additional help or to report issues, you can:';

  @override
  String get emailSupport => 'Email us at: support@harvesthub.com';

  @override
  String get reportIssue => 'Report issues through the app feedback';

  @override
  String get visitWebsite => 'Visit our website: www.harvesthub.com';

  @override
  String get appVersion => 'App Version: 1.5.0';

  @override
  String get lastUpdated => 'Last Updated: June 2025';
}
