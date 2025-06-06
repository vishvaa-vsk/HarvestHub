/// The main entry point of the HarvestHub application.
///
/// This file initializes Firebase, loads environment variables, and sets up
/// the `MultiProvider` for state management. It also defines the `HarvestHubApp`
/// widget, which serves as the root of the application.
///
/// The app dynamically updates its locale and theme based on user preferences.
/// It also handles authentication state changes to navigate between the
/// authentication and home screens.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:harvesthub/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/auth/presentation/pages/language_selection_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/providers/weather_provider.dart';
import 'core/utils/avatar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'screens/community_feed.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<_HarvestHubAppState> harvestHubAppKey =
    GlobalKey<_HarvestHubAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // or your app's background color
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  // Preload common avatars for better performance
  _preloadAvatars();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
      child: HarvestHubApp(key: harvestHubAppKey),
    ),
  );
}

/// Preload common avatars to improve performance
void _preloadAvatars() {
  // Preload HarvestBot avatar
  AvatarUtils.preloadAvatar(userId: 'harvestbot');

  // Preload guest user avatar
  AvatarUtils.preloadAvatar(userId: 'guest');

  // If user is already authenticated, preload their avatar
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser?.phoneNumber != null) {
    AvatarUtils.preloadAvatar(userId: currentUser!.phoneNumber!);
  }
}

class HarvestHubApp extends StatefulWidget {
  const HarvestHubApp({super.key});

  @override
  State<HarvestHubApp> createState() => _HarvestHubAppState();
}

class _HarvestHubAppState extends State<HarvestHubApp> {
  Locale? _locale;
  bool _languagePicked = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('preferred_language');
    if (mounted) {
      setState(() {
        _languagePicked = langCode != null;
        if (langCode != null) {
          _locale = Locale(langCode);
          // Set WeatherProvider language
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final provider = Provider.of<WeatherProvider>(
                context,
                listen: false,
              );
              provider.setLanguage(langCode);
            }
          });
        }
      });
    }
  }

  Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', langCode);
    if (mounted) {
      setState(() {
        _locale = Locale(langCode);
        _languagePicked = true;
      });
    }
    // Set WeatherProvider language
    if (mounted) {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider.setLanguage(langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? fontFamily;
    switch ((_locale ?? const Locale('en')).languageCode) {
      case 'en':
        fontFamily = 'Poppins';
        break;
      case 'hi':
        fontFamily = 'NotoSansDevanagari';
        break;
      case 'ta':
        fontFamily = 'NotoSansTamil';
        break;
      case 'te':
        fontFamily = 'NotoSansTelugu';
        break;
      case 'ml':
        fontFamily = 'NotoSansMalayalam';
        break;
      default:
        fontFamily = 'Poppins';
    }
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('ta', ''), // Tamil
        Locale('te', ''), // Telugu
        Locale('ml', ''), // Malayalam
      ],
      locale: _locale,
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) return _locale;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en', '');
      },
      theme: ThemeData(
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MainScreen(),
        '/community': (context) => CommunityFeedPage(),
      },
      home:
          !_languagePicked
              ? LanguageSelectionPage(
                onLanguageSelected: (code) => setLocale(code),
              )
              : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const PhoneAuthPage();
                  }
                  return const MainScreen();
                },
              ),
    );
  }
}
