import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/comment_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final FirebaseService _firebaseService = FirebaseService();

  PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(post.authorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? {};
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
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        user['profilePic'] != null
                            ? CachedNetworkImageProvider(user['profilePic'])
                            : null,
                    child:
                        user['profilePic'] == null
                            ? Icon(Icons.person, size: 20)
                            : null,
                  ),
                  SizedBox(width: 12),
                  // Content Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row with Name and Time
                        Row(
                          children: [
                            Text(
                              user['name'] ?? 'User',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '·',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              _timeAgo(post.timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Post Content
                        Text(
                          post.content,
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                        // Post Image (if exists)
                        if (post.imageUrl != null) ...[
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                        SizedBox(height: 12),
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
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Comment Button
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          count: 0, // TODO: Add comment count to Post model
          color: Colors.grey[600]!,
          activeColor: Colors.blue,
          onTap: () => _showCommentsBottomSheet(context),
        ),

        // Repost Button
        _buildActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: 0, // TODO: Add repost functionality
          color: Colors.grey[600]!,
          activeColor: Colors.green,
          onTap: () {
            // TODO: Implement repost functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Repost feature coming soon!')),
            );
          },
        ),

        // Like Button
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
        ),

        // Share Button
        _buildActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          color: Colors.grey[600]!,
          activeColor: Colors.blue,
          onTap: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Share feature coming soon!')),
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? activeColor : color,
            ),
            if (count > 0) ...[
              SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? activeColor : color,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    // Comments content
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
}
