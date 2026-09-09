import 'dart:async';

import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;

  List<GroupModel> groups = [];

  StreamSubscription<List<GroupModel>>? _groupsSubscription;

  Future<void> createGroup({
    required String name,
    required String userId,
    required String currency,
  }) async {
    isLoading = true;
    notifyListeners();

    await _firestoreService.createGroup(
      name: name,
      createdBy: userId,
      currency: currency,
    );

    isLoading = false;
    notifyListeners();
  }

  void listenToGroups(String userId) {
    _groupsSubscription?.cancel();

    _groupsSubscription = _firestoreService.getUserGroups(userId).listen((
      groupList,
    ) {
      groups = groupList;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    super.dispose();
  }
}
