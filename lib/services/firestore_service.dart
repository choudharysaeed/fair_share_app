import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/group_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoUrl': null,
      'createdAt': Timestamp.now(),
    });
  }

    Future<String> createGroup({
    required String name,
    required String createdBy,
    required String currency,
  }) async {
    final docRef = await _firestore.collection('groups').add({
      'name': name,
      'memberIds': [createdBy],
      'createdBy': createdBy,
      'currency': currency,
      'createdAt': Timestamp.now(),
    });

    return docRef.id;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (doc.exists) {
      return doc.data();
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }

    return null;
  }

  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return GroupModel.fromMap({...data, 'id': doc.id});
          }).toList();
        });
  }
}
