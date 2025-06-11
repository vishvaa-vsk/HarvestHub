import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-wide constants for colors, dimensions, and other reusable values
/// to improve performance and maintainability
class AppConstants {
  // Color constants
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color lightGreen = Color(0xFF20c25e);
  static const Color darkGreen = Color(0xFF12ab64);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textGray = Color(0xFF6B7280);
  static const Color dividerGray = Color(0xFFF0F0F0);

  // Additional color constants
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color borderGray = Color(0xFFE7E7E8);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color weatherBlue = Color(0xFF2196F3);
  static const Color materialGreen = Color(0xFF4CAF50);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color offWhite = Color(0xFFF9F9F9);
  static const Color switchInactive = Color(0xFFE5E5E5);

  // Gradient constants
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightGreen, darkGreen],
    stops: [0.25, 0.75],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dimension constants
  static const double defaultPadding = 16.0;
  static const double cardPadding = 20.0;
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;
  // Shadow constants
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  // System UI overlay styles
  static const SystemUiOverlayStyle defaultSystemUIStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  );

  // Performance constants
  static const int maxCacheSize = 100;
  static const Duration cacheExpiration = Duration(hours: 6);
  static const int maxMessagesInSession = 50;
  static const int saveThrottleMs = 1000;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
