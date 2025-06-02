import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      authorId: data['authorId'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment.fromMap(id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
