import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// A service for managing avatar caching to reduce API calls.
///
/// This service caches avatar URLs locally using SharedPreferences,
/// ensuring that each user gets a consistent avatar throughout the app
/// without making repeated API calls to the avatar service.
class AvatarCacheService {
  static const String _cacheKeyPrefix = 'cached_avatar_';
  static const String _avatarBaseUrl = 'https://avatar.iran.liara.run/public';

  // Memory cache to avoid SharedPreferences calls
  final Map<String, String> _memoryCache = {};

  // Singleton pattern
  static final AvatarCacheService _instance = AvatarCacheService._internal();
  factory AvatarCacheService() => _instance;
  AvatarCacheService._internal();

  /// Get a cached avatar URL for a user, or generate and cache a new one
  Future<String> getCachedAvatar({
    String? userId,
    String? seed,
    bool forceRefresh = false,
  }) async {
    try {
      final identifier = userId ?? seed ?? 'default';

      // Check memory cache first
      if (!forceRefresh && _memoryCache.containsKey(identifier)) {
        return _memoryCache[identifier]!;
      }

      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(userId: userId, seed: seed);

      // Check persistent cache
      if (!forceRefresh) {
        final cachedUrl = prefs.getString(cacheKey);
        if (cachedUrl != null && cachedUrl.isNotEmpty) {
          _memoryCache[identifier] = cachedUrl;
          return cachedUrl;
        }
      } // Generate a new avatar URL from the API (ONE TIME ONLY)
      final newAvatarUrl = await _generateAvatarUrl();

      // Cache in both memory and persistent storage
      _memoryCache[identifier] = newAvatarUrl;
      await prefs.setString(cacheKey, newAvatarUrl);

      return newAvatarUrl;
    } catch (e) {
      // Fallback to a deterministic avatar if caching fails
      return _getFallbackAvatar(seed: seed ?? userId);
    }
  }

  /// Generate a cache key for storing avatar URLs
  String _generateCacheKey({String? userId, String? seed}) {
    final identifier = userId ?? seed ?? 'default';
    return '$_cacheKeyPrefix$identifier';
  }

  /// Generate a new avatar URL from the simple API endpoint
  Future<String> _generateAvatarUrl() async {
    try {
      // Make ONE API call to the simple endpoint (no parameters needed)
      final response = await http
          .get(
            Uri.parse(_avatarBaseUrl),
            headers: {'User-Agent': 'HarvestHub-App/1.0'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // The API should redirect to a specific avatar image
        // We can get the final URL from the response
        return response.request?.url.toString() ?? _avatarBaseUrl;
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      // If API call fails, return fallback
      return _getFallbackAvatar();
    }
  }

  /// Get a fallback avatar URL (deterministic based on seed)
  String _getFallbackAvatar({String? seed}) {
    final Random random = seed != null ? Random(seed.hashCode) : Random();
    final avatarNumber = (random.nextInt(50) + 1); // Use 1-50 for fallback
    return '$_avatarBaseUrl/$avatarNumber';
  }

  /// Clear a specific user's cached avatar
  Future<void> clearUserAvatar({String? userId, String? seed}) async {
    try {
      final identifier = userId ?? seed ?? 'default';
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(userId: userId, seed: seed);

      // Remove from both memory and persistent cache
      _memoryCache.remove(identifier);
      await prefs.remove(cacheKey);
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Clear all cached avatars
  Future<void> clearAllCachedAvatars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // Clear memory cache
      _memoryCache.clear();

      // Remove all keys that start with our cache prefix
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Get avatar with fallback options for backward compatibility
  Future<String> getAvatarWithFallback({
    String? userAvatar,
    String? userId,
    bool forceRefresh = false,
  }) async {
    // If user has a custom avatar, use it
    if (userAvatar != null &&
        userAvatar.isNotEmpty &&
        !userAvatar.startsWith('data:')) {
      return userAvatar;
    }

    // Get cached avatar based on user ID - this makes only ONE API call per user
    return await getCachedAvatar(userId: userId, forceRefresh: forceRefresh);
  }

  /// Preload avatar for better performance - makes ONE API call and caches forever
  Future<void> preloadAvatar({String? userId, String? seed}) async {
    try {
      await getCachedAvatar(userId: userId, seed: seed);
    } catch (e) {
      // Ignore preload errors
    }
  }

  /// Get multiple avatars at once (useful for community posts)
  /// Each user gets ONE API call total, then cached forever
  Future<Map<String, String>> getCachedAvatars(List<String> userIds) async {
    final Map<String, String> avatars = {};

    for (final userId in userIds) {
      try {
        avatars[userId] = await getCachedAvatar(userId: userId);
      } catch (e) {
        avatars[userId] = _getFallbackAvatar(seed: userId);
      }
    }

    return avatars;
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cachedAvatarKeys =
          keys.where((k) => k.startsWith(_cacheKeyPrefix)).toList();

      return {
        'totalCachedAvatars': cachedAvatarKeys.length,
        'memoryCache': _memoryCache.length,
        'cachedUserIds':
            cachedAvatarKeys
                .map((k) => k.replaceFirst(_cacheKeyPrefix, ''))
                .toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
