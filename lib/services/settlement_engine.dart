class SettlementEngine {
  
  List<Map<String, dynamic>> calculateSettlements(
    Map<String, double> balances,
  ) {
    final List<Map<String, dynamic>> debtors = [];

    final List<Map<String, dynamic>> creditors = [];
    balances.forEach((userId, balance) {
      if (balance < 0) {
        debtors.add({
          'userId': userId,
          'amount': -balance,
        });
      } else if (balance > 0) {
        creditors.add({
          'userId': userId,
          'amount': balance,
        });
      }
    });

    final List<Map<String, dynamic>> settlements = [];

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (
        debtorIndex < debtors.length &&
        creditorIndex < creditors.length) {
      
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];

      final double payment = debtor['amount'] < creditor['amount']
          ? debtor['amount']
          : creditor['amount'];

      settlements.add({
        'fromUserId': debtor['userId'],
        'toUserId': creditor['userId'],
        'amount': payment,
      });
      debtor['amount'] -= payment;
      creditor['amount'] -= payment;

      if (debtor['amount'] == 0) {
        debtorIndex++;
      }

      if (creditor['amount'] == 0) {
        creditorIndex++;
      }
    }

    return settlements;
  }
}
