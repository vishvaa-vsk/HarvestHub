import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

/// Frame Drop Performance Monitor
/// Tracks frame drops and UI freezes to identify performance bottlenecks
class FrameDropMonitor {
  static final List<Duration> _frameTimes = [];
  static final List<String> _heavyOperations = [];
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  static int _skippedFrames = 0;
  static DateTime? _lastFrameTime;

  static const Duration _frameDropThreshold = Duration(
    milliseconds: 32,
  ); // 2 frames

  /// Start monitoring frame performance
  static void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _skippedFrames = 0;
    _frameTimes.clear();
    _heavyOperations.clear();

    if (kDebugMode) {
      debugPrint('🔍 Frame Drop Monitor started');
    }

    // Use SchedulerBinding to monitor frame timing
    SchedulerBinding.instance.addPostFrameCallback(_frameCallback);

    // Start periodic reporting
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _reportFramePerformance();
    });
  }

  /// Stop monitoring frame performance
  static void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    if (kDebugMode) {
      debugPrint('🛑 Frame Drop Monitor stopped');
      _printFinalReport();
    }
  }

  /// Mark a heavy operation that might cause frame drops
  static void markHeavyOperation(String operation) {
    if (_isMonitoring) {
      _heavyOperations.add(
        '${DateTime.now().millisecondsSinceEpoch}: $operation',
      );
      if (kDebugMode) {
        debugPrint('🔥 Heavy operation: $operation');
      }
    }
  }

  /// Wrap a function to automatically track if it causes frame drops
  static T trackOperation<T>(String operationName, T Function() operation) {
    final startTime = DateTime.now();
    final result = operation();
    final duration = DateTime.now().difference(startTime);

    if (duration > _frameDropThreshold) {
      markHeavyOperation('$operationName (${duration.inMilliseconds}ms)');
    }

    return result;
  }

  /// Async version of trackOperation
  static Future<T> trackAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final startTime = DateTime.now();
    final result = await operation();
    final duration = DateTime.now().difference(startTime);

    if (duration > _frameDropThreshold) {
      markHeavyOperation('$operationName (${duration.inMilliseconds}ms)');
    }

    return result;
  }

  static void _frameCallback(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);

      // Check for dropped frames
      if (frameDuration > _frameDropThreshold) {
        _skippedFrames++;
        if (kDebugMode) {
          debugPrint(
            '🐌 Frame drop detected: ${frameDuration.inMilliseconds}ms',
          );
        }
      }
    }

    _lastFrameTime = now;

    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_frameCallback);
  }

  static void _reportFramePerformance() {
    if (!_isMonitoring || _frameTimes.isEmpty) return;

    final averageFrameTime = _calculateAverageFrameTime();
    final fps = (1000 / averageFrameTime.inMilliseconds).round();

    if (kDebugMode) {
      debugPrint('📊 Frame Performance Report:');
      debugPrint('   FPS: $fps');
      debugPrint('   Skipped frames: $_skippedFrames');
      debugPrint('   Average frame time: ${averageFrameTime.inMilliseconds}ms');

      if (_heavyOperations.isNotEmpty) {
        debugPrint('   Recent heavy operations:');
        for (final op in _heavyOperations.take(3)) {
          debugPrint('     • $op');
        }
      }
    }
  }

  static void _printFinalReport() {
    if (_frameTimes.isEmpty) return;

    debugPrint('=' * 50);
    debugPrint('📊 Frame Drop Monitor Final Report');
    debugPrint('=' * 50);

    final averageFrameTime = _calculateAverageFrameTime();
    final fps = (1000 / averageFrameTime.inMilliseconds).round();
    final frameDropPercentage = (_skippedFrames / _frameTimes.length * 100)
        .toStringAsFixed(2);
    debugPrint('Total frames monitored: ${_frameTimes.length}');
    debugPrint('Skipped frames: $_skippedFrames ($frameDropPercentage%)');
    debugPrint('Average FPS: $fps');
    debugPrint('Average frame time: ${averageFrameTime.inMilliseconds}ms');

    if (_heavyOperations.isNotEmpty) {
      debugPrint('\nHeavy operations detected:');
      for (final op in _heavyOperations) {
        debugPrint('  • $op');
      }
    }

    // Performance recommendations    debugPrint('\n💡 Performance Recommendations:');
    if (_skippedFrames > _frameTimes.length * 0.1) {
      debugPrint('  • High frame drop rate detected (>$frameDropPercentage%)');
      debugPrint('  • Consider using RepaintBoundary for complex widgets');
      debugPrint(
        '  • Profile with Flutter Inspector for widget rebuild analysis',
      );
    }

    if (_heavyOperations.length > 10) {
      debugPrint('  • Many heavy operations detected');
      debugPrint('  • Consider debouncing/throttling user interactions');
      debugPrint('  • Move heavy computations to isolates or background');
    }

    if (fps < 55) {
      debugPrint('  • Low FPS detected ($fps)');
      debugPrint('  • Consider lazy loading and viewport optimization');
      debugPrint('  • Review widget building complexity');
    }

    debugPrint('=' * 50);
  }

  static Duration _calculateAverageFrameTime() {
    if (_frameTimes.isEmpty) return Duration.zero;

    final totalMicroseconds = _frameTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ _frameTimes.length);
  }

  /// Get current performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    if (_frameTimes.isEmpty) {
      return {
        'isMonitoring': _isMonitoring,
        'framesMonitored': 0,
        'skippedFrames': 0,
        'averageFPS': 0,
        'frameDropPercentage': 0.0,
      };
    }

    final averageFrameTime = _calculateAverageFrameTime();
    final fps = (1000 / averageFrameTime.inMilliseconds).round();
    final frameDropPercentage = _skippedFrames / _frameTimes.length * 100;

    return {
      'isMonitoring': _isMonitoring,
      'framesMonitored': _frameTimes.length,
      'skippedFrames': _skippedFrames,
      'averageFPS': fps,
      'frameDropPercentage': frameDropPercentage,
      'heavyOperations': _heavyOperations.length,
    };
  }
}
