import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/providers/settlement_provider.dart';
import 'package:fair_share_app/services/firestore_service.dart';

class SettlementHistoryScreen extends StatefulWidget {
  final GroupModel group;

  const SettlementHistoryScreen({
    super.key,
    required this.group,
  });

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState
    extends State<SettlementHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadSettlementHistory();
  }

  Future<void> _loadSettlementHistory() async {
    final settlementProvider =
        Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    await settlementProvider.loadSettlements(widget.group.id);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getUserName(String userId) async {
    final user = await _firestoreService.getUserById(userId);

    if (user == null) {
      return 'Unknown User';
    }

    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';

    return '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlement History'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<SettlementProvider>(
              builder: (context, provider, child) {
                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      'Error: ${provider.errorMessage}',
                    ),
                  );
                }

                if (provider.settlements.isEmpty) {
                  return const Center(
                    child: Text(
                      'No settlement history yet.',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.settlements.length,
                  itemBuilder: (context, index) {
                    final settlement =
                        provider.settlements[index];

                    final fromUserId =
                        settlement.fromUserId;

                    final toUserId =
                        settlement.toUserId;

                    final amount = settlement.amount;

                    return FutureBuilder(
                      future: Future.wait([
                        _getUserName(fromUserId),
                        _getUserName(toUserId),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Card(
                            child: ListTile(
                              title: Text('Loading...'),
                            ),
                          );
                        }

                        final names = snapshot.data!;

                        final fromName = names[0];
                        final toName = names[1];

                        // Convert Timestamp to readable date.
                        final date =
                            settlement.createdAt.toDate();

                        final dateText =
                            '${date.day}/${date.month}/${date.year}';

                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.check,
                              ),
                            ),

                            title: Text(
                              '$fromName paid $toName',
                            ),

                            subtitle: Text(
                              'Paid on $dateText',
                            ),

                            trailing: Text(
                              '${widget.group.currency} '
                              '${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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