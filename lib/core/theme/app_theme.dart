import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32), // Green shade for agriculture theme
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  );

  static String fontFamilyForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Poppins';
      case 'ta':
        return 'NotoSansTamil';
      case 'te':
        return 'NotoSansTelugu';
      case 'ml':
        return 'NotoSansMalayalam';
      case 'hi':
        return 'NotoSansDevanagari';
      default:
        return 'Poppins';
    }
  }

  static ThemeData themedForLocale(Locale locale) {
    final fontFamily = fontFamilyForLocale(locale);
    return lightTheme.copyWith(
      textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
    );
  }
}
