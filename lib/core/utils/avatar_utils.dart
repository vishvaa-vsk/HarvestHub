import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/avatar_cache_service.dart';

class AvatarUtils {
  static final Random _random = Random();
  static final AvatarCacheService _cacheService = AvatarCacheService();

  /// Generate a cached avatar URL using iran.liara.run API with caching
  static Future<String> generateRandomAvatar({
    String? seed,
    bool forceRefresh = false,
  }) async {
    try {
      return await _cacheService.getCachedAvatar(
        seed: seed,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      // Fallback to sync method if async fails
      return generateRandomAvatarSync(seed: seed);
    }
  }

  /// Get avatar with fallback options and caching
  static Future<String> getAvatarWithFallback({
    String? userAvatar,
    String? userId,
    bool forceRefresh = false,
  }) async {
    try {
      return await _cacheService.getAvatarWithFallback(
        userAvatar: userAvatar,
        userId: userId,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      // Fallback to sync method if async fails
      return getAvatarWithFallbackSync(userAvatar: userAvatar, userId: userId);
    }
  }

  /// Synchronous version for backward compatibility (generates deterministic URL without caching)
  static String generateRandomAvatarSync({
    String? seed,
    String style = 'personas',
  }) {
    try {
      final avatarSeed = seed ?? _random.nextInt(10000).toString();
      return 'https://avatar.iran.liara.run/public/${avatarSeed.hashCode % 100 + 1}';
    } catch (e) {
      // Ultimate fallback
      return 'https://avatar.iran.liara.run/public/1';
    }
  }

  /// Synchronous fallback for backward compatibility
  static String getAvatarWithFallbackSync({
    String? userAvatar,
    String? userId,
  }) {
    try {
      // If user has a custom avatar, use it
      if (userAvatar != null && userAvatar.isNotEmpty) {
        return userAvatar;
      }

      // Generate consistent avatar based on user ID
      if (userId != null && userId.isNotEmpty) {
        return generateRandomAvatarSync(seed: userId);
      }

      // Fallback to completely random avatar
      return generateRandomAvatarSync();
    } catch (e) {
      // Ultimate fallback
      return 'https://avatar.iran.liara.run/public/1';
    }
  }

  /// Clear cached avatar for a user
  static Future<void> clearUserAvatar({String? userId, String? seed}) async {
    try {
      await _cacheService.clearUserAvatar(userId: userId, seed: seed);
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Clear all cached avatars
  static Future<void> clearAllCachedAvatars() async {
    try {
      await _cacheService.clearAllCachedAvatars();
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Preload avatar for better performance
  static Future<void> preloadAvatar({String? userId, String? seed}) async {
    try {
      await _cacheService.preloadAvatar(userId: userId, seed: seed);
    } catch (e) {
      // Ignore preload errors
    }
  }

  /// Get multiple avatars at once (useful for community posts)
  static Future<Map<String, String>> getCachedAvatars(
    List<String> userIds,
  ) async {
    try {
      return await _cacheService.getCachedAvatars(userIds);
    } catch (e) {
      // Return fallback avatars if caching fails
      final Map<String, String> fallbackAvatars = {};
      for (final userId in userIds) {
        fallbackAvatars[userId] = getAvatarWithFallbackSync(userId: userId);
      }
      return fallbackAvatars;
    }
  }

  /// Alternative avatar services (in case iran.liara.run is down)
  static List<String> getAlternativeAvatars(String seed) {
    return [
      'https://avatar.iran.liara.run/public/${seed.hashCode % 100 + 1}',
      'https://api.dicebear.com/7.x/personas/png?seed=$seed',
      'https://api.dicebear.com/7.x/avataaars/png?seed=$seed',
      'https://api.dicebear.com/7.x/fun-emoji/png?seed=$seed',
      'https://robohash.org/$seed?set=set4&size=150x150',
      'https://ui-avatars.com/api/?name=${seed.replaceAll(' ', '+')}&background=4CAF50&color=fff&size=150',
    ];
  }

  /// Check if a URL is a data URL (base64 encoded image)
  static bool isDataUrl(String url) {
    return url.startsWith('data:');
  }

  /// Convert data URL to Uint8List for Image.memory()
  static Uint8List? dataUrlToBytes(String dataUrl) {
    try {
      if (!dataUrl.startsWith('data:')) return null;

      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex == -1) return null;

      final base64Data = dataUrl.substring(commaIndex + 1);
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }

  /// Create an avatar widget that handles both regular URLs and data URLs
  static Widget buildAvatarWidget({
    required String avatarUrl,
    double? radius,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackChild,
  }) {
    radius ??= 20.0;
    
    try {
      if (isDataUrl(avatarUrl)) {
        // Handle data URL (base64 encoded image)
        final imageBytes = dataUrlToBytes(avatarUrl);
        if (imageBytes != null) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(imageBytes),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading errors
            },
          );
        }
      } else if (avatarUrl.isNotEmpty) {
        // Handle regular URL
        return CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading errors
          },
        );
      }
    } catch (e) {
      // Fall through to fallback
    }

    // Fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: fallbackChild ?? Icon(
        Icons.person,
        size: radius * 1.2,
        color: Colors.grey[600],
      ),
    );
  }

  /// Build an avatar widget with async loading
  static Widget buildAsyncAvatarWidget({
    required Future<String> avatarFuture,
    double? radius,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackChild,
    Widget? loadingWidget,
  }) {
    radius ??= 20.0;

    return FutureBuilder<String>(
      future: avatarFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[200],
            child: SizedBox(
              width: radius! * 0.8,
              height: radius * 0.8,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return buildAvatarWidget(
            avatarUrl: snapshot.data!,
            radius: radius,
            fit: fit,
            fallbackChild: fallbackChild,
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: fallbackChild ?? Icon(
              Icons.person,
              size: radius! * 1.2,
              color: Colors.grey[600],
            ),
          );
        }
      },
    );
  }

  /// Get cache statistics for debugging
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      return await _cacheService.getCacheStats();
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
