import 'package:flutter/foundation.dart';
import 'package:fair_share_app/models/settlement_model.dart';
import 'package:fair_share_app/services/settlement_service.dart';

class SettlementProvider extends ChangeNotifier {
  final SettlementService _settlementService = SettlementService();

  List<SettlementModel> settlements = [];

  bool isLoading = false;

  String? errorMessage;

  Future<void> addSettlement(SettlementModel settlement) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _settlementService.addSettlement(settlement);

      settlements.add(settlement);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
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

  Future<void> deleteSettlement(String settlementId) async {
    try {
      await _settlementService.deleteSettlement(settlementId);

      settlements.removeWhere(
        (settlement) => settlement.id == settlementId,
      );

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}