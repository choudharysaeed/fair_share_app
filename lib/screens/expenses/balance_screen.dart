import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/providers/settlement_provider.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:fair_share_app/services/balance_calculator.dart';

class BalanceScreen extends StatefulWidget {
  final String groupId;
  final List<String> memberIds;

  const BalanceScreen({
    super.key,
    required this.groupId,
    required this.memberIds,
  });

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).listenToExpenses(widget.groupId);

      Provider.of<SettlementProvider>(
        context,
        listen: false,
      ).listenToSettlements(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balances')),
      body: Consumer2<ExpenseProvider, SettlementProvider>(
        builder: (context, expenseProvider, settlementProvider, child) {
          if (expenseProvider.isLoading || settlementProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final balances = BalanceCalculator.calculateBalances(
            memberIds: widget.memberIds,
            expenses: expenseProvider.expenses,
            settlements: settlementProvider.settlements,
          );

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.memberIds.length,
            itemBuilder: (context, index) {
              final memberId = widget.memberIds[index];
              final balance = balances[memberId] ?? 0;

              return FutureBuilder(
                future: _firestoreService.getUserById(memberId),
                builder: (context, snapshot) {
                  String memberName = 'Loading...';

                  if (snapshot.hasData && snapshot.data != null) {
                    final user = snapshot.data!;
                    final firstName = user['firstName'] ?? '';
                    final lastName = user['lastName'] ?? '';
                    memberName = '$firstName $lastName'.trim();
                    if (memberName.isEmpty) memberName = 'Unknown';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            balance > 0
                                ? 'Gets: ${balance.toStringAsFixed(2)}'
                                : balance < 0
                                ? 'Owes: ${(-balance).toStringAsFixed(2)}'
                                : 'Settled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}