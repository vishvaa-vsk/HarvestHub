import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/comment_page.dart';
import '../core/constants/app_constants.dart';

// Simple user data cache to prevent redundant Firebase calls
class _UserDataCache {
  static final Map<String, Map<String, dynamic>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static Future<Map<String, dynamic>?> getUserData(String authorId) async {
    // Check if we have cached data
    if (_cache.containsKey(authorId)) {
      final timestamp = _cacheTimestamps[authorId];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _cache[authorId];
      }
    }

    // Fetch new data
    try {
      final userData = await FirebaseService().getUserByPhone(authorId);
      if (userData != null) {
        _cache[authorId] = userData;
        _cacheTimestamps[authorId] = DateTime.now();
        return userData;
      }
    } catch (e) {
      // Return cached data if available, even if expired
      return _cache[authorId];
    }

    return null;
  }

  static Map<String, dynamic>? getCachedUserData(String authorId) {
    return _cache[authorId];
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final FirebaseService _firebaseService = FirebaseService();

  PostCard({super.key, required this.post, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _UserDataCache.getUserData(post.authorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Try to show cached data immediately while loading
          final cachedData = _UserDataCache.getCachedUserData(post.authorId);
          if (cachedData != null) {
            return _buildPostCard(context, cachedData);
          }
          // Show skeleton loading if no cached data
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? {};
        return _buildPostCard(context, user);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    user['profilePic'] != null
                        ? CachedNetworkImageProvider(user['profilePic'])
                        : null,
                child:
                    user['profilePic'] == null
                        ? const Icon(Icons.person, size: 22)
                        : null,
              ),
              const SizedBox(width: 12),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Name and Time
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                user['name'] ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '·',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _timeAgo(post.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu button for post owner
                        if (_isCurrentUserPost())
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(context);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete Post',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Post Content
                    Text(
                      post.content,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    // Post Image (if exists)
                    if (post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Action Buttons Row (Twitter style)
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Like Button (first)
        StreamBuilder<bool>(
          stream: _firebaseService.userLikedPostStream(
            postId: post.id,
            userId: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
          ),
          builder: (context, likeSnapshot) {
            final user = FirebaseAuth.instance.currentUser;
            final userId = user?.phoneNumber ?? '';
            final isLiked = likeSnapshot.data ?? false;

            return _buildActionButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              activeIcon: Icons.favorite,
              count: post.likeCount,
              color: Colors.grey[600]!,
              activeColor: Colors.red,
              isActive: isLiked,
              onTap:
                  userId.isEmpty
                      ? null
                      : () async {
                        if (isLiked) {
                          await _firebaseService.unlikePost(
                            postId: post.id,
                            userId: userId,
                          );
                        } else {
                          await _firebaseService.likePost(
                            postId: post.id,
                            userId: userId,
                          );
                        }
                      },
            );
          },
        ), // Comment Button (second)
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          count: 0, // TODO: Add comment count to Post model
          color: Colors.grey[600]!,
          activeColor: AppConstants.primaryGreen,
          onTap: () => _showCommentsBottomSheet(context),
        ),

        // Repost Button (third)
        _buildActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: 0, // TODO: Add repost functionality
          color: Colors.grey[600]!,
          activeColor: Colors.green,
          onTap: () {
            // TODO: Implement repost functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Repost feature coming soon!')),
            );
          },
        ), // Share Button (fourth)
        _buildActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          color: Colors.grey[600]!,
          activeColor: AppConstants.primaryGreen,
          onTap: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required int count,
    required Color color,
    required Color activeColor,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? activeColor : color,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? activeColor : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                // Minimal header with handle and close button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Handle bar
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ), // Thin divider
                SizedBox(
                  height: 0.5,
                  child: Container(color: Colors.grey[200]),
                ),
                // Clean comments section - no post content, just comments
                Expanded(child: ModernCommentPage(postId: post.id)),
              ],
            ),
          ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  // Check if current user owns this post
  bool _isCurrentUserPost() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.phoneNumber == post.authorId;
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Post'),
            content: Text(
              'Are you sure you want to delete this post? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true && context.mounted) {
      await _deletePost(context);
    }
  } // Delete the post

  Future<void> _deletePost(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.phoneNumber;
    if (userId == null) return;

    // Store the navigator and scaffold messenger
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool isDialogShowing = false;

    try {
      print('Starting post deletion...');

      // Show loading indicator
      if (context.mounted) {
        isDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (dialogContext) =>
                  const Center(child: CircularProgressIndicator()),
        );
      }

      print('PostId: ${post.id}, UserId: $userId');

      await _firebaseService.deletePost(postId: post.id, userId: userId);

      print('Post deleted successfully');

      // Close loading dialog
      if (isDialogShowing) {
        navigator.pop();
        isDialogShowing = false;
      }

      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting post: $e');

      // Close loading dialog
      if (isDialogShowing) {
        navigator.pop();
        isDialogShowing = false;
      }

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete post: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
