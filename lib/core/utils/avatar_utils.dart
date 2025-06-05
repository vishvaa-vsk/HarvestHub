import 'dart:math';

class AvatarUtils {
  static final Random _random = Random();

  /// Generate a random avatar URL using DiceBear API (more reliable than avatar.iran.liara.run)
  static String generateRandomAvatar({
    String? seed,
    String style = 'personas',
  }) {
    final avatarSeed = seed ?? _random.nextInt(10000).toString();
    return 'https://api.dicebear.com/7.x/$style/png?seed=$avatarSeed&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf';
  }

  /// Get avatar with fallback options
  static String getAvatarWithFallback({String? userAvatar, String? userId}) {
    // If user has a custom avatar, use it
    if (userAvatar != null && userAvatar.isNotEmpty) {
      return userAvatar;
    }

    // Generate consistent avatar based on user ID
    if (userId != null && userId.isNotEmpty) {
      return generateRandomAvatar(seed: userId);
    }

    // Fallback to completely random avatar
    return generateRandomAvatar();
  }

  /// Alternative avatar services (in case DiceBear is down)
  static List<String> getAlternativeAvatars(String seed) {
    return [
      'https://api.dicebear.com/7.x/personas/png?seed=$seed',
      'https://api.dicebear.com/7.x/avataaars/png?seed=$seed',
      'https://api.dicebear.com/7.x/fun-emoji/png?seed=$seed',
      'https://robohash.org/$seed?set=set4&size=150x150',
      'https://ui-avatars.com/api/?name=${seed.replaceAll(' ', '+')}&background=4CAF50&color=fff&size=150',
    ];
  }
}
