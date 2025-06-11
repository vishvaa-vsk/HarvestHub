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
  String get selectLanguage => 'ఇష్టమైన భాషను ఎంచుకోండి';

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
  String get pestDetection => 'పురుగుల గుర్తింపు';

  @override
  String get community => 'సమూహం';

  @override
  String get yourFarmingCompanion => 'మీ కృషి సహచరుడు';

  @override
  String get editProfileSettings => 'ప్రొఫైల్ సెట్టింగ్స్ ఎడిట్ చేయండి';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get loading => 'లోడ్ చేస్తోంది...';

  @override
  String get errorLoadingUserData => 'ఉపయోగదారు డేటా లోడ్ చేయడంలో పొరపాటు';

  @override
  String get weatherForecast => 'వాతావరణ అంచనాలు';

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
    return 'ఒత్తిడి: $value mb';
  }

  @override
  String humidity(Object value) {
    return 'ఆర్ద్రత: $value%';
  }

  @override
  String visibility(Object value) {
    return 'దృశ్యత: $value కిమీ';
  }

  @override
  String uvIndex(Object value) {
    return 'UV సూచిక: $value';
  }

  @override
  String cloudCover(Object value) {
    return 'మేఘ కవర్: $value%';
  }

  @override
  String get threeDayForecast => '3-రోజుల అంచనాలు';

  @override
  String get thirtyDayForecast => '30-రోజుల అంచనాలు';

  @override
  String weatherForecastCalendar(Object startDate, Object endDate) {
    return 'వాతావరణ అంచనాలు: $startDate - $endDate';
  }

  @override
  String get viewMore => 'మరింత చూడండి';

  @override
  String get failedToLoadWeather => 'వాతావరణ డేటా లోడ్ చేయడంలో విఫలమైంది';

  @override
  String get farmingTip => 'కృషి సూచన';

  @override
  String get noFarmingTip => 'కృషి సూచన అందుబాటులో లేదు';

  @override
  String get recommendedCrop => 'సిఫారసు చేసిన పంట';

  @override
  String get noCropRecommendation => 'పంట సిఫారసు అందుబాటులో లేదు';

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
  String get invalidOTP => 'చెల్లని OTP';

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
  String get nextContinue => 'కొనసాగించు';

  @override
  String get proceed => 'ముందుకు సాగండి';

  @override
  String get changeLanguage => 'భాష మార్చండి';

  @override
  String get talkToHarvestBot => 'హార్వెస్ట్ బాట్‌తో మాట్లాడండి';

  @override
  String get createPost => 'పోస్ట్ సృష్టించండి';

  @override
  String get addComment => 'వ్యాఖ్య జోడించండి...';

  @override
  String get post => 'పోస్ట్';

  @override
  String get noPostsYet => 'ఇంకా పోస్ట్‌లు లేవు.';

  @override
  String get whatsOnYourMind => 'మీ మనసులో ఏమిటి?';

  @override
  String get welcomeToHarvestHub => 'HarvestHub కు స్వాగతం...';

  @override
  String get shareYourThoughts => 'మీ ఆలోచనలను పంచుకోండి, ప్రశ్నలు అడగండి మరియు తోటి రైతులతో కనెక్ట్ అవ్వండి.';

  @override
  String get somethingWentWrong => 'ఏదో తప్పు జరిగింది';

  @override
  String get checkConnectionAndTryAgain => 'దయచేసి మీ కనెక్షన్‌ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి';

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get welcomeToCommunity => 'కమ్యూనిటీకి స్వాగతం!';

  @override
  String get shareYourFarmingExperiences => 'మీ వ్యవసాయ అనుభవాలు, చిట్కాలను పంచుకోండి మరియు తోటి రైతులతో కనెక్ట్ అవ్వండి';

  @override
  String get createFirstPost => 'మొదటి పోస్ట్ సృష్టించండి';

  @override
  String get currentWeather => 'ప్రస్తుత వాతావరణం';

  @override
  String get upcomingForecast => 'రాబోయే అంచనాలు';

  @override
  String get tomorrow => 'రేపు';

  @override
  String get minTemperature => 'కనిష్ట:';

  @override
  String get rain => 'వర్షం';

  @override
  String get viewAll => 'అన్నీ చూడండి >';

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

  @override
  String get darkMode => 'డార్క్ మోడ్';

  @override
  String get notifications => 'నోటిఫికేషన్లు';

  @override
  String get helpSupport => 'సహాయం మరియు మద్దతు';

  @override
  String get about => 'గురించి';

  @override
  String get helpAndSupportTitle => 'సహాయం మరియు మద్దతు';

  @override
  String get appFeaturesTitle => 'యాప్ లక్షణాలు';

  @override
  String get gettingStartedTitle => 'ప్రారంభించడం';

  @override
  String get featuresAndUsageTitle => 'లక్షణాలు మరియు వినియోగం';

  @override
  String get contactSupportTitle => 'మద్దతు సంప్రదించండి';

  @override
  String get weatherUpdatesFeature => 'వాతావరణ నవీకరణలు';

  @override
  String get weatherUpdatesDesc => 'మీ కృషి కార్యకలాపాలను ప్రణాళిక చేయడానికి ఉష్ణోగ్రత, ఆర్ద్రత, గాలి వేగం మరియు 3-రోజుల అంచనాలను కలిగి ఉన్న రియల్-టైమ్ వాతావరణ సమాచారాన్ని పొందండి.';

  @override
  String get aiChatFeature => 'హార్వెస్ట్ బాట్ AI సహాయకుడు';

  @override
  String get aiChatDesc => 'వ్యక్తిగత సలహా, పంట సిఫారసులు మరియు మీ వ్యవసాయ ప్రశ్నలకు సమాధానాలు కోసం మా AI-శక్తి కలిగిన వ్యవసాయ నిపుణుడితో చాట్ చేయండి.';

  @override
  String get pestDetectionFeature => 'పురుగుల గుర్తింపు';

  @override
  String get pestDetectionDesc => 'సంభావ్య పురుగుల సమస్యలను గుర్తించడానికి మరియు చికిత్స మరియు నివారణకు సిఫారసులు పొందడానికి మీ పంటల ఫోటోలను అప్‌లోడ్ చేయండి.';

  @override
  String get communityFeature => 'వ్యవసాయ సమూహం';

  @override
  String get communityDesc => 'ఇతర రైతులతో కనెక్ట్ అవ్వండి, అనుభవాలను పంచుకోండి, ప్రశ్నలు అడగండి మరియు వ్యవసాయ సమూహం నుండి నేర్చుకోండి.';

  @override
  String get multiLanguageFeature => 'బహుభాషా మద్దతు';

  @override
  String get multiLanguageDesc => 'ఆంగ్లం, హిందీ, తమిళం, తెలుగు మరియు మలయాళం వంటి మీ ఇష్టమైన భాషలో యాప్‌ను ఉపయోగించండి.';

  @override
  String get profileManagementFeature => 'ప్రొఫైల్ నిర్వహణ';

  @override
  String get profileManagementDesc => 'వ్యక్తిగత సమాచారం, పంట ప్రాధాన్యతలు మరియు వ్యక్తిగతీకరించిన సిఫారసుల కోసం స్థానం సెట్టింగ్‌లను నిర్వహించండి.';

  @override
  String get gettingStartedStep1 => '1. మీ స్థానం మరియు పంట ప్రాధాన్యతలతో మీ ప్రొఫైల్‌ను సెట్అప్ చేయండి';

  @override
  String get gettingStartedStep2 => '2. ఖచ్చితమైన వాతావరణ నవీకరణల కోసం స్థానం యాక్సెస్‌ను అనుమతించండి';

  @override
  String get gettingStartedStep3 => '3. హోమ్ స్క్రీన్‌లో వాతావరణ అంచనాలు మరియు వ్యవసాయ అంతర్దృష్టులను అన్వేషించండి';

  @override
  String get gettingStartedStep4 => '4. వ్యక్తిగతీకరించిన వ్యవసాయ సలహా కోసం హార్వెస్ట్‌బాట్‌తో చాట్ చేయండి';

  @override
  String get gettingStartedStep5 => '5. ఇతర రైతులతో కనెక్ట్ అవ్వడానికి సమూహంలో చేరండి';

  @override
  String get weatherUsageTitle => 'వాతావరణ లక్షణాలను ఉపయోగించడం';

  @override
  String get weatherUsageDesc => 'ప్రస్తుత వాతావరణ పరిస్థితులు, 3-రోజుల అంచనాలు మరియు 30-రోజుల విస్తృత అంచనాలను చూడండి. వివరమైన క్యాలెండర్ వీక్షణ కోసం \'అన్నీ చూడండి\'పై నొక్కండి.';

  @override
  String get aiChatUsageTitle => 'హార్వెస్ట్‌బాట్ ఉపయోగించడం';

  @override
  String get aiChatUsageDesc => 'పంటలు, వ్యాధులు, ఎరువులు లేదా ఏదైనా వ్యవసాయ అంశం గురించి ప్రశ్నలు అడగండి. మీ సంభాషణ ఆధారంగా AI సందర్భానుసారమైన సమాధానాలను ఇస్తుంది.';

  @override
  String get pestDetectionUsageTitle => 'పురుగుల గుర్తింపు ఉపయోగించడం';

  @override
  String get pestDetectionUsageDesc => 'బాధిత మొక్కల స్పష్టమైన ఫోటోలు తీయండి. వ్యవస్థ విశ్లేషించి గుర్తింపు మరియు చికిత్స సిఫారసులు ఇస్తుంది.';

  @override
  String get communityUsageTitle => 'సమూహ లక్షణాలను ఉపయోగించడం';

  @override
  String get communityUsageDesc => 'పోస్టులు, ఫోటోలు, అనుభవాలను పంచుకోండి. ఇతరుల పోస్టులపై వ్యాఖ్యానించండి మరియు రైతులతో సంబంధాలు నిర్మించండి.';

  @override
  String get troubleshootingTitle => 'సమస్య పరిష్కారం';

  @override
  String get locationIssues => 'స్థానం సమస్యలు';

  @override
  String get locationIssuesDesc => 'ఖచ్చితమైన వాతావరణ డేటా కోసం మీ డివైస్ సెట్టింగ్స్‌లో స్థానం సేవలు ప్రారంభించండి.';

  @override
  String get weatherNotLoading => 'వాతావరణం లోడ్ కావడంలేదు';

  @override
  String get weatherNotLoadingDesc => 'మీ ఇంటర్నెట్ కనెక్షన్ మరియు స్థానం అనుమతులను తనిఖీ చేయండి. హోమ్ స్క్రీన్‌ను రిఫ్రెష్ చేయడానికి క్రిందికి లాగండి.';

  @override
  String get aiNotResponding => 'AI స్పందించడంలేదు';

  @override
  String get aiNotRespondingDesc => 'స్థిరమైన ఇంటర్నెట్ కనెక్షన్ ఉందో లేదో చూసుకోండి. AI అర్థం కాకపోతే మీ ప్రశ్నను మళ్లీ అడగండి.';

  @override
  String get contactSupportDesc => 'అదనపు సహాయం లేదా సమస్యలు నివేదించడానికి, మీరు చేయవచ్చు:';

  @override
  String get emailSupport => 'మాకు ఈమెయిల్ చేయండి: support@harvesthub.com';

  @override
  String get reportIssue => 'యాప్ ఫీడ్‌బ్యాక్ ద్వారా సమస్యలను నివేదించండి';

  @override
  String get visitWebsite => 'మా వెబ్‌సైట్ సందర్శించండి: www.harvesthub.com';

  @override
  String get appVersion => 'యాప్ వెర్షన్: 1.5.0';

  @override
  String get lastUpdated => 'చివరిగా నవీకరించబడింది: జూన్ 2025';

  @override
  String get uploadPlantImage => 'మొక్క చిత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get uploadPlantImageDesc => 'పురుగులు మరియు వ్యాధులను గుర్తించడానికి మొక్క ఆకుల స్పష్టమైన ఫోటో తీయండి లేదా గ్యాలరీ నుండి అప్‌లోడ్ చేయండి.';

  @override
  String get camera => 'కెమెరా';

  @override
  String get gallery => 'గ్యాలరీ';

  @override
  String get analyzing => 'విశ్లేషిస్తోంది...';

  @override
  String get analyzingForecast => '30-రోజుల అంచనాలు విశ్లేషిస్తోంది...';

  @override
  String get analyzeImage => 'చిత్రాన్ని విశ్లేషించండి';

  @override
  String get detectionResults => 'గుర్తింపు ఫలితాలు';

  @override
  String get noImageSelected => 'చిత్రం ఎంచుకోబడలేదు';

  @override
  String get uploadImageToGetStarted => 'ప్రారంభించడానికి చిత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get analysisComplete => 'విశ్లేషణ పూర్తయింది';

  @override
  String get noPestsDetected => 'ఈ చిత్రంలో పురుగులు గుర్తించబడలేదు';

  @override
  String get cropsHealthyMessage => 'మీ పంటలు ఆరోగ్యంగా కనిపిస్తున్నాయి! రెగ్యులర్ మానిటరింగ్ కొనసాగించండి మరియు మంచి వ్యవసాయ పద్ధతులను కొనసాగించండి.';

  @override
  String get recommendations => 'సిఫారసులు';

  @override
  String get confidence => 'విశ్వాసం';

  @override
  String get diagnosis => 'నిర్ధారణ';

  @override
  String get causalAgent => 'కారక ఏజెంట్';

  @override
  String get analysisError => 'విశ్లేషణ లోపం';

  @override
  String get analysisErrorDesc => 'చిత్రాన్ని విశ్లేషించలేకపోయింది. దయచేసి స్పష్టమైన ఫోటోతో మళ్లీ ప్రయత్నించండి.';

  @override
  String get readyToAnalyze => 'విశ్లేషించడానికి సిద్ధం';

  @override
  String get uploadImageAndAnalyze => 'చిత్రాన్ని అప్‌లోడ్ చేసి పురుగులను గుర్తించడానికి మరియు సిఫారసులు పొందడానికి \"విశ్లేషించండి\"పై టాప్ చేయండి';

  @override
  String get scanAgain => 'మళ్లీ స్కాన్ చేయండి';

  @override
  String get saveResult => 'ఫలితాన్ని సేవ్ చేయండి';

  @override
  String get resultSaved => 'ఫలితం సేవ్ చేయబడింది';

  @override
  String get uploadImageFirst => 'మొదట చిత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get tapAnalyzeToStart => 'గుర్తింపును ప్రారంభించడానికి విశ్లేషణ బటన్‌ను టాప్ చేయండి';

  @override
  String get selectImageFromCameraOrGallery => 'కెమెరా లేదా గ్యాలరీ నుండి చిత్రాన్ని ఎంచుకోండి';

  @override
  String get failedToAnalyzeImage => 'చిత్రాన్ని విశ్లేషించడంలో విఫలమైంది';

  @override
  String get howToUse => 'ఎలా ఉపయోగించాలి';

  @override
  String get takeClearPhotos => 'మొక్క ఆకుల స్పష్టమైన, బాగా వెలుగుతున్న ఫోటోలు తీయండి';

  @override
  String get focusOnAffectedAreas => 'కనిపించే లక్షణాలతో ప్రభావిత ప్రాంతాలపై దృష్టి పెట్టండి';

  @override
  String get avoidBlurryImages => 'అస్పష్టమైన లేదా చీకటి చిత్రాలను నివారించండి';

  @override
  String get includeMultipleLeaves => 'వీలైతే అనేక ఆకులను చేర్చండి';

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get basedOn30DayForecast => '30-రోజుల వాతావరణ అంచనా ఆధారంగా';

  @override
  String get basedOnCurrentConditions => 'ప్రస్తుత వాతావరణ పరిస్థితుల ఆధారంగా';

  @override
  String get personalInformation => 'వ్యక్తిగత సమాచారం';

  @override
  String get updateYourProfileDetails => 'మీ ప్రొఫైల్ వివరాలను అప్‌డేట్ చేయండి';

  @override
  String get fullName => 'పూర్తి పేరు';

  @override
  String get enterYourFullName => 'మీ పూర్తి పేరును నమోదు చేయండి';

  @override
  String get emailAddress => 'ఈమెయిల్ చిరునామా';

  @override
  String get enterYourEmailAddress => 'మీ ఈమెయిల్ చిరునామాను నమోదు చేయండి';

  @override
  String get enterYourPhoneNumber => 'మీ ఫోన్ నంబర్‌ను నమోదు చేయండి';

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయండి';

  @override
  String get changeProfilePicture => 'ప్రొఫైల్ చిత్రాన్ని మార్చండి';

  @override
  String get remove => 'తొలగించు';

  @override
  String get profileUpdatedSuccessfully => 'మీ ప్రొఫైల్ విజయవంతంగా అప్‌డేట్ చేయబడింది.';

  @override
  String get mobileNumberUpdatedSuccessfully => 'మీ మొబైల్ నంబర్ విజయవంతంగా అప్‌డేట్ చేయబడింది.';

  @override
  String get pleaseEnterVerificationCode => 'దయచేసి మీ ఫోన్‌కు పంపబడిన వెరిఫికేషన్ కోడ్‌ను నమోదు చేయండి';

  @override
  String get otpAutoFilledSuccessfully => 'OTP విజయవంతంగా ఆటో-ఫిల్ చేయబడింది!';

  @override
  String get otpWillBeFilledAutomatically => 'SMS అందినప్పుడు OTP ఆటోమేటిక్‌గా భర్తీ చేయబడుతుంది';

  @override
  String get didntReceiveOTP => 'OTP రాలేదా? ';

  @override
  String get resend => 'మళ్లీ పంపు';

  @override
  String resendInSeconds(Object seconds) {
    return '$secondsలో మళ్లీ పంపు';
  }

  @override
  String get otpResentSuccessfully => 'OTP విజయవంతంగా మళ్లీ పంపబడింది';
}
