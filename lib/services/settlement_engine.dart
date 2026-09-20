class SettlementEngine {
  List<Map<String, dynamic>> calculateSettlements(
    Map<String, double> balances,
  ) {

    final List<Map<String, dynamic>> debtors = [];
    final List<Map<String, dynamic>> creditors = [];

    balances.forEach((userId, balance) {
      final int cents = (balance * 100).round();

      if (cents < 0) {
        debtors.add({
          'userId': userId,
          'amountCents': -cents,
        });
      } else if (cents > 0) {
        creditors.add({
          'userId': userId,
          'amountCents': cents,
        });
      }
    });

    final List<Map<String, dynamic>> settlements = [];

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];

      final int debtorCents = debtor['amountCents'];
      final int creditorCents = creditor['amountCents'];

      final int paymentCents =
          debtorCents < creditorCents ? debtorCents : creditorCents;

      settlements.add({
        'fromUserId': debtor['userId'],
        'toUserId': creditor['userId'],
        'amount': paymentCents / 100,
      });

      debtor['amountCents'] = debtorCents - paymentCents;
      creditor['amountCents'] = creditorCents - paymentCents;

      if (debtor['amountCents'] == 0) {
        debtorIndex++;
      }

      if (creditor['amountCents'] == 0) {
        creditorIndex++;
      }
    }

    return settlements;
  }
}