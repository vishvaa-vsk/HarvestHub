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
  String get home => 'ഹോം';

  @override
  String get harvestBot => 'HarvestBot';

  @override
  String get pestDetection => 'കീടനിയന്ത്രണം';

  @override
  String get community => 'സമൂഹം';

  @override
  String get yourFarmingCompanion => 'നിങ്ങളുടെ കൃഷി കൂട്ടുകാരൻ';

  @override
  String get editProfileSettings => 'പ്രൊഫൈൽ ക്രമീകരണങ്ങൾ എഡിറ്റ് ചെയ്യുക';

  @override
  String get logout => 'ലോഗ് ഔട്ട്';

  @override
  String get loading => 'ലോഡ് ചെയ്യുന്നു...';

  @override
  String get errorLoadingUserData => 'ഉപയോക്തൃ ഡാറ്റ ലോഡ് ചെയ്യുന്നതിൽ പിഴവ്';

  @override
  String get weatherForecast => 'കാലാവസ്ഥാ പ്രവചനങ്ങൾ';

  @override
  String feelsLike(Object value) {
    return 'അനുഭവപ്പെടുന്നത്: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'കാറ്റ്: $speed കിമീ/മണിക്കൂർ ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'മർദ്ദം: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'ആർദ്രത: $value%';
  }

  @override
  String visibility(Object value) {
    return 'ദൃശ്യതാ ദൂരം: $value കിമീ';
  }

  @override
  String uvIndex(Object value) {
    return 'UV സൂചിക: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'മേഘാവരണം: $value%';
  }

  @override
  String get threeDayForecast => '3-ദിവസ പ്രവചനങ്ങൾ';

  @override
  String get thirtyDayForecast => '30-ദിവസ പ്രവചനങ്ങൾ';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'കാലാവസ്ഥാ പ്രവചനം: $startDate - $endDate';
  }

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
  String get locationServicesRequired => 'ഈ ആപ്പ് ഉപയോഗിക്കാൻ സ്ഥാന സേവനങ്ങൾ ആവശ്യമാണ്.';

  @override
  String get failedToLoadInsights => 'ഉൾക്കാഴ്ചകൾ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get sendOTP => 'OTP അയക്കുക';

  @override
  String get verifyOTP => 'OTP സ്ഥിരീകരിക്കുക';

  @override
  String get name => 'പേര്';

  @override
  String get phoneNumber => 'ഫോൺ നമ്പർ';

  @override
  String get enterOTP => 'OTP നൽകുക';

  @override
  String get pleaseEnterNameAndPhone => 'ദയവായി നിങ്ങളുടെ പേര് മറ്റും ഫോൺ നമ്പർ നൽകുക';

  @override
  String get invalidOTP => 'അസാധുവായ OTP';

  @override
  String get failedToSendOTP => 'OTP അയക്കുന്നതിൽ പരാജയം. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get failedToSignIn => 'സൈൻ ഇൻ ചെയ്യുന്നതിൽ പരാജയം';

  @override
  String get enableLocationServices => 'സ്ഥാന സേവനങ്ങൾ സജീവമാക്കുക';

  @override
  String get openSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

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
  String get welcomeToHarvestHub => 'HarvestHub ലേക്ക് സ്വാഗതം...';

  @override
  String get shareYourThoughts => 'നിങ്ങളുടെ ആശയങ്ങൾ പങ്കിടുക, ചോദ്യങ്ങൾ ചോദിക്കുക, സഹ കർഷകരുമായി ബന്ധപ്പെടുക.';

  @override
  String get somethingWentWrong => 'എന്തോ തെറ്റ് സംഭവിച്ചു';

  @override
  String get checkConnectionAndTryAgain => 'ദയവായി നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get welcomeToCommunity => 'സമൂഹത്തിലേക്ക് സ്വാഗതം!';

  @override
  String get shareYourFarmingExperiences => 'നിങ്ങളുടെ കൃഷിയനുഭവങ്ങൾ, നുറുങ്ങുകൾ പങ്കിടുക, സഹ കർഷകരുമായി ബന്ധപ്പെടുക';

  @override
  String get createFirstPost => 'ആദ്യ പോസ്റ്റ് സൃഷ്ടിക്കുക';

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
  String get viewAll => 'എല്ലാം കാണുക >';

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

  @override
  String get helpAndSupportTitle => 'സഹായവും പിന്തുണയും';

  @override
  String get appFeaturesTitle => 'ആപ്പ് സവിശേഷതകൾ';

  @override
  String get gettingStartedTitle => 'ആരംഭിക്കുന്നത്';

  @override
  String get featuresAndUsageTitle => 'സവിശേഷതകൾ & ഉപയോഗം';

  @override
  String get contactSupportTitle => 'പിന്തുണയെ ബന്ധപ്പെടുക';

  @override
  String get weatherUpdatesFeature => 'കാലാവസ്ഥാ അപ്ഡേറ്റുകൾ';

  @override
  String get weatherUpdatesDesc => 'നിങ്ങളുടെ കൃഷി പ്രവർത്തനങ്ങൾ ആസൂത്രണം ചെയ്യാൻ താപനില, ആർദ്രത, കാറ്റിന്റെ വേഗത, 3-ദിവസ പ്രവചനങ്ങൾ എന്നിവ ഉൾപ്പെടെയുള്ള തത്സമയ കാലാവസ്ഥാ വിവരങ്ങൾ നേടുക.';

  @override
  String get aiChatFeature => 'HarvestBot AI അസിസ്റ്റന്റ്';

  @override
  String get aiChatDesc => 'വ്യക്തിഗത ഉപദേശം, വിള ശുപാർശകൾ, നിങ്ങളുടെ കാർഷിക ചോദ്യങ്ങൾക്കുള്ള ഉത്തരങ്ങൾ എന്നിവയ്ക്കായി ഞങ്ങളുടെ AI-ശക്തമായ കൃഷി വിദഗ്ധനുമായി ചാറ്റ് ചെയ്യുക.';

  @override
  String get pestDetectionFeature => 'കീടനിയന്ത്രണം';

  @override
  String get pestDetectionDesc => 'സാധ്യതയുള്ള കീട പ്രശ്നങ്ങൾ തിരിച്ചറിയാനും ചികിത്സയ്ക്കും പ്രതിരോധത്തിനുമായി ശുപാർശകൾ നേടാനും നിങ്ങളുടെ വിളകളുടെ ഫോട്ടോകൾ അപ്‌ലോഡ് ചെയ്യുക.';

  @override
  String get communityFeature => 'കൃഷി സമൂഹം';

  @override
  String get communityDesc => 'സഹ കർഷകരുമായി ബന്ധപ്പെടുക, അനുഭവങ്ങൾ പങ്കിടുക, ചോദ്യങ്ങൾ ചോദിക്കുക, കൃഷി സമൂഹത്തിൽ നിന്ന് പഠിക്കുക.';

  @override
  String get multiLanguageFeature => 'ബഹുഭാഷാ പിന്തുണ';

  @override
  String get multiLanguageDesc => 'ഇംഗ്ലീഷ്, ഹിന്ദി, തമിഴ്, തെലുങ്ക്, മലയാളം എന്നിവയുടെ പിന്തുണയോടെ നിങ്ങളുടെ ഇഷ്ട ഭാഷയിൽ ആപ്പ് ഉപയോഗിക്കുക.';

  @override
  String get profileManagementFeature => 'പ്രൊഫൈൽ മാനേജ്മെന്റ്';

  @override
  String get profileManagementDesc => 'വ്യക്തിഗത ശുപാർശകൾക്കായി നിങ്ങളുടെ വ്യക്തിഗത വിവരങ്ങൾ, വിള മുൻഗണനകൾ, സ്ഥാന ക്രമീകരണങ്ങൾ എന്നിവ കൈകാര്യം ചെയ്യുക.';

  @override
  String get gettingStartedStep1 => '1. നിങ്ങളുടെ സ്ഥാനവും വിള മുൻഗണനകളും ഉപയോഗിച്ച് നിങ്ങളുടെ പ്രൊഫൈൽ സജ്ജമാക്കുക';

  @override
  String get gettingStartedStep2 => '2. കൃത്യമായ കാലാവസ്ഥാ അപ്ഡേറ്റുകൾക്കായി സ്ഥാന ആക്സസ് അനുവദിക്കുക';

  @override
  String get gettingStartedStep3 => '3. ഹോം സ്ക്രീനിൽ കാലാവസ്ഥാ പ്രവചനങ്ങളും കൃഷി ഉൾക്കാഴ്ചകളും പര്യവേക്ഷണം ചെയ്യുക';

  @override
  String get gettingStartedStep4 => '4. വ്യക്തിഗത കൃഷി ഉപദേശത്തിനായി HarvestBot-മായി ചാറ്റ് ചെയ്യുക';

  @override
  String get gettingStartedStep5 => '5. മറ്റ് കർഷകരുമായി ബന്ധപ്പെടാൻ സമൂഹത്തിൽ ചേരുക';

  @override
  String get weatherUsageTitle => 'കാലാവസ്ഥാ സവിശേഷതകൾ ഉപയോഗിക്കുന്നത്';

  @override
  String get weatherUsageDesc => 'നിലവിലെ കാലാവസ്ഥാ അവസ്ഥകൾ, 3-ദിവസ പ്രവചനങ്ങൾ, 30-ദിവസ വിപുലീകൃത പ്രവചനങ്ങൾ എന്നിവ കാണുക. വിശദമായ കലണ്ടർ കാഴ്ച കാണാൻ \'എല്ലാം കാണുക\' ടാപ്പ് ചെയ്യുക.';

  @override
  String get aiChatUsageTitle => 'HarvestBot ഉപയോഗിക്കുന്നത്';

  @override
  String get aiChatUsageDesc => 'വിളകൾ, രോഗങ്ങൾ, വളങ്ങൾ, അല്ലെങ്കിൽ ഏതെങ്കിലും കൃഷി വിഷയത്തെക്കുറിച്ച് ചോദ്യങ്ങൾ ചോദിക്കുക. AI നിങ്ങളുടെ സംഭാഷണത്തെ അടിസ്ഥാനമാക്കി സന്ദർഭ-അവബോധമുള്ള മറുപടികൾ നൽകുന്നു.';

  @override
  String get pestDetectionUsageTitle => 'കീടനിയന്ത്രണം ഉപയോഗിക്കുന്നത്';

  @override
  String get pestDetectionUsageDesc => 'ബാധിച്ച ചെടികളുടെ വ്യക്തമായ ഫോട്ടോകൾ എടുക്കുക. സിസ്റ്റം വിശകലനം ചെയ്ത് തിരിച്ചറിയലും ചികിത്സാ ശുപാർശകളും നൽകും.';

  @override
  String get communityUsageTitle => 'സമൂഹ സവിശേഷതകൾ ഉപയോഗിക്കുന്നത്';

  @override
  String get communityUsageDesc => 'പോസ്റ്റുകൾ, ഫോട്ടോകൾ, അനുഭവങ്ങൾ എന്നിവ പങ്കിടുക. മറ്റുള്ളവരുടെ പോസ്റ്റുകളിൽ അഭിപ്രായം രേഖപ്പെടുത്തുകയും സഹ കർഷകരുമായി ബന്ധം സ്ഥാപിക്കുകയും ചെയ്യുക.';

  @override
  String get troubleshootingTitle => 'പ്രശ്നപരിഹാരം';

  @override
  String get locationIssues => 'സ്ഥാന പ്രശ്നങ്ങൾ';

  @override
  String get locationIssuesDesc => 'കൃത്യമായ കാലാവസ്ഥാ ഡാറ്റയ്ക്കായി നിങ്ങളുടെ ഉപകരണ ക്രമീകരണങ്ങളിൽ സ്ഥാന സേവനങ്ങൾ പ്രവർത്തനക്ഷമമാക്കിയിട്ടുണ്ടെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get weatherNotLoading => 'കാലാവസ്ഥ ലോഡ് ചെയ്യുന്നില്ല';

  @override
  String get weatherNotLoadingDesc => 'നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷനും സ്ഥാന അനുമതികളും പരിശോധിക്കുക. ഹോം സ്ക്രീൻ പുതുക്കാൻ താഴേക്ക് വലിക്കുക.';

  @override
  String get aiNotResponding => 'AI പ്രതികരിക്കുന്നില്ല';

  @override
  String get aiNotRespondingDesc => 'നിങ്ങൾക്ക് സുസ്ഥിരമായ ഇന്റർനെറ്റ് കണക്ഷൻ ഉണ്ടെന്ന് ഉറപ്പാക്കുക. AI മനസ്സിലാകുന്നില്ലെങ്കിൽ നിങ്ങളുടെ ചോദ്യം പുനർനിർമ്മിക്കാൻ ശ്രമിക്കുക.';

  @override
  String get contactSupportDesc => 'കൂടുതൽ സഹായത്തിനോ പ്രശ്നങ്ങൾ റിപ്പോർട്ട് ചെയ്യാനോ, നിങ്ങൾക്ക്:';

  @override
  String get emailSupport => 'ഞങ്ങളെ ഇമെയിൽ ചെയ്യുക: support@harvesthub.com';

  @override
  String get reportIssue => 'ആപ്പ് ഫീഡ്ബാക്ക് വഴി പ്രശ്നങ്ങൾ റിപ്പോർട്ട് ചെയ്യുക';

  @override
  String get visitWebsite => 'ഞങ്ങളുടെ വെബ്സൈറ്റ് സന്ദർശിക്കുക: www.harvesthub.com';

  @override
  String get appVersion => 'ആപ്പ് പതിപ്പ്: 1.5.0';

  @override
  String get lastUpdated => 'അവസാനമായി അപ്ഡേറ്റ് ചെയ്തത്: ജൂൺ 2025';

  @override
  String get uploadPlantImage => 'ചെടിയുടെ ചിത്രം അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get uploadPlantImageDesc => 'കീടങ്ങളെയും രോഗങ്ങളെയും കണ്ടെത്താൻ ചെടിയുടെ ഇലകളുടെ വ്യക്തമായ ഫോട്ടോ എടുക്കുകയോ ഗാലറിയിൽ നിന്ന് അപ്‌ലോഡ് ചെയ്യുകയോ ചെയ്യുക.';

  @override
  String get camera => 'ക്യാമറ';

  @override
  String get gallery => 'ഗാലറി';

  @override
  String get analyzing => 'വിശകലനം ചെയ്യുന്നു...';

  @override
  String get analyzingForecast => '30-ദിവസത്തെ പ്രവചനം വിശകലനം ചെയ്യുന്നു...';

  @override
  String get analyzeImage => 'ചിത്രം വിശകലനം ചെയ്യുക';

  @override
  String get detectionResults => 'കണ്ടെത്തൽ ഫലങ്ങൾ';

  @override
  String get noImageSelected => 'ചിത്രം തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String get uploadImageToGetStarted => 'ആരംഭിക്കാൻ ഒരു ചിത്രം അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get analysisComplete => 'വിശകലനം പൂർത്തിയായി';

  @override
  String get noPestsDetected => 'ഈ ചിത്രത്തിൽ കീടങ്ങളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get cropsHealthyMessage => 'നിങ്ങളുടെ വിളകൾ ആരോഗ്യകരമായി കാണപ്പെടുന്നു! പതിവ് നിരീക്ഷണം തുടരുകയും നല്ല കാർഷിക രീതികൾ നിലനിർത്തുകയും ചെയ്യുക.';

  @override
  String get recommendations => 'ശുപാർശകൾ';

  @override
  String get confidence => 'ആത്മവിശ്വാസം';

  @override
  String get diagnosis => 'രോഗനിർണ്ണയം';

  @override
  String get causalAgent => 'കാരണ ഏജന്റ്';

  @override
  String get analysisError => 'വിശകലന പിശക്';

  @override
  String get analysisErrorDesc => 'ചിത്രം വിശകലനം ചെയ്യാൻ കഴിയുന്നില്ല. ദയവായി കൂടുതൽ വ്യക്തമായ ഫോട്ടോയോടെ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get readyToAnalyze => 'വിശകലനത്തിന് തയ്യാർ';

  @override
  String get uploadImageAndAnalyze => 'ചിത്രം അപ്‌ലോഡ് ചെയ്ത് കീടങ്ങളെ കണ്ടെത്താനും ശുപാർശകൾ നേടാനും \"വിശകലനം ചെയ്യുക\" ടാപ്പ് ചെയ്യുക';

  @override
  String get scanAgain => 'വീണ്ടും സ്കാൻ ചെയ്യുക';

  @override
  String get saveResult => 'ഫലം സേവ് ചെയ്യുക';

  @override
  String get resultSaved => 'ഫലം സേവ് ചെയ്തു';

  @override
  String get uploadImageFirst => 'ആദ്യം ചിത്രം അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get tapAnalyzeToStart => 'കണ്ടെത്തൽ ആരംഭിക്കാൻ വിശകലന ബട്ടൺ ടാപ്പ് ചെയ്യുക';

  @override
  String get selectImageFromCameraOrGallery => 'ക്യാമറയിൽ നിന്നോ ഗാലറിയിൽ നിന്നോ ചിത്രം തിരഞ്ഞെടുക്കുക';

  @override
  String get failedToAnalyzeImage => 'ചിത്രം വിശകലനം ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get howToUse => 'എങ്ങനെ ഉപയോഗിക്കാം';

  @override
  String get takeClearPhotos => 'ചെടിയുടെ ഇലകളുടെ വ്യക്തമായ, നന്നായി പ്രകാശമുള്ള ഫോട്ടോകൾ എടുക്കുക';

  @override
  String get focusOnAffectedAreas => 'ദൃശ്യമായ ലക്ഷണങ്ങളുള്ള ബാധിത പ്രദേശങ്ങളിൽ ശ്രദ്ധ കേന്ദ്രീകരിക്കുക';

  @override
  String get avoidBlurryImages => 'അവ്യക്തമായതോ ഇരുണ്ടതോ ആയ ചിത്രങ്ങൾ ഒഴിവാക്കുക';

  @override
  String get includeMultipleLeaves => 'സാധ്യമെങ്കിൽ ഒന്നിലധികം ഇലകൾ ഉൾപ്പെടുത്തുക';

  @override
  String get gotIt => 'മനസ്സിലായി';

  @override
  String get basedOn30DayForecast => '30-ദിവസത്തെ കാലാവസ്ഥാ പ്രവചനത്തെ അടിസ്ഥാനമാക്കി';

  @override
  String get basedOnCurrentConditions => 'നിലവിലെ കാലാവസ്ഥാ സാഹചര്യങ്ങളെ അടിസ്ഥാനമാക്കി';

  @override
  String get personalInformation => 'വ്യക്തിഗത വിവരങ്ങൾ';

  @override
  String get updateYourProfileDetails => 'നിങ്ങളുടെ പ്രൊഫൈൽ വിശദാംശങ്ങൾ അപ്‌ഡേറ്റ് ചെയ്യുക';

  @override
  String get fullName => 'പൂർണ്ണ നാമം';

  @override
  String get enterYourFullName => 'നിങ്ങളുടെ പൂർണ്ണ നാമം നൽകുക';

  @override
  String get emailAddress => 'ഇമെയിൽ വിലാസം';

  @override
  String get enterYourEmailAddress => 'നിങ്ങളുടെ ഇമെയിൽ വിലാസം നൽകുക';

  @override
  String get enterYourPhoneNumber => 'നിങ്ങളുടെ ഫോൺ നമ്പർ നൽകുക';

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get changeProfilePicture => 'പ്രൊഫൈൽ ചിത്രം മാറ്റുക';

  @override
  String get remove => 'നീക്കം ചെയ്യുക';

  @override
  String get profileUpdatedSuccessfully => 'നിങ്ങളുടെ പ്രൊഫൈൽ വിജയകരമായി അപ്‌ഡേറ്റ് ചെയ്തു.';

  @override
  String get mobileNumberUpdatedSuccessfully => 'നിങ്ങളുടെ മൊബൈൽ നമ്പർ വിജയകരമായി അപ്‌ഡേറ്റ് ചെയ്തു.';

  @override
  String get pleaseEnterVerificationCode => 'ദയവായി നിങ്ങളുടെ ഫോണിലേക്ക് അയച്ച സ്ഥിരീകരണ കോഡ് നൽകുക';

  @override
  String get otpAutoFilledSuccessfully => 'OTP വിജയകരമായി സ്വയം പൂരിപ്പിച്ചു!';

  @override
  String get otpWillBeFilledAutomatically => 'SMS ലഭിക്കുമ്പോൾ OTP സ്വയം പൂരിപ്പിക്കപ്പെടും';

  @override
  String get didntReceiveOTP => 'OTP ലഭിച്ചില്ലേ? ';

  @override
  String get resend => 'വീണ്ടും അയക്കുക';

  @override
  String resendInSeconds(Object seconds) {
    return '${seconds}s ൽ വീണ്ടും അയക്കുക';
  }

  @override
  String get otpResentSuccessfully => 'OTP വിജയകരമായി വീണ്ടും അയച്ചു';

  @override
  String get aiDisclaimer => 'AI-ജനറേറ്റുചെയ്ത ഫലങ്ങളുടെ ഡിസ്‌ക്ലെയിമർ';

  @override
  String get aiDisclaimerDesc => 'നൽകുന്ന രോഗനിർണ്ണയവും ശുപാർശകളും AI-യിലൂടെ സൃഷ്ടിച്ചതാണ്, അതിൽ പിശകുകൾ ഉണ്ടാകാം. നിർണായക തീരുമാനങ്ങൾക്ക് കാർഷിക വിദഗ്ധരുമായി നിർബന്ധമായി ആശയവിനിമയം നടത്തുക. ഈ വിവരങ്ങൾ ഒരു അധിക മാർഗ്ഗനിർദ്ദേശമായി മാത്രം ഉപയോഗിക്കുക.';
}
