import 'package:fair_share_app/models/expence_model.dart';
import 'package:fair_share_app/models/settlement_model.dart';

class BalanceCalculator {
  static Map<String, double> calculateBalances({
    required List<String> memberIds,
    required List<ExpenseModel> expenses,
    required List<SettlementModel> settlements,
  }) {
   
    final Map<String, int> balanceCents = {
      for (final id in memberIds) id: 0,
    };

    for (final expense in expenses) {
      final int amountCents = (expense.amount * 100).round();

      if (balanceCents.containsKey(expense.paidBy)) {
        balanceCents[expense.paidBy] =
            balanceCents[expense.paidBy]! + amountCents;
      }

      expense.splits.forEach((memberId, share) {
        if (balanceCents.containsKey(memberId)) {
          final int shareCents = (share.toDouble() * 100).round();
          balanceCents[memberId] = balanceCents[memberId]! - shareCents;
        }
      });
    }

    for (final settlement in settlements) {
      final int amountCents = (settlement.amount * 100).round();

      if (balanceCents.containsKey(settlement.fromUserId)) {
        balanceCents[settlement.fromUserId] =
            balanceCents[settlement.fromUserId]! + amountCents;
      }

      if (balanceCents.containsKey(settlement.toUserId)) {
        balanceCents[settlement.toUserId] =
            balanceCents[settlement.toUserId]! - amountCents;
      }
    }

    return balanceCents.map(
      (memberId, cents) => MapEntry(memberId, cents / 100),
    );
  }
}