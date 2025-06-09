import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/comment_page.dart';
import '../core/constants/app_constants.dart';
import '../widgets/skeleton_widgets.dart';
import '../utils/performance_utils.dart';

/// Optimized PostCard with caching and performance improvements
class OptimizedPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final Map<String, dynamic>? cachedUserData;

  const OptimizedPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.cachedUserData,
  });

  @override
  State<OptimizedPostCard> createState() => _OptimizedPostCardState();
}

class _OptimizedPostCardState extends State<OptimizedPostCard> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Use cached data if available
    if (widget.cachedUserData != null) {
      if (_mounted) {
        setState(() {
          _userData = widget.cachedUserData;
          _isLoading = false;
        });
      }
      return;
    }

    // Check if user data is in cache
    final cachedData = _firebaseService.getUserFromCache(widget.post.authorId);
    if (cachedData != null) {
      if (_mounted) {
        setState(() {
          _userData = cachedData;
          _isLoading = false;
        });
      }
      return;
    }

    // Load from Firebase
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
    return PerformanceUtils.monitorPerformance(
      name: 'PostCard-${widget.post.id}',
      child:
          _isLoading ? SkeletonWidgets.postCardSkeleton() : _buildPostContent(),
    );
  }

  Widget _buildPostContent() {
    final user = _userData ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
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
                    // Header Row with Name and Time - optimized
                    _buildHeader(user),
                    const SizedBox(height: 8),
                    // Post Content - const text style
                    Text(
                      widget.post.content,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    // Post Image (if exists) - optimized caching
                    if (widget.post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildPostImage(),
                    ],
                    const SizedBox(height: 16),
                    // Action Buttons Row - optimized with keys
                    _buildActionButtons(),
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
    return CircleAvatar(
      radius: 22,
      backgroundImage:
          user['profilePic'] != null
              ? CachedNetworkImageProvider(
                user['profilePic'],
                cacheKey: 'avatar_${widget.post.authorId}',
              )
              : null,
      child:
          user['profilePic'] == null
              ? const Icon(Icons.person, size: 22)
              : null,
    );
  }

  Widget _buildHeader(Map<String, dynamic> user) {
    return Row(
      children: [
        Text(
          user['name'] ?? 'User',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(width: 4),
        Text(
          '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
        const SizedBox(width: 4),
        Text('·', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        const SizedBox(width: 4),
        Text(
          _timeAgo(widget.post.timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: widget.post.imageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheKey: 'post_${widget.post.id}',
        memCacheWidth: 600, // Limit memory usage
        memCacheHeight: 400,
        placeholder:
            (context, url) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Like Button - optimized stream handling
        _OptimizedLikeButton(
          key: ValueKey('like_${widget.post.id}'),
          post: widget.post,
        ),
        // Comment Button
        _buildActionButton(
          key: ValueKey('comment_${widget.post.id}'),
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          count: 0, // TODO: Add comment count to Post model
          color: Colors.grey[600]!,
          activeColor: AppConstants.primaryGreen,
          onTap: _showCommentsBottomSheet,
        ),
        // Repost Button
        _buildActionButton(
          key: ValueKey('repost_${widget.post.id}'),
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: 0,
          color: Colors.grey[600]!,
          activeColor: Colors.green,
          onTap: _handleRepost,
        ),
        // Share Button
        _buildActionButton(
          key: ValueKey('share_${widget.post.id}'),
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          color: Colors.grey[600]!,
          activeColor: AppConstants.primaryGreen,
          onTap: _handleShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    Key? key,
    required IconData icon,
    required IconData activeIcon,
    required int count,
    required Color color,
    required Color activeColor,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      key: key,
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
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
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
                ),
                SizedBox(
                  height: 0.5,
                  child: Container(color: Colors.grey[200]),
                ),
                // Comments section - optimized
                Expanded(
                  child: ModernCommentPage(
                    key: ValueKey('comments_${widget.post.id}'),
                    postId: widget.post.id,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _handleRepost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repost feature coming soon!')),
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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

/// Optimized like button with better stream handling
class _OptimizedLikeButton extends StatefulWidget {
  final Post post;

  const _OptimizedLikeButton({super.key, required this.post});

  @override
  State<_OptimizedLikeButton> createState() => _OptimizedLikeButtonState();
}

class _OptimizedLikeButtonState extends State<_OptimizedLikeButton> {
  final FirebaseService _firebaseService = FirebaseService();
  final Throttler _likeThrottler = Throttler(milliseconds: 1000);
  bool _isProcessing = false;

  @override
  void dispose() {
    _likeThrottler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _firebaseService.userLikedPostStream(
        postId: widget.post.id,
        userId: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      ),
      builder: (context, likeSnapshot) {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.phoneNumber ?? '';
        final isLiked = likeSnapshot.data ?? false;

        return InkWell(
          onTap:
              userId.isEmpty || _isProcessing
                  ? null
                  : () => _handleLike(userId, isLiked),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
                if (widget.post.likeCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(widget.post.likeCount),
                    style: TextStyle(
                      fontSize: 13,
                      color: isLiked ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLike(String userId, bool isLiked) {
    _likeThrottler.run(() async {
      if (_isProcessing) return;

      setState(() {
        _isProcessing = true;
      });

      try {
        if (isLiked) {
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
      } catch (e) {
        // Handle error silently to avoid UI disruption
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    });
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
