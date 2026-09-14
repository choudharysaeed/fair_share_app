import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/services/firestore_service.dart';

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
      ).loadExpenses(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balances')),

      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.memberIds.length,
            itemBuilder: (context, index) {
              final memberId = widget.memberIds[index];

              final paid = provider.getMemberPaidAmount(memberId);

              final share = provider.getMemberShareAmount(memberId);

              final balance = provider.getMemberBalance(memberId);

              return FutureBuilder(
                future: _firestoreService.getUserById(memberId),
                builder: (context, snapshot) {
                  String memberName = 'Loading...';

                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    memberName = '$user{"firstName"} $user{"lastName"}';
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

                          const SizedBox(height: 10),

                          Text('Paid: ${paid.toStringAsFixed(2)}'),

                          Text('Share: ${share.toStringAsFixed(2)}'),

                          const SizedBox(height: 8),

                          Text(
                            balance > 0
                                ? 'Gets: ${balance.toStringAsFixed(2)}'
                                : balance < 0
                                ? 'Owes: ${(-balance).toStringAsFixed(2)}'
                                : 'Settled',
                            style: TextStyle(
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
