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

  final Map<String, int> _memberShares = {};

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
      _memberShares[memberId] = 1;
    }

    _includedMembers = Set<String>.from(widget.memberIds);

    _amountController.addListener(_onFormChanged);
    for (final controller in _exactControllers.values) {
      controller.addListener(_onFormChanged);
    }

    _loadMemberNames();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
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

  String _splitTypeLabel(SplitType type) {
    switch (type) {
      case SplitType.equal:
        return 'Equally';
      case SplitType.exact:
        return 'Exact';
      case SplitType.shares:
        return 'Shares';
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

  Map<String, int> _distributeCentsByWeight(int totalCents) {
    final int totalWeight = widget.memberIds.fold(
      0,
      (sum, id) => sum + (_memberShares[id] ?? 0),
    );

    if (totalWeight <= 0) {
      return {for (final id in widget.memberIds) id: 0};
    }

    final Map<String, int> result = {};

    int used = 0;

    for (int i = 0; i < widget.memberIds.length; i++) {
      final memberId = widget.memberIds[i];

      final weight = _memberShares[memberId] ?? 0;

      int cents;

      if (i == widget.memberIds.length - 1) {
        cents = totalCents - used;
      } else {
        cents = (totalCents * weight / totalWeight).round();

        used += cents;
      }

      result[memberId] = cents;
    }

    return result;
  }
  Map<String, double> _sharesPreview() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    final totalCents = (amount * 100).round();

    final centsMap = _distributeCentsByWeight(totalCents);

    return centsMap.map((id, cents) => MapEntry(id, cents / 100));
  }

  Map<String, num>? _calculateSharesSplit(double amount) {
    final totalWeight = widget.memberIds.fold<int>(
      0,
      (sum, id) => sum + (_memberShares[id] ?? 0),
    );

    if (totalWeight <= 0) {
      _showError('Please assign at least 1 share to someone.');
      return null;
    }

    final preview = _sharesPreview();

    return preview.map((id, value) => MapEntry(id, value));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense added successfully')));

    Navigator.pop(context);
  }

  Widget _buildSplitTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: SplitType.values.map((type) {
          final isSelected = _selectedSplitType == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSplitType = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _splitTypeLabel(type),
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF087F75)
                        : const Color(0xFF71807E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignedBanner() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    double assigned;

    if (_selectedSplitType == SplitType.shares) {
      assigned = _sharesPreview().values.fold(0.0, (a, b) => a + b);
    } else {
      assigned = widget.memberIds.fold(0.0, (sum, id) {
        final value = double.tryParse(_exactControllers[id]!.text.trim());
        return sum + (value ?? 0);
      });
    }

    final bool matches = (assigned * 100).round() == (amount * 100).round();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: matches ? const Color(0xFFE3F3E9) : const Color(0xFFFDE9E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle : Icons.error_outline,
            color: matches
                ? const Color(0xFF268A4B)
                : const Color(0xFFD65A32),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rs ${assigned.toStringAsFixed(0)} of '
              'Rs ${amount.toStringAsFixed(0)} assigned',
              style: TextStyle(
                color: matches
                    ? const Color(0xFF268A4B)
                    : const Color(0xFFD65A32),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
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

                    const SizedBox(height: 20),

                    const Text(
                      'SPLIT TYPE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF71807E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildSplitTypeSelector(),

                    const SizedBox(height: 20),

                    if (_selectedSplitType == SplitType.equal)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Split equally between',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...widget.memberIds.map((memberId) {
                            final isIncluded = _includedMembers.contains(
                              memberId,
                            );

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
                              fontSize: 16,
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
                                      'Amount for '
                                      '${_memberNames[memberId] ?? memberId}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            );
                          }),
                          _buildAssignedBanner(),
                        ],
                      ),

                    if (_selectedSplitType == SplitType.shares)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assign shares',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...widget.memberIds.map((memberId) {
                            final shares = _memberShares[memberId] ?? 1;
                            final preview = _sharesPreview()[memberId] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _memberNames[memberId] ?? memberId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '$shares '
                                          '${shares == 1 ? 'share' : 'shares'}'
                                          ' → Rs ${preview.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF71807E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: shares > 1
                                        ? () {
                                            setState(() {
                                              _memberShares[memberId] =
                                                  shares - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$shares',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _memberShares[memberId] = shares + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          _buildAssignedBanner(),
                        ],
                      ),

                    const SizedBox(height: 20),

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
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF087F75),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: provider.isLoading
                                ? null
                                : _addExpense,
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save expense'),
                          ),
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