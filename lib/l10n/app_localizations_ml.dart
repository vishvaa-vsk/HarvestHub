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
  String get thirtyDayForecast => '30-ദിവസ പ്രവചനങ്ങൾ';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'കാലാവസ്ഥാ പ്രവചനം';
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
  String get viewAll => 'കൂടുതൽ >';

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
  String get appFeaturesTitle => 'ആപ്പ് లక్షణങ്ങൾ';

  @override
  String get gettingStartedTitle => 'ആരംഭിക്കുന്നത്';

  @override
  String get featuresAndUsageTitle => 'ലక్షణങ്ങൾ & వినియോഗം';

  @override
  String get contactSupportTitle => 'പിന്തുണയെ ബന്ധപ്പെടുക';

  @override
  String get weatherUpdatesFeature => 'കാലാവസ്ഥാ അപ്ഡേറ്റുകൾ';

  @override
  String get weatherUpdatesDesc => 'നിലവിലെ കാലാവസ്ഥ, ആർദ്രത, കാറ്റിന്റെ వేగം, 3-ദിവസ പ്രവചനങ്ങൾ వంటి నిజസమయంలో കാലാവസ്ഥാ വിവരങ്ങൾ పొందండి.';

  @override
  String get aiChatFeature => 'HarvestBot AI അസിസ്റ്റന്റ്';

  @override
  String get aiChatDesc => 'നിങ്ങളുടെ കൃഷി സംബന്ധമായ ప్రశ്നങ്ങൾക്ക് വ്യക്തിഗത ഉപദേശം, വിള ശുപാർശകൾ, മറുപടികൾക്കായി ഞങ്ങളുടെ AI-ശക്തമായ കൃഷി വിദഗ്ധനുമായി ചാറ്റ് ചെയ്യുക.';

  @override
  String get pestDetectionFeature => 'പൂച്ചിക്കണ്ടൽ';

  @override
  String get pestDetectionDesc => 'നിങ്ങളുടെ വിളകളുടെ ഫോട്ടോകൾ അപ്‌ലോഡ് ചെയ്ത് സാധ്യതയുള്ള പൂച്ചിക്കണ്ടൽ പ്രശ്നങ്ങളെ തിരിച്ചറിയുക, ചികിത്സയും నివാരണയും സംബന്ധിച്ച ശുപാർശകൾ పొందുക.';

  @override
  String get communityFeature => 'കൃഷി സമൂഹം';

  @override
  String get communityDesc => 'ఇతర రైతులతో కనెక్ట్ అవ్వండి, అనుభవాలను పంచుకోండి, ప్రశ్నలు అడగండి, మరియు కృషి సమాజం నుండి నేర్చుకోండి.';

  @override
  String get multiLanguageFeature => 'బహుభాషా మద్దతు';

  @override
  String get multiLanguageDesc => 'ఇంగ్లీష్, హిందీ, తమిళ్, తెలుగు మరియు മലയാളం మద్దతుతో మీ ఇష్టమైన భాషలో యాప్‌ను ఉపయోగించండి.';

  @override
  String get profileManagementFeature => 'ప్రొఫైల్ నిర్వహణ';

  @override
  String get profileManagementDesc => 'వ్యక్తిగత సమాచారం, పంట ప్రాధాన్యతలు మరియు వ్యక్తిగతీకరించిన సిఫారసుల కోసం స్థానం సెట్టింగ్స్‌ను నిర్వహించండి.';

  @override
  String get gettingStartedStep1 => '1. మీ స్థానం మరియు పంట ప్రాధాన్యతలతో మీ ప్రొఫైల్‌ను సెట్ చేయండి';

  @override
  String get gettingStartedStep2 => '2. ఖచ్చితమైన వాతావరణ అప్డేట్స్ కోసం స్థానం యాక్సెస్‌ను అనుమతించండి';

  @override
  String get gettingStartedStep3 => '3. హోమ్ స్క్రీన్‌లో వాతావరణ అంచనాలు మరియు కృషి అంతర్దృష్టులను అన్వేషించండి';

  @override
  String get gettingStartedStep4 => '4. వ్యక్తిగత కృషి సలహాల కోసం HarvestBot తో చాట్ చేయండి';

  @override
  String get gettingStartedStep5 => '5. മറ്റു കര്‍ഷകരുമായി ബന്ധപ്പെടാന്‍ സമൂഹത്തില്‍ ചേരുക';

  @override
  String get weatherUsageTitle => 'കാലാവസ്ഥാ സവിശേഷതകള്‍ ഉപയോഗിക്കുന്നത്';

  @override
  String get weatherUsageDesc => 'നിലവിലെ കാലാവസ്ഥ, 3-ദിവസ പ്രവചനങ്ങള്‍, 30-ദിവസ വിപുലമായ പ്രവചനങ്ങള്‍ കാണുക. വിശദമായ കലണ്ടര്‍ കാഴ്ചയ്ക്ക് \'കൂടുതല്‍ കാണുക\' അമര്‍ത്തുക.';

  @override
  String get aiChatUsageTitle => 'HarvestBot ഉപയോഗിക്കുന്നത്';

  @override
  String get aiChatUsageDesc => 'വിളകള്‍, രോഗങ്ങള്‍, വളങ്ങള്‍, അല്ലെങ്കില്‍ മറ്റ് കൃഷി വിഷയങ്ങളില്‍ ചോദ്യങ്ങള്‍ ചോദിക്കുക. നിങ്ങളുടെ സംഭാഷണത്തിന്റെ അടിസ്ഥാനത്തില്‍ AI പ്രസക്തമായ മറുപടികള്‍ നല്‍കും.';

  @override
  String get pestDetectionUsageTitle => 'പൂച്ചിക്കണ്ടല്‍ ഉപയോഗിക്കുന്നത്';

  @override
  String get pestDetectionUsageDesc => 'ബാധിതമായ ചെടികളുടെ വ്യക്തമായ ഫോട്ടോകള്‍ എടുക്കുക. സിസ്റ്റം വിശകലനം ചെയ്ത് തിരിച്ചറിയലും ചികിത്സാ ശുപാര്‍ശകളും നല്‍കും.';

  @override
  String get communityUsageTitle => 'സമൂഹ സവിശേഷതകള്‍ ഉപയോഗിക്കുന്നത്';

  @override
  String get communityUsageDesc => 'പോസ്റ്റുകളും ഫോട്ടോകളും അനുഭവങ്ങളും പങ്കിടുക. മറ്റുള്ളവരുടെ പോസ്റ്റുകളില്‍ അഭിപ്രായം രേഖപ്പെടുത്തി കര്‍ഷക സുഹൃത്തുക്കളുമായി ബന്ധം സ്ഥാപിക്കുക.';

  @override
  String get troubleshootingTitle => 'പ്രശ്നപരിഹാരം';

  @override
  String get locationIssues => 'സ്ഥാനം സംബന്ധിച്ച പ്രശ്നങ്ങള്‍';

  @override
  String get locationIssuesDesc => 'ശരിയായ കാലാവസ്ഥാ ഡാറ്റയ്ക്കായി നിങ്ങളുടെ ഉപകരണത്തിലെ സ്ഥാനം സേവനങ്ങള്‍ സജീവമാണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get weatherNotLoading => 'കാലാവസ്ഥാ ഡാറ്റ ലോഡ് ചെയ്യുന്നില്ല';

  @override
  String get weatherNotLoadingDesc => 'നിങ്ങളുടെ ഇന്റര്‍നെറ്റ് കണക്ഷനും സ്ഥാനം അനുമതികളും പരിശോധിക്കുക. ഹോം സ്‌ക്രീന്‍ പുതുക്കാന്‍ താഴേക്ക് വലിക്കുക.';

  @override
  String get aiNotResponding => 'AI പ്രതികരിക്കുന്നില്ല';

  @override
  String get aiNotRespondingDesc => 'നല്ല ഇന്റര്‍നെറ്റ് കണക്ഷന്‍ ഉണ്ടെന്ന് ഉറപ്പാക്കുക. AI മനസ്സിലാക്കുന്നില്ലെങ്കില്‍ നിങ്ങളുടെ ചോദ്യങ്ങള്‍ പുനരാഖ്യാനം ചെയ്യാന്‍ ശ്രമിക്കുക.';

  @override
  String get contactSupportDesc => 'കൂടുതല്‍ സഹായത്തിനോ പ്രശ്നങ്ങള്‍ റിപ്പോര്‍ട്ട് ചെയ്യാനോ, നിങ്ങള്‍ക്ക്:';

  @override
  String get emailSupport => 'ഞങ്ങളെ ഇമെയില്‍ ചെയ്യുക: support@harvesthub.com';

  @override
  String get reportIssue => 'ആപ്പിലെ ഫീഡ്ബാക്ക് വഴി പ്രശ്നങ്ങള്‍ റിപ്പോര്‍ട്ട് ചെയ്യുക';

  @override
  String get visitWebsite => 'ഞങ്ങളുടെ വെബ്സൈറ്റ് സന്ദര്‍ശിക്കുക: www.harvesthub.com';

  @override
  String get appVersion => 'ആപ്പ് പതിപ്പ്: 1.5.0';

  @override
  String get lastUpdated => 'അവസാനം അപ്ഡേറ്റ് ചെയ്തത്: ജൂണ്‍ 2025';

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
  String get readyToAnalyze => 'വിശകലനത്തിന് തയ്യാർ';

  @override
  String get uploadImageAndAnalyze => 'ഒരു ചിത്രം അപ്‌ലോഡ് ചെയ്ത് കീടങ്ങളെ കണ്ടെത്താനും ശുപാർശകൾ ലഭിക്കാനും \"വിശകലനം ചെയ്യുക\" ടാപ്പ് ചെയ്യുക';

  @override
  String get howToUse => 'എങ്ങനെ ഉപയോഗിക്കാം';

  @override
  String get takeClearPhotos => 'ചെടിയുടെ ഇലകളുടെ വ്യക്തമായ, നന്നായി പ്രകാശമുള്ള ഫോട്ടോകൾ എടുക്കുക';

  @override
  String get focusOnAffectedAreas => 'ദൃശ്യമായ ലക്ഷണങ്ങളുള്ള ബാധിത പ്രദേശങ്ങളിൽ ശ്രദ്ധ കേന്ദ്രീകരിക്കുക';

  @override
  String get avoidBlurryImages => 'മങ്ങിയതോ ഇരുണ്ടതോ ആയ ചിത്രങ്ങൾ ഒഴിവാക്കുക';

  @override
  String get includeMultipleLeaves => 'സാധ്യമെങ്കിൽ ഒന്നിലധികം ഇലകൾ ഉൾപ്പെടുത്തുക';

  @override
  String get gotIt => 'മനസ്സിലായി';
}
