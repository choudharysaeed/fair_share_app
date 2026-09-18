import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/activity_model.dart';
import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/models/settlement_model.dart';
import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/providers/settlement_provider.dart';
import 'package:fair_share_app/screens/expenses/add_expense_screen.dart';
import 'package:fair_share_app/screens/expenses/edit_expense_screen.dart';
import 'package:fair_share_app/screens/groups/add_member_screen.dart';
import 'package:fair_share_app/services/balance_calculator.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:fair_share_app/services/settlement_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirestoreService _firestoreService = FirestoreService();
  final SettlementEngine _settlementEngine = SettlementEngine();

  Map<String, String> _memberNames = {};
  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // Expenses aur settlements dono ko live sunna shuru karo — taake
    // dono tabs (Expenses, Balances) hamesha up-to-date rahein.
    Future.microtask(() {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).listenToExpenses(widget.group.id);

      Provider.of<SettlementProvider>(
        context,
        listen: false,
      ).listenToSettlements(widget.group.id);
    });

    _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    final Map<String, String> names = {};

    for (final memberId in widget.group.memberIds) {
      final userData = await _firestoreService.getUserById(memberId);

      if (userData != null) {
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        names[memberId] = fullName.isEmpty ? memberId : fullName;
      } else {
        names[memberId] = memberId;
      }
    }

    if (mounted) {
      setState(() {
        _memberNames = names;
        _isLoadingNames = false;
      });
    }
  }

  String _initialsFor(String memberId) {
    final name = _memberNames[memberId] ?? '';
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Balances'),
          ],
        ),
        actions: [
          if (!_isLoadingNames)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.group.memberIds.take(3).map((memberId) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF087F75),
                      child: Text(
                        _initialsFor(memberId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      body: _isLoadingNames
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ExpensesTab(group: widget.group, memberNames: _memberNames),
                _BalancesTab(
                  group: widget.group,
                  memberNames: _memberNames,
                  settlementEngine: _settlementEngine,
                ),
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addMember',
            backgroundColor: const Color(0xFF71807E),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemberScreen(group: widget.group),
                ),
              );
            },
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'addExpense',
            backgroundColor: const Color(0xFF087F75),
            onPressed: () {
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(
                    groupId: widget.group.id,
                    currentUserId: currentUserId,
                    memberIds: widget.group.memberIds,
                  ),
                ),
              );
            },
            child: const Icon(Icons.receipt_long),
          ),
        ],
      ),
    );
  }
}

// ---------------- Expenses tab ----------------

class _ExpensesTab extends StatelessWidget {
  final GroupModel group;
  final Map<String, String> memberNames;

  const _ExpensesTab({required this.group, required this.memberNames});

  Future<void> _deleteExpense(BuildContext context, String expenseId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text(
            'Are you sure you want to delete this expense?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(expenseId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.expenses.isEmpty) {
          return const Center(
            child: Text('No expenses yet', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) {
            final expense = provider.expenses[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('Amount: ${expense.amount}'),
                    Text(
                      'Paid by: ${memberNames[expense.paidBy] ?? expense.paidBy}',
                    ),
                    Text('Split: ${expense.splitType.name}'),
                    Text(
                      'Date: '
                      '${expense.date.toDate().day}/'
                      '${expense.date.toDate().month}/'
                      '${expense.date.toDate().year}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditExpenseScreen(
                              expense: expense,
                              memberIds: group.memberIds,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteExpense(context, expense.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------- Balances tab ----------------

class _BalancesTab extends StatefulWidget {
  final GroupModel group;
  final Map<String, String> memberNames;
  final SettlementEngine settlementEngine;

  const _BalancesTab({
    required this.group,
    required this.memberNames,
    required this.settlementEngine,
  });

  @override
  State<_BalancesTab> createState() => _BalancesTabState();
}

class _BalancesTabState extends State<_BalancesTab> {
  Future<void> _markAsPaid(Map<String, dynamic> settlement) async {
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

      final fromName = widget.memberNames[fromUserId] ?? fromUserId;
      final toName = widget.memberNames[toUserId] ?? toUserId;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settlement marked as paid!')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save settlement: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, SettlementProvider>(
      builder: (context, expenseProvider, settlementProvider, child) {
        if (expenseProvider.isLoading || settlementProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final balances = BalanceCalculator.calculateBalances(
          memberIds: widget.group.memberIds,
          expenses: expenseProvider.expenses,
          settlements: settlementProvider.settlements,
        );

        final suggestions = widget.settlementEngine.calculateSettlements(
          balances,
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'NET BALANCES',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            ...widget.group.memberIds.map((memberId) {
              final balance = balances[memberId] ?? 0;
              final name = widget.memberNames[memberId] ?? memberId;

              String balanceText;
              Color color;

              if (balance > 0) {
                balanceText =
                    '+${widget.group.currency} ${balance.toStringAsFixed(2)}';
                color = const Color(0xFF268A4B);
              } else if (balance < 0) {
                balanceText =
                    '-${widget.group.currency} ${balance.abs().toStringAsFixed(2)}';
                color = const Color(0xFFD65A32);
              } else {
                balanceText = 'settled';
                color = const Color(0xFF647270);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  trailing: Text(
                    balanceText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            const Text(
              'SETTLE UP · MINIMUM PAYMENTS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            if (suggestions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Everyone is settled up!'),
              )
            else
              ...suggestions.map((settlement) {
                final fromName =
                    widget.memberNames[settlement['fromUserId']] ??
                    settlement['fromUserId'];
                final toName =
                    widget.memberNames[settlement['toUserId']] ??
                    settlement['toUserId'];
                final amount = (settlement['amount'] as num).toDouble();

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('$fromName → $toName'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.group.currency} '
                          '${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _markAsPaid(settlement),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF087F75),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Settle'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}