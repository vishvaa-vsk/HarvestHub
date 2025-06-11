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
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/auth/presentation/pages/language_selection_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/providers/weather_provider.dart';
import 'core/utils/avatar_utils.dart';
import 'core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'screens/community_feed.dart';
import 'utils/startup_performance.dart';
import 'widgets/ultra_minimal_startup_screen.dart';

final GlobalKey<State<HarvestHubApp>> harvestHubAppKey =
    GlobalKey<State<HarvestHubApp>>();

void main() async {
  // Mark startup beginning for performance monitoring
  StartupPerformance.markAppStart();

  WidgetsFlutterBinding.ensureInitialized();
  // Set system UI overlay style early
  StartupPerformance.markStart('system_ui_setup');
  SystemChrome.setSystemUIOverlayStyle(AppConstants.defaultSystemUIStyle);
  StartupPerformance.markEnd('system_ui_setup');
  // CRITICAL: Make startup completely non-blocking
  StartupPerformance.markStart('async_initialization');

  // Run Firebase and dotenv in parallel with timeout to prevent blocking
  await StartupPerformance.measure('firebase_dotenv_parallel', () async {
    await Future.wait([
      Firebase.initializeApp().timeout(
        const Duration(seconds: 3),
      ), // Reduced timeout
      dotenv
          .load(fileName: ".env")
          .timeout(const Duration(seconds: 2)), // Reduced timeout
    ]);
  });

  StartupPerformance.markEnd('async_initialization');

  StartupPerformance.markStart('app_creation');
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
      child: HarvestHubApp(key: harvestHubAppKey),
    ),
  );
  StartupPerformance.markEnd('app_creation');
  // Defer avatar preloading with much longer delay to prevent any startup blocking
  Future.delayed(const Duration(seconds: 5), () {
    _preloadAvatarsAsync();
  });

  // Track when first frame is rendered
  StartupPerformance.onFirstFrameCallback();
}

/// Preload common avatars asynchronously to improve performance without blocking startup
void _preloadAvatarsAsync() {
  // Run avatar preloading in the background to avoid blocking main thread
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // Preload HarvestBot avatar
      await AvatarUtils.preloadAvatar(userId: 'harvestbot');

      // Preload guest user avatar
      await AvatarUtils.preloadAvatar(userId: 'guest');

      // If user is already authenticated, preload their avatar
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.phoneNumber != null) {
        await AvatarUtils.preloadAvatar(userId: currentUser!.phoneNumber!);
      }
    } catch (e) {
      // Silently handle preload errors to avoid impacting app startup
    }
  });
}

class HarvestHubApp extends StatefulWidget {
  const HarvestHubApp({super.key});

  @override
  State<HarvestHubApp> createState() => _HarvestHubAppState();
}

class _HarvestHubAppState extends State<HarvestHubApp> {
  Locale? _locale;
  bool _isLanguageLoaded = false;
  bool _isFirstTimeUser = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      // Use multiple layers of deferral to prevent any blocking
      Future.microtask(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add even more delay to prevent startup blocking
          Future.delayed(const Duration(seconds: 1), () async {
            try {
              final prefs = await SharedPreferences.getInstance();
              final langCode = prefs.getString('preferred_language');

              if (mounted) {
                setState(() {
                  _isLanguageLoaded = true;
                  // Show language selection only if no language preference exists
                  _isFirstTimeUser = langCode == null;
                  if (langCode != null) {
                    _locale = Locale(langCode);
                  } else {
                    _locale = const Locale('en'); // Default to English
                  }
                });

                // Set WeatherProvider language asynchronously with additional deferral
                if (langCode != null) {
                  Future.microtask(() {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        final provider = Provider.of<WeatherProvider>(
                          context,
                          listen: false,
                        );
                        provider.setLanguage(langCode);
                      }
                    });
                  });
                }
              }
            } catch (e) {
              // Handle any errors gracefully
              if (mounted) {
                setState(() {
                  _isLanguageLoaded = true;
                  _isFirstTimeUser = false;
                  _locale = const Locale('en');
                });
              }
            }
          });
        });
      });
    } catch (e) {
      // Handle any errors gracefully
      if (mounted) {
        setState(() {
          _isLanguageLoaded = true;
          _isFirstTimeUser = false;
          _locale = const Locale('en');
        });
      }
    }
  }

  Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', langCode);
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      setState(() {
        _locale = Locale(langCode);
        _isFirstTimeUser = false;
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Use a more efficient loading state to prevent frame drops
          if (snapshot.connectionState == ConnectionState.waiting ||
              !_isLanguageLoaded) {
            return const UltraMinimalStartupScreen();
          }

          // Check authentication first
          if (!snapshot.hasData) {
            // User is not authenticated, show phone auth
            return const PhoneAuthPage();
          }

          // User is authenticated - check if they need language selection
          if (_isFirstTimeUser) {
            return LanguageSelectionPage(
              onLanguageSelected: (code) => setLocale(code),
            );
          }

          // User is authenticated and has completed onboarding
          return const MainScreen();
        },
      ),
    );
  }
}
