import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentTile extends StatelessWidget {
  final String commentId;
  final Map<String, dynamic> data;
  final FirebaseService _firebaseService = FirebaseService();

  CommentTile({required this.commentId, required this.data});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(data['authorId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final user = snapshot.data ?? {};
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user['profilePic'] != null
                    ? CachedNetworkImageProvider(user['profilePic'])
                    : null,
            child: user['profilePic'] == null ? Icon(Icons.person) : null,
          ),
          title: Text(user['name'] ?? 'User'),
          subtitle: Text(data['content']),
          trailing: Text(
            _timeAgo((data['timestamp'] as Timestamp).toDate()),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// Modern Twitter-style comment tile
class ModernCommentTile extends StatelessWidget {
  final String commentId;
  final Map<String, dynamic> data;
  final FirebaseService _firebaseService = FirebaseService();

  ModernCommentTile({required this.commentId, required this.data});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(data['authorId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 200,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final user = snapshot.data ?? {};
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    user['profilePic'] != null
                        ? CachedNetworkImageProvider(user['profilePic'])
                        : null,
                child:
                    user['profilePic'] == null
                        ? Icon(Icons.person, size: 16)
                        : null,
              ),
              SizedBox(width: 12),

              // Comment Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name and time
                    Row(
                      children: [
                        Text(
                          user['name'] ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '·',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _timeAgo((data['timestamp'] as Timestamp).toDate()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),

                    // Comment text
                    Text(
                      data['content'],
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                    SizedBox(height: 8),

                    // Comment actions (like, reply)
                    Row(
                      children: [
                        _buildCommentAction(
                          icon: Icons.favorite_border,
                          count: 0, // TODO: Add like functionality for comments
                          onTap: () {
                            // TODO: Implement comment likes
                          },
                        ),
                        SizedBox(width: 24),
                        _buildCommentAction(
                          icon: Icons.mode_comment_outlined,
                          count: 0, // TODO: Add reply functionality
                          onTap: () {
                            // TODO: Implement comment replies
                          },
                        ),
                        SizedBox(width: 24),
                        _buildCommentAction(
                          icon: Icons.share_outlined,
                          count: 0,
                          onTap: () {
                            // TODO: Implement comment sharing
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentAction({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            if (count > 0) ...[
              SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
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
