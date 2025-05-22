import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  /// Save a new user with embedding to Firestore
  Future<void> saveUser({
    required String uid,
    required String email,
    required List<double> embedding,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'embedding': embedding,
    });
  }

  /// Fetch a user's embedding by UID
  Future<List<double>> getEmbeddingByUid(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || !doc.data()!.containsKey('embedding')) {
      throw Exception("User or embedding not found");
    }
    return List<double>.from(doc['embedding']);
  }

  /// Fetch a user's UID and embedding by email
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("User not found");
    }

    final doc = snapshot.docs.first;
    return {
      'uid': doc.id,
      'embedding': List<double>.from(doc['embedding']),
    };
  }

  /// Optional: update an existing user's embedding
  Future<void> updateEmbedding(String uid, List<double> newEmbedding) async {
    await _firestore.collection('users').doc(uid).update({
      'embedding': newEmbedding,
    });
  }
}
