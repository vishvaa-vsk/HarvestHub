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
  String get selectLanguage => 'पसंदीदा भाषा चुनें';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

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
  String get thirtyDayForecast => '30-दिन का पूर्वानुमान';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'मौसम पूर्वानुमान: $startDate - $endDate';
  }

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
  String get createPost => 'पोस्ट बनाएं';

  @override
  String get addComment => 'टिप्पणी जोड़ें...';

  @override
  String get post => 'पोस्ट';

  @override
  String get noPostsYet => 'अभी तक कोई पोस्ट नहीं।';

  @override
  String get whatsOnYourMind => 'आपके मन में क्या है?';

  @override
  String get welcomeToHarvestHub => 'HarvestHub में आपका स्वागत है...';

  @override
  String get shareYourThoughts => 'अपने विचार साझा करें, प्रश्न पूछें, और साथी किसानों से जुड़ें।';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get checkConnectionAndTryAgain => 'कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get welcomeToCommunity => 'समुदाय में आपका स्वागत है!';

  @override
  String get shareYourFarmingExperiences => 'अपने कृषि अनुभव, सुझाव साझा करें और साथी किसानों से जुड़ें';

  @override
  String get createFirstPost => 'पहली पोस्ट बनाएं';

  @override
  String get currentWeather => 'वर्तमान मौसम';

  @override
  String get upcomingForecast => 'आने वाला पूर्वानुमान';

  @override
  String get tomorrow => 'कल';

  @override
  String get minTemperature => 'न्यून:';

  @override
  String get rain => 'बारिश';

  @override
  String get viewAll => 'अधिक >';

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फरवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get sunday => 'रवि';

  @override
  String get monday => 'सोम';

  @override
  String get tuesday => 'मंगल';

  @override
  String get wednesday => 'बुध';

  @override
  String get thursday => 'गुरु';

  @override
  String get friday => 'शुक्र';

  @override
  String get saturday => 'शनि';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get about => 'के बारे में';

  @override
  String get helpAndSupportTitle => 'सहायता और समर्थन';

  @override
  String get appFeaturesTitle => 'ऐप फीचर्स';

  @override
  String get gettingStartedTitle => 'शुरुआत करना';

  @override
  String get featuresAndUsageTitle => 'फीचर्स और उपयोग';

  @override
  String get contactSupportTitle => 'संपर्क सहायता';

  @override
  String get weatherUpdatesFeature => 'मौसम अपडेट';

  @override
  String get weatherUpdatesDesc => 'अपनी कृषि गतिविधियों की योजना बनाने के लिए तापमान, आर्द्रता, हवा की गति और 3-दिन के पूर्वानुमान सहित रीयल-टाइम मौसम जानकारी प्राप्त करें।';

  @override
  String get aiChatFeature => 'हार्वेस्टबॉट AI असिस्टेंट';

  @override
  String get aiChatDesc => 'व्यक्तिगत सलाह, फसल सिफारिशों और आपके कृषि प्रश्नों के उत्तर के लिए हमारे AI-संचालित कृषि विशेषज्ञ से चैट करें।';

  @override
  String get pestDetectionFeature => 'कीट पहचान';

  @override
  String get pestDetectionDesc => 'संभावित कीट समस्याओं की पहचान करने और उपचार और रोकथाम के लिए सिफारिशें प्राप्त करने के लिए अपनी फसलों की तस्वीरें अपलोड करें।';

  @override
  String get communityFeature => 'कृषि समुदाय';

  @override
  String get communityDesc => 'साथी किसानों से जुड़ें, अनुभव साझा करें, प्रश्न पूछें और कृषि समुदाय से सीखें।';

  @override
  String get multiLanguageFeature => 'बहुभाषी समर्थन';

  @override
  String get multiLanguageDesc => 'अंग्रेजी, हिंदी, तमिल, तेलुगु और मलयालम के समर्थन के साथ अपनी पसंदीदा भाषा में ऐप का उपयोग करें।';

  @override
  String get profileManagementFeature => 'प्रोफाइल प्रबंधन';

  @override
  String get profileManagementDesc => 'व्यक्तिगत सिफारिशों के लिए अपनी व्यक्तिगत जानकारी, फसल प्राथमिकताओं और स्थान सेटिंग्स का प्रबंधन करें।';

  @override
  String get gettingStartedStep1 => '1. अपने स्थान और फसल प्राथमिकताओं के साथ अपना प्रोफाइल सेट करें';

  @override
  String get gettingStartedStep2 => '2. सटीक मौसम अपडेट के लिए स्थान पहुंच की अनुमति दें';

  @override
  String get gettingStartedStep3 => '3. होम स्क्रीन पर मौसम पूर्वानुमान और कृषि अंतर्दृष्टि देखें';

  @override
  String get gettingStartedStep4 => '4. व्यक्तिगत कृषि सलाह के लिए हार्वेस्टबॉट से चैट करें';

  @override
  String get gettingStartedStep5 => '5. अन्य किसानों से जुड़ने के लिए समुदाय में शामिल हों';

  @override
  String get weatherUsageTitle => 'मौसम फीचर्स का उपयोग';

  @override
  String get weatherUsageDesc => 'वर्तमान मौसम स्थितियों, 3-दिन के पूर्वानुमान और 30-दिन के विस्तृत पूर्वानुमान देखें। विस्तृत कैलेंडर दृश्य देखने के लिए \'सभी देखें\' पर टैप करें।';

  @override
  String get aiChatUsageTitle => 'हार्वेस्टबॉट का उपयोग';

  @override
  String get aiChatUsageDesc => 'फसलों, बीमारियों, उर्वरकों या किसी भी कृषि विषय के बारे में प्रश्न पूछें। AI आपकी बातचीत के आधार पर संदर्भ-जागरूक उत्तर प्रदान करता है।';

  @override
  String get pestDetectionUsageTitle => 'कीट पहचान का उपयोग';

  @override
  String get pestDetectionUsageDesc => 'प्रभावित पौधों की स्पष्ट तस्वीरें लें। सिस्टम विश्लेषण करेगा और पहचान और उपचार सिफारिशें प्रदान करेगा।';

  @override
  String get communityUsageTitle => 'समुदाय फीचर्स का उपयोग';

  @override
  String get communityUsageDesc => 'पोस्ट, फोटो और अनुभव साझा करें। दूसरों की पोस्ट पर टिप्पणी करें और साथी किसानों के साथ संबंध बनाएं।';

  @override
  String get troubleshootingTitle => 'समस्या निवारण';

  @override
  String get locationIssues => 'स्थान समस्याएं';

  @override
  String get locationIssuesDesc => 'सटीक मौसम डेटा के लिए अपनी डिवाइस सेटिंग्स में स्थान सेवाएं सक्षम हैं यह सुनिश्चित करें।';

  @override
  String get weatherNotLoading => 'मौसम लोड नहीं हो रहा';

  @override
  String get weatherNotLoadingDesc => 'अपना इंटरनेट कनेक्शन और स्थान अनुमतियां जांचें। होम स्क्रीन को रीफ्रेश करने के लिए नीचे खींचें।';

  @override
  String get aiNotResponding => 'AI जवाब नहीं दे रहा';

  @override
  String get aiNotRespondingDesc => 'सुनिश्चित करें कि आपके पास स्थिर इंटरनेट कनेक्शन है। यदि AI समझ नहीं पाता तो अपना प्रश्न दोबारा तैयार करने का प्रयास करें।';

  @override
  String get contactSupportDesc => 'अतिरिक्त सहायता के लिए या समस्याओं की रिपोर्ट करने के लिए, आप कर सकते हैं:';

  @override
  String get emailSupport => 'हमें ईमेल करें: support@harvesthub.com';

  @override
  String get reportIssue => 'ऐप फीडबैक के माध्यम से समस्याओं की रिपोर्ट करें';

  @override
  String get visitWebsite => 'हमारी वेबसाइट पर जाएं: www.harvesthub.com';

  @override
  String get appVersion => 'ऐप संस्करण: 1.5.0';

  @override
  String get lastUpdated => 'अंतिम अपडेट: जून 2025';

  @override
  String get uploadPlantImage => 'पौधे की छवि अपलोड करें';

  @override
  String get uploadPlantImageDesc => 'कीट और बीमारियों का पता लगाने के लिए अपने पौधे की पत्तियों की स्पष्ट तस्वीर लें या गैलरी से अपलोड करें।';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get analyzing => 'विश्लेषण कर रहे हैं...';

  @override
  String get analyzeImage => 'छवि का विश्लेषण करें';

  @override
  String get detectionResults => 'पहचान परिणाम';

  @override
  String get noImageSelected => 'कोई छवि चयनित नहीं';

  @override
  String get uploadImageToGetStarted => 'शुरू करने के लिए एक छवि अपलोड करें';

  @override
  String get analysisComplete => 'विश्लेषण पूर्ण';

  @override
  String get noPestsDetected => 'इस छवि में कोई कीट नहीं मिला';

  @override
  String get cropsHealthyMessage => 'आपकी फसलें स्वस्थ दिख रही हैं! नियमित निगरानी जारी रखें और अच्छी कृषि प्रथाओं को बनाए रखें।';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get readyToAnalyze => 'Ready to analyze';

  @override
  String get uploadImageAndAnalyze => 'Upload an image and tap \"Analyze\" to detect pests and get recommendations';

  @override
  String get howToUse => 'How to use';

  @override
  String get takeClearPhotos => 'Take clear, well-lit photos of plant leaves';

  @override
  String get focusOnAffectedAreas => 'Focus on affected areas with visible symptoms';

  @override
  String get avoidBlurryImages => 'Avoid blurry or dark images';

  @override
  String get includeMultipleLeaves => 'Include multiple leaves if possible';

  @override
  String get gotIt => 'Got it';
}
