// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'హార్వెస్ట్ హబ్';

  @override
  String get welcomeMessage => 'హార్వెస్ట్ హబ్‌కు స్వాగతం!';

  @override
  String get selectLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get english => 'ఆంగ్లం';

  @override
  String get hindi => 'హిందీ';

  @override
  String get tamil => 'తమిళం';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get malayalam => 'మలయాళం';

  @override
  String get home => 'హోమ్';

  @override
  String get harvestBot => 'హార్వెస్ట్ బాట్';

  @override
  String get pestDetection => 'పొత్తికాయ గుర్తింపు';

  @override
  String get community => 'సముదాయం';

  @override
  String get yourFarmingCompanion => 'మీ కృషి సహచరుడు';

  @override
  String get editProfileSettings => 'ప్రొఫైల్ సెట్టింగ్స్ ఎడిట్ చేయండి';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get errorLoadingUserData => 'ఉపయోగదారు డేటా లోడ్ చేయడంలో పొరపాటు';

  @override
  String get weatherForecast => 'కాలావస్థా అంచనాలు';

  @override
  String feelsLike(Object value) {
    return 'అనుభవం: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'గాలి: $speed కిమీ/గంట ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'అళుత్తం: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'ఆర్ద్రత: $value%';
  }

  @override
  String visibility(Object value) {
    return 'తెళివు: $value కిమీ';
  }

  @override
  String uvIndex(Object value) {
    return 'UV సూచిక: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'మెగ కవర్: $value%';
  }

  @override
  String get threeDayForecast => '3-రోజుల అంచనాలు';

  @override
  String get viewMore => 'మరింత చూడండి';

  @override
  String get failedToLoadWeather => 'కాలావస్థా డేటా లోడ్ చేయడంలో విఫలమైంది';

  @override
  String get farmingTip => 'కృషి సూచన';

  @override
  String get noFarmingTip => 'కృషి సూచన అందుబాటులో లేదు';

  @override
  String get recommendedCrop => 'శ్రేష్ఠమైన పంట';

  @override
  String get noCropRecommendation => 'పంట సూచన అందుబాటులో లేదు';

  @override
  String get locationServicesRequired => 'ఈ యాప్‌ను ఉపయోగించడానికి స్థానం సేవలు అవసరం.';

  @override
  String get failedToLoadInsights => 'అంతర్దృష్టులను లోడ్ చేయడంలో విఫలమైంది';

  @override
  String get sendOTP => 'OTP పంపండి';

  @override
  String get verifyOTP => 'OTP ధృవీకరించండి';

  @override
  String get name => 'పేరు';

  @override
  String get phoneNumber => 'ఫోన్ నంబర్';

  @override
  String get enterOTP => 'OTP నమోదు చేయండి';

  @override
  String get pleaseEnterNameAndPhone => 'దయచేసి మీ పేరు మరియు ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get invalidOTP => 'అసాధువైన OTP';

  @override
  String get failedToSendOTP => 'OTP పంపడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get failedToSignIn => 'సైన్ ఇన్ చేయడంలో విఫలమైంది';

  @override
  String get enableLocationServices => 'స్థానం సేవలను ప్రారంభించండి';

  @override
  String get openSettings => 'సెట్టింగ్స్ తెరవండి';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get nextContinue => 'జారీ रखें';

  @override
  String get proceed => 'ముందుకు సాగండి';

  @override
  String get changeLanguage => 'భాష మార్చండి';

  @override
  String get talkToHarvestBot => 'హార్వెస్ట్ బాట్‌తో మాట్లాడండి';

  @override
  String get createPost => 'పోస్ట్ సృష్టించండి';

  @override
  String get addComment => 'వ్యాఖ్యను జోడించండి...';

  @override
  String get post => 'పోస్ట్';

  @override
  String get noPostsYet => 'ఇంకా పోస్టులు లేవు.';

  @override
  String get whatsOnYourMind => 'మీ మనసులో ఏముంది?';

  @override
  String get currentWeather => 'ప్రస్తుత వాతావరణం';

  @override
  String get upcomingForecast => 'రాబోయే అంచనాలు';

  @override
  String get tomorrow => 'రేపు';

  @override
  String get minTemperature => 'Min:';

  @override
  String get rain => 'వర్షం';

  @override
  String get viewAll => 'అన్నింటినీ చూడండి >';

  @override
  String get weatherForecastCalendar => 'వాతావరణ అంచనాలు';

  @override
  String get january => 'జనవరి';

  @override
  String get february => 'ఫిబ్రవరి';

  @override
  String get march => 'మార్చి';

  @override
  String get april => 'ఏప్రిల్';

  @override
  String get may => 'మే';

  @override
  String get june => 'జూన్';

  @override
  String get july => 'జూలై';

  @override
  String get august => 'ఆగస్టు';

  @override
  String get september => 'సెప్టెంబర్';

  @override
  String get october => 'అక్టోబర్';

  @override
  String get november => 'నవంబర్';

  @override
  String get december => 'డిసెంబర్';

  @override
  String get sunday => 'ఆది';

  @override
  String get monday => 'సోమ';

  @override
  String get tuesday => 'మంగళ';

  @override
  String get wednesday => 'బుధ';

  @override
  String get thursday => 'గురు';

  @override
  String get friday => 'శుక్ర';

  @override
  String get saturday => 'శని';
}
