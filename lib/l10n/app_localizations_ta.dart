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
  String get selectLanguage => 'விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

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
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get errorLoadingUserData => 'பயனர் தரவுகளை ஏற்றுவதில் பிழை';

  @override
  String get weatherForecast => 'காலநிலை முன்னறிவிப்பு';

  @override
  String feelsLike(Object value) {
    return 'உணர்வு: $value°C';
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
    return 'காலநிலை முன்னறிவிப்பு: $startDate - $endDate';
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
  String get createPost => 'இடுகை உருவாக்க';

  @override
  String get addComment => 'கருத்து சேர்க்க...';

  @override
  String get post => 'இடுகை';

  @override
  String get noPostsYet => 'இன்னும் இடுகைகள் இல்லை.';

  @override
  String get whatsOnYourMind => 'உங்கள் மனதில் என்ன?';

  @override
  String get welcomeToHarvestHub => 'HarvestHub இல் உங்களை வரவேற்கிறோம்...';

  @override
  String get shareYourThoughts => 'உங்கள் எண்ணங்களைப் பகிரவும், கேள்விகள் கேட்கவும், சக விவசாயிகளுடன் இணைந்தொழுகவும்.';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்தது';

  @override
  String get checkConnectionAndTryAgain => 'உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்';

  @override
  String get tryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get welcomeToCommunity => 'சமூகத்திற்கு வரவேற்கிறோம்!';

  @override
  String get shareYourFarmingExperiences => 'உங்கள் விவசாய அனுபவங்கள், குறிப்புகளைப் பகிரவும் மற்றும் சக விவசாயிகளுடன் இணைந்தொழுகவும்';

  @override
  String get createFirstPost => 'முதல் இடுகையை உருவாக்கவும்';

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

  @override
  String get helpAndSupportTitle => 'உதவி மற்றும் ஆதரவு';

  @override
  String get appFeaturesTitle => 'ஆப் அம்சங்கள்';

  @override
  String get gettingStartedTitle => 'தொடங்குவது';

  @override
  String get featuresAndUsageTitle => 'அம்சங்கள் மற்றும் பயன்பாடு';

  @override
  String get contactSupportTitle => 'தொடர்பு ஆதரவு';

  @override
  String get weatherUpdatesFeature => 'வானிலை புதுப்பிப்புகள்';

  @override
  String get weatherUpdatesDesc => 'உங்கள் விவசாய நடவடிக்கைகளைத் திட்டமிட வெப்பநிலை, ஈரப்பதம், காற்றின் வேகம் மற்றும் 3-நாள் முன்னறிவிப்புகள் உள்ளிட்ட நிகழ்நேர வானிலை தகவல்களைப் பெறுங்கள்.';

  @override
  String get aiChatFeature => 'ஹார்வெஸ்ட்பாட் AI உதவியாளர்';

  @override
  String get aiChatDesc => 'தனிப்பட்ட ஆலோசனை, பயிர் பரிந்துரைகள் மற்றும் உங்கள் விவசாய கேள்விகளுக்கான பதில்களுக்கு எங்கள் AI-இயங்கும் விவசாய நிபுணரிடம் அரட்டையடிக்கவும்.';

  @override
  String get pestDetectionFeature => 'பூச்சி கண்டறிதல்';

  @override
  String get pestDetectionDesc => 'சாத்தியமான பூச்சி பிரச்சினைகளைக் கண்டறிந்து சிகிச்சை மற்றும் தடுப்புக்கான பரிந்துரைகளைப் பெற உங்கள் பயிர்களின் புகைப்படங்களைப் பதிவேற்றவும்.';

  @override
  String get communityFeature => 'விவசாய சமூகம்';

  @override
  String get communityDesc => 'சக விவசாயிகளுடன் இணைக்கவும், அனுபவங்களைப் பகிரவும், கேள்விகள் கேட்கவும் மற்றும் விவசாய சமூகத்திலிருந்து கற்றுக்கொள்ளவும்.';

  @override
  String get multiLanguageFeature => 'பல மொழி ஆதரவு';

  @override
  String get multiLanguageDesc => 'ஆங்கிலம், இந்தி, தமிழ், தெலுங்கு மற்றும் மலையாளம் ஆதரவுடன் உங்கள் விருப்பமான மொழியில் ஆப்ஸைப் பயன்படுத்தவும்.';

  @override
  String get profileManagementFeature => 'சுயவிவர மேலாண்மை';

  @override
  String get profileManagementDesc => 'தனிப்பயனாக்கப்பட்ட பரிந்துரைகளுக்காக உங்கள் தனிப்பட்ட தகவல், பயிர் விருப்பத்தேர்வுகள் மற்றும் இருப்பிட அமைப்புகளை நிர்வகிக்கவும்.';

  @override
  String get gettingStartedStep1 => '1. உங்கள் இருப்பிடம் மற்றும் பயிர் விருப்பத்தேர்வுகளுடன் உங்கள் சுயவிவரத்தை அமைக்கவும்';

  @override
  String get gettingStartedStep2 => '2. துல்லியமான வானிலை புதுப்பிப்புகளுக்கு இருப்பிட அணுகலை அனுமதிக்கவும்';

  @override
  String get gettingStartedStep3 => '3. முகப்பு திரையில் வானிலை முன்னறிவிப்புகள் மற்றும் விவசாய நுண்ணறிவுகளை ஆராயுங்கள்';

  @override
  String get gettingStartedStep4 => '4. தனிப்பயனாக்கப்பட்ட விவசாய ஆலோசனைக்காக ஹார்வெஸ்ட்பாட்டுடன் அரட்டையடிக்கவும்';

  @override
  String get gettingStartedStep5 => '5. மற்ற விவசாயிகளுடன் இணைவதற்கு சமூகத்தில் சேரவும்';

  @override
  String get weatherUsageTitle => 'வானிலை அம்சங்களைப் பயன்படுத்துதல்';

  @override
  String get weatherUsageDesc => 'தற்போதைய வானிலை நிலைமைகள், 3-நாள் முன்னறிவிப்புகள் மற்றும் 30-நாள் நீட்டிக்கப்பட்ட முன்னறிவிப்புகளைக் காண்க. விரிவான காலண்டர் பார்வையைக் காண \'அனைத்தையும் காண்க\' என்பதைத் தட்டவும்.';

  @override
  String get aiChatUsageTitle => 'ஹார்வெஸ்ட்பாட்டைப் பயன்படுத்துதல்';

  @override
  String get aiChatUsageDesc => 'பயிர்கள், நோய்கள், உரங்கள் அல்லது ஏதேனும் விவசாய தலைப்பு பற்றி கேள்விகள் கேளுங்கள். AI உங்கள் உரையாடலின் அடிப்படையில் சூழல்-விழிப்புணர்வு பதில்களை வழங்குகிறது.';

  @override
  String get pestDetectionUsageTitle => 'பூச்சி கண்டறிதலைப் பயன்படுத்துதல்';

  @override
  String get pestDetectionUsageDesc => 'பாதிக்கப்பட்ட தாவரங்களின் தெளிவான புகைப்படங்களை எடுக்கவும். கணினி பகுப்பாய்வு செய்து அடையாளம் மற்றும் சிகிச்சை பரிந்துரைகளை வழங்கும்.';

  @override
  String get communityUsageTitle => 'சமூக அம்சங்களைப் பயன்படுத்துதல்';

  @override
  String get communityUsageDesc => 'இடுகைகள், புகைப்படங்கள் மற்றும் அனுபவங்களைப் பகிரவும். மற்றவர்களின் இடுகைகளில் கருத்து தெரிவித்து சக விவசாயிகளுடன் தொடர்புகளை உருவாக்குங்கள்.';

  @override
  String get troubleshootingTitle => 'சரிசெய்தல்';

  @override
  String get locationIssues => 'இருப்பிட பிரச்சினைகள்';

  @override
  String get locationIssuesDesc => 'துல்லியமான வானிலை தரவுக்காக உங்கள் சாதன அமைப்புகளில் இருப்பிட சேவைகள் இயக்கப்பட்டுள்ளன என்பதை உறுதிப்படுத்தவும்.';

  @override
  String get weatherNotLoading => 'வானிலை ஏற்றப்படவில்லை';

  @override
  String get weatherNotLoadingDesc => 'உங்கள் இணைய இணைப்பு மற்றும் இருப்பிட அனுமதிகளைச் சரிபார்க்கவும். முகப்பு திரையை புதுப்பிக்க கீழே இழுக்கவும்.';

  @override
  String get aiNotResponding => 'AI பதிலளிக்கவில்லை';

  @override
  String get aiNotRespondingDesc => 'உங்களிடம் நிலையான இணைய இணைப்பு உள்ளது என்பதை உறுதிப்படுத்தவும். AI புரிந்துகொள்ளவில்லை என்றால் உங்கள் கேள்வியை மீண்டும் வடிவமைக்க முயற்சிக்கவும்.';

  @override
  String get contactSupportDesc => 'கூடுதல் உதவிக்காக அல்லது சிக்கல்களைப் புகாரளிக்க, நீங்கள் செய்யலாம்:';

  @override
  String get emailSupport => 'எங்களுக்கு மின்னஞ்சல் அனுப்புங்கள்: support@harvesthub.com';

  @override
  String get reportIssue => 'ஆப் கருத்து மூலம் சிக்கல்களைப் புகாரளிக்கவும்';

  @override
  String get visitWebsite => 'எங்கள் வலைத்தளத்தைப் பார்வையிடவும்: www.harvesthub.com';

  @override
  String get appVersion => 'ஆப் பதிப்பு: 1.5.0';

  @override
  String get lastUpdated => 'கடைசியாக புதுப்பிக்கப்பட்டது: ஜூன் 2025';

  @override
  String get uploadPlantImage => 'தாவர படத்தை பதிவேற்றவும்';

  @override
  String get uploadPlantImageDesc => 'கீடுகள் மற்றும் நோய்களைக் கண்டறிய உங்கள் தாவர இலைகளின் தெளிவான புகைப்படம் எடுக்கவும் அல்லது கேலரியிலிருந்து பதிவேற்றவும்.';

  @override
  String get camera => 'கேமரா';

  @override
  String get gallery => 'கேலரி';

  @override
  String get analyzing => 'பகுப்பாய்வு செய்கிறது...';

  @override
  String get analyzingForecast => '30-நாள் முன்னறிவிப்பு பகுப்பாய்வு...';

  @override
  String get analyzeImage => 'படத்தை பகுப்பாய்வு செய்';

  @override
  String get detectionResults => 'கண்டறிதல் முடிவுகள்';

  @override
  String get noImageSelected => 'படம் தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String get uploadImageToGetStarted => 'தொடங்க ஒரு படத்தை பதிவேற்றவும்';

  @override
  String get analysisComplete => 'பகுப்பாய்வு முடிந்தது';

  @override
  String get noPestsDetected => 'இந்த படத்தில் கீடுகள் எதுவும் கண்டறியப்படவில்லை';

  @override
  String get cropsHealthyMessage => 'உங்கள் பயிர்கள் ஆரோக்கியமாக தெரிகின்றன! வழக்கமான கண்காணிப்பைத் தொடரவும் மற்றும் நல்ல விவசாய நடைமுறைகளை பராமரிக்கவும்.';

  @override
  String get recommendations => 'பரிந்துரைகள்';

  @override
  String get confidence => 'நம்பிக்கை';

  @override
  String get diagnosis => 'நோயறிதல்';

  @override
  String get causalAgent => 'காரணமான முகவர்';

  @override
  String get analysisError => 'பகுப்பாய்வு பிழை';

  @override
  String get analysisErrorDesc => 'படத்தை பகுப்பாய்வு செய்ய முடியவில்லை. தயவு செய்து தெளிவான புகைப்படத்துடன் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get readyToAnalyze => 'பகுப்பாய்வு செய்ய தயார்';

  @override
  String get uploadImageAndAnalyze => 'படத்தை பதிவேற்றி கீடுகளைக் கண்டறிந்து பரிந்துரைகளைப் பெற \"பகுப்பாய்வு\" என்பதைத் தட்டவும்';

  @override
  String get scanAgain => 'மீண்டும் ஸ்கேன் செய்யவும்';

  @override
  String get saveResult => 'முடிவை சேமிக்கவும்';

  @override
  String get resultSaved => 'முடிவு சேமிக்கப்பட்டது';

  @override
  String get uploadImageFirst => 'முதலில் ஒரு படத்தை பதிவேற்றவும்';

  @override
  String get tapAnalyzeToStart => 'கண்டறிதலைத் தொடங்க பகுப்பாய்வு பொத்தானைத் தட்டவும்';

  @override
  String get selectImageFromCameraOrGallery => 'கேமரா அல்லது கேலரியில் இருந்து படத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get failedToAnalyzeImage => 'படத்தை பகுப்பாய்வு செய்வதில் தோல்வி';

  @override
  String get howToUse => 'எப்படி பயன்படுத்துவது';

  @override
  String get takeClearPhotos => 'தாவர இலைகளின் தெளிவான, நன்கு ஒளிரும் புகைப்படங்களை எடுக்கவும்';

  @override
  String get focusOnAffectedAreas => 'தெரியும் அறிகுறிகளுடன் பாதிக்கப்பட்ட பகுதிகளில் கவனம் செலுத்துங்கள்';

  @override
  String get avoidBlurryImages => 'மங்கலான அல்லது இருண்ட படங்களைத் தவிர்க்கவும்';

  @override
  String get includeMultipleLeaves => 'முடிந்தால் பல இலைகளைச் சேர்க்கவும்';

  @override
  String get gotIt => 'புரிந்தது';

  @override
  String get basedOn30DayForecast => '30-நாள் வானிலை முன்னறிவிப்பின் அடிப்படையில்';

  @override
  String get basedOnCurrentConditions => 'தற்போதைய வானிலை நிலைமைகளின் அடிப்படையில்';

  @override
  String get personalInformation => 'தனிப்பட்ட தகவல்';

  @override
  String get updateYourProfileDetails => 'உங்கள் சுயவிவர விவரங்களை புதுப்பிக்கவும்';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get enterYourFullName => 'உங்கள் முழு பெயரை உள்ளிடவும்';

  @override
  String get emailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get enterYourEmailAddress => 'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get enterYourPhoneNumber => 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get saveChanges => 'மாற்றங்களை சேமிக்கவும்';

  @override
  String get changeProfilePicture => 'சுயவிவர படத்தை மாற்றவும்';

  @override
  String get remove => 'அகற்று';

  @override
  String get profileUpdatedSuccessfully => 'உங்கள் சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது.';

  @override
  String get mobileNumberUpdatedSuccessfully => 'உங்கள் மொபைல் எண் வெற்றிகரமாக புதுப்பிக்கப்பட்டது.';

  @override
  String get pleaseEnterVerificationCode => 'தயவு செய்து உங்கள் தொலைபேசிக்கு அனுப்பப்பட்ட சரிபார்ப்பு குறியீட்டை உள்ளிடவும்';

  @override
  String get otpAutoFilledSuccessfully => 'OTP வெற்றிகரமாக தானாக நிரப்பப்பட்டது!';

  @override
  String get otpWillBeFilledAutomatically => 'SMS பெறப்படும் போது OTP தானாகவே நிரப்பப்படும்';

  @override
  String get didntReceiveOTP => 'OTP பெறவில்லையா? ';

  @override
  String get resend => 'மீண்டும் அனுப்பு';

  @override
  String resendInSeconds(Object seconds) {
    return '$secondsவில் மீண்டும் அனுப்பு';
  }

  @override
  String get otpResentSuccessfully => 'OTP வெற்றிகரமாக மீண்டும் அனுப்பப்பட்டது';

  @override
  String get aiDisclaimer => 'AI உருவாக்கிய முடிவுகள் மறுப்பு';

  @override
  String get aiDisclaimerDesc => 'AI மூலம் உருவாக்கப்பட்ட நோயறிதல் மற்றும் பரிந்துரைகள் பிழைகள் இருக்கலாம். முக்கிய முடிவுகளுக்கு விவசாய நிபுணர்களை அணுகவும். இந்த தகவலை கூடுதல் வழிகாட்டியாக மட்டும் பயன்படுத்தவும்.';
}
