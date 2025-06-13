import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  } // Test Firebase Storage connectivity

  Future<bool> testStorageConnectivity() async {
    try {
      print('Testing Firebase Storage connectivity...');

      // Get the default bucket
      final storageRef = _storage.ref();
      print('Storage reference created successfully');

      // Try to get storage bucket info
      final bucket = _storage.bucket;
      print('Storage bucket: $bucket');

      // Test by creating a small reference (doesn't upload anything)
      final testRef = storageRef.child('test/connectivity_test.txt');
      print('Test reference created: ${testRef.fullPath}');

      return true;
    } on FirebaseException catch (e) {
      print(
        'Firebase Storage connectivity test failed: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('Storage connectivity test error: $e');
      return false;
    }
  }

  // Upload image with improved error handling and validation
  Future<String> uploadImage(String path, String userId) async {
    try {
      print('=== Starting image upload ===');

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
      }

      print('Uploading image for user: $userId');
      print('File path: $path');
      print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload images');
      }
      print('User is authenticated: ${currentUser.uid}');

      // Clean the userId to be filesystem-safe (remove + symbol and other special chars)
      final cleanUserId = userId.replaceAll(RegExp(r'[+\-\s()]'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = file.path.split('/').last.split('.').first;
      final extension = file.path.toLowerCase().split('.').last;
      final fileName =
          '${timestamp}_${originalFileName}_${cleanUserId}.${extension}';

      print('Clean user ID: $cleanUserId');
      print('Generated filename: $fileName');

      // Create reference with the storage bucket explicitly
      // Use a simpler path structure to avoid issues
      final storagePath = '$_storageFolder/$fileName';
      print('Storage path: $storagePath');

      final ref = _storage.ref(storagePath);
      print('Storage reference created: ${ref.fullPath}');

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
      }

      print('Content type: $contentType');

      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedBy': userId,
          'uploadTime': DateTime.now().toIso8601String(),
          'originalFileName': originalFileName,
          'userUid': currentUser.uid,
        },
      );

      print('Starting upload...');

      // Use uploadTask for better error handling
      final uploadTask = ref.putFile(file, metadata);

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final taskSnapshot = await uploadTask;
      print('Upload completed. Getting download URL...');

      // Get download URL from the completed upload
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Download URL obtained: $downloadUrl');
      print('=== Upload successful ===');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
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
      print('General error: $e');
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
