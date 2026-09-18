import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/screens/expenses/edit_expense_screen.dart';
import 'package:fair_share_app/services/firestore_service.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final String groupId;

  final List<String> memberIds;

  const ExpenseHistoryScreen({
    super.key,
    required this.groupId,
    required this.memberIds,
  });

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, String> _memberNames = {};

  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).listenToExpenses(widget.groupId);
    });

    _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    final Map<String, String> names = {};

    for (final memberId in widget.memberIds) {
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

  Future<void> _deleteExpense(BuildContext context, String expenseId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
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
    return Scaffold(
      appBar: AppBar(title: const Text('Expense History')),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || _isLoadingNames) {
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
                        'Paid by: ${_memberNames[expense.paidBy] ?? expense.paidBy}',
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
                                memberIds: widget.memberIds,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(context, expense.id);
                        },
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