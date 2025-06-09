import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utility class for monitoring and optimizing app startup performance
class StartupPerformance {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, Duration> _durations = {};
  static DateTime? _appStartTime;
  /// Mark the start of app initialization
  static void markAppStart() {
    _appStartTime = DateTime.now();
    if (kDebugMode) {
      debugPrint('🚀 App startup began at $_appStartTime');
    }
  }

  /// Mark the start of a specific operation
  static void markStart(String operation) {
    _startTimes[operation] = DateTime.now();
    if (kDebugMode) {
      debugPrint('⏱️ Started: $operation');
    }
  }

  /// Mark the end of a specific operation and calculate duration
  static void markEnd(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _durations[operation] = duration;
      _startTimes.remove(operation);
      
      if (kDebugMode) {
        debugPrint('✅ Completed: $operation in ${duration.inMilliseconds}ms');
        
        // Warn if operation took too long
        if (duration.inMilliseconds > 100) {
          debugPrint('⚠️ Performance Warning: $operation took ${duration.inMilliseconds}ms (>100ms)');
        }
      }
    }
  }

  /// Mark when first frame is rendered
  static void markFirstFrame() {
    if (_appStartTime != null) {
      final totalStartupTime = DateTime.now().difference(_appStartTime!);
      _durations['total_startup'] = totalStartupTime;
      
      if (kDebugMode) {
        debugPrint('🎯 First frame rendered in ${totalStartupTime.inMilliseconds}ms');
        printSummary();
      }
    }
  }

  /// Execute a function while measuring its performance
  static Future<T> measure<T>(String operation, Future<T> Function() function) async {
    markStart(operation);
    try {
      final result = await function();
      markEnd(operation);
      return result;
    } catch (e) {
      markEnd(operation);
      if (kDebugMode) {
        debugPrint('❌ Error in $operation: $e');
      }
      rethrow;
    }
  }

  /// Execute a synchronous function while measuring its performance
  static T measureSync<T>(String operation, T Function() function) {
    markStart(operation);
    try {
      final result = function();
      markEnd(operation);
      return result;
    } catch (e) {
      markEnd(operation);
      if (kDebugMode) {
        debugPrint('❌ Error in $operation: $e');
      }
      rethrow;
    }
  }

  /// Print performance summary
  static void printSummary() {
    if (!kDebugMode) return;
    
    debugPrint('\n📊 STARTUP PERFORMANCE SUMMARY');
    debugPrint('=' * 50);
    
    final sortedEntries = _durations.entries.toList()
      ..sort((a, b) => b.value.inMilliseconds.compareTo(a.value.inMilliseconds));
    
    for (final entry in sortedEntries) {
      final operation = entry.key;
      final duration = entry.value;
      final emoji = duration.inMilliseconds > 100 ? '🐌' : 
                   duration.inMilliseconds > 50 ? '🚶' : '🏃';
      debugPrint('$emoji $operation: ${duration.inMilliseconds}ms');
    }
    
    debugPrint('=' * 50);
  }

  /// Get duration for a specific operation
  static Duration? getDuration(String operation) {
    return _durations[operation];
  }

  /// Get all recorded durations
  static Map<String, Duration> getAllDurations() {
    return Map.from(_durations);
  }

  /// Clear all recorded data
  static void clear() {
    _startTimes.clear();
    _durations.clear();
    _appStartTime = null;
  }

  /// Callback to be used with WidgetsBinding.instance.addPostFrameCallback
  static void onFirstFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markFirstFrame();
    });
  }

  /// Optimize widget for performance monitoring
  static Widget wrapWidget(String name, Widget child) {
    if (!kDebugMode) return child;
    
    return Builder(
      builder: (context) {
        markStart('widget_build_$name');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          markEnd('widget_build_$name');
        });
        return child;
      },
    );
  }
}

/// Mixin for widgets that want to track their build performance
mixin PerformanceTracking<T extends StatefulWidget> on State<T> {
  late String _widgetName;

  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
    StartupPerformance.markStart('init_$_widgetName');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupPerformance.markEnd('init_$_widgetName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StartupPerformance.measureSync('build_$_widgetName', () {
      return buildWithTracking(context);
    });
  }

  /// Override this method instead of build() when using PerformanceTracking
  Widget buildWithTracking(BuildContext context);
}
