import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'comment_page.dart';
import '../core/constants/app_constants.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isCommentingMode = false; // Track if user is commenting

  void _onCommentFocusChanged(bool isComposing) {
    setState(() {
      _isCommentingMode = isComposing;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom App Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Add share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                  ),
                ],
              ),
            ),
          ), // Post Content
          Expanded(
            child: Column(
              children: [
                // Show post content only when not commenting
                if (!_isCommentingMode) ...[
                  // Main post display - Use limited flexible space
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.6, // Max 60% of screen
                    ),
                    child: SingleChildScrollView(child: _buildMainPost()),
                  ),

                  // Divider
                  Container(height: 8, color: Colors.grey[100]),
                ],

                // Comments section - Takes full space when commenting
                Expanded(
                  child: ModernCommentPage(
                    postId: widget.post.id,
                    onFocusChanged: _onCommentFocusChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPost() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(widget.post.authorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User info row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          user['profilePic'] != null
                              ? CachedNetworkImageProvider(user['profilePic'])
                              : null,
                      child:
                          user['profilePic'] == null
                              ? const Icon(Icons.person, size: 24)
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                      onSelected: (value) {
                        // TODO: Handle menu actions
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$value coming soon!')),
                        );
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'Report',
                              child: Row(
                                children: [
                                  Icon(Icons.flag_outlined, size: 20),
                                  SizedBox(width: 12),
                                  Text('Report post'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'Block',
                              child: Row(
                                children: [
                                  Icon(Icons.block_outlined, size: 20),
                                  SizedBox(width: 12),
                                  Text('Block user'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Post content
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // Post image if exists
                if (widget.post.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: widget.post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Post timestamp
                Text(
                  _formatDetailedTime(widget.post.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),

                const SizedBox(height: 16),

                // Engagement stats
                _buildEngagementStats(),

                const SizedBox(height: 16), // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEngagementStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(widget.post.likeCount, 'Likes'),
          const SizedBox(width: 24),
          _buildStatItem(0, 'Reposts'), // TODO: Add repost count
          const SizedBox(width: 24),
          _buildStatItem(0, 'Comments'), // TODO: Add comment count
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label) {
    return GestureDetector(
      onTap: () {
        // TODO: Show users who engaged
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _formatCount(count),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Like button (first)
          StreamBuilder<bool>(
            stream: _firebaseService.userLikedPostStream(
              postId: widget.post.id,
              userId: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
            ),
            builder: (context, likeSnapshot) {
              final user = FirebaseAuth.instance.currentUser;
              final userId = user?.phoneNumber ?? '';
              final isLiked = likeSnapshot.data ?? false;

              return _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                activeIcon: Icons.favorite,
                color: Colors.grey[600]!,
                activeColor: Colors.red,
                isActive: isLiked,
                onTap:
                    userId.isEmpty
                        ? null
                        : () async {
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
                        },
              );
            },
          ), // Comment button (second)
          _buildActionButton(
            icon: Icons.mode_comment_outlined,
            activeIcon: Icons.mode_comment,
            color: Colors.grey[600]!,
            activeColor: AppConstants.primaryGreen,
            onTap: () {
              // Auto focus on comment input (handled by ModernCommentPage)
            },
          ),

          // Repost button (third)
          _buildActionButton(
            icon: Icons.repeat,
            activeIcon: Icons.repeat,
            color: Colors.grey[600]!,
            activeColor: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Repost feature coming soon!')),
              );
            },
          ), // Share button (fourth)
          _buildActionButton(
            icon: Icons.share_outlined,
            activeIcon: Icons.share,
            color: Colors.grey[600]!,
            activeColor: AppConstants.primaryGreen,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required Color color,
    required Color activeColor,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 20,
          color: isActive ? activeColor : color,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _formatDetailedTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      // Show actual date for older posts
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
