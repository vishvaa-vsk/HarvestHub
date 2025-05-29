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
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/auth/presentation/pages/language_selection_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/providers/weather_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
      child: const HarvestHubApp(),
    ),
  );
}

class HarvestHubApp extends StatefulWidget {
  const HarvestHubApp({super.key});

  @override
  State<HarvestHubApp> createState() => _HarvestHubAppState();
}

class _HarvestHubAppState extends State<HarvestHubApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('preferred_language');
    if (langCode != null) {
      setState(() {
        _locale = Locale(langCode);
      });
      // Set WeatherProvider language
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<WeatherProvider>(context, listen: false);
        provider.setLanguage(langCode);
      });
    }
  }

  // Call this after language selection
  Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', langCode);
    setState(() {
      _locale = Locale(langCode);
    });
    // Set WeatherProvider language
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    provider.setLanguage(langCode);
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
      routes: {'/home': (context) => const MainScreen()},
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const PhoneAuthPage();
          }
          return FutureBuilder<String?>(
            future: _getPreferredLanguage(),
            builder: (context, langSnapshot) {
              if (langSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (langSnapshot.data == null) {
                return LanguageSelectionPage(
                  onLanguageSelected: (code) => setLocale(code),
                );
              }
              return const MainScreen();
            },
          );
        },
      ),
    );
  }
}

// Add this function to the HarvestHubApp class (as a static helper or top-level function)
Future<String?> _getPreferredLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('preferred_language');
}
