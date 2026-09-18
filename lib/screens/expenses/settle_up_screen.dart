import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fair_share_app/models/activity_model.dart';
import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/models/settlement_model.dart';

import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/providers/settlement_provider.dart';

import 'package:fair_share_app/services/balance_calculator.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:fair_share_app/services/settlement_engine.dart';

class SettleUpScreen extends StatefulWidget {
  final GroupModel group;

  const SettleUpScreen({
    super.key,
    required this.group,
  });

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final SettlementEngine _settlementEngine = SettlementEngine();
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> settlements = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _calculateSettlements();
  }

  Future<void> _calculateSettlements() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    await expenseProvider.loadExpenses(widget.group.id);
    await settlementProvider.loadSettlements(widget.group.id);

    final balances = BalanceCalculator.calculateBalances(
      memberIds: widget.group.memberIds,
      expenses: expenseProvider.expenses,
      settlements: settlementProvider.settlements,
    );

    final result = _settlementEngine.calculateSettlements(balances);

    if (mounted) {
      setState(() {
        settlements = result;
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

  Future<void> _markAsPaid(
    Map<String, dynamic> settlement,
    int index,
  ) async {
    try {
      final settlementProvider = Provider.of<SettlementProvider>(
        context,
        listen: false,
      );

      final settlementId = DateTime.now().millisecondsSinceEpoch.toString();

      final String fromUserId = settlement['fromUserId'];
      final String toUserId = settlement['toUserId'];
      final double amount = (settlement['amount'] as num).toDouble();

      final newSettlement = SettlementModel(
        id: settlementId,
        groupId: widget.group.id,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        createdAt: Timestamp.now(),
      );

      await settlementProvider.addSettlement(newSettlement);

      if (!mounted) return;

      final fromName = await _getUserName(fromUserId);
      final toName = await _getUserName(toUserId);

      if (!mounted) return;

      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );

      await activityProvider.addActivity(
        ActivityModel(
          id: '${settlementId}_from',
          userId: fromUserId,
          groupId: widget.group.id,
          groupName: widget.group.name,
          type: 'settlement_paid',
          title: 'You paid $toName',
          description: 'Settlement payment',
          amount: -amount,
          createdAt: Timestamp.now(),
        ),
      );

      await activityProvider.addActivity(
        ActivityModel(
          id: '${settlementId}_to',
          userId: toUserId,
          groupId: widget.group.id,
          groupName: widget.group.name,
          type: 'settlement_received',
          title: '$fromName paid you',
          description: 'Settlement payment',
          amount: amount,
          createdAt: Timestamp.now(),
        ),
      );

      if (!mounted) return;

      setState(() {
        settlements.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settlement marked as paid successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settlement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : settlements.isEmpty
              ? const Center(
                  child: Text(
                    'Everyone is settled up!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: settlements.length,
                  itemBuilder: (context, index) {
                    final settlement = settlements[index];

                    final String fromUserId = settlement['fromUserId'];
                    final String toUserId = settlement['toUserId'];
                    final double amount =
                        (settlement['amount'] as num).toDouble();

                    return FutureBuilder(
                      future: Future.wait([
                        _getUserName(fromUserId),
                        _getUserName(toUserId),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Card(
                            child: ListTile(title: Text('Loading...')),
                          );
                        }

                        final names = snapshot.data!;

                        final String fromName = names[0];
                        final String toName = names[1];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.arrow_forward),
                                  ),
                                  title: Text('$fromName pays $toName'),
                                  subtitle: const Text('Settlement payment'),
                                  trailing: Text(
                                    '${widget.group.currency} '
                                    '${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _markAsPaid(settlement, index);
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text('Mark as Paid'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}