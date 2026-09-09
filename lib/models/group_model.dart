import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String id;
  String name;
  List<String> memberIds;
  String createdBy;
  String currency;
  Timestamp createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdBy,
    required this.currency,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'],
      name: map['name'],
      memberIds: List<String>.from(map['memberIds']),
      createdBy: map['createdBy'],
      currency: map['currency'],
      createdAt: map['createdAt'],
    );
  }
}
