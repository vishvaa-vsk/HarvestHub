import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Debouncer to prevent excessive function calls
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive == true) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler to limit function calls to once per interval
class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _canExecute = true;

  Throttler({required this.milliseconds});

  void run(VoidCallback action) {
    if (_canExecute) {
      action();
      _canExecute = false;
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _canExecute = true;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Batch loader for optimizing multiple async operations
class BatchLoader<T> {
  final Map<String, T> _cache = {};
  final Map<String, Future<T>> _pendingRequests = {};
  final Future<T> Function(String key) _loader;
  final Duration _cacheDuration;
  final Map<String, DateTime> _cacheTimestamps = {};

  BatchLoader({
    required Future<T> Function(String key) loader,
    Duration cacheDuration = const Duration(minutes: 5),
  }) : _loader = loader,
       _cacheDuration = cacheDuration;

  Future<T?> load(String key) async {
    // Check cache first
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheDuration) {
        return _cache[key];
      }
    }

    // Check if already loading
    if (_pendingRequests.containsKey(key)) {
      return await _pendingRequests[key];
    }

    // Start loading
    final future = _loader(key);
    _pendingRequests[key] = future;

    try {
      final result = await future;
      _cache[key] = result;
      _cacheTimestamps[key] = DateTime.now();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('BatchLoader error for key $key: $e');
      }
      return null;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  Future<List<T?>> loadBatch(List<String> keys) async {
    final futures = keys.map((key) => load(key)).toList();
    return await Future.wait(futures);
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  T? getCached(String key) {
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheDuration) {
        return _cache[key];
      }
    }
    return null;
  }
}

/// Performance utilities for the HarvestHub app
class PerformanceUtils {
  /// Memory-efficient ListView builder with automatic disposal
  static Widget buildOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index)
    itemBuilder,
    double? itemExtent,
    double? cacheExtent,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      itemCount: items.length,
      itemExtent: itemExtent,
      cacheExtent: cacheExtent ?? 250.0, // Reduced cache for memory efficiency
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        if (index >= items.length) return const SizedBox.shrink();
        return itemBuilder(context, items[index], index);
      },
    );
  }

  /// Widget tree performance monitor (debug only)
  static Widget monitorPerformance({required Widget child, String? name}) {
    if (kDebugMode) {
      return _PerformanceMonitor(name: name ?? 'Widget', child: child);
    }
    return child;
  }
}

class _PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String name;

  const _PerformanceMonitor({required this.child, required this.name});

  @override
  State<_PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<_PerformanceMonitor> {
  int _buildCount = 0;
  DateTime? _lastBuild;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final now = DateTime.now();

    if (_lastBuild != null) {
      final timeSinceLastBuild = now.difference(_lastBuild!).inMilliseconds;
      if (timeSinceLastBuild < 16) {
        // Less than 1 frame at 60fps
        debugPrint(
          '⚠️ ${widget.name}: Rapid rebuild #$_buildCount (${timeSinceLastBuild}ms)',
        );
      }
    }

    _lastBuild = now;

    return widget.child;
  }
}

/// Navigation performance utilities
class NavigationUtils {
  static const Duration _defaultNavigationThrottle = Duration(milliseconds: 300);
  static DateTime? _lastNavigationTime;

  /// Throttle navigation to prevent rapid taps causing frame drops
  static bool canNavigate({Duration? throttleDuration}) {
    final now = DateTime.now();
    final threshold = throttleDuration ?? _defaultNavigationThrottle;
    
    if (_lastNavigationTime == null || 
        now.difference(_lastNavigationTime!) > threshold) {
      _lastNavigationTime = now;
      return true;
    }
    return false;
  }

  /// Reset navigation throttle (useful for testing)
  static void resetThrottle() {
    _lastNavigationTime = null;
  }

  /// Optimized route builder that reduces animation overhead
  static Route<T> buildOptimizedRoute<T extends Object?>(
    Widget page, {
    Duration? transitionDuration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: curve ?? Curves.fastOutSlowIn,
          ),
          child: child,
        );
      },
    );
  }
}
