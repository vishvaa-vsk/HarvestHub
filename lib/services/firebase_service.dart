import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
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

  // Private method to compress images for community posts
  // This performs light compression transparently - users are not notified
  // Only compresses files > 1MB to maintain quality while reducing storage costs
  Future<String> _compressImage(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      final fileSize = await originalFile.length();

      // Only compress if file is larger than 1MB to avoid unnecessary processing
      if (fileSize <= 1024 * 1024) {
        return originalPath;
      }

      // Create a temporary file path for the compressed image
      final directory = originalFile.parent;
      final originalName = path.basenameWithoutExtension(originalPath);
      final extension = path.extension(originalPath);
      final compressedPath = path.join(
        directory.path,
        '${originalName}_compressed$extension',
      );

      // Light compression - maintain high quality while reducing file size
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        compressedPath,
        quality: 90, // Higher quality for better user experience
        minWidth: 1200, // Slightly higher resolution for better quality
        minHeight: 1200, // Slightly higher resolution for better quality
        format: CompressFormat.jpeg, // Use JPEG for better compression
      );

      if (compressedFile != null) {
        return compressedFile.path;
      } else {
        // If compression fails, return original path
        return originalPath;
      }
    } catch (e) {
      // If any error occurs during compression, silently use original image
      return originalPath;
    }
  } // Test Firebase Storage connectivity

  Future<bool> testStorageConnectivity() async {
    try {
      // Get the default bucket
      final storageRef = _storage.ref();

      // Test by creating a small reference (doesn't upload anything)
      storageRef.child('test/connectivity_test.txt');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Upload image with improved error handling and validation
  Future<String> uploadImage(String path, String userId) async {
    String? compressedImagePath;

    try {
      // Check connectivity first
      final isConnected = await testStorageConnectivity();
      if (!isConnected) {
        throw Exception(
          'Firebase Storage is not properly configured or accessible',
        );
      }

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

      // Check file size (limit to 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw ArgumentError('Image file is too large (max 10MB)');
      } // Compress the image before upload (done silently)
      compressedImagePath = await _compressImage(path);
      final compressedFile = File(compressedImagePath);

      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload images');
      }

      // Clean the userId to be filesystem-safe (remove + symbol and other special chars)
      final cleanUserId = userId.replaceAll(RegExp(r'[+\-\s()]'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = file.path.split('/').last.split('.').first;
      final extension = file.path.toLowerCase().split('.').last;
      final fileName =
          '${timestamp}_$originalFileName'
          '_$cleanUserId.$extension';

      // Create reference with the storage bucket explicitly
      // Use a simpler path structure to avoid issues
      final storagePath = '$_storageFolder/$fileName';

      final ref = _storage.ref(storagePath);

      // Determine content type from file extension
      String contentType = 'image/jpeg'; // default
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      } // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedBy': userId,
          'uploadTime': DateTime.now().toIso8601String(),
          'originalFileName': originalFileName,
          'userUid': currentUser.uid,
        },
      );

      // Use uploadTask for better error handling
      final uploadTask = ref.putFile(compressedFile, metadata);

      // Wait for upload to complete
      final taskSnapshot = await uploadTask;

      // Get download URL from the completed upload
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Clean up temporary compressed file if it's different from original
      if (compressedImagePath != path) {
        try {
          await compressedFile.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Handle specific Firebase Storage errors
      switch (e.code) {
        case 'storage/object-not-found':
          throw Exception(
            'Storage bucket not found. Please check Firebase project configuration.',
          );
        case 'storage/bucket-not-found':
          throw Exception(
            'Storage bucket does not exist. Please verify Firebase Storage setup.',
          );
        case 'storage/project-not-found':
          throw Exception(
            'Firebase project not found. Please check project configuration.',
          );
        case 'storage/quota-exceeded':
          throw Exception(
            'Storage quota exceeded. Please check your Firebase plan.',
          );
        case 'storage/unauthenticated':
          throw Exception(
            'User not authenticated. Please sign in and try again.',
          );
        case 'storage/unauthorized':
          throw Exception(
            'Permission denied. Please check storage rules and user permissions.',
          );
        case 'storage/retry-limit-exceeded':
          throw Exception(
            'Upload failed after multiple retries. Please try again later.',
          );
        case 'storage/invalid-format':
          throw Exception(
            'Invalid file format. Please select a valid image file.',
          );
        case 'storage/no-default-bucket':
          throw Exception(
            'No default storage bucket configured. Please check Firebase setup.',
          );
        case 'storage/cannot-slice-blob':
          throw Exception(
            'File upload failed. Please try with a different image.',
          );
        case 'storage/invalid-checksum':
          throw Exception('File corrupted during upload. Please try again.');
        case 'storage/invalid-event-name':
          throw Exception('Invalid storage operation. Please contact support.');
        case 'storage/no-available-buckets':
          throw Exception(
            'No storage buckets available. Please check Firebase configuration.',
          );
        case 'storage/invalid-argument':
          throw Exception('Invalid upload parameters. Please try again.');
        default:
          throw Exception(
            'Upload failed (${e.code}): ${e.message ?? 'Unknown error'}',
          );
      }
    } catch (e) {
      // Clean up temporary compressed file if it's different from original
      if (compressedImagePath != null && compressedImagePath != path) {
        try {
          await File(compressedImagePath).delete();
        } catch (cleanupError) {
          // Ignore cleanup errors
        }
      }

      // Handle other types of errors
      if (e.toString().contains('object-not-found')) {
        throw Exception(
          'Storage bucket not properly configured. Please contact support.',
        );
      } else if (e.toString().contains('unauthorized')) {
        throw Exception('Permission denied. Please ensure you are logged in.');
      } else if (e.toString().contains('permission-denied')) {
        throw Exception(
          'Access denied. Please check your account permissions.',
        );
      } else if (e.toString().contains('network')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      } else {
        throw Exception('Failed to upload image: ${e.toString()}');
      }
    } finally {
      // Additional cleanup in finally block to ensure cleanup happens
      if (compressedImagePath != null && compressedImagePath != path) {
        try {
          final tempFile = File(compressedImagePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      }
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
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      print(
        'FirebaseService: Starting deletePost with postId: $postId, userId: $userId',
      );

      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }
      if (userId.trim().isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      final postRef = _firestore.collection(_postsCollection).doc(postId);
      print('FirebaseService: Getting post document...');
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        print('FirebaseService: Post not found');
        throw Exception('Post not found');
      }

      final postData = postDoc.data()!;
      print('FirebaseService: Post data: $postData');

      // Check if user owns the post
      if (postData['authorId'] != userId) {
        print(
          'FirebaseService: User does not own post. AuthorId: ${postData['authorId']}, UserId: $userId',
        );
        throw Exception('You can only delete your own posts');
      }

      // Delete image from storage if exists
      if (postData['imageUrl'] != null &&
          postData['imageUrl'].toString().isNotEmpty) {
        try {
          print('FirebaseService: Deleting image from storage...');
          final imageUrl = postData['imageUrl'] as String;
          if (imageUrl.contains('firebase')) {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
            print('FirebaseService: Image deleted from storage');
          }
        } catch (e) {
          print('FirebaseService: Failed to delete image: $e');
          // Continue with post deletion even if image deletion fails
        }
      }

      // Delete all comments in the post
      print('FirebaseService: Deleting comments...');
      final commentsSnapshot =
          await postRef.collection(_commentsCollection).get();
      final batch = _firestore.batch();

      for (final commentDoc in commentsSnapshot.docs) {
        batch.delete(commentDoc.reference);
      }
      print(
        'FirebaseService: Added ${commentsSnapshot.docs.length} comments to batch deletion',
      );

      // Delete all likes in the post
      print('FirebaseService: Deleting likes...');
      final likesSnapshot = await postRef.collection('likes').get();
      for (final likeDoc in likesSnapshot.docs) {
        batch.delete(likeDoc.reference);
      }
      print(
        'FirebaseService: Added ${likesSnapshot.docs.length} likes to batch deletion',
      );

      // Delete the post itself
      print('FirebaseService: Adding post to batch deletion...');
      batch.delete(postRef);

      // Execute all deletions
      print('FirebaseService: Committing batch deletion...');
      await batch.commit();
      print('FirebaseService: Post deleted successfully');
    } catch (e) {
      print('FirebaseService: Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      print(
        'FirebaseService: Starting deleteComment with postId: $postId, commentId: $commentId, userId: $userId',
      );

      if (postId.trim().isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }
      if (commentId.trim().isEmpty) {
        throw ArgumentError('Comment ID cannot be empty');
      }
      if (userId.trim().isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      final commentRef = _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection(_commentsCollection)
          .doc(commentId);

      print('FirebaseService: Getting comment document...');
      final commentDoc = await commentRef.get();

      if (!commentDoc.exists) {
        print('FirebaseService: Comment not found');
        throw Exception('Comment not found');
      }

      final commentData = commentDoc.data()!;
      print('FirebaseService: Comment data: $commentData');

      // Check if user owns the comment
      if (commentData['authorId'] != userId) {
        print(
          'FirebaseService: User does not own comment. AuthorId: ${commentData['authorId']}, UserId: $userId',
        );
        throw Exception('You can only delete your own comments');
      }

      // Delete the comment
      print('FirebaseService: Deleting comment...');
      await commentRef.delete();
      print('FirebaseService: Comment deleted successfully');
    } catch (e) {
      print('FirebaseService: Error deleting comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Check if user owns a post
  Future<bool> userOwnsPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final postDoc =
          await _firestore.collection(_postsCollection).doc(postId).get();
      if (!postDoc.exists) return false;

      final postData = postDoc.data()!;
      return postData['authorId'] == userId;
    } catch (e) {
      return false;
    }
  }

  // Check if user owns a comment
  Future<bool> userOwnsComment({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      final commentDoc =
          await _firestore
              .collection(_postsCollection)
              .doc(postId)
              .collection(_commentsCollection)
              .doc(commentId)
              .get();

      if (!commentDoc.exists) return false;

      final commentData = commentDoc.data()!;
      return commentData['authorId'] == userId;
    } catch (e) {
      return false;
    }
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

  // Check if user has liked a post (synchronous)
  Future<bool> hasUserLikedPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDoc =
          await _firestore
              .collection(_postsCollection)
              .doc(postId)
              .collection('likes')
              .doc(userId)
              .get();
      return likeDoc.exists;
    } catch (e) {
      return false;
    }
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
}
