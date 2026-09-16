import 'dart:async';

import 'package:fair_share_app/models/expence_model.dart';
import 'package:fair_share_app/services/expence_service.dart';
import 'package:flutter/foundation.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<ExpenseModel> expenses = [];

  bool isLoading = false;

  String? errorMessage;

  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;
  void listenToExpenses(String groupId) {
    isLoading = true;
    notifyListeners();

    _expensesSubscription?.cancel();

    _expensesSubscription = _expenseService.streamExpenses(groupId).listen(
      (expenseList) {
        expenses = expenseList;
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

  Future<void> loadExpenses(String groupId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      expenses = await _expenseService.getExpenses(groupId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      errorMessage = null;
      await _expenseService.addExpense(expense);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      errorMessage = null;
      await _expenseService.updateExpense(expense);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      errorMessage = null;
      await _expenseService.deleteExpense(expenseId);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  double getMemberPaidAmount(String memberId) {
    double totalPaid = 0;
    for (final expense in expenses) {
      if (expense.paidBy == memberId) {
        totalPaid += expense.amount;
      }
    }
    return totalPaid;
  }

  double getMemberShareAmount(String memberId) {
    double totalShare = 0;
    for (final expense in expenses) {
      totalShare += expense.splits[memberId]?.toDouble() ?? 0;
    }
    return totalShare;
  }

  double getMemberBalance(String memberId) {
    final paid = getMemberPaidAmount(memberId);
    final share = getMemberShareAmount(memberId);
    return paid - share;
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }
}