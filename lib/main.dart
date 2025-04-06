/// The main entry point of the HarvestHub application.
///
/// This file initializes Firebase, loads environment variables, and sets up
/// the `MultiProvider` for state management. It also defines the `HarvestHubApp`
/// widget, which serves as the root of the application.
///
/// The app dynamically updates its locale and theme based on user preferences.
/// It also handles authentication state changes to navigate between the
/// authentication and home screens.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/providers/weather_provider.dart';

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

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
        Locale('de', ''), // German
        Locale('hi', ''), // Hindi
        Locale('ta', ''), // Tamil
        Locale('te', ''), // Telugu
        Locale('kn', ''), // Kannada
        Locale('ml', ''), // Malayalam
        Locale('bn', ''), // Bengali
        Locale('gu', ''), // Gujarati
        Locale('mr', ''), // Marathi
        Locale('pa', ''), // Punjabi
        Locale('or', ''), // Odia
        Locale('zh', ''), // Chinese
        Locale('ja', ''), // Japanese
        Locale('ru', ''), // Russian
        Locale('ar', ''), // Arabic
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale is not supported, use the default locale
        return const Locale('en', '');
      },
      theme: AppTheme.lightTheme.copyWith(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.green, // Match the floating chat icon color
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MainScreen(), // Defined the '/home' route
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.hasData ? const MainScreen() : const PhoneAuthPage();
        },
      ),
    );
  }
}
