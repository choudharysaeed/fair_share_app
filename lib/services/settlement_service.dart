import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/settlement_model.dart';

class SettlementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSettlement(SettlementModel settlement) async {
    await _firestore
        .collection('settlements')
        .doc(settlement.id)
        .set(settlement.toMap());
  }

  Future<List<SettlementModel>> getSettlements(String groupId) async {
    final snapshot = await _firestore
        .collection('settlements')
        .where('groupId', isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) {
      return SettlementModel.fromMap(doc.data());
    }).toList();
  }

  Future<void> deleteSettlement(String settlementId) async {
    await _firestore
        .collection('settlements')
        .doc(settlementId)
        .delete();
  }
}