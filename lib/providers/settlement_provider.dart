import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fair_share_app/models/settlement_model.dart';
import 'package:fair_share_app/services/settlement_service.dart';

class SettlementProvider extends ChangeNotifier {
  final SettlementService _settlementService = SettlementService();

  List<SettlementModel> settlements = [];

  bool isLoading = false;

  String? errorMessage;

  StreamSubscription<List<SettlementModel>>? _settlementsSubscription;

  void listenToSettlements(String groupId) {
    isLoading = true;
    notifyListeners();

    _settlementsSubscription?.cancel();

    _settlementsSubscription = _settlementService
        .streamSettlements(groupId)
        .listen(
          (settlementList) {
            settlements = settlementList;
            isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            isLoading = false;
            errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> loadSettlements(String groupId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      settlements = await _settlementService.getSettlements(groupId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addSettlement(SettlementModel settlement) async {
    try {
      errorMessage = null;
      await _settlementService.addSettlement(settlement);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSettlement(String settlementId) async {
    try {
      await _settlementService.deleteSettlement(settlementId);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _settlementsSubscription?.cancel();
    super.dispose();
  }
}