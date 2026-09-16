import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fair_share_app/models/activity_model.dart';
import 'package:fair_share_app/services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  List<ActivityModel> activities = [];

  StreamSubscription<List<ActivityModel>>? _activitySubscription;

  bool isLoading = false;
  String? errorMessage;

  void listenToActivities(String userId) {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _activitySubscription?.cancel();

    _activitySubscription = _activityService
        .getActivities(userId)
        .listen(
          (activityList) {
            activities = activityList;
            isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            errorMessage = error.toString();
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _activityService.addActivity(activity);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }
}