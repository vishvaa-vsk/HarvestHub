import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HarvestHub'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HarvestHub!'**
  String get welcomeMessage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @harvestBot.
  ///
  /// In en, this message translates to:
  /// **'HarvestBot'**
  String get harvestBot;

  /// No description provided for @pestDetection.
  ///
  /// In en, this message translates to:
  /// **'Pest Detection'**
  String get pestDetection;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @yourFarmingCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your farming companion'**
  String get yourFarmingCompanion;

  /// No description provided for @editProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Settings'**
  String get editProfileSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @errorLoadingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error loading user data'**
  String get errorLoadingUserData;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherForecast;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like: {value}°C'**
  String feelsLike(Object value);

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind: {speed} km/h ({dir})'**
  String wind(Object speed, Object dir);

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure: {value} mb'**
  String pressure(Object value);

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity: {value}%'**
  String humidity(Object value);

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility: {value} km'**
  String visibility(Object value);

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index: {value}'**
  String uvIndex(Object value);

  /// No description provided for @cloudCover.
  ///
  /// In en, this message translates to:
  /// **'Cloud Cover: {value}%'**
  String cloudCover(Object value);

  /// No description provided for @threeDayForecast.
  ///
  /// In en, this message translates to:
  /// **'3-Day Forecast'**
  String get threeDayForecast;

  /// No description provided for @thirtyDayForecast.
  ///
  /// In en, this message translates to:
  /// **'30-Day Forecast'**
  String get thirtyDayForecast;

  /// No description provided for @weatherForecastCalendar.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String weatherForecastCalendar(Object startDate, Object endDate);

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @failedToLoadWeather.
  ///
  /// In en, this message translates to:
  /// **'Failed to load weather data'**
  String get failedToLoadWeather;

  /// No description provided for @farmingTip.
  ///
  /// In en, this message translates to:
  /// **'Farming Tip'**
  String get farmingTip;

  /// No description provided for @noFarmingTip.
  ///
  /// In en, this message translates to:
  /// **'No farming tip available'**
  String get noFarmingTip;

  /// No description provided for @recommendedCrop.
  ///
  /// In en, this message translates to:
  /// **'Recommended Crop'**
  String get recommendedCrop;

  /// No description provided for @noCropRecommendation.
  ///
  /// In en, this message translates to:
  /// **'No crop recommendation available'**
  String get noCropRecommendation;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Location services are required to use this app.'**
  String get locationServicesRequired;

  /// No description provided for @failedToLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Failed to load insights'**
  String get failedToLoadInsights;

  /// No description provided for @sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOTP;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// No description provided for @pleaseEnterNameAndPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name and phone number'**
  String get pleaseEnterNameAndPhone;

  /// No description provided for @invalidOTP.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOTP;

  /// No description provided for @failedToSendOTP.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get failedToSendOTP;

  /// No description provided for @failedToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get failedToSignIn;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable Location Services'**
  String get enableLocationServices;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @nextContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get nextContinue;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get proceed;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @talkToHarvestBot.
  ///
  /// In en, this message translates to:
  /// **'Talk to HarvestBot'**
  String get talkToHarvestBot;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get noPostsYet;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get currentWeather;

  /// No description provided for @upcomingForecast.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Forecast'**
  String get upcomingForecast;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @minTemperature.
  ///
  /// In en, this message translates to:
  /// **'Min:'**
  String get minTemperature;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All >'**
  String get viewAll;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpAndSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportTitle;

  /// No description provided for @appFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'App Features'**
  String get appFeaturesTitle;

  /// No description provided for @gettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStartedTitle;

  /// No description provided for @featuresAndUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Features & Usage'**
  String get featuresAndUsageTitle;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @weatherUpdatesFeature.
  ///
  /// In en, this message translates to:
  /// **'Weather Updates'**
  String get weatherUpdatesFeature;

  /// No description provided for @weatherUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get real-time weather information including temperature, humidity, wind speed, and 3-day forecasts to plan your farming activities.'**
  String get weatherUpdatesDesc;

  /// No description provided for @aiChatFeature.
  ///
  /// In en, this message translates to:
  /// **'HarvestBot AI Assistant'**
  String get aiChatFeature;

  /// No description provided for @aiChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with our AI-powered farming expert for personalized advice, crop recommendations, and answers to your agricultural questions.'**
  String get aiChatDesc;

  /// No description provided for @pestDetectionFeature.
  ///
  /// In en, this message translates to:
  /// **'Pest Detection'**
  String get pestDetectionFeature;

  /// No description provided for @pestDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload photos of your crops to identify potential pest issues and get recommendations for treatment and prevention.'**
  String get pestDetectionDesc;

  /// No description provided for @communityFeature.
  ///
  /// In en, this message translates to:
  /// **'Farming Community'**
  String get communityFeature;

  /// No description provided for @communityDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with fellow farmers, share experiences, ask questions, and learn from the farming community.'**
  String get communityDesc;

  /// No description provided for @multiLanguageFeature.
  ///
  /// In en, this message translates to:
  /// **'Multi-Language Support'**
  String get multiLanguageFeature;

  /// No description provided for @multiLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the app in your preferred language with support for English, Hindi, Tamil, Telugu, and Malayalam.'**
  String get multiLanguageDesc;

  /// No description provided for @profileManagementFeature.
  ///
  /// In en, this message translates to:
  /// **'Profile Management'**
  String get profileManagementFeature;

  /// No description provided for @profileManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information, crop preferences, and location settings for personalized recommendations.'**
  String get profileManagementDesc;

  /// No description provided for @gettingStartedStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Set up your profile with your location and crop preferences'**
  String get gettingStartedStep1;

  /// No description provided for @gettingStartedStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Allow location access for accurate weather updates'**
  String get gettingStartedStep2;

  /// No description provided for @gettingStartedStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Explore weather forecasts and farming insights on the home screen'**
  String get gettingStartedStep3;

  /// No description provided for @gettingStartedStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Chat with HarvestBot for personalized farming advice'**
  String get gettingStartedStep4;

  /// No description provided for @gettingStartedStep5.
  ///
  /// In en, this message translates to:
  /// **'5. Join the community to connect with other farmers'**
  String get gettingStartedStep5;

  /// No description provided for @weatherUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Weather Features'**
  String get weatherUsageTitle;

  /// No description provided for @weatherUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'View current weather conditions, 3-day forecasts, and 30-day extended forecasts. Tap \'View All\' to see detailed calendar view.'**
  String get weatherUsageDesc;

  /// No description provided for @aiChatUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Using HarvestBot'**
  String get aiChatUsageTitle;

  /// No description provided for @aiChatUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask questions about crops, diseases, fertilizers, or any farming topic. The AI provides context-aware responses based on your conversation.'**
  String get aiChatUsageDesc;

  /// No description provided for @pestDetectionUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Pest Detection'**
  String get pestDetectionUsageTitle;

  /// No description provided for @pestDetectionUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Take clear photos of affected plants. The system will analyze and provide identification and treatment recommendations.'**
  String get pestDetectionUsageDesc;

  /// No description provided for @communityUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Community Features'**
  String get communityUsageTitle;

  /// No description provided for @communityUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Share posts, photos, and experiences. Comment on others\' posts and build connections with fellow farmers.'**
  String get communityUsageDesc;

  /// No description provided for @troubleshootingTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshootingTitle;

  /// No description provided for @locationIssues.
  ///
  /// In en, this message translates to:
  /// **'Location Issues'**
  String get locationIssues;

  /// No description provided for @locationIssuesDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure location services are enabled in your device settings for accurate weather data.'**
  String get locationIssuesDesc;

  /// No description provided for @weatherNotLoading.
  ///
  /// In en, this message translates to:
  /// **'Weather Not Loading'**
  String get weatherNotLoading;

  /// No description provided for @weatherNotLoadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and location permissions. Pull down to refresh the home screen.'**
  String get weatherNotLoadingDesc;

  /// No description provided for @aiNotResponding.
  ///
  /// In en, this message translates to:
  /// **'AI Not Responding'**
  String get aiNotResponding;

  /// No description provided for @aiNotRespondingDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure you have a stable internet connection. Try rephrasing your question if the AI doesn\'t understand.'**
  String get aiNotRespondingDesc;

  /// No description provided for @contactSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'For additional help or to report issues, you can:'**
  String get contactSupportDesc;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email us at: support@harvesthub.com'**
  String get emailSupport;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report issues through the app feedback'**
  String get reportIssue;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit our website: www.harvesthub.com'**
  String get visitWebsite;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version: 1.5.0'**
  String get appVersion;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: June 2025'**
  String get lastUpdated;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'ml', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'ml': return AppLocalizationsMl();
    case 'ta': return AppLocalizationsTa();
    case 'te': return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
