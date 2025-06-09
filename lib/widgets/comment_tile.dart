import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Legacy comment tile for backward compatibility
class CommentTile extends StatelessWidget {
  final String commentId;
  final Map<String, dynamic> data;
  final FirebaseService _firebaseService = FirebaseService();

  CommentTile({super.key, required this.commentId, required this.data});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(data['authorId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
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
            child: user['profilePic'] == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user['name'] ?? 'User'),
          subtitle: Text(data['content']),
          trailing: Text(
            _timeAgo(_getDateTime(data['timestamp'])),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  DateTime _getDateTime(dynamic timestamp) {
    if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else {
      throw ArgumentError('Invalid timestamp type: ${timestamp.runtimeType}');
    }
  }
}

// Modern Twitter-style comment tile (now the main one)
class ModernCommentTile extends StatelessWidget {
  final String commentId;
  final Map<String, dynamic> data;
  final FirebaseService _firebaseService = FirebaseService();

  ModernCommentTile({super.key, required this.commentId, required this.data});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firebaseService.getUserByPhone(data['authorId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE7E7E8), width: 0.5),
            ),
          ),
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
                        ? const Icon(Icons.person, size: 16)
                        : null,
              ),
              const SizedBox(width: 12),

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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '@${user['name']?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '·',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeAgo(_getDateTime(data['timestamp'])),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Comment text
                    Text(
                      data['content'],
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 8),

                    // Comment actions (like, reply)
                    Row(
                      children: [
                        _buildCommentAction(
                          context: context,
                          icon: Icons.favorite_border,
                          count: 0, // TODO: Add like functionality for comments
                          onTap: () {
                            // TODO: Implement comment likes
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment likes coming soon!'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 24),
                        _buildCommentAction(
                          context: context,
                          icon: Icons.mode_comment_outlined,
                          count: 0, // TODO: Add reply functionality
                          onTap: () {
                            // TODO: Implement comment replies
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment replies coming soon!'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 24),
                        _buildCommentAction(
                          context: context,
                          icon: Icons.share_outlined,
                          count: 0,
                          onTap: () {
                            // TODO: Implement comment sharing
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment sharing coming soon!'),
                              ),
                            );
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
    required BuildContext context,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            if (count > 0) ...[
              const SizedBox(width: 4),
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

  DateTime _getDateTime(dynamic timestamp) {
    if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else {
      throw ArgumentError('Invalid timestamp type: ${timestamp.runtimeType}');
    }
  }
}
