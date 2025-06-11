import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likeCount;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likeCount,
  });

  factory Post.fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      authorId: data['authorId'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likeCount: data['likeCount'] ?? 0,
    );
  }

  factory Post.fromFirestore(Map<String, dynamic> data, String id) {
    return Post.fromMap(id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likeCount': likeCount,
    };
  }
}
