import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/comment_page.dart';
import '../core/constants/app_constants.dart';
import '../widgets/skeleton_widgets.dart';

/// Ultra-optimized PostCard designed for 60fps performance
class PerformanceOptimizedPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final Map<String, dynamic>? cachedUserData;

  const PerformanceOptimizedPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.cachedUserData,
  });

  @override
  State<PerformanceOptimizedPostCard> createState() =>
      _PerformanceOptimizedPostCardState();
}

class _PerformanceOptimizedPostCardState
    extends State<PerformanceOptimizedPostCard>
    with AutomaticKeepAliveClientMixin {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _mounted = true;

  // Cache the formatted time to avoid recalculation
  late final String _formattedTime;

  @override
  bool get wantKeepAlive => true; // Keep alive to prevent rebuilds

  @override
  void initState() {
    super.initState();
    _formattedTime = _formatTime(widget.post.timestamp);

    if (widget.cachedUserData != null) {
      _userData = widget.cachedUserData;
      _isLoading = false;
    } else {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseService.getUserByPhone(
        widget.post.authorId,
      );
      if (_mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_mounted) {
        setState(() {
          _userData = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return SkeletonWidgets.postCardSkeleton();
    }

    return _buildPostContent();
  }

  Widget _buildPostContent() {
    final user = _userData ?? {};

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar - optimized with const constructor
              _buildProfileAvatar(user),
              const SizedBox(width: 12),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row - cached values
                    _buildHeader(user),
                    const SizedBox(height: 8),
                    // Post Content
                    _buildContent(),
                    const SizedBox(height: 12),
                    // Action Buttons - simplified
                    _buildActionRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Map<String, dynamic> user) {
    const double avatarSize = 44;

    return RepaintBoundary(
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(avatarSize / 2),
          child: CachedNetworkImage(
            imageUrl:
                user['photoURL'] ?? 'https://avatar.iran.liara.run/public/1',
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF9E9E9E),
                    size: 24,
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF9E9E9E),
                    size: 24,
                  ),
                ),
            memCacheWidth: 88, // 2x for high DPI
            memCacheHeight: 88,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['name'] ?? 'Anonymous User',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '@${(user['name'] ?? 'user').toLowerCase().replaceAll(' ', '')}',
                style: const TextStyle(color: Color(0xFF757575), fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          _formattedTime,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like Button - simplified
        _buildActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: widget.post.likeCount,
          color: const Color(0xFF757575),
          activeColor: Colors.red,
          onTap: _handleLike,
        ),
        // Comment Button
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          count: 0, // TODO: Add comment count
          color: const Color(0xFF757575),
          activeColor: AppConstants.primaryGreen,
          onTap: _showCommentsBottomSheet,
        ),
        // Share Button
        _buildActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          color: const Color(0xFF757575),
          activeColor: AppConstants.primaryGreen,
          onTap: _handleShare,
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
          mainAxisSize: MainAxisSize.min,
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

  void _handleLike() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.phoneNumber;
      if (userId != null) {
        // Check if user has already liked the post
        final hasLiked = await _firebaseService.hasUserLikedPost(
          postId: widget.post.id,
          userId: userId,
        );

        if (hasLiked) {
          await _firebaseService.unlikePost(
            postId: widget.post.id,
            userId: userId,
          );
        } else {
          await _firebaseService.likePost(
            postId: widget.post.id,
            userId: userId,
          );
        }
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  void _showCommentsBottomSheet() {
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
            child: ModernCommentPage(postId: widget.post.id),
          ),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 30).floor()}mo';
    }
  }
}
