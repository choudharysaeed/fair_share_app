import 'package:cloud_firestore/cloud_firestore.dart';

enum SplitType { equal, exact, shares }

class ExpenseModel {
  String id;
  String groupId;
  String description;
  double amount;
  String paidBy;

  SplitType splitType;

  Map<String, num> splits;

  Timestamp date;

  String createdBy;

  Timestamp createdAt;

  ExpenseModel({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
    required this.date,
    required this.createdBy,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      groupId: map['groupId'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidBy: map['paidBy'] as String,

      splitType: SplitType.values.firstWhere(
        (type) => type.name == map['splitType'],
      ),

      splits: Map<String, num>.from(map['splits']),

      date: map['date'] as Timestamp,
      createdBy: map['createdBy'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,

      'splitType': splitType.name,

      'splits': splits,
      'date': date,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
