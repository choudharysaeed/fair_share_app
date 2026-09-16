import 'package:cloud_firestore/cloud_firestore.dart';

class SettlementModel {
  String id;
  String groupId;
  String fromUserId;
  String toUserId;
  double amount;
  Timestamp createdAt;

  SettlementModel({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'createdAt': createdAt,
    };
  }

  factory SettlementModel.fromMap(Map<String, dynamic> map) {
    return SettlementModel(
      id: map['id'],
      groupId: map['groupId'],
      fromUserId: map['fromUserId'],
      toUserId: map['toUserId'],
      amount: (map['amount'] as num).toDouble(),
      createdAt: map['createdAt'],
    );
  }
}