import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fair_share_app/providers/group_provider.dart';

import 'package:fair_share_app/screens/groups/group_details_screen.dart';
import 'package:fair_share_app/screens/groups/create_group_screen.dart';

import 'package:fair_share_app/screens/activity/activity_screen.dart';
import 'package:fair_share_app/screens/settings/settings_screen.dart';

import 'package:fair_share_app/services/firestore_service.dart';
import 'package:fair_share_app/services/expence_service.dart';
import 'package:fair_share_app/services/settlement_service.dart';
import 'package:fair_share_app/services/balance_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();
  final ExpenseService _expenseService = ExpenseService();
  final SettlementService _settlementService = SettlementService();

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    Future.microtask(() {
      Provider.of<GroupProvider>(
        context,
        listen: false,
      ).listenToGroups(userId);
    });
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return await _firestoreService.getUserById(userId);
  }

  Future<double> _getOverallOwed(
    List<dynamic> groups,
    String currentUserId,
  ) async {
    double totalOwed = 0;

    for (final group in groups) {
      final expenses = await _expenseService.getExpenses(group.id);
      final settlements = await _settlementService.getSettlements(group.id);

      final balances = BalanceCalculator.calculateBalances(
        memberIds: List<String>.from(group.memberIds),
        expenses: expenses,
        settlements: settlements,
      );

      final groupBalance = balances[currentUserId] ?? 0;

      if (groupBalance > 0) {
        totalOwed += groupBalance;
      }
    }

    return totalOwed;
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildGroupsHome(),
      const ActivityScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),

      body: screens[_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF087F75),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationChanged,

        backgroundColor: Colors.white,

        selectedItemColor: const Color(0xFF087F75),
        unselectedItemColor: const Color(0xFF6B7A78),

        selectedFontSize: 11,
        unselectedFontSize: 11,

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsHome() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your groups',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172B3A),
                    ),
                  ),
                ),

                FutureBuilder<Map<String, dynamic>?>(
                  future: _getCurrentUser(),
                  builder: (context, snapshot) {
                    String initials = 'U';

                    if (snapshot.hasData && snapshot.data != null) {
                      final firstName =
                          snapshot.data!['firstName'] ?? '';
                      final lastName =
                          snapshot.data!['lastName'] ?? '';

                      if (firstName.isNotEmpty &&
                          lastName.isNotEmpty) {
                        initials =
                            '${firstName[0]}${lastName[0]}'
                                .toUpperCase();
                      } else if (firstName.isNotEmpty) {
                        initials = firstName[0].toUpperCase();
                      }
                    }

                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF087F75),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GroupProvider>(
              builder: (context, groupProvider, child) {
                final groups = groupProvider.groups;

                if (groups.isEmpty) {
                  return _buildEmptyGroups();
                }

                return Column(
                  children: [
                    FutureBuilder<double>(
                      future: _getOverallOwed(
                        groups,
                        currentUserId,
                      ),
                      builder: (context, snapshot) {
                        final amount = snapshot.data ?? 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF087F75),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "OVERALL YOU'RE OWED",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Rs ${amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'across ${groups.length} '
                                '${groups.length == 1 ? 'group' : 'groups'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'GROUPS',
                          style: TextStyle(
                            color: Color(0xFF71807E),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Groups list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          90,
                        ),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];

                          return _buildGroupCard(group);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    return FutureBuilder<double>(
      future: _getGroupBalance(group),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;

        final bool positive = balance > 0;
        final bool negative = balance < 0;

        String balanceText;

        if (balance == 0) {
          balanceText = 'settled';
        } else if (positive) {
          balanceText =
              '+${group.currency} ${balance.toStringAsFixed(0)}';
        } else {
          balanceText =
              '-${group.currency} ${balance.abs().toStringAsFixed(0)}';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Group card par click -> GroupDetailsScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupDetailsScreen(group: group),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Group icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F2EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      color: Color(0xFF087F75),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172B3A),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'You, ${group.memberIds.length > 1 ? '${group.memberIds.length - 1} others' : 'only member'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71807E),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${group.memberIds.length} members',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9AA5A3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: positive
                          ? const Color(0xFFE3F3E9)
                          : negative
                              ? const Color(0xFFFDE9E1)
                              : const Color(0xFFE9EEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      balanceText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: positive
                            ? const Color(0xFF268A4B)
                            : negative
                                ? const Color(0xFFD65A32)
                                : const Color(0xFF647270),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Ab settlements bhi shamil hain — sirf expenses se calculate nahi ho raha.
  Future<double> _getGroupBalance(dynamic group) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final expenses = await _expenseService.getExpenses(group.id);
    final settlements = await _settlementService.getSettlements(group.id);

    final balances = BalanceCalculator.calculateBalances(
      memberIds: List<String>.from(group.memberIds),
      expenses: expenses,
      settlements: settlements,
    );

    return balances[currentUserId] ?? 0;
  }

  Widget _buildEmptyGroups() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 70,
            color: Color(0xFF087F75),
          ),

          const SizedBox(height: 15),

          const Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B3A),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Create a group to start sharing expenses.',
            style: TextStyle(
              color: Color(0xFF71807E),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CreateGroupScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF087F75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create group'),
          ),
        ],
      ),
    );
  }
}