import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/expence_model.dart';
import 'package:flutter/foundation.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ExpenseModel> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = <ExpenseModel>[];
    for (final doc in snapshot.docs) {
      try {
        list.add(ExpenseModel.fromMap(doc.data(), doc.id));
      } catch (e) {
        debugPrint('Skipping bad expense ${doc.id}: $e');
      }
    }
    return list;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).set(expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses(String groupId) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .limit(200)
        .get();
    return _parse(snapshot);
  }

  Stream<List<ExpenseModel>> streamExpenses(String groupId) {
    return _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .limit(200)
        .snapshots()
        .map(_parse);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }
}