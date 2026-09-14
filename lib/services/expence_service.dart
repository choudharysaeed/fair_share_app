import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/expence_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses(String groupId) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) {
      return ExpenseModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }
}
