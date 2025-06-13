import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../widgets/comment_tile.dart';
import '../models/comment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_constants.dart';
import '../utils/performance_utils.dart';

// Modern Twitter-style comment page (now the main one)
class ModernCommentPage extends StatefulWidget {
  final String postId;
  final Function(bool)?
  onFocusChanged; // Callback to notify parent about focus changes
  const ModernCommentPage({
    super.key,
    required this.postId,
    this.onFocusChanged,
  });

  @override
  State<ModernCommentPage> createState() => _ModernCommentPageState();
}

class _ModernCommentPageState extends State<ModernCommentPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposingComment = false;
  bool _hasText = false; // Track if text field has content
  Map<String, dynamic>? _userData; // Cache user data

  // Performance optimization: debounce text changes
  late final Debouncer _textDebouncer;

  @override
  void initState() {
    super.initState();
    _textDebouncer = Debouncer(milliseconds: 150);
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChangedDebounced);
    _loadUserData();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChangedDebounced);
    _textDebouncer.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final userData = await FirebaseService().getUserByPhone(
      FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
    );
    if (mounted) {
      setState(() {
        _userData = userData;
      });
    }
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (_isComposingComment != hasFocus) {
      setState(() {
        _isComposingComment = hasFocus;
      });
      // Notify parent about focus change
      widget.onFocusChanged?.call(hasFocus);
    }
  }

  void _onTextChangedDebounced() {
    // Debounce text changes to prevent excessive setState calls
    _textDebouncer.run(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (_hasText != hasText && mounted) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comment composition area
        _buildCommentComposer(),

        Divider(
          height: 1,
          color: Colors.grey[200],
        ), // Comments list - isolated to prevent rebuilds
        Expanded(child: CommentsListWidget(postId: widget.postId)),
      ],
    );
  }

  Widget _buildCommentComposer() {
    return SizedBox(
      height: _isComposingComment ? 52 : 56, // Slightly smaller when focused
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _isComposingComment ? 8 : 12, // Less padding when focused
          vertical: _isComposingComment ? 4 : 6,
        ),
        child: Row(
          children: [
            // Compact user avatar - use cached data
            CircleAvatar(
              radius: _isComposingComment ? 14 : 16, // Smaller when focused
              backgroundImage:
                  _userData?['profilePic'] != null
                      ? CachedNetworkImageProvider(_userData!['profilePic'])
                      : null,
              child:
                  _userData?['profilePic'] == null
                      ? Icon(Icons.person, size: _isComposingComment ? 14 : 16)
                      : null,
            ),
            const SizedBox(width: 8),

            // Text input field - larger and more readable
            Expanded(
              child: Container(
                height: _isComposingComment ? 40 : 44, // Smaller when focused
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        _isComposingComment
                            ? AppConstants.primaryGreen
                            : Colors.grey[300]!,
                    width: _isComposingComment ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color:
                      _isComposingComment
                          ? AppConstants.lightGreenBg
                          : Colors.grey[50],
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 16, // Larger font for readability
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Post your reply',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  // Removed onChanged to prevent unnecessary rebuilds
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ), // Send button - always visible, enabled when text exists
            SizedBox(
              height: _isComposingComment ? 40 : 44,
              width: _isComposingComment ? 40 : 44,
              child: ElevatedButton(
                onPressed: !_hasText ? null : _postComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      !_hasText
                          ? Colors.grey[300]
                          : (_isComposingComment
                              ? AppConstants.darkGreen
                              : AppConstants.primaryGreen),
                  foregroundColor: !_hasText ? Colors.grey[600] : Colors.white,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  elevation: _isComposingComment ? 2 : 0,
                ),
                child: const Icon(Icons.send, size: 18),
              ),
            ),
          ],
        ),
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

// Separate widget for comments list to prevent unnecessary rebuilds
class CommentsListWidget extends StatelessWidget {
  final String postId;

  const CommentsListWidget({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: FirebaseService().getComments(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryGreen,
                ),
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
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          key: const ValueKey(
            'comments_list',
          ), // Add key for better performance
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 0),
          itemBuilder:
              (context, i) => ModernCommentTile(
                key: ValueKey(comments[i].id), // Add key for each comment
                commentId: comments[i].id,
                data: {
                  'authorId': comments[i].authorId,
                  'content': comments[i].content,
                  'timestamp': comments[i].timestamp,
                  'postId': postId, // Add postId for delete functionality
                },
              ),
        );
      },
    );
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
                        'postId':
                            widget
                                .postId, // Add postId for delete functionality
                      },
                    ),
              );
            },
          ),
        ), // Compact comment composer
        SizedBox(
          height: 60, // Fixed height for predictable layout
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.grey[50],
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 16, height: 1.2),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  width: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
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
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
