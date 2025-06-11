import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import '../widgets/post_card.dart';
import 'create_post.dart';
import 'post_detail.dart';
import '../utils/performance_utils.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  // Performance optimization: throttle scroll events
  late final Throttler _scrollThrottler;

  // Cache for better performance
  Stream<List<Post>>? _postsStream;

  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs

  @override
  void initState() {
    super.initState();
    _scrollThrottler = Throttler(milliseconds: 100);
    _scrollController.addListener(_scrollListener);

    // Initialize stream only once
    _postsStream = _firebaseService.getCommunityPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scrollThrottler.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Throttle scroll events to prevent excessive setState calls
    _scrollThrottler.run(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFab) setState(() => _showFab = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFab) setState(() => _showFab = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Post>>(
        stream: _postsStream,
        builder: (context, snapshot) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with centered title
              SliverAppBar(
                expandedHeight: 60,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  AppLocalizations.of(context)!.community,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 0.5, color: Colors.grey[200]),
                ),
              ),
              // Welcome section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Welcome text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.welcomeToHarvestHub,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.shareYourThoughts,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              SliverToBoxAdapter(
                child: Container(height: 8, color: Colors.grey[100]),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.somethingWentWrong,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.checkConnectionAndTryAgain,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Trigger rebuild to retry
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(AppLocalizations.of(context)!.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if ((snapshot.data ?? []).isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.welcomeToCommunity,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.shareYourFarmingExperiences,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.noPostsYet,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreatePostPage(),
                                  ),
                                ),
                            icon: const Icon(Icons.add),
                            label: Text(
                              AppLocalizations.of(context)!.createFirstPost,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final posts = snapshot.data!;
                      if (index >= posts.length) return null;

                      // Use RepaintBoundary to isolate post rebuilds
                      return RepaintBoundary(
                        key: ValueKey('post_${posts[index].id}'),
                        child: PerformanceUtils.monitorPerformance(
                          name: 'PostCard_$index',
                          child: PostCard(
                            post: posts[index],
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            PostDetailPage(post: posts[index]),
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                    childCount: snapshot.data?.length ?? 0,
                    addAutomaticKeepAlives: false, // Reduce memory usage
                    addRepaintBoundaries: false, // We're handling this manually
                    addSemanticIndexes: false, // Disable for performance
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage()),
                ),
            tooltip: AppLocalizations.of(context)!.createPost,
            child: const Icon(Icons.add, size: 24),
          ),
        ),
      ),
    );
  }
}
