// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ஹார்வெஸ்ட்ஹப்';

  @override
  String get welcomeMessage => 'ஹார்வெஸ்ட்ஹப்-க்கு வரவேற்கிறோம்!';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get hindi => 'இந்தி';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get telugu => 'தெலுங்கு';

  @override
  String get malayalam => 'மலையாளம்';

  @override
  String get home => 'முகப்பு';

  @override
  String get harvestBot => 'ஹார்வெஸ்ட்பாட்';

  @override
  String get pestDetection => 'பூச்சி கண்டறிதல்';

  @override
  String get community => 'சமூகம்';

  @override
  String get yourFarmingCompanion => 'உங்கள் விவசாய நண்பன்';

  @override
  String get editProfileSettings => 'சுயவிவர அமைப்புகளைத் திருத்தவும்';

  @override
  String get logout => 'லாக்அவுட்';

  @override
  String get errorLoadingUserData => 'பயனர் தரவுகளை ஏற்றுவதில் பிழை';

  @override
  String get weatherForecast => 'காலநிலை முன்னறிவிப்பு';

  @override
  String feelsLike(Object value) {
    return 'மனிதன் உணர்கிறார்: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'காற்று: $speed கிமீ/மணிநேரம் ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'அழுத்தம்: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'ஈரப்பதம்: $value%';
  }

  @override
  String visibility(Object value) {
    return 'தெளிவுத்தன்மை: $value கிமீ';
  }

  @override
  String uvIndex(Object value) {
    return 'UV குறியீடு: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'மேகக் கவர்: $value%';
  }

  @override
  String get threeDayForecast => '3-நாள் முன்னறிவிப்பு';

  @override
  String get thirtyDayForecast => '30-நாள் முன்னறிவிப்பு';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'காலநிலை முன்னறிவிப்பு';
  }

  @override
  String get viewMore => 'மேலும் காண்க';

  @override
  String get failedToLoadWeather => 'காலநிலை தரவுகளை ஏற்றுவதில் தோல்வி';

  @override
  String get farmingTip => 'விவசாய குறிப்புகள்';

  @override
  String get noFarmingTip => 'குறிப்பு கிடைக்கவில்லை';

  @override
  String get recommendedCrop => 'பரிந்துரைக்கப்பட்ட பயிர்';

  @override
  String get noCropRecommendation => 'பயிர் பரிந்துரை இல்லை';

  @override
  String get locationServicesRequired => 'இப்பயன்பாட்டைப் பயன்படுத்த இடம் சேவைகள் தேவை.';

  @override
  String get failedToLoadInsights => 'நுண்ணறிவுகளை ஏற்றுவதில் தோல்வி';

  @override
  String get sendOTP => 'OTP அனுப்பவும்';

  @override
  String get verifyOTP => 'OTP சரிபார்க்கவும்';

  @override
  String get name => 'பெயர்';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get enterOTP => 'OTP உள்ளிடவும்';

  @override
  String get pleaseEnterNameAndPhone => 'தயவுசெய்து உங்கள் பெயர் மற்றும் தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get invalidOTP => 'தவறான OTP';

  @override
  String get failedToSendOTP => 'OTP அனுப்புவதில் தோல்வி. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get failedToSignIn => 'உள்நுழைவதில் தோல்வி';

  @override
  String get enableLocationServices => 'இடம் சேவைகளை இயக்கவும்';

  @override
  String get openSettings => 'அமைப்புகளை திறக்கவும்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get nextContinue => 'தொடர்க';

  @override
  String get proceed => 'முன்னேறு';

  @override
  String get changeLanguage => 'மொழி மாற்றவும்';

  @override
  String get talkToHarvestBot => 'ஹார்வெஸ்ட்பாட்-க்கு பேசுங்கள்';

  @override
  String get createPost => 'பதிவு உருவாக்கவும்';

  @override
  String get addComment => 'கருத்தைச் சேர்க்கவும்...';

  @override
  String get post => 'பதிவு';

  @override
  String get noPostsYet => 'இன்னும் பதிவுகள் இல்லை.';

  @override
  String get whatsOnYourMind => 'உங்கள் மனதில் என்ன உள்ளது?';

  @override
  String get currentWeather => 'தற்போதைய காலநிலை';

  @override
  String get upcomingForecast => 'வரவிருக்கும் முன்னறிவிப்பு';

  @override
  String get tomorrow => 'நாளை';

  @override
  String get minTemperature => 'குறை:';

  @override
  String get rain => 'மழை';

  @override
  String get viewAll => 'மேலும் >';

  @override
  String get january => 'ஜனவரி';

  @override
  String get february => 'பிப்ரவரி';

  @override
  String get march => 'மார்ச்';

  @override
  String get april => 'ஏப்ரல்';

  @override
  String get may => 'மே';

  @override
  String get june => 'ஜூன்';

  @override
  String get july => 'ஜூலை';

  @override
  String get august => 'ஆகஸ்ட்';

  @override
  String get september => 'செப்டம்பர்';

  @override
  String get october => 'அக்டோபர்';

  @override
  String get november => 'நவம்பர்';

  @override
  String get december => 'டிசம்பர்';

  @override
  String get sunday => 'ஞா';

  @override
  String get monday => 'தி';

  @override
  String get tuesday => 'செ';

  @override
  String get wednesday => 'பு';

  @override
  String get thursday => 'வி';

  @override
  String get friday => 'வெ';

  @override
  String get saturday => 'ச';

  @override
  String get darkMode => 'இருண்ட பயன்முறை';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get helpSupport => 'உதவி மற்றும் ஆதரவு';

  @override
  String get about => 'பற்றி';
}
