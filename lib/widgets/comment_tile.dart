import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                        Expanded(
                          child: Row(
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
                        ),
                        // Delete button for comment owner
                        if (_isCurrentUserComment())
                          InkWell(
                            onTap:
                                () => _showDeleteCommentConfirmation(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.grey[600],
                                size: 16,
                              ),
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

  // Check if current user owns this comment
  bool _isCurrentUserComment() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.phoneNumber == data['authorId'];
  }

  // Show delete confirmation dialog for comment
  Future<void> _showDeleteCommentConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Comment'),
            content: Text('Are you sure you want to delete this comment?'),
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
      await _deleteComment(context);
    }
  } // Delete the comment

  Future<void> _deleteComment(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.phoneNumber;
    if (userId == null) return;

    // Store the navigator and scaffold messenger
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool isDialogShowing = false;

    try {
      print('Starting comment deletion...');

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

      // Extract postId from context
      final postId = data['postId'];

      print('PostId: $postId, CommentId: $commentId, UserId: $userId');

      if (postId == null) {
        throw Exception('Post ID not found');
      }

      await _firebaseService.deleteComment(
        postId: postId,
        commentId: commentId,
        userId: userId,
      );

      print('Comment deleted successfully');

      // Close loading dialog
      if (isDialogShowing) {
        navigator.pop();
        isDialogShowing = false;
      }

      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Comment deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting comment: $e');

      // Close loading dialog
      if (isDialogShowing) {
        navigator.pop();
        isDialogShowing = false;
      }

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete comment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
