// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'ഹാർവെസ്റ്റ് ഹബ്';

  @override
  String get welcomeMessage => 'HarvestHub-ലേക്ക് സ്വാഗതം!';

  @override
  String get selectLanguage => 'ഇഷ്ടപ്പെട്ട ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get english => 'ഇംഗ്ലീഷ്';

  @override
  String get hindi => 'ഹിന്ദി';

  @override
  String get tamil => 'തമിഴ്';

  @override
  String get telugu => 'തെലുങ്ക്';

  @override
  String get malayalam => 'മലയാളം';

  @override
  String get home => 'മുക്‌ക്കപ്പ്';

  @override
  String get harvestBot => 'HarvestBot';

  @override
  String get pestDetection => 'പൂച്ചിക്കണ്ടൽ';

  @override
  String get community => 'സമൂഹം';

  @override
  String get yourFarmingCompanion => 'നിങ്ങളുടെ കൃഷി കൂട്ടുകാരൻ';

  @override
  String get editProfileSettings => 'പ്രൊഫൈൽ ക്രമീകരണങ്ങൾ എഡിറ്റ് ചെയ്യുക';

  @override
  String get logout => 'ലോഗ് ഔട്ട്';

  @override
  String get errorLoadingUserData => 'ഉപയോക്തൃ ഡാറ്റ ലോഡ് ചെയ്യുന്നതിൽ പിഴവ്';

  @override
  String get weatherForecast => 'കാലാവസ്ഥാ പ്രവചനങ്ങൾ';

  @override
  String feelsLike(Object value) {
    return 'മനസ്സിലാക്കുന്നത്: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'കാറ്റ്: $speed കിമീ/മണിക്കൂർ ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'അഴുത്തം: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'ആർദ്രത: $value%';
  }

  @override
  String visibility(Object value) {
    return 'തെളിവ്: $value കിമീ';
  }

  @override
  String uvIndex(Object value) {
    return 'UV സൂചിക: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'മേകക്കവര: $value%';
  }

  @override
  String get threeDayForecast => '3-ദിവസ പ്രവചനങ്ങൾ';

  @override
  String get viewMore => 'കൂടുതൽ കാണുക';

  @override
  String get failedToLoadWeather => 'കാലാവസ്ഥാ ഡാറ്റ ലോഡ് ചെയ്യുന്നതിൽ പരാജയം';

  @override
  String get farmingTip => 'കൃഷി ടിപ്പ്';

  @override
  String get noFarmingTip => 'കൃഷി ടിപ്പ് ലഭ്യമല്ല';

  @override
  String get recommendedCrop => 'ശുപാർശ ചെയ്ത വിള';

  @override
  String get noCropRecommendation => 'വിള ശുപാർശ ലഭ്യമല്ല';

  @override
  String get locationServicesRequired => 'ഈ ആപ്പ് ഉപയോഗിക്കാൻ സ്ഥാനം സേവനങ്ങൾ ആവശ്യമാണ്.';

  @override
  String get failedToLoadInsights => 'ഉൾക്കാഴ്ചകൾ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get sendOTP => 'OTP അയയ്ക്കുക';

  @override
  String get verifyOTP => 'OTP സ്ഥിരീകരിക്കുക';

  @override
  String get name => 'പേര്';

  @override
  String get phoneNumber => 'ഫോൺ നമ്പർ';

  @override
  String get enterOTP => 'OTP നൽകുക';

  @override
  String get pleaseEnterNameAndPhone => 'ദയവായി നിങ്ങളുടെ പേര് और ഫോൺ നമ്പർ നൽകുക';

  @override
  String get invalidOTP => 'അസാധുവായ OTP';

  @override
  String get failedToSendOTP => 'OTP അയയ്ക്കുന്നതിൽ പരാജയം. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get failedToSignIn => 'ഉള്പ്പെടുത്തുന്നതിൽ പരാജയം';

  @override
  String get enableLocationServices => 'സ്ഥാനം സേവനങ്ങൾ സജീവമാക്കുക';

  @override
  String get openSettings => 'അമിപ്പുകൾ തുറക്കുക';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get nextContinue => 'തുടരുക';

  @override
  String get proceed => 'മുന്നോട്ട് പോകുക';

  @override
  String get changeLanguage => 'ഭാഷ മാറ്റുക';

  @override
  String get talkToHarvestBot => 'HarvestBot-നോട് സംസാരിക്കുക';

  @override
  String get createPost => 'പോസ്റ്റ് സൃഷ്ടിക്കുക';

  @override
  String get addComment => 'അഭിപ്രായം ചേർക്കുക...';

  @override
  String get post => 'പോസ്റ്റ്';

  @override
  String get noPostsYet => 'ഇതുവരെ പോസ്റ്റുകളൊന്നുമില്ല.';

  @override
  String get whatsOnYourMind => 'നിങ്ങളുടെ മനസ്സിൽ എന്താണ്?';

  @override
  String get currentWeather => 'നിലവിലെ കാലാവസ്ഥ';

  @override
  String get upcomingForecast => 'വരാനിരിക്കുന്ന പ്രവചനം';

  @override
  String get tomorrow => 'നാളെ';

  @override
  String get minTemperature => 'ഏറ്റവും കുറഞ്ഞത്:';

  @override
  String get rain => 'മഴ';

  @override
  String get viewAll => 'കൂടുതൽ >';

  @override
  String get weatherForecastCalendar => 'കാലാവസ്ഥാ പ്രവചനം';

  @override
  String get january => 'ജനുവരി';

  @override
  String get february => 'ഫെബ്രുവരി';

  @override
  String get march => 'മാർച്ച്';

  @override
  String get april => 'ഏപ്രിൽ';

  @override
  String get may => 'മെയ്';

  @override
  String get june => 'ജൂൺ';

  @override
  String get july => 'ജൂലൈ';

  @override
  String get august => 'ഓഗസ്റ്റ്';

  @override
  String get september => 'സെപ്റ്റംബർ';

  @override
  String get october => 'ഒക്ടോബർ';

  @override
  String get november => 'നവംബർ';

  @override
  String get december => 'ഡിസംബർ';

  @override
  String get sunday => 'ഞാ';

  @override
  String get monday => 'തി';

  @override
  String get tuesday => 'ചൊ';

  @override
  String get wednesday => 'ബു';

  @override
  String get thursday => 'വ്യാ';

  @override
  String get friday => 'വെ';

  @override
  String get saturday => 'ശ';

  @override
  String get darkMode => 'ഇരുണ്ട മോഡ്';

  @override
  String get notifications => 'അറിയിപ്പുകൾ';

  @override
  String get helpSupport => 'സഹായവും പിന്തുണയും';

  @override
  String get about => 'കുറിച്ച്';
}
