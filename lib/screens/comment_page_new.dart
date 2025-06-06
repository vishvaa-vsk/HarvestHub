import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../widgets/comment_tile.dart';
import '../models/comment.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Modern Twitter-style comment page (now the main one)
class ModernCommentPage extends StatefulWidget {
  final String postId;
  const ModernCommentPage({super.key, required this.postId});

  @override
  State<ModernCommentPage> createState() => _ModernCommentPageState();
}

class _ModernCommentPageState extends State<ModernCommentPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposingComment = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isComposingComment = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comment composition area
        _buildCommentComposer(),

        Divider(height: 1, color: Colors.grey[200]),

        // Comments list
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: FirebaseService().getComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share your thoughts!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: comments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder:
                    (context, i) => ModernCommentTile(
                      commentId: comments[i].id,
                      data: {
                        'authorId': comments[i].authorId,
                        'content': comments[i].content,
                        'timestamp': comments[i].timestamp,
                      },
                    ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: FirebaseService().getUserByPhone(
          FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        ),
        builder: (context, snapshot) {
          final user = snapshot.data ?? {};

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    user['profilePic'] != null
                        ? CachedNetworkImageProvider(user['profilePic'])
                        : null,
                child:
                    user['profilePic'] == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
              ),
              const SizedBox(width: 12),

              // Comment input area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: _isComposingComment ? 4 : 1,
                      decoration: InputDecoration(
                        hintText: 'Post your reply',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        setState(() {}); // Refresh to update button state
                      },
                    ),

                    if (_isComposingComment) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  // TODO: Add image attachment
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Image attachment coming soon!',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.image_outlined),
                                iconSize: 20,
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Add emoji picker
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Emoji picker coming soon!',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.emoji_emotions_outlined),
                                iconSize: 20,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed:
                                _controller.text.trim().isEmpty
                                    ? null
                                    : _postComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Reply',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Quick reply button (when not composing)
              if (!_isComposingComment && _controller.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: _postComment,
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 20,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to comment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading state
    final originalText = _controller.text;
    _controller.clear();
    _focusNode.unfocus();

    try {
      await FirebaseService().addComment(
        postId: widget.postId,
        authorId: user.phoneNumber!,
        content: text,
      );

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment posted successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Restore original text on error
      _controller.text = originalText;

      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment. Please try again.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Legacy comment page for backward compatibility
class CommentPage extends StatefulWidget {
  final String postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: FirebaseService().getComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading comments: ${snapshot.error}'),
                );
              }

              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return const Center(
                  child: Text('No comments yet. Be the first to comment!'),
                );
              }

              return ListView.builder(
                itemCount: comments.length,
                itemBuilder:
                    (context, i) => CommentTile(
                      commentId: comments[i].id,
                      data: {
                        'authorId': comments[i].authorId,
                        'content': comments[i].content,
                        'timestamp': comments[i].timestamp,
                      },
                    ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                  ), // Localize
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  final user = FirebaseAuth.instance.currentUser!;
                  await FirebaseService().addComment(
                    postId: widget.postId,
                    authorId: user.phoneNumber!,
                    content: text,
                  );
                  _controller.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
