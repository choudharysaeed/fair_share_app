import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  String id;
  String userId;
  String groupId;
  String groupName;
  String type;
  String title;
  String description;
  double? amount;
  Timestamp createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.groupName,
    required this.type,
    required this.title,
    required this.description,
    this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'groupName': groupName,
      'type': type,
      'title': title,
      'description': description,
      'amount': amount,
      'createdAt': createdAt,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: map['amount'] != null
          ? (map['amount'] as num).toDouble()
          : null,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}