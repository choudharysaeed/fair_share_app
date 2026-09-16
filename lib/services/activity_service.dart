import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addActivity(ActivityModel activity) async {
    await _firestore
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());
  }

  Stream<List<ActivityModel>> getActivities(String userId) {
    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityModel.fromMap(doc.data());
      }).toList();
    });
  }
}