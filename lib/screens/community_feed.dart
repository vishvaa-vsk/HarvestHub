import 'package:flutter/material.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import '../widgets/post_card.dart';
import 'create_post.dart';
import 'post_detail.dart';

class CommunityFeedPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  CommunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.community,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firebaseService.getCommunityPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger rebuild to retry
                        (context as Element).markNeedsBuild();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to the Community!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.noPostsYet,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CreatePostPage()),
                          ),
                      icon: Icon(Icons.edit),
                      label: Text('Create first post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger a rebuild to refresh the stream
              (context as Element).markNeedsBuild();
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder:
                  (context, i) => PostCard(
                    post: posts[i],
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(post: posts[i]),
                          ),
                        ),
                  ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreatePostPage()),
            ),
        tooltip: AppLocalizations.of(context)!.createPost,
        child: const Icon(Icons.edit, size: 24),
      ),
    );
  }
}
