import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Navigation Performance Tracker
/// Monitors navigation performance and frame drops during tab switches
class NavigationPerformanceTracker {
  static final Map<String, DateTime> _navigationStartTimes = {};
  static final Map<String, Duration> _navigationDurations = {};
  static final List<String> _performanceWarnings = [];
  
  static const Duration _warningThreshold = Duration(milliseconds: 100);
  
  /// Start tracking navigation performance
  static void startNavigation(String navigationKey) {
    if (kDebugMode) {
      _navigationStartTimes[navigationKey] = DateTime.now();
      debugPrint('🚀 Navigation started: $navigationKey');
    }
  }
  
  /// End tracking navigation performance
  static void endNavigation(String navigationKey) {
    if (kDebugMode) {
      final startTime = _navigationStartTimes[navigationKey];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        _navigationDurations[navigationKey] = duration;
        
        final emoji = duration > _warningThreshold ? '🐌' : '⚡';
        debugPrint('$emoji Navigation completed: $navigationKey (${duration.inMilliseconds}ms)');
        
        if (duration > _warningThreshold) {
          final warning = 'Slow navigation: $navigationKey took ${duration.inMilliseconds}ms';
          _performanceWarnings.add(warning);
          debugPrint('⚠️ $warning');
        }
        
        _navigationStartTimes.remove(navigationKey);
      }
    }
  }
  
  /// Get all navigation durations
  static Map<String, Duration> getNavigationDurations() {
    return Map.from(_navigationDurations);
  }
  
  /// Get performance warnings
  static List<String> getPerformanceWarnings() {
    return List.from(_performanceWarnings);
  }
  
  /// Print navigation performance summary
  static void printPerformanceSummary() {
    if (kDebugMode) {
      debugPrint('=' * 50);
      debugPrint('📊 Navigation Performance Summary');
      debugPrint('=' * 50);
      
      if (_navigationDurations.isEmpty) {
        debugPrint('No navigation data recorded');
        return;
      }
      
      for (final entry in _navigationDurations.entries) {
        final navigation = entry.key;
        final duration = entry.value;
        final emoji = duration.inMilliseconds > 100 ? '🐌' : 
                     duration.inMilliseconds > 50 ? '🚶' : '⚡';
        debugPrint('$emoji $navigation: ${duration.inMilliseconds}ms');
      }
      
      if (_performanceWarnings.isNotEmpty) {
        debugPrint('\n⚠️ Performance Warnings:');
        for (final warning in _performanceWarnings) {
          debugPrint('  • $warning');
        }
      }
      
      final averageDuration = _calculateAverageDuration();
      debugPrint('\n📈 Average navigation time: ${averageDuration.inMilliseconds}ms');
      
      debugPrint('=' * 50);
    }
  }
  
  /// Clear all navigation data
  static void clear() {
    _navigationStartTimes.clear();
    _navigationDurations.clear();
    _performanceWarnings.clear();
  }
  
  static Duration _calculateAverageDuration() {
    if (_navigationDurations.isEmpty) return Duration.zero;
    
    final totalMs = _navigationDurations.values
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMs ~/ _navigationDurations.length);
  }
}

/// Mixin for widgets that want to track navigation performance
mixin NavigationPerformanceMixin<T extends StatefulWidget> on State<T> {
  String get navigationKey => widget.runtimeType.toString();
  
  @override
  void initState() {
    super.initState();
    NavigationPerformanceTracker.startNavigation('${navigationKey}_init');
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NavigationPerformanceTracker.endNavigation('${navigationKey}_init');
  }
  
  void trackNavigation(String operation, VoidCallback callback) {
    final key = '${navigationKey}_$operation';
    NavigationPerformanceTracker.startNavigation(key);
    callback();
    // Use post-frame callback to track completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationPerformanceTracker.endNavigation(key);
    });
  }
}
