import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';
import '../models/comment.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // User data cache for performance
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Collection constants
  static const String _usersCollection = 'users';
  static const String _postsCollection = 'communityPosts';
  static const String _commentsCollection = 'comments';
  static const String _storageFolder = 'community_images';

  // Get community posts with error handling
  Stream<List<Post>> getCommunityPosts() {
    try {
      return _firestore
          .collection(_postsCollection)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Post.fromFirestore(doc.data(), doc.id))
                    .toList(),
          );
    } catch (e) {
      throw Exception('Failed to fetch community posts: $e');
    }
  }

  // Get user by UID with error handling
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      if (uid.trim().isEmpty) {
        throw ArgumentError('UID cannot be empty');
      }

      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to fetch user by UID: $e');
    }
  }

  // Get user by phone number with caching for performance
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      if (phoneNumber.trim().isEmpty) {
        throw ArgumentError('Phone number cannot be empty');
      }

      // Check cache first
      final cacheKey = phoneNumber.trim();
      if (_userCache.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < _cacheExpiration) {
          return _userCache[cacheKey];
        }
      }

      // Fetch from Firestore
      final doc =
          await _firestore.collection(_usersCollection).doc(phoneNumber).get();
      final userData = doc.exists ? doc.data() : null;

      // Cache the result
      if (userData != null) {
        _userCache[cacheKey] = userData;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return userData;
    } catch (e) {
      throw Exception('Failed to fetch user by phone: $e');
    }
  }

  // Get user from cache only (for synchronous access)
  Map<String, dynamic>? getUserFromCache(String phoneNumber) {
    final cacheKey = phoneNumber.trim();
    if (_userCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheExpiration) {
        return _userCache[cacheKey];
      }
    }
    return null;
  }

  // Clear user cache
  void clearUserCache() {
    _userCache.clear();
    _cacheTimestamps.clear();
  }

  // Preload user data for multiple users (batch loading)
  Future<void> preloadUsersData(List<String> phoneNumbers) async {
    final uncachedNumbers =
        phoneNumbers.where((number) {
          final cached = getUserFromCache(number);
          return cached == null;
        }).toList();

    if (uncachedNumbers.isEmpty) return;

    try {
      // Batch load users
      final futures = uncachedNumbers.map((number) => getUserByPhone(number));
      await Future.wait(futures);
    } catch (e) {
      // Handle batch loading errors gracefully
    }
  }

  // Create post with validation and error handling
  Future<String> createPost({
    required String authorId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      if (authorId.trim().isEmpty) {
        throw ArgumentError('Author ID cannot be empty');
      }
      if (content.trim().isEmpty) {
        throw ArgumentError('Content cannot be empty');
      }

      final docRef = await _firestore.collection(_postsCollection).add({
        'authorId': authorId,
        'content': content.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likeCount': 0,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Upload image with improved error handling and validation
  Future<String> uploadImage(String path, String userId) async {
    try {
      if (path.trim().isEmpty) {
        throw ArgumentError('Image path cannot be empty');
      }
      if (userId.trim().isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      final file = File(path);
      if (!await file.exists()) {
        throw ArgumentError('Image file does not exist at path: $path');
      }

      // Clean the userId to be filesystem-safe (remove + symbol and other special chars)
      final cleanUserId = userId.replaceAll(RegExp(r'[+\-\s()]'), '');
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final ref = _storage.ref().child(
        '$_storageFolder/$cleanUserId/$fileName',
      );
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get comments with typed return and error handling
  Stream<List<Comment>> getComments(String postId) {
    try {
      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }

      return _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection(_commentsCollection)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Comment.fromFirestore(doc.data(), doc.id))
                    .toList(),
          );
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  // Add comment with validation and error handling
  Future<String> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }
      if (authorId.trim().isEmpty) {
        throw ArgumentError('Author ID cannot be empty');
      }
      if (content.trim().isEmpty) {
        throw ArgumentError('Content cannot be empty');
      }

      final docRef = await _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection(_commentsCollection)
          .add({
            'authorId': authorId,
            'content': content.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Create or update user profile
  Future<void> createOrUpdateUser({
    required String userId,
    required String name,
    String? email,
    String? profilePic,
  }) async {
    try {
      if (userId.trim().isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }
      if (name.trim().isEmpty) {
        throw ArgumentError('Name cannot be empty');
      }

      await _firestore.collection(_usersCollection).doc(userId).set({
        'name': name.trim(),
        'email': email?.trim(),
        'profilePic': profilePic,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  // Delete post (admin functionality)
  Future<void> deletePost(String postId) async {
    try {
      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }

      await _firestore.collection(_postsCollection).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Update like count
  Future<void> updateLikeCount(String postId, int newCount) async {
    try {
      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }
      if (newCount < 0) {
        throw ArgumentError('Like count cannot be negative');
      }

      await _firestore.collection(_postsCollection).doc(postId).update({
        'likeCount': newCount,
      });
    } catch (e) {
      throw Exception('Failed to update like count: $e');
    }
  }

  // Check if user has liked a post
  Future<bool> hasUserLikedPost({
    required String postId,
    required String userId,
  }) async {
    final doc =
        await _firestore
            .collection(_postsCollection)
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();
    return doc.exists;
  }

  // Like a post
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    final batch = _firestore.batch();
    batch.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
    batch.update(postRef, {'likeCount': FieldValue.increment(1)});
    await batch.commit();
  }

  // Unlike a post
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    final batch = _firestore.batch();
    batch.delete(likeRef);
    batch.update(postRef, {'likeCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  // Stream whether user has liked a post (for real-time UI)
  Stream<bool> userLikedPostStream({
    required String postId,
    required String userId,
  }) {
    return _firestore
        .collection(_postsCollection)
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
