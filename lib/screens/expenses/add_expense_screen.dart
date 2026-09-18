import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/models/activity_model.dart';
import 'package:fair_share_app/models/expence_model.dart';
import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:fair_share_app/providers/expence_provider.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  final List<String> memberIds;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.memberIds,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _amountController = TextEditingController();

  SplitType _selectedSplitType = SplitType.equal;

  late String _selectedPayerId;

  DateTime _selectedDate = DateTime.now();

  final Map<String, TextEditingController> _exactControllers = {};

  final Map<String, TextEditingController> _shareControllers = {};

  final FirestoreService _firestoreService = FirestoreService();

  Map<String, String> _memberNames = {};

  Set<String> _includedMembers = {};

  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();

    _selectedPayerId = widget.currentUserId;

    for (final memberId in widget.memberIds) {
      _exactControllers[memberId] = TextEditingController();
      _shareControllers[memberId] = TextEditingController(text: '1');
    }
    _includedMembers = Set<String>.from(widget.memberIds);
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

  Map<String, num> _calculateEqualSplit(
    List<String> memberIds,
    double amount,
  ) {
    final int totalCents = (amount * 100).round();

    final int basicShare = totalCents ~/ memberIds.length;

    final int remainder = totalCents % memberIds.length;

    final Map<String, num> splits = {};

    for (int i = 0; i < memberIds.length; i++) {
      final int memberCents = basicShare + (i < remainder ? 1 : 0);

      splits[memberIds[i]] = memberCents / 100;
    }

    return splits;
  }

  Map<String, num>? _calculateExactSplit(double amount) {
    final Map<String, num> splits = {};

    double total = 0;

    for (final memberId in widget.memberIds) {
      final String text = _exactControllers[memberId]!.text.trim();

      final double? memberAmount = double.tryParse(text);

      if (memberAmount == null || memberAmount < 0) {
        _showError('Please enter valid amounts for all members.');
        return null;
      }

      splits[memberId] = memberAmount;

      total += memberAmount;
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
    final Map<String, num> shares = {};

    double totalShares = 0;

    for (final memberId in widget.memberIds) {
      final String text = _shareControllers[memberId]!.text.trim();

      final double? memberShares = double.tryParse(text);

      if (memberShares == null || memberShares <= 0) {
        _showError('Please enter valid shares for all members.');
        return null;
      }

      shares[memberId] = memberShares;

      totalShares += memberShares;
    }

    if (totalShares <= 0) {
      _showError('Total shares must be greater than zero.');
      return null;
    }

    final int totalCents = (amount * 100).round();

    final Map<String, num> splits = {};

    int usedCents = 0;

    final List<String> memberIds = widget.memberIds;

    for (int i = 0; i < memberIds.length; i++) {
      final String memberId = memberIds[i];

      final double memberShares = shares[memberId]!.toDouble();

      int memberCents;

      if (i == memberIds.length - 1) {
        memberCents = totalCents - usedCents;
      } else {
        memberCents = (totalCents * memberShares / totalShares).round();

        usedCents += memberCents;
      }

      splits[memberId] = memberCents / 100;
    }

    return splits;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.parse(_amountController.text.trim());

    Map<String, num>? splits;

    if (_selectedSplitType == SplitType.equal) {
      if (_includedMembers.isEmpty) {
        _showError('Please select at least one member to split with.');
        return;
      }
      splits = _calculateEqualSplit(_includedMembers.toList(), amount);
    } else if (_selectedSplitType == SplitType.exact) {
      splits = _calculateExactSplit(amount);
    } else if (_selectedSplitType == SplitType.shares) {
      splits = _calculateSharesSplit(amount);
    }

    if (splits == null) {
      return;
    }

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.groupId,
      description: _descriptionController.text.trim(),
      amount: amount,
      paidBy: _selectedPayerId,
      splitType: _selectedSplitType,
      splits: splits,
      date: Timestamp.fromDate(_selectedDate),
      createdBy: widget.currentUserId,
      createdAt: Timestamp.now(),
    );

    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).addExpense(expense);

    if (!mounted) return;
    final activity = ActivityModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: widget.currentUserId,
      groupId: widget.groupId,
      groupName: 'Group',
      type: 'expense_added',
      title: 'Expense added',
      description: '${_descriptionController.text.trim()} was added',
      amount: amount,
      createdAt: Timestamp.now(),
    );

    await Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).addActivity(activity);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: _isLoadingNames
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g. Dinner',
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
                        hintText: 'e.g. 1000',
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
                          child: Text(_memberNames[memberId] ?? memberId),
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

                    if (_selectedSplitType == SplitType.equal)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Split equally between',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...widget.memberIds.map((memberId) {
                            final isIncluded =
                                _includedMembers.contains(memberId);

                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _memberNames[memberId] ?? memberId,
                              ),
                              value: isIncluded,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _includedMembers.add(memberId);
                                  } else {
                                    _includedMembers.remove(memberId);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),

                    if (_selectedSplitType == SplitType.exact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter exact amount for each member',
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText:
                                      'Amount for ${_memberNames[memberId] ?? memberId}',
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
                            'Enter shares for each member',
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText:
                                      'Shares for ${_memberNames[memberId] ?? memberId}',
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
                          onPressed: provider.isLoading ? null : _addExpense,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Add Expense'),
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