import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists(
    User user, {
    String? name,
    String? profilePic,
  }) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'name': name ?? 'User',
        'profilePic': profilePic,
      });
    }
  }
}
