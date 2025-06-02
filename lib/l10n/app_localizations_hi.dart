// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'हार्वेस्टहब';

  @override
  String get welcomeMessage => 'हार्वेस्टहब में आपका स्वागत है!';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get tamil => 'तमिल';

  @override
  String get telugu => 'तेलुगु';

  @override
  String get malayalam => 'मलयालम';

  @override
  String get home => 'होम';

  @override
  String get harvestBot => 'हार्वेस्टबॉट';

  @override
  String get pestDetection => 'कीट पहचान';

  @override
  String get community => 'समुदाय';

  @override
  String get yourFarmingCompanion => 'आपका कृषि साथी';

  @override
  String get editProfileSettings => 'प्रोफ़ाइल सेटिंग्स संपादित करें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get errorLoadingUserData => 'उपयोगकर्ता डेटा लोड करने में त्रुटि';

  @override
  String get weatherForecast => 'मौसम पूर्वानुमान';

  @override
  String feelsLike(Object value) {
    return 'महसूस होता है: $value°C';
  }

  @override
  String wind(Object speed, Object dir) {
    return 'हवा: $speed किमी/घंटा ($dir)';
  }

  @override
  String pressure(Object value) {
    return 'दबाव: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'आर्द्रता: $value%';
  }

  @override
  String visibility(Object value) {
    return 'दृश्यता: $value किमी';
  }

  @override
  String uvIndex(Object value) {
    return 'यूवी इंडेक्स: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'मेघ आवरण: $value%';
  }

  @override
  String get threeDayForecast => '3-दिन का पूर्वानुमान';

  @override
  String get viewMore => 'और देखें';

  @override
  String get failedToLoadWeather => 'मौसम डेटा लोड करने में विफल';

  @override
  String get farmingTip => 'कृषि टिप';

  @override
  String get noFarmingTip => 'कोई कृषि टिप उपलब्ध नहीं है';

  @override
  String get recommendedCrop => 'अनुशंसित फसल';

  @override
  String get noCropRecommendation => 'कोई फसल अनुशंसा उपलब्ध नहीं है';

  @override
  String get locationServicesRequired => 'इस ऐप का उपयोग करने के लिए स्थान सेवाएँ आवश्यक हैं।';

  @override
  String get failedToLoadInsights => 'अंतर्दृष्टि लोड करने में विफल';

  @override
  String get sendOTP => 'OTP भेजें';

  @override
  String get verifyOTP => 'OTP सत्यापित करें';

  @override
  String get name => 'नाम';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterOTP => 'OTP दर्ज करें';

  @override
  String get pleaseEnterNameAndPhone => 'कृपया अपना नाम और फोन नंबर दर्ज करें';

  @override
  String get invalidOTP => 'अमान्य OTP';

  @override
  String get failedToSendOTP => 'OTP भेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get failedToSignIn => 'Failed to sign in';

  @override
  String get enableLocationServices => 'स्थान सेवाएँ सक्षम करें';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get nextContinue => 'जारी रखें';

  @override
  String get proceed => 'आगे बढ़ें';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get talkToHarvestBot => 'हार्वेस्टबॉट से बात करें';

  @override
  String get createPost => 'पोस्ट बनाएँ';

  @override
  String get addComment => 'टिप्पणी जोड़ें...';

  @override
  String get post => 'पोस्ट';

  @override
  String get noPostsYet => 'अभी तक कोई पोस्ट नहीं है।';

  @override
  String get whatsOnYourMind => 'आपके मन में क्या है?';
}
