import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/expence_model.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  final List<String> memberIds;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.memberIds,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late String _selectedPayerId;
  late SplitType _selectedSplitType;
  late DateTime _selectedDate;

  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _shareControllers = {};

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );

    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );

    _selectedPayerId = widget.expense.paidBy;

    _selectedSplitType = widget.expense.splitType;

    _selectedDate = widget.expense.date.toDate();

    for (final memberId in widget.memberIds) {
      final existingValue = widget.expense.splits[memberId];

      _exactControllers[memberId] = TextEditingController(
        text: existingValue?.toString() ?? '',
      );
      _shareControllers[memberId] = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();

    for (final controller in _exactControllers.values) {
      controller.dispose();
    }

    for (final controller in _shareControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Map<String, num> _calculateEqualSplit(double amount) {
    final int totalCents = (amount * 100).round();

    final int basicShare = totalCents ~/ widget.memberIds.length;

    final int remainder = totalCents % widget.memberIds.length;

    final Map<String, num> splits = {};

    for (int i = 0; i < widget.memberIds.length; i++) {
      final int memberCents = basicShare + (i < remainder ? 1 : 0);

      splits[widget.memberIds[i]] = memberCents / 100;
    }

    return splits;
  }

  Map<String, num>? _calculateExactSplit(double amount) {
    final Map<String, num> splits = {};

    double total = 0;

    for (final memberId in widget.memberIds) {
      final value = double.tryParse(_exactControllers[memberId]!.text.trim());

      if (value == null || value < 0) {
        _showError('Please enter valid amounts for all members.');
        return null;
      }

      splits[memberId] = value;
      total += value;
    }

    final int totalCents = (total * 100).round();

    final int amountCents = (amount * 100).round();

    if (totalCents != amountCents) {
      _showError('Exact split total must equal expense amount.');
      return null;
    }

    return splits;
  }

  Map<String, num>? _calculateSharesSplit(double amount) {
    final Map<String, double> shares = {};

    double totalShares = 0;

    for (final memberId in widget.memberIds) {
      final value = double.tryParse(_shareControllers[memberId]!.text.trim());

      if (value == null || value <= 0) {
        _showError('Please enter valid shares for all members.');
        return null;
      }

      shares[memberId] = value;
      totalShares += value;
    }

    final int totalCents = (amount * 100).round();

    final Map<String, num> splits = {};

    int usedCents = 0;

    for (int i = 0; i < widget.memberIds.length; i++) {
      final memberId = widget.memberIds[i];

      int memberCents;

      if (i == widget.memberIds.length - 1) {
        memberCents = totalCents - usedCents;
      } else {
        memberCents = (totalCents * shares[memberId]! / totalShares).round();

        usedCents += memberCents;
      }

      splits[memberId] = memberCents / 100;
    }

    return splits;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.parse(_amountController.text.trim());

    Map<String, num>? splits;

    if (_selectedSplitType == SplitType.equal) {
      splits = _calculateEqualSplit(amount);
    } else if (_selectedSplitType == SplitType.exact) {
      splits = _calculateExactSplit(amount);
    } else if (_selectedSplitType == SplitType.shares) {
      splits = _calculateSharesSplit(amount);
    }

    if (splits == null) {
      return;
    }
    final updatedExpense = ExpenseModel(
      id: widget.expense.id,

      groupId: widget.expense.groupId,

      description: _descriptionController.text.trim(),

      amount: amount,

      paidBy: _selectedPayerId,

      splitType: _selectedSplitType,

      splits: splits,

      date: Timestamp.fromDate(_selectedDate),

      createdBy: widget.expense.createdBy,

      createdAt: widget.expense.createdAt,
    );

    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).updateExpense(updatedExpense);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,

                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedPayerId,

                decoration: const InputDecoration(
                  labelText: 'Paid By',
                  border: OutlineInputBorder(),
                ),

                items: widget.memberIds.map((memberId) {
                  return DropdownMenuItem<String>(
                    value: memberId,
                    child: Text(memberId),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPayerId = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<SplitType>(
                initialValue: _selectedSplitType,

                decoration: const InputDecoration(
                  labelText: 'Split Type',
                  border: OutlineInputBorder(),
                ),

                items: SplitType.values.map((type) {
                  return DropdownMenuItem<SplitType>(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSplitType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              if (_selectedSplitType == SplitType.exact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exact Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...widget.memberIds.map((memberId) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _exactControllers[memberId],

                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),

                          decoration: InputDecoration(
                            labelText: 'Amount for $memberId',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

              if (_selectedSplitType == SplitType.shares)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shares',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...widget.memberIds.map((memberId) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _shareControllers[memberId],

                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),

                          decoration: InputDecoration(
                            labelText: 'Shares for $memberId',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

              ListTile(
                contentPadding: EdgeInsets.zero,

                title: const Text('Expense Date'),

                subtitle: Text(
                  '${_selectedDate.day}/'
                  '${_selectedDate.month}/'
                  '${_selectedDate.year}',
                ),

                trailing: ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('Select Date'),
                ),
              ),

              const SizedBox(height: 24),

              Consumer<ExpenseProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _updateExpense,

                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Update Expense'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
