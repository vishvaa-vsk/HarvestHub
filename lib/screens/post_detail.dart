import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import 'comment_page.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // You can expand this with more post details, likes, etc.
    return Scaffold(
      appBar: AppBar(title: Text('Post')), // Localize
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content, style: TextStyle(fontSize: 18)),
                if (post.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.network(
                      post.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  children: [
                    StreamBuilder<bool>(
                      stream: FirebaseService().userLikedPostStream(
                        postId: post.id,
                        userId:
                            (ModalRoute.of(context)?.settings.arguments
                                as String?) ??
                            (FirebaseAuth.instance.currentUser?.phoneNumber ??
                                ''),
                      ),
                      builder: (context, likeSnapshot) {
                        final user = FirebaseAuth.instance.currentUser;
                        final userId = user?.phoneNumber ?? '';
                        final isLiked = likeSnapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up_alt
                                : Icons.thumb_up_alt_outlined,
                            color: isLiked ? Colors.green : Colors.grey,
                          ),
                          onPressed:
                              userId.isEmpty
                                  ? null
                                  : () async {
                                    if (isLiked) {
                                      await FirebaseService().unlikePost(
                                        postId: post.id,
                                        userId: userId,
                                      );
                                    } else {
                                      await FirebaseService().likePost(
                                        postId: post.id,
                                        userId: userId,
                                      );
                                    }
                                  },
                          tooltip: isLiked ? 'Unlike' : 'Like',
                        );
                      },
                    ),
                    SizedBox(width: 4),
                    Text('${post.likeCount}'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: CommentPage(postId: post.id)),
        ],
      ),
    );
  }
}
