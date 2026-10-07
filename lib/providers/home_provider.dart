import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fair_share_app/services/firestore_service.dart';
import 'package:fair_share_app/services/expence_service.dart';
import 'package:fair_share_app/services/settlement_service.dart';
import 'package:fair_share_app/services/balance_calculator.dart';

class HomeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ExpenseService _expenseService = ExpenseService();
  final SettlementService _settlementService = SettlementService();

  String _initials = 'U';
  double _overallOwed = 0;
  double _overallOwe = 0;
  Map<String, double> _groupBalances = {};
  int _requestId = 0;

  String get initials => _initials;
  double get overallOwed => _overallOwed;
  double get overallOwe => _overallOwe;

  double balanceFor(String groupId) => _groupBalances[groupId] ?? 0;

  Future<void> loadUserInitials() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final user = await _firestoreService.getUserById(userId);

      String result = 'U';
      if (user != null) {
        final firstName = user['firstName'] ?? '';
        final lastName = user['lastName'] ?? '';

        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          result = '${firstName[0]}${lastName[0]}'.toUpperCase();
        } else if (firstName.isNotEmpty) {
          result = firstName[0].toUpperCase();
        }
      }

      _initials = result;
    } catch (e) {
      debugPrint('loadUserInitials error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadBalances(List<dynamic> groups) async {
    final requestId = ++_requestId;

    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final Map<String, double> newBalances = {};
      double totalOwed = 0;
      double totalOwe = 0;

      for (final group in groups) {
        final expenses = await _expenseService.getExpenses(group.id);
        final settlements = await _settlementService.getSettlements(group.id);

        final balances = BalanceCalculator.calculateBalances(
          memberIds: List<String>.from(group.memberIds),
          expenses: expenses,
          settlements: settlements,
        );

        final balance = balances[currentUserId] ?? 0;
        newBalances[group.id] = balance;

        if (balance > 0) {
          totalOwed += balance;
        } else if (balance < 0) {
          totalOwe += balance.abs();
        }
      }

      if (requestId != _requestId) return;

      _groupBalances = newBalances;
      _overallOwed = totalOwed;
      _overallOwe = totalOwe;
    } catch (e) {
      debugPrint('loadBalances error: $e');
    } finally {
      if (requestId == _requestId) notifyListeners();
    }
  }

  void reset() {
    _initials = 'U';
    _overallOwed = 0;
    _overallOwe = 0;
    _groupBalances = {};
    notifyListeners();
  }
}